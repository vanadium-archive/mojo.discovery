include ../shared/mojo.mk

ifdef ANDROID
	BUILD_DIR := $(CURDIR)/gen/mojo/arm_android
	TEST_BUILD_DIR := $(CURDIR)/gen/mojo_test/arm_android
else
	BUILD_DIR := $(CURDIR)/gen/mojo/amd64_linux
	TEST_BUILD_DIR := $(CURDIR)/gen/mojo_test/amd64_linux
endif

# If this is not the first mojo shell, then you must reuse the dev servers
# to avoid a "port in use" error.
ifneq ($(shell netstat -ntl | fgrep 31840 | wc -l),0)
	REUSE_FLAG := --reuse-servers
endif

MOJO_SHELL_FLAGS := $(MOJO_SHELL_FLAGS) \
	--config-alias DISCOVERY_DIR=$(CURDIR) \
	--config-alias BUILD_DIR=$(BUILD_DIR) \
	--config-alias TEST_BUILD_DIR=$(TEST_BUILD_DIR) \
	--origin $(MOJO_SERVICES) \
	$(REUSE_FLAG)

V23_GO_FILES := $(shell find $(JIRI_ROOT) -name "*.go")

all: build

# Installs dart dependencies.
.PHONY: packages
packages:
	pub upgrade

# Build mojo app.
.PHONY: build
build: packages gen-mojom $(BUILD_DIR)/discovery.mojo

MOJOM_FILE := mojom/v.io/discovery.mojom
MOJOM_FILE_GO := gen/go/src/mojom/v.io/discovery/discovery.mojom.go
MOJOM_FILE_JAVA := gen/mojom/v.io/discovery.mojom.srcjar
MOJOM_FILE_DART := lib/gen/dart-gen/mojom/lib/discovery/discovery.mojom.dart

.PHONY: gen-mojom
gen-mojom: $(MOJOM_FILE_GO) $(MOJOM_FILE_JAVA) $(MOJOM_FILE_DART)

COMMA := ,
$(MOJOM_FILE_GO) $(MOJOM_FILE_JAVA): $(MOJOM_FILE) | mojo-env-check
	$(call MOJOM_GEN,$<,.,gen,go$(COMMA)java)

$(MOJOM_FILE_DART): $(MOJOM_FILE) | mojo-env-check
	$(call MOJOM_GEN,$<,.,lib/gen,dart)
	# TODO(nlacasse): mojom_bindings_generator creates bad symlinks on dart
	# files, so we delete them.  Stop doing this once the generator is fixed.
	# See https://github.com/domokit/mojo/issues/386
	rm -f lib/gen/mojom/$(notdir $@)

ifdef ANDROID
$(BUILD_DIR)/discovery.mojo: $(MOJOM_FILE_JAVA) gradle-build

.PHONY: gradle-build
gradle-build:
	cd java && MOJO_SDK=$(MOJO_SDK) OUT_DIR=$(BUILD_DIR) ./gradlew buildMojo
else
$(BUILD_DIR)/discovery.mojo: $(MOJOM_FILE_GO) $(V23_GO_FILES) $(MOJO_SHARED_LIB) | mojo-env-check
	$(call MOGO_BUILD,v.io/mojo/discovery,$@)
endif

# Tests
.PHONY: test
test: unittest apptest

.PHONY: unittest
unittest: $(MOJOM_FILE_GO) $(V23_GO_FILES) $(MOJO_SHARED_LIB) | mojo-env-check
	$(call MOGO_TEST,-v v.io/mojo/discovery/...)

.PHONY: apptest
apptest: build $(TEST_BUILD_DIR)/discovery_apptests.mojo mojoapptests | mojo-env-check
	$(call MOJO_APPTEST,"mojoapptests")

$(TEST_BUILD_DIR)/discovery_apptests.mojo: $(MOJOM_FILE_GO) $(V23_GO_FILES) $(MOJO_SHARED_LIB) | mojo-env-check
	$(call MOGO_BUILD,v.io/mojo/discovery/apptest/main,$@)

# Publish
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

local-publish: clean packages
	$(MAKE) build  # Build for Linux.
	ANDROID=1 $(MAKE) build  # Cross-compile for Android.
	mkdir -p $(PACKAGE_MOJO_BIN_DIR)
	cp -r gen/mojo/* $(PACKAGE_MOJO_BIN_DIR)

# Cleanup
clean:
	rm -rf build
	rm -rf lib/gen/dart-pkg
	rm -rf lib/gen/mojom
	rm -rf $(PACKAGE_MOJO_BIN_DIR)
	cd java && ./gradlew clean

# Examples
run-advertiser: $(TEST_BUILD_DIR)/advertiser.mojo $(BUILD_DIR)/discovery.mojo
	$(call MOJO_RUN,"https://test.v.io/advertiser.mojo")

run-scanner: $(TEST_BUILD_DIR)/scanner.mojo $(BUILD_DIR)/discovery.mojo
	$(call MOJO_RUN,"https://test.v.io/scanner.mojo")

$(TEST_BUILD_DIR)/advertiser.mojo: $(MOJOM_FILE_GO) $(V23_GO_FILES) $(MOJO_SHARED_LIB) | mojo-env-check
	$(call MOGO_BUILD,examples/advertiser,$@)

$(TEST_BUILD_DIR)/scanner.mojo: $(MOJOM_FILE_GO) $(V23_GO_FILES) $(MOJO_SHARED_LIB) | mojo-env-check
	$(call MOGO_BUILD,examples/scanner,$@)
