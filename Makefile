ROOT_EXE ?= $(shell which root.exe)
ifeq ($(ROOT_EXE),)
$(error Could not find root.exe)
endif

DICT_DIR := $(shell pwd)/dict/$(dict_dir)
WRITE_DIR := $(shell pwd)/write/$(write_dir)
READ_DIR := $(shell pwd)/read/$(write_dir)/$(read_dir)
BASE_DIR := $(shell pwd)
export DICT_DIR

.PHONY: all
all:
	$(MAKE) dict
	$(MAKE) write
	$(MAKE) read

# This assumes there is no whitespace in any of the paths...
DICT_MAKEFILE_DIR := $(sort $(shell find */ -name Makefile -printf "%h\n"))
WRITE_C := $(sort $(shell find . -name write.C))
READ_C := $(sort $(shell find . -name read.C))

.PHONY: dict
dict:: $(DICT_MAKEFILE_DIR)
$(DICT_MAKEFILE_DIR):: $(DICT_DIR)
	@$(MAKE) -C $@
$(DICT_DIR)::
	@if [ -z "$(dict_dir)" ]; then echo "ERROR: dict_dir is not set"; exit 1; fi
	@mkdir -p $@
	$(info Storing dictionaries in: '$@')

.PHONY: write
write:: $(WRITE_C)
$(WRITE_C):: $(WRITE_DIR)
	@LD_LIBRARY_PATH="$${LD_LIBRARY_PATH:+$$LD_LIBRARY_PATH:}$(DICT_DIR)" $(ROOT_EXE) -q -l '$@("$(WRITE_DIR)/$(subst /,.,$(shell dirname $@)).root")'
$(WRITE_DIR)::
	@if [ -z "$(write_dir)" ]; then echo "ERROR: write_dir is not set"; exit 1; fi
	@if [ -z "$(dict_dir)" ]; then echo "ERROR: dict_dir is not set"; exit 1; fi
	@mkdir -p $@
	$(info Storing root files in: '$@')

.PHONY: read
read:: $(READ_C)
$(READ_C):: $(READ_DIR)
	@LD_LIBRARY_PATH="$${LD_LIBRARY_PATH:+$$LD_LIBRARY_PATH:}$(DICT_DIR)" $(ROOT_EXE) -q -l \
	'$@("$(WRITE_DIR)/$(subst /,.,$(shell dirname $@)).root", "$(READ_DIR)/$(subst /,.,$(shell dirname $@)).json")'
$(READ_DIR)::
	@if [ -z "$(read_dir)" ]; then echo "ERROR: read_dir is not set"; exit 1; fi
	@if [ -z "$(write_dir)" ]; then echo "ERROR: write_dir is not set"; exit 1; fi
	@if [ -z "$(dict_dir)" ]; then echo "ERROR: dict_dir is not set"; exit 1; fi
	@mkdir -p $@
	$(info Storing root files in: '$@')
