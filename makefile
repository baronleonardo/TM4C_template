# TARGET="$(shell basename $(CURDIR))"
TARGET=Output

C_FILES=$(wildcard src/*.c) ./startup.c
OBJ_FILES=$(addprefix obj/,$(notdir $(C_FILES:.c=.o)))

FLASH=/usr/bin/lm4flash
OPENOCD=/usr/bin/openocd
GDB=/usr/bin/arm-none-eabi-gdb

CC=/usr/bin/arm-none-eabi-gcc
OBJCOPY=/usr/bin/arm-none-eabi-objcopy
CCFLAGS=-mcpu=cortex-m4 \
-march=armv7e-m \
-mthumb \
-mfloat-abi=hard \
-mfpu=fpv4-sp-d16 \
-DPART_TM4C123GH6PM \
-ffunction-sections \
-fdata-sections \
-g \
-gdwarf-3 \
-gstrict-dwarf \
-Wall \
-MD \
-std=c99 \
-c \
-MMD \
-MP \
-MF"$@.d" \
-MT"$@.d"

LFLAGS=-march=armv7e-m \
-mthumb \
-mfloat-abi=hard \
-mfpu=fpv4-sp-d16 \
-DPART_TM4C123GH6PM \
-ffunction-sections \
-fdata-sections \
-g \
-gdwarf-3 \
-gstrict-dwarf \
-Wall  \
--specs=rdimon.specs \
-Wl,-T"./tm4c123gh6pm.lds" \
-Wl,--start-group -l"gcc" \
-l"nosys" \
-l"c" \
-lrdimon \
-Wl,--end-group

all: $(OBJ_FILES)
	$(CC) $(LFLAGS) -o$(TARGET).elf $^
	# Generate binary file from elf file
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin

obj/%.o: src/%.c
	$(CC) $(CCFLAGS) -o $@ $<

obj/startup.o: startup.c
	$(CC) $(CCFLAGS) -o $@ $<

upload:
	$(FLASH) $(TARGET).bin

debug: all
	# launch openocd
	$(OPENOCD) --file /usr/share/openocd/scripts/board/ek-tm4c123gxl.cfg &>2 /dev/null &
	sleep 1
	# launch gdb
	$(GDB) --tui --init-command=debug_helper_files/pre --command=debug_helper_files/cmd $(TARGET).elf
	# kill openocd after quiting from gdb
	killall openocd

clean:
	rm $(TARGET).* obj/*