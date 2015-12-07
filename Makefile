include ../shared/mojo.mk

ifdef ANDROID
	DISCOVERY_BUILD_DIR := $(CURDIR)/gen/mojo/android

	# For some reason we need to set the origin flag when running on Android,
	# but setting it on Linux causes errors.
	ORIGIN_FLAG = --origin $(MOJO_SERVICES)
else
	DISCOVERY_BUILD_DIR := $(CURDIR)/gen/mojo/linux_amd64
endif

MOJO_SHELL_FLAGS := $(MOJO_SHELL_FLAGS) \
	--config-alias DISCOVERY_DIR=$(CURDIR) \
	--config-alias DISCOVERY_BUILD_DIR=$(DISCOVERY_BUILD_DIR) \
	$(ORIGIN_FLAG)

define CGO_TEST
	jiri go --profiles=$(MOJO_PROFILE),base test -v $1
endef

V23_GO_FILES := $(shell find $(JIRI_ROOT) -name "*.go")

all: build

# Installs dart dependencies.
.PHONY: packages
packages:
	pub upgrade

.PHONY: build
build: packages gen-mojom $(DISCOVERY_BUILD_DIR)/discovery.mojo

.PHONY: test
test: discovery-test

.PHONY: gen-mojom
gen-mojom: go/src/mojom/vanadium/discovery/discovery.mojom.go lib/gen/dart-gen/mojom/lib/mojo/discovery.mojom.dart

go/src/mojom/vanadium/discovery/discovery.mojom.go: mojom/vanadium/discovery.mojom | mojo-env-check
	$(call MOJOM_GEN,$<,.,.,go)
	gofmt -w $@

lib/gen/dart-gen/mojom/lib/mojo/discovery.mojom.dart: mojom/vanadium/discovery.mojom | mojo-env-check
	$(call MOJOM_GEN,$<,.,lib/gen,dart)
	# TODO(nlacasse): mojom_bindings_generator creates bad symlinks on dart
	# files, so we delete them.  Stop doing this once the generator is fixed.
	# See https://github.com/domokit/mojo/issues/386
	rm -f lib/gen/mojom/$(notdir $@)

$(DISCOVERY_BUILD_DIR)/discovery.mojo: $(V23_GO_FILES) | mojo-env-check
	$(call MOGO_BUILD,vanadium/discovery,$@)

discovery-test: $(V23_GO_FILES) go/src/mojom/vanadium/discovery/discovery.mojom.go | mojo-env-check
	$(call CGO_TEST,vanadium/discovery/internal)

clean:
	rm -rf gen
	rm -rf lib/gen/dart-pkg
	rm -rf lib/gen/mojom
	rm -rf $(PACKAGE_MOJO_BIN_DIR)

.PHONY: publish
# NOTE(aghassemi): This must be inside lib in order to be accessible.
PACKAGE_MOJO_BIN_DIR := lib/mojo_services
ifdef DRYRUN
	PUBLISH_FLAGS := --dry-run
endif
# NOTE(aghassemi): Publishing will fail unless you increment the version number
# in pubspec.yaml. See https://www.dartlang.org/tools/pub/versioning.html for
# guidelines.
publish: clean packages
	$(MAKE) test  # Test
	$(MAKE) build  # Build for Linux.
	ANDROID=1 $(MAKE) build  # Cross-compile for Android.
	mkdir -p $(PACKAGE_MOJO_BIN_DIR)
	cp -r gen/mojo/* $(PACKAGE_MOJO_BIN_DIR)
	# Note: The '-' at the beginning of the following command tells make to ignore
	# failures and always continue to the next command.
	-pub publish $(PUBLISH_FLAGS)
	rm -rf $(PACKAGE_MOJO_BIN_DIR)

# Examples.
run-advertiser: $(DISCOVERY_BUILD_DIR)/advertiser.mojo $(DISCOVERY_BUILD_DIR)/discovery.mojo
	$(MOJO_DEVTOOLS)/mojo_run --config-file $(CURDIR)/mojoconfig $(MOJO_SHELL_FLAGS) $(MOJO_ANDROID_FLAGS) https://mojo.v.io/advertiser.mojo \
	--args-for="https://mojo.v.io/discovery.mojo"

run-scanner: $(DISCOVERY_BUILD_DIR)/scanner.mojo $(DISCOVERY_BUILD_DIR)/discovery.mojo
	$(MOJO_DEVTOOLS)/mojo_run --config-file $(CURDIR)/mojoconfig $(MOJO_SHELL_FLAGS) $(MOJO_ANDROID_FLAGS) https://mojo.v.io/scanner.mojo \
	--args-for="https://mojo.v.io/discovery.mojo"

$(DISCOVERY_BUILD_DIR)/advertiser.mojo: $(V23_GO_FILES) go/src/mojom/vanadium/discovery/discovery.mojom.go | mojo-env-check
	$(call MOGO_BUILD,examples/advertiser,$@)

$(DISCOVERY_BUILD_DIR)/scanner.mojo: $(V23_GO_FILES) go/src/mojom/vanadium/discovery/discovery.mojom.go | mojo-env-check
	$(call MOGO_BUILD,examples/scanner,$@)
