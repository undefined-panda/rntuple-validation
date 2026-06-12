SHELL := /bin/bash # to use 'source' command 

#ROOT_EXE ?= $(shell which root.exe)
#ifeq ($(ROOT_EXE),)
#$(error Could not find root.exe)
#ndif

ROOT_VERSION := $(shell root-config --version)
ROOT_EXE = $(shell which root.exe)

# if directory arguments (dict_dir, write_dir, read_dir) are empty, current ROOT version will be used as folder name
DICT_DIR := $(shell pwd)/dict/$(or $(dict_dir),$(ROOT_VERSION))
WRITE_DIR := $(shell pwd)/write/$(or $(write_dir),$(ROOT_VERSION))
READ_DIR := $(shell pwd)/read/$(or $(read_dir),$(ROOT_VERSION))
export DICT_DIR # export to make it available for deeper Makefiles

# This assumes there is no whitespace in any of the paths...
DICT_MAKEFILE_DIR := $(sort $(shell find */ -name Makefile -printf "%h\n"))
WRITE_C := $(sort $(shell find . -name write.C))
READ_C := $(sort $(shell find . -name read.C))

.PHONY: all
all:
	$(MAKE) dict
	$(MAKE) write
	$(MAKE) read

# run this target for each given ROOT version
.PHONY: validate
validate:: $(source_dir)
$(source_dir)::
	@source $@ && echo -e "\nSourcing '$@' with ROOT version: $(ROOT_VERSION)" && $(MAKE) dict && $(MAKE) write

.PHONY: dict
dict:: $(DICT_MAKEFILE_DIR)
$(DICT_MAKEFILE_DIR):: $(DICT_DIR)
	@$(MAKE) -C $@
$(DICT_DIR)::
	@echo -e "\nStoring dictionaries in: '$@'" && mkdir -p $@

.PHONY: write
write:: $(WRITE_C)
$(WRITE_C):: $(WRITE_DIR)
	@LD_LIBRARY_PATH="$${LD_LIBRARY_PATH:+$$LD_LIBRARY_PATH:}$(DICT_DIR)" $(ROOT_EXE) -q -l \
	'$@("$(WRITE_DIR)/$(subst /,.,$(shell dirname $@)).root")'
$(WRITE_DIR)::
	@echo -e "\nStoring root files in: '$@'" && mkdir -p $@

.PHONY: read
read:: $(READ_C)
$(READ_C):: $(READ_DIR)
	@LD_LIBRARY_PATH="$${LD_LIBRARY_PATH:+$$LD_LIBRARY_PATH:}$(DICT_DIR)" $(ROOT_EXE) -q -l \
	'$@("$(WRITE_DIR)/$(subst /,.,$(shell dirname $@)).root", "$(READ_DIR)/$(subst /,.,$(shell dirname $@)).json")'
$(READ_DIR)::
	@echo -e "\nStoring json files in: '$@'" && mkdir -p $@
