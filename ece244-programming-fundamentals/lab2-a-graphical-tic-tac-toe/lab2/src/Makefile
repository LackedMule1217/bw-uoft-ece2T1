
# add parallelism equal to number of available cores
# it seems that adding -jX to MAKEFLAGS directly doesn't work any more
# so recurvely invoke make! (details at bottom of file)
ifeq ($(PARALELL_WRAPPER_ABXCOEOEKCOEBMQJKHTOEUB),done)

.PHONY: all clean build_info build ABCD_FORCE_BUILD

# remove ALL implicit rules & all suffixes
MAKEFLAGS+=-r
.SUFFIXES:
.SECONDEXPANSION:

BUILD_MODE ?= debug

PROJECT_ROOT = ../
BUILD_DIR = $(PROJECT_ROOT)build/
EXE_DIR  = $(BUILD_DIR)EXE/$(BUILD_MODE)/
EXE_SYMLINK_DIR = $(BUILD_DIR)EXE/
OBJ_DIR  = $(BUILD_DIR)OBJ/$(BUILD_MODE)/
DEPS_DIR = $(BUILD_DIR)DEPS/$(BUILD_MODE)/

BUILD_SUBDIRS = $(EXE_DIR) $(OBJ_DIR) $(DEPS_DIR)

# CXX = clang++
# CXX = g++

# put warning flags here - go to compiler *and* linker.
#WARNING_FLAGS += -Wall -Wextra -pedantic -Wconversion
WARNING_FLAGS += -Wall -Wextra -pedantic 

# put other flags for both the compiler & linker here
EXTRA_FLAGS += -std=c++14

# add flags for debugging, release, etc
ifeq ($(BUILD_MODE),debug)
	EXTRA_FLAGS += -ggdb # -D _GLIBCXX_DEBUG
else ifeq ($(BUILD_MODE),release)
	EXTRA_FLAGS += -O3 -flto -D NDEBUG
else ifneq ($(SIM_MODE),custom)
	$(error "bad BUILD_MODE choice ('$(BUILD_MODE)'). Use 'custom' to disable setting of optimization/debug flags")
endif

# passed to all test runs
TEST_RUN_ARGS ?=

ASSIGNMENT = tic-tac-toe
ECE244_HOME ?= /share/copy/ece244f/
ECE244_HOME_ASSIGNMENTS = $(ECE244_HOME)assignments/
ECE244_HOME_SRC_DIR = $(ECE244_HOME_ASSIGNMENTS)src/
ECE244_HOME_DATA_DIR = $(ECE244_HOME_ASSIGNMENTS)etc/data/
ECE244_LIB_INSTALL_DIR = $(ECE244_HOME)
ECE244_PKG_CONFIG_PATH = $(ECE244_HOME)pkgconfig

SFML_DIR = $(ECE244_LIB_INSTALL_DIR)SFML-2.4.2
SFML_LIBDIRS = $(SFML_DIR)/lib /lib64 $(ECE244_LIB_INSTALL_DIR)openal-soft-1.17.2/build
SFML_LIBNAMES = sfml-audio-s sfml-network-s sfml-graphics-s sfml-window-s sfml-system-s :libudev.so.0 Xrandr pthread rt GL SM ICE X11 Xext freetype jpeg :libFLAC.so.8 vorbis vorbisenc ogg vorbisfile # openal
SFML_INCLUDEDIRS = $(SFML_DIR)/include

# TODO: make working pkg-config files
# SFML_LINK_FLAGS = $(shell bash -c 'PKG_CONFIG_PATH="$$(PKG_CONFIG_PATH):$(ECE244_PKG_CONFIG_PATH)" pkg-config sfml-all --libs')
SFML_LINK_FLAGS = $(patsubst %,-L%,$(SFML_LIBDIRS)) $(patsubst %,-l%,$(SFML_LIBNAMES))

# TODO: make working pkg-config files
# SFML_INCLUDE_FLAGS = $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) echo $$PKG_CONFIG_PATH)
# SFML_INCLUDE_FLAGS = $(subst -I,-isystem,$(shell bash -c 'PKG_CONFIG_PATH="$$(PKG_CONFIG_PATH):$(ECE244_PKG_CONFIG_PATH)" pkg-config sfml-all --cflags'))
SFML_INCLUDE_FLAGS = $(patsubst %,-isystem %,$(SFML_INCLUDEDIRS))

# Common link flags
LIBRARY_LINK_FLAGS += $(SFML_LINK_FLAGS)

# Common include flags
INCLUDE_FLAGS += -I . -I $(ECE244_HOME_SRC_DIR)
INCLUDE_FLAGS += $(SFML_INCLUDE_FLAGS)

CXXFLAGS += $(EXTRA_FLAGS) $(WARNING_FLAGS) $(INCLUDE_FLAGS)
LDFLAGS  += $(EXTRA_FLAGS) $(WARNING_FLAGS) $(LIBRARY_LINK_FLAGS)

# keep .o files
.SECONDARY: $(OBJ_DIR)%.o

# define source directories.
# current impl finds all directories where this Makefile is run
SOURCE_DIRS = ./ $(sort $(dir $(wildcard */)))

