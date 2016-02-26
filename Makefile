include ../shared/mojo.mk

ifdef ANDROID
	DISCOVERY_BUILD_DIR := $(CURDIR)/gen/mojo/android

	# For some reason we need to set the origin flag when running on Android,
	# but setting it on Linux causes errors.
	ORIGIN_FLAG = --origin $(MOJO_SERVICES)
else
	DISCOVERY_BUILD_DIR := $(CURDIR)/gen/mojo/linux_amd64
endif

# If this is not the first mojo shell, then you must reuse the dev servers
# to avoid a "port in use" error.
#ifneq ($(shell fuser 32000/tcp),)
ifneq ($(shell netstat -ntl | fgrep 32000 | wc -l),0)
	REUSE_FLAG := --reuse-servers
endif

MOJO_SHELL_FLAGS := $(MOJO_SHELL_FLAGS) \
	--config-alias DISCOVERY_DIR=$(CURDIR) \
	--config-alias DISCOVERY_BUILD_DIR=$(DISCOVERY_BUILD_DIR) \
	$(REUSE_FLAG) \
	$(ORIGIN_FLAG)

V23_GO_FILES := $(shell find $(JIRI_ROOT) -name "*.go")
PYTHONPATH := $(MOJO_SDK)/src/mojo/public/third_party:$(PYTHONPATH)

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
gen-mojom: go/src/mojom/vanadium/discovery/discovery.mojom.go lib/gen/dart-gen/mojom/lib/mojo/discovery.mojom.dart java/generated-src/io/v/mojo/discovery/Advertiser.java

# Note: These Java files are checked in.
java/generated-src/io/v/mojo/discovery/Advertiser.java: java/generated-src/mojom/vanadium/discovery.mojom.srcjar
	cd java/generated-src/ && jar -xf mojom/vanadium/discovery.mojom.srcjar

# Clean up the old files and regenerate mojom files.
# Due to https://github.com/domokit/mojo/issues/674, we must create the folder
# that will hold the srcjar. This .srcjar is not checked in, however.
java/generated-src/mojom/vanadium/discovery.mojom.srcjar: mojom/vanadium/discovery.mojom | mojo-env-check
	rm -r java/generated-src/io/v/mojo/discovery
	mkdir -p java/generated-src/mojom/vanadium
	$(call MOJOM_GEN,$<,.,java/generated-src,java)

go/src/mojom/vanadium/discovery/discovery.mojom.go: mojom/vanadium/discovery.mojom | mojo-env-check
	$(call MOJOM_GEN,$<,.,.,go)
	gofmt -w $@


ifdef ANDROID
gradle-build:
	cd java && ./gradlew build

java/build/outputs/apk/java-debug.apk: gradle-build

build/classes.dex: java/build/outputs/apk/java-debug.apk | mojo-env-check
	mkdir -p build
	cd build && jar -xf ../$<

$(DISCOVERY_BUILD_DIR)/discovery.mojo: build/classes.dex java/Manifest.txt | mojo-env-check
	rm -fr build/zip-scratch build/discovery.zip
	mkdir -p build/zip-scratch/META-INF
	cp build/classes.dex build/zip-scratch
	cp java/Manifest.txt build/zip-scratch/META-INF/MANIFEST.MF
	cp -r build/lib/ build/zip-scratch/
	cp build/lib/armeabi-v7a/libv23.so build/zip-scratch
	cd build/zip-scratch && zip -r ../discovery.zip .
	mkdir -p `dirname $@`
	echo "#!mojo mojo:java_handler" > $@
	cat build/discovery.zip >> $@
else

$(DISCOVERY_BUILD_DIR)/discovery.mojo: $(V23_GO_FILES) $(MOJO_SHARED_LIB) | mojo-env-check
	$(call MOGO_BUILD,vanadium/discovery,$@)
endif


lib/gen/dart-gen/mojom/lib/mojo/discovery.mojom.dart: mojom/vanadium/discovery.mojom | mojo-env-check
	$(call MOJOM_GEN,$<,.,lib/gen,dart)
	# TODO(nlacasse): mojom_bindings_generator creates bad symlinks on dart
	# files, so we delete them.  Stop doing this once the generator is fixed.
	# See https://github.com/domokit/mojo/issues/386
	rm -f lib/gen/mojom/$(notdir $@)

discovery-test: $(V23_GO_FILES) go/src/mojom/vanadium/discovery/discovery.mojom.go | mojo-env-check
	$(call MOGO_TEST,-v vanadium/discovery/internal/...)

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

local-publish: clean packages
	$(MAKE) build  # Build for Linux.
	ANDROID=1 $(MAKE) build  # Cross-compile for Android.
	mkdir -p $(PACKAGE_MOJO_BIN_DIR)
	cp -r gen/mojo/* $(PACKAGE_MOJO_BIN_DIR)

# Examples.
run-advertiser: $(DISCOVERY_BUILD_DIR)/advertiser.mojo $(DISCOVERY_BUILD_DIR)/discovery.mojo
	$(call MOJO_RUN,"https://mojo.v.io/advertiser.mojo")

run-scanner: $(DISCOVERY_BUILD_DIR)/scanner.mojo $(DISCOVERY_BUILD_DIR)/discovery.mojo
	$(call MOJO_RUN,"https://mojo.v.io/scanner.mojo")

$(DISCOVERY_BUILD_DIR)/advertiser.mojo: $(V23_GO_FILES) go/src/mojom/vanadium/discovery/discovery.mojom.go | mojo-env-check
	$(call MOGO_BUILD,examples/advertiser,$@)

$(DISCOVERY_BUILD_DIR)/scanner.mojo: $(V23_GO_FILES) go/src/mojom/vanadium/discovery/discovery.mojom.go | mojo-env-check
	$(call MOGO_BUILD,examples/scanner,$@)
