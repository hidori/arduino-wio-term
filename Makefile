# Makefile for Arduino application projects
.DEFAULT_GOAL := all

## Project specific configurations

PROJECT ?= WioTerm
SKETCH ?= ./$(PROJECT)/$(PROJECT).ino
LIBS ?= \
	lvgl@8.3.11
CORES ?= \
	Seeeduino:samd

## Project specific targets

.PHONY: build
build: build/wio-terminal

.PHONY: deploy
deploy: deploy/wio-terminal

## Configurations

TMP_DIR ?= ./tmp
BIN_DIR ?= ./bin

BUILD_CONFIG ?= ./arduino-cli.yaml
BUILD_DIR ?= ./$(PROJECT)/build

DEPLOY_ARDUINO_PORT_TTYUSB ?= /dev/ttyUSB0
DEPLOY_ARDUINO_PORT_TTYACM ?= /dev/ttyACM0

DEPLOY_UF2_PORT ?= A:/

## Macros

define build-arduino
	arduino-cli compile \
		--library ./src \
		--fqbn $(1) \
		--export-binaries \
		$(if $(filter-out undefined,$(origin DEBUG)),--build-property "build.extra_flags=-DDEBUG") \
		$(SKETCH)
endef

define deploy-arduino
	arduino-cli upload --verbose \
		-b $(1) \
		-p $(2) \
		--input-file $(BUILD_DIR)/$(subst :,.,$(word 1,$(subst :, ,$(1))).$(word 2,$(subst :, ,$(1))).$(word 3,$(subst :, ,$(1))))/$(basename $(3)).ino.hex
endef

define deploy-arduinoasisp
	arduino-cli upload --verbose \
		-b $(1) \
		-p $(2) \
		-P arduinoasisp \
		--input-dir $(BUILD_DIR)/$(subst :,.,$(word 1,$(subst :, ,$(1))).$(word 2,$(subst :, ,$(1))).$(word 3,$(subst :, ,$(1))))
endef

define deploy-uf2
	/mnt/c/Windows/System32/robocopy.exe \
		"$(subst /,\,$(BUILD_DIR)/$(subst :,.,$(word 1,$(subst :, ,$(1))).$(word 2,$(subst :, ,$(1))).$(word 3,$(subst :, ,$(1)))))" \
		"$(DEPLOY_UF2_PORT)" $(2).ino.uf2
endef

define deploy-ch32v
	arduino-cli upload --verbose \
		-b $(1) \
		--input-file $(BUILD_DIR)/$(subst :,.,$(word 1,$(subst :, ,$(1))).$(word 2,$(subst :, ,$(1))).$(word 3,$(subst :, ,$(1))))/$(2).ino.elf
endef

## Targets

.PHONY: clean
clean:
	rm -rf $(TMP_DIR)
	rm -rf $(BIN_DIR)
	find . -type d -name "build" -exec rm -rf {} +
	find . -type f -name "*.lst" -exec rm {} +
	find . -type f -name "*.map" -exec rm {} +
	find . -type f -name "*.gcda" -exec rm {} +
	find . -type f -name "*.gcno" -exec rm {} +
	find . -type f -exec chmod -x {} +

.PHONY: all
all: clean install build

.PHONY: install
install: install/core install/lib

.PHONY: install/core
install/core:
ifeq ($(strip $(CORES)),)
	@echo "No cores defined. Skipping install/core."
else
	@echo "Installing Arduino cores..."
	@if [ ! -f ~/.arduino15/arduino-cli.yaml ]; then arduino-cli config init; fi
	arduino-cli --config-file $(BUILD_CONFIG) core update-index
	arduino-cli --config-file $(BUILD_CONFIG) core install $(CORES)
	@echo ""
	@echo "Arduino cores installed."
endif

.PHONY: install/lib
install/lib:
ifeq ($(strip $(LIBS)),)
	@echo "No libraries defined. Skipping install/lib."
else
	@echo "Installing Arduino libraries..."
	@if [ ! -f ~/.arduino15/arduino-cli.yaml ]; then arduino-cli config init; fi
	arduino-cli --config-file $(BUILD_CONFIG) lib update-index
	arduino-cli --config-file $(BUILD_CONFIG) lib install $(LIBS)
	@echo ""
	@echo "Arduino libraries installed."
endif

## Build targets for each board

.PHONY: build/wio-terminal
build/wio-terminal:
	$(call build-arduino,Seeeduino:samd:seeed_wio_terminal)

## Deploy targets for each board

.PHONY: deploy/wio-terminal
deploy/wio-terminal:
	$(call deploy-arduino,Seeeduino:samd:seeed_wio_terminal,$(DEPLOY_ARDUINO_PORT_TTYACM),$(SKETCH))
