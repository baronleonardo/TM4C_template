TARGET=$(notdir $(shell pwd))

C_FILES=$(wildcard src/*.c) ./startup.c
OBJ_FILES=$(addprefix obj/,$(notdir $(C_FILES:.c=.o)))

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
-Wl,-T"./tm4c123gh6pm.lds" \
-Wl,--start-group -l"gcc" \
-l"nosys" \
-l"c" \
-Wl,--end-group

all: $(OBJ_FILES)
	$(CC) $(LFLAGS) -o"obj/$(TARGET).elf" $^
	# Generate binary file from elf file
	$(OBJCOPY) -O binary "obj/$(TARGET).elf" $(TARGET).bin

obj/%.o: src/%.c
	$(CC) $(CCFLAGS) -o $@ $<

obj/startup.o: startup.c
	$(CC) $(CCFLAGS) -o $@ $<

upload:
	lm4flash $(TARGET).bin

clean:
	rm $(TARGET).bin obj/*