
#####################################################################################
TARGET = Stm32f446_Blink
#####################################################################################
BUILD_DIR = build
gcc_path = D:/Software/EmbeddedGCC/arm_gcc/bin
CC = $(gcc_path)/arm-none-eabi-gcc
CXX = $(gcc_path)/arm-none-eabi-g++
AS = $(gcc_path)/arm-none-eabi-gcc -x assembler-with-cpp
CP = $(gcc_path)/arm-none-eabi-objcopy
SZ = $(gcc_path)/arm-none-eabi-size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
######################################################################################
inc_files = -IInc
inc_files += -ICMSIS/Inc
######################################################################################
cpp_files = Src/main.cpp
######################################################################################
c_files = CMSIS/Src/system_stm32f4xx.c
######################################################################################
asm_files = startup_stm32f446xx.s
######################################################################################
CPU = -mcpu=cortex-m4
FPU = -mfpu=fpv4-sp-d16
FLOAT-ABI = -mfloat-abi=hard
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)
######################################################################################
ld_files = STM32F446RETx_FLASH.ld
libs = -lc -lm -lnosys
lib_dir =
ld_flags = $(MCU) -specs=nano.specs -T$(ld_files) $(lib_dir) $(libs) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections
######################################################################################
c_defs = -DSTM32F446xx
c_flags = $(MCU) $(c_defs) $(inc_files) -Wall -fdata-sections -ffunction-sections
c_flags += -MMD -MP -MF"$(@:%.o=%.d)"
cxx_flags = -std=gnu++14 -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables
asm_flags = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

######################################################################################
# Starting create project
######################################################################################

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

obj = $(addprefix $(BUILD_DIR)/,$(notdir $(c_files:.c=.o)))
vpath %.c $(sort $(dir $(c_files)))
obj += $(addprefix $(BUILD_DIR)/,$(notdir $(cpp_files:.cpp=.o)))
vpath %.cpp $(sort $(dir $(cpp_files)))
obj += $(addprefix $(BUILD_DIR)/,$(notdir $(asm_files:.s=.o)))
vpath %.s $(sort $(dir $(asm_files)))

# *.c --> *.o
$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	@echo $<
	$(CC) -c $(c_flags) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

# *.cpp --> *.o
$(BUILD_DIR)/%.o: %.cpp Makefile | $(BUILD_DIR)
	@echo $<
	$(CXX) -c $(c_flags) $(cxx_flags) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.cpp=.lst)) $< -o $@

# *.s --> *.o
$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	@echo $<
	$(AS) -c $(CFLAGS) $< -o $@

# Create .elf file
$(BUILD_DIR)/$(TARGET).elf: $(obj) Makefile
	$(CC) $(obj) $(ld_flags) -o $@
	$(SZ) $@

# Create .hex file
$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@

# Create .bin file	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@

$(BUILD_DIR):
	mkdir $@

#############################################################################

clean:
	-rm -fR $(BUILD_DIR)

#############################################################################

-include $(wildcard $(BUILD_DIR)/*.d)