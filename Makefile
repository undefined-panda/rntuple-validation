ROOT_EXE ?= $(shell which root.exe)
ifeq ($(ROOT_EXE),)
$(error Could not find root.exe)
endif

# 1 - folder, 2 - subfolder, 3 - file type
define move_files
    mkdir -p $(1)/$(2) && find . -name "*.$(3)" -not -path "./$(1)/*" -exec mv {} "$(1)/$(2)" \;
endef

dv := # dict version
wv := # write version
rv := # read version
DICT_DIR := $(shell pwd)/dict/$(dv)/
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
READ_C := $(sort $(shell find . -name read.C)) # get absolute paths of read.C files

.PHONY: dict
dict:: $(DICT_MAKEFILE_DIR)
$(DICT_MAKEFILE_DIR):: $(DICT_DIR)
	@$(MAKE) -C $@
$(DICT_DIR)::
	@mkdir -p $@
	$(info Storing dictionaries in: '$@')

.PHONY: write
write:: $(WRITE_C)
$(WRITE_C)::
	@LD_LIBRARY_PATH="$${LD_LIBRARY_PATH:+$$LD_LIBRARY_PATH:}$(DICT_DIR)" $(ROOT_EXE) -q -l $@
	@$(call move_files,write,$(dv),root)

.PHONY: read
read:: $(READ_C)
$(READ_C)::
	@cd write/$(wv) && LD_LIBRARY_PATH="$${LD_LIBRARY_PATH:+$$LD_LIBRARY_PATH:}$(DICT_DIR)" $(ROOT_EXE) -q -l $(BASE_DIR)/$@
	@$(call move_files,read,$(dv)/$(rv),json)
