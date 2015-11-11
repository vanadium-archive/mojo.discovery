include ../shared/mojo.mk

ifndef MOJO_DIR
        $(error MOJO_DIR is not set)
endif

ifdef ANDROID
	DISCOVERY_BUILD_DIR := $(PWD)/gen/mojo/android
else
	DISCOVERY_BUILD_DIR := $(PWD)/gen/mojo/linux_amd64
endif

MOJO_SHELL_FLAGS := $(MOJO_SHELL_FLAGS) \
	--config-alias DISCOVERY_DIR=$(PWD) \
	--config-alias DISCOVERY_BUILD_DIR=$(DISCOVERY_BUILD_DIR)

define CGO_TEST
	GOPATH="$(GOPATH)" \
	CGO_CFLAGS="-I$(MOJO_DIR)/src $(CGO_CFLAGS)" \
	CGO_CXXFLAGS="-I$(MOJO_DIR)/src $(CGO_CXXFLAGS)" \
	CGO_LDFLAGS="-L$(dir $(MOJO_SHARED_LIB)) -lsystem_thunk $(CGO_LDFLAGS)" \
	$(GOROOT)/bin/go test -v $1
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

$(DISCOVERY_BUILD_DIR)/discovery.mojo: $(V23_GO_FILES) $(MOJO_SHARED_LIB) | mojo-env-check
	$(call MOGO_BUILD,vanadium/discovery,$@)

discovery-test: $(V23_GO_FILES) $(MOJO_SHARED_LIB) go/src/mojom/vanadium/discovery/discovery.mojom.go | mojo-env-check
	$(call CGO_TEST,vanadium/discovery/internal)

clean:
	rm -rf gen
	rm -rf lib/gen/dart-pkg
	rm -rf lib/gen/mojom

# Examples.
run-advertiser: $(DISCOVERY_BUILD_DIR)/advertiser.mojo $(DISCOVERY_BUILD_DIR)/discovery.mojo
	$(MOJO_DIR)/src/mojo/devtools/common/mojo_run --config-file $(PWD)/mojoconfig $(MOJO_SHELL_FLAGS) $(MOJO_ANDROID_FLAGS) https://mojo.v.io/advertiser.mojo \
	--args-for="https://mojo.v.io/discovery.mojo"

run-scanner: $(DISCOVERY_BUILD_DIR)/scanner.mojo $(DISCOVERY_BUILD_DIR)/discovery.mojo
	$(MOJO_DIR)/src/mojo/devtools/common/mojo_run --config-file $(PWD)/mojoconfig $(MOJO_SHELL_FLAGS) $(MOJO_ANDROID_FLAGS) https://mojo.v.io/scanner.mojo \
	--args-for="https://mojo.v.io/discovery.mojo"

$(DISCOVERY_BUILD_DIR)/advertiser.mojo: $(V23_GO_FILES) $(MOJO_SHARED_LIB) go/src/mojom/vanadium/discovery/discovery.mojom.go | mojo-env-check
	$(call MOGO_BUILD,examples/advertiser,$@)

$(DISCOVERY_BUILD_DIR)/scanner.mojo: $(V23_GO_FILES) $(MOJO_SHARED_LIB) go/src/mojom/vanadium/discovery/discovery.mojom.go | mojo-env-check
	$(call MOGO_BUILD,examples/scanner,$@)
