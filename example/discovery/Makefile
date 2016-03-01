ifndef DEVICE_NUM
	DEVICE_NUM := 1
endif

DEVICE_NUM_PLUS_ONE := $(shell echo $(DEVICE_NUM) \+ 1 | bc)
DEVICE_ID := $(shell adb devices | sed -n $(DEVICE_NUM_PLUS_ONE)p | awk '{ print $$1; }')
DEVICE_FLAG := --target-device $(DEVICE_ID)

ifneq ($(DEVICE_NUM), 1)
	REUSE_FLAG := --reuse-servers
endif

ifdef VLOG
	VLOG_FLAGS = --v=$(VLOG) --logtostderr=true
endif

MOJO_DEVTOOLS := $(shell jiri profile env --profiles=v23:mojo --target=arm-android MOJO_DEVTOOLS=)
MOJO_SHELL := $(shell jiri profile env --profiles=v23:mojo --target=arm-android MOJO_SHELL=)

APP_FLX_FILE := $(PWD)/build/app.flx
DISCOVERY_MOJO_DIR := $(PWD)/packages/v23discovery/mojo_services/android
MOJO_SHELL_CMD_PATH := /data/local/tmp/org.chromium.mojo.shell.cmd

default: run

.PHONY: dartanalyzer
dartanalyzer: packages
	dartanalyzer lib/main.dart

.PHONY: dartfmt
dartfmt: packages
	dartfmt --overwrite lib

packages: pubspec.yaml
	pub get

.PHONY: upgrade-packages
upgrade-packages:
	pub upgrade

.PHONY: build
build: packages
	pub run flutter_tools build

.PHONY: install-shell
install-shell:
	adb -s $(DEVICE_ID) install $(MOJO_SHELL)

.PHONY: uninstall-shell
uninstall-shell:
	adb -s $(DEVICE_ID) uninstall org.chromium.mojo.shell

# Usage example:
# DEVICE_NUM=1 make run
# DEVICE_NUM=2 make run
run: build install-shell
	pub run flutter_tools run_mojo \
	--devtools-path $(MOJO_DEVTOOLS)/mojo_run \
	--android --mojo-debug -- --enable-multiprocess \
	--map-origin="https://discovery.mojo.v.io/=$(DISCOVERY_MOJO_DIR)" \
	$(DEVICE_FLAG) \
	$(REUSE_FLAG) \
	--no-config-file

# Helper targets
run1:
	DEVICE_NUM=1 make run
run2:
	DEVICE_NUM=2 make run
run3:
	DEVICE_NUM=3 make run
run4:
	DEVICE_NUM=4 make run

.PHONY: clean
clean:
	rm -rf packages