ALL_OBJ_DIRS  = $(addprefix $(OBJ_DIR),  $(SOURCE_DIRS))
ALL_DEPS_DIRS = $(addprefix $(DEPS_DIR), $(SOURCE_DIRS))

# compute all directories that might need creation
DIRS= \
	$(ALL_OBJ_DIRS) \
	$(ALL_DEPS_DIRS) \
	$(BUILD_SUBDIRS) \
	$(BUILD_DIR)

# define executables
TEST_EXES = 
SFML_EXES = $(addprefix $(EXE_SYMLINK_DIR),$(ASSIGNMENT))

EXES=\
	$(SFML_EXES) \
	$(TEST_EXES)

all: build
build: $(EXES) | ../data build_info
	@true

../data:
	echo " "
#	ln -sf $(ECE244_HOME_DATA_DIR) $@
#	rm ../data

TEST_EXE_RUN_TARGETS = $(patsubst %, run_%, $(TEST_EXES))
test: $(TEST_EXE_RUN_TARGETS)
$(TEST_EXE_RUN_TARGETS): RUN_PROGRAM_ARGS = $(TEST_RUN_ARGS)

build_info:
	@echo "Building with makeflags ${MAKEFLAGS}"
	@echo "In build mode ${BUILD_MODE}"

# add more dependencies here:

TIC_TAC_TOE_OBJS = \
	$(OBJ_DIR)tic-tac-toe/playMove.o \

$(EXE_DIR)tic-tac-toe: \
	$(TIC_TAC_TOE_OBJS) \
	$(OBJ_DIR)tic-tac-toe/main.o \

# include all the dependency files, if any exist
EXISTING_DEP_FILES = \
	$(foreach dir,$(SOURCE_DIRS), \
		$(wildcard $(DEPS_DIR)$(dir)*.d) \
	)
ifneq (,$(EXISTING_DEP_FILES))
include $(EXISTING_DEP_FILES)
endif

# compile .c++ to .o
# second CXX line generates the initial dependency file
# first sed line adds $(OBJ_DIR) prefixes to the dependency file,
# second one adds stub rules for each depended-on file (make might
# complain with generated files)
$(OBJ_DIR)%.o: %.cpp | build_info # $(OBJ_DIR)$$(dir %) $(DEPS_DIR)$$(dir %)
	@mkdir -p $(dir $@)
	@mkdir -p $(DEPS_DIR)$(dir $*)
	'$(CXX)' -c  '$(shell readlink --canonicalize $<)' -o  '$@' $(CXXFLAGS)
	@'$(CXX)' -MM '$<' -MF '$(DEPS_DIR)$<.d.tmp' $(CXXFLAGS)
	@sed -e 's|.*:|$@:|' < '$(DEPS_DIR)$<.d.tmp' > '$(DEPS_DIR)$<.d'
	@sed -e 's/.*://' -e 's/\\$$//' < '$(DEPS_DIR)$<.d.tmp'| fmt -1 | \
	 sed -e 's/^ *//' -e 's/$$/:/' >> '$(DEPS_DIR)$<.d'
	@rm -f $(DEPS_DIR)$<.d.tmp

$(OBJ_DIR)%.o: $(ECE244_HOME_SRC_DIR)$(OBJ_DIR)%.o
	@mkdir -p $(dir $@)
	cp $< $@

$(EXE_SYMLINK_DIR)%: $(EXE_DIR)% ABCD_FORCE_BUILD
	@ln -sf $(abspath $<) $@
	@symlinks -c $(dir $@) > /dev/null # makes all symlinks in here relative

$(EXE_DIR)%: | build_info $(EXE_DIR)
	'$(CXX)' $^ -o '$@' $(LDFLAGS)

# will run anything in $EXES. Use the format run_EXENAME
$(patsubst %, run_%, $(EXES)): $$(patsubst run_%, %, $$(@))
	@\
		STRWILLEVAL='cd $(ECE244_HOME_ASSIGNMENTS) && $(realpath $^) $(RUN_PROGRAM_ARGS)'; \
		echo "Running: $$STRWILLEVAL"; \
		( eval "$$STRWILLEVAL" && echo "SUCCESS: $^" ) || echo "FAIL: $^"

# for creating directories
$(DIRS):
	mkdir -p $@

# cleaning target
clean:
	rm -f $(EXES) $(wildcard $(EXE_DIR)*)
	rm -f $(shell find $(OBJ_DIR) -type f -name '*.o')
	rm -f $(shell find $(DEPS_DIR) -type f -name '*.d')
	-[[ ! -e $(BUILD_DIR) ]] || find $(BUILD_DIR) -type d -delete

# match for if statement at top of file
else

NUM_CORES ?= $(shell nproc)
MAKEFLAGS += -l$(NUM_CORES)
# MAKEFLAGS +=-j$(NUM_CORES)

# for the default target case
parallel_wrapper_default_target_anthsqjkshbeohcbmeuthnoethoaeou:
	@scl enable devtoolset-4 '$(MAKE) --no-print-directory PARALELL_WRAPPER_ABXCOEOEKCOEBMQJKHTOEUB=done'

# catches everything else
% :
	@scl enable devtoolset-4 '$(MAKE) --no-print-directory PARALELL_WRAPPER_ABXCOEOEKCOEBMQJKHTOEUB=done $@'

endif
