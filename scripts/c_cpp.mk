LOCAL_MODULE := $(notdir $(CURDIR))

BUILD_DIR := build

default: all

CROSS_COMPILE ?=
CC  := $(CROSS_COMPILE)gcc
CXX := $(CROSS_COMPILE)g++

CFLAGS   := -Wall -O3 -fdata-sections -ffunction-sections -std=c17
CXXFLAGS := -Wall -O3 -fdata-sections -ffunction-sections -fpermissive -std=c++17
LDFLAGS  := -Wl,--gc-sections -Wl,--hash-style=gnu -Wl,--sort-common

CFLAGS   += -fstack-protector-strong -z now -D_FORTIFY_SOURCE=2
CXXFLAGS += -fstack-protector-strong -z now -D_FORTIFY_SOURCE=2

SRC_C   = $(patsubst ./%.c,$(BUILD_DIR)/%.c,$(shell find -L ./ -name "*.c"))
SRC_CPP = $(patsubst ./%.cpp,$(BUILD_DIR)/%.cpp,$(shell find -L ./ -name "*.cpp"))
DEP_C   = $(patsubst %.c,%.d,$(SRC_C))
DEP_CPP = $(patsubst %.cpp,%.d,$(SRC_CPP))

-include $(DEP_C) $(DEP_CPP)

$(BUILD_DIR)/%.d: %.c
	@umask 0022 && mkdir -m 0755 -p $(@D)
	@$(CC) -MM -MT $(@:.d=.o) -MF $@ $(CFLAGS) $<

$(BUILD_DIR)/%.d: %.cpp
	@umask 0022 && mkdir -m 0755 -p $(@D)
	@$(CXX) -MM -MT $(@:.d=.o) -MF $@ $(CXXFLAGS) $<

$(BUILD_DIR)/%.o: %.c
	@umask 0022 && mkdir -m 0755 -p $(@D)
	@echo "  CC     $<"
	@$(CC) -c -o $@ $< $(CFLAGS)

$(BUILD_DIR)/%.o: %.cpp
	@umask 0022 && mkdir -m 0755 -p $(@D)
	@echo "  CXX    $<"
	@$(CXX) -c -o $@ $< $(CXXFLAGS)

# ==============================================================

$(LOCAL_MODULE): $(SRC_C:.cpp=.o) $(SRC_CPP:.cpp=.o)
	@echo "  LD     $@"
	@$(CXX) -o $@ $^ $(LDFLAGS)

all: $(LOCAL_MODULE)

clean:
	@echo "  CLEAN  $(BUILD_DIR) $(LOCAL_MODULE)"
	@rm -rf $(BUILD_DIR) $(LOCAL_MODULE)

