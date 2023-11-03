
# compile options (see README.md for descriptions)
# 0 = remove code
# 1 = include code

# When testing the extra options, be careful not to exceed the
# 64 kB flash memory limit.

ENABLE_CLANG                     := 0
ENABLE_SWD                       := 0
ENABLE_OVERLAY                   := 0
ENABLE_LTO                       := 1
# UART Programming 2.9 kB
ENABLE_UART                      := 1
ENABLE_UART_DEBUG                := 0
# AirCopy 2.5 kB
ENABLE_AIRCOPY                   := 0
ENABLE_AIRCOPY_REMEMBER_FREQ     := 1
ENABLE_AIRCOPY_RX_REBOOT         := 0
# FM Radio 4.2 kB
ENABLE_FMRADIO_64_76             := 0
ENABLE_FMRADIO_76_90             := 0
ENABLE_FMRADIO_76_108            := 0
ENABLE_FMRADIO_875_108           := 1
ENABLE_FMRADIO_64_108            := 0
# NOAA 1.2 kB
ENABLE_NOAA                      := 0
# Voice 1.7 kB
ENABLE_VOICE                     := 0
ENABLE_MUTE_RADIO_FOR_VOICE      := 0
# Tx on Voice 1.0 kB
ENABLE_VOX                       := 0
ENABLE_VOX_MORE_SENSITIVE        := 1
ENABLE_REDUCE_LOW_MID_TX_POWER   := 1
# Tx Alarm 600 B
ENABLE_ALARM                     := 0
ENABLE_TX1750                    := 0
# MDC1200 2.8 kB
ENABLE_MDC1200                   := 0
ENABLE_MDC1200_SHOW_OP_ARG       := 1
ENABLE_PWRON_PASSWORD            := 0
ENABLE_RESET_AES_KEY             := 0
ENABLE_BIG_FREQ                  := 0
# smaa bolf 580 B
ENABLE_SMALL_BOLD                := 1
# smallest font 2 kB
ENABLE_SMALLEST_FONT             := 0
# trim trailing 44 B
ENABLE_TRIM_TRAILING_ZEROS       := 0
ENABLE_KEEP_MEM_NAME             := 1
ENABLE_WIDE_RX                   := 1
ENABLE_TX_WHEN_AM                := 0
# Freq calibration 188 B
ENABLE_F_CAL_MENU                := 0
ENABLE_TX_UNLOCK                 := 0
ENABLE_CTCSS_TAIL_PHASE_SHIFT    := 1
ENABLE_CONTRAST                  := 0
ENABLE_BOOT_BEEPS                := 0
ENABLE_DTMF_CALL_FLASH_LIGHT     := 1
ENABLE_FLASH_LIGHT_SOS_TONE      := 1
ENABLE_SHOW_CHARGE_LEVEL         := 0
ENABLE_REVERSE_BAT_SYMBOL        := 1
ENABLE_FREQ_SEARCH_TIMEOUT       := 0
ENABLE_CODE_SEARCH_TIMEOUT       := 0
ENABLE_SCAN_IGNORE_LIST          := 1
# Kill and Revive 400 B
ENABLE_KILL_REVIVE               := 0
# AM Fix 800 B
ENABLE_AM_FIX                    := 1
ENABLE_AM_FIX_SHOW_DATA          := 0
# Squelch 12 B .. can't be right ?
ENABLE_SQUELCH_MORE_SENSITIVE    := 1
ENABLE_SQ_OPEN_WITH_UP_DN_BUTTS  := 1
ENABLE_FASTER_CHANNEL_SCAN       := 1
ENABLE_COPY_CHAN_TO_VFO_TO_CHAN  := 1
# Rx Signal Bar 400 B
ENABLE_RX_SIGNAL_BAR             := 1
# Tx Audio Bar 300 B
ENABLE_TX_AUDIO_BAR              := 0
# Side Button Menu 300 B
ENABLE_SIDE_BUTT_MENU            := 1
# Key Lock 400 B
ENABLE_KEYLOCK                   := 0
#ENABLE_PANADAPTER               := 0
#ENABLE_SINGLE_VFO_CHAN          := 0

#############################################################

TARGET = firmware

GIT_HASH_TMP := $(shell git rev-parse --short HEAD)
ifeq ($(GIT_HASH_TMP), )
	GIT_HASH := "NOGIT"
else
	GIT_HASH := $(GIT_HASH_TMP)
endif

$(info GIT_HASH = $(GIT_HASH))

ifeq ($(ENABLE_UART), 0)
	ENABLE_UART_DEBUG := 0
endif

ifeq ($(ENABLE_CLANG),1)
	# GCC's linker, ld, doesn't understand LLVM's generated bytecode
	ENABLE_LTO := 0
endif

ifeq ($(ENABLE_LTO),1)
	# can't have LTO and OVERLAY enabled at same time
	ENABLE_OVERLAY := 0
endif

ifeq ($(filter $(ENABLE_FMRADIO_64_76) $(ENABLE_FMRADIO_76_90) $(ENABLE_FMRADIO_76_108) $(ENABLE_FMRADIO_875_108) $(ENABLE_FMRADIO_64_108), 1), 1)
	ENABLE_FMRADIO := 1
else
	ENABLE_FMRADIO := 0
endif

ifeq ($(ENABLE_VOICE),1)
	# no need for beeps
	ENABLE_BOOT_BEEPS := 0
endif

BSP_DEFINITIONS := $(wildcard hardware/*/*.def)
BSP_HEADERS     := $(patsubst hardware/%,bsp/%,$(BSP_DEFINITIONS))
BSP_HEADERS     := $(patsubst %.def,%.h,$(BSP_HEADERS))

OBJS =
# Startup files
OBJS += start.o
OBJS += init.o
ifeq ($(ENABLE_OVERLAY),1)
	OBJS += sram-overlay.o
endif
OBJS += external/printf/printf.o

# Drivers
OBJS += driver/adc.o
ifeq ($(ENABLE_UART),1)
	OBJS += driver/aes.o
endif
OBJS += driver/backlight.o
ifeq ($(ENABLE_FMRADIO), 1)
	OBJS += driver/bk1080.o
endif
OBJS += driver/bk4819.o
ifeq ($(filter $(ENABLE_AIRCOPY) $(ENABLE_UART) $(ENABLE_MDC1200), 1), 1)
	OBJS += driver/crc.o
endif
OBJS += driver/eeprom.o
ifeq ($(ENABLE_OVERLAY),1)
	OBJS += driver/flash.o
endif
OBJS += driver/gpio.o
OBJS += driver/i2c.o
OBJS += driver/keyboard.o
OBJS += driver/spi.o
OBJS += driver/st7565.o
OBJS += driver/system.o
OBJS += driver/systick.o
ifeq ($(ENABLE_UART),1)
	OBJS += driver/uart.o
endif

# Main
OBJS += app/action.o
ifeq ($(ENABLE_AIRCOPY),1)
	OBJS += app/aircopy.o
endif
OBJS += app/app.o
OBJS += app/dtmf.o
ifeq ($(ENABLE_FMRADIO), 1)
	OBJS += app/fm.o
endif
OBJS += app/generic.o
OBJS += app/main.o
OBJS += app/menu.o
OBJS += app/search.o
ifeq ($(ENABLE_SCAN_IGNORE_LIST),1)
	OBJS += freq_ignore.o
endif
ifeq ($(ENABLE_PANADAPTER),1)
	OBJS += app/spectrum.o
endif
ifeq ($(ENABLE_UART),1)
	OBJS += app/uart.o
endif
ifeq ($(ENABLE_AM_FIX), 1)
	OBJS += am_fix.o
endif
OBJS += audio.o
OBJS += bitmaps.o
OBJS += board.o
OBJS += dcs.o
OBJS += font.o
OBJS += frequencies.o
OBJS += functions.o
OBJS += helper/battery.o
OBJS += helper/boot.o
ifeq ($(ENABLE_MDC1200),1)
	OBJS += mdc1200.o
endif
OBJS += misc.o
OBJS += radio.o
OBJS += scheduler.o
OBJS += settings.o
ifeq ($(ENABLE_AIRCOPY),1)
	OBJS += ui/aircopy.o
endif
OBJS += ui/battery.o
ifeq ($(ENABLE_FMRADIO), 1)
	OBJS += ui/fmradio.o
endif
OBJS += ui/helper.o
OBJS += ui/inputbox.o
ifeq ($(ENABLE_PWRON_PASSWORD),1)
	OBJS += ui/lock.o
endif
OBJS += ui/main.o
OBJS += ui/menu.o
OBJS += ui/search.o
OBJS += ui/status.o
OBJS += ui/ui.o
OBJS += version.o
OBJS += main.o

ifeq ($(OS), Windows_NT)
	TOP := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
else
	TOP := $(shell pwd)
endif

$(info TOP = $(TOP))

AS = arm-none-eabi-gcc

CC =
LD = arm-none-eabi-gcc

ifeq ($(ENABLE_CLANG),0)
	CC += arm-none-eabi-gcc
# Use GCC's linker to avoid undefined symbol errors
#	LD += arm-none-eabi-gcc
else
#	May need to adjust this to match your system
	CC += clang --sysroot=/usr/arm-none-eabi --target=arm-none-eabi
#	Bloats binaries to 512MB
#	LD = ld.lld
endif

OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

ASFLAGS = -c -mcpu=cortex-m0
ifeq ($(ENABLE_OVERLAY),1)
	ASFLAGS += -DENABLE_OVERLAY
endif

CFLAGS =

ifeq ($(ENABLE_CLANG),0)
	#CFLAGS += -Os -Wall -Werror -mcpu=cortex-m0 -fno-builtin -fshort-enums -fno-delete-null-pointer-checks -std=c11 -MMD
	CFLAGS += -Os -Werror -mcpu=cortex-m0 -freorder-blocks-algorithm=stc -std=c11 -MMD
else
	# Oz needed to make it fit on flash
	CFLAGS += -Oz -Werror -mcpu=cortex-m0 -fno-builtin -fshort-enums -fno-delete-null-pointer-checks -std=c11 -MMD
endif

ifeq ($(ENABLE_LTO),1)
	CFLAGS += -flto=2
else
	# We get most of the space savings if LTO creates problems
	CFLAGS += -ffunction-sections -fdata-sections
endif

# May cause unhelpful build failures
#CFLAGS += -Wpadded

# catch any and all warnings
# better to bust than add new bugs
CFLAGS += -Wall -Wextra -Wpedantic

CFLAGS += -DPRINTF_INCLUDE_CONFIG_H
CFLAGS += -DGIT_HASH=\"$(GIT_HASH)\"
ifeq ($(ENABLE_SWD),1)
	CFLAGS += -DENABLE_SWD
endif
ifeq ($(ENABLE_OVERLAY),1)
	CFLAGS += -DENABLE_OVERLAY
endif
ifeq ($(ENABLE_AIRCOPY),1)
	CFLAGS += -DENABLE_AIRCOPY
endif
ifeq ($(ENABLE_AIRCOPY_REMEMBER_FREQ),1)
	CFLAGS += -DENABLE_AIRCOPY_REMEMBER_FREQ
endif
ifeq ($(ENABLE_AIRCOPY_RX_REBOOT),1)
	CFLAGS += -DENABLE_AIRCOPY_RX_REBOOT
endif
ifeq ($(ENABLE_FMRADIO_64_76),1)
	CFLAGS += -DENABLE_FMRADIO_64_76
endif
ifeq ($(ENABLE_FMRADIO_76_90),1)
	CFLAGS += -DENABLE_FMRADIO_76_90
endif
ifeq ($(ENABLE_FMRADIO_76_108),1)
	CFLAGS += -DENABLE_FMRADIO_76_108
endif
ifeq ($(ENABLE_FMRADIO_875_108),1)
	CFLAGS += -DENABLE_FMRADIO_875_108
endif
ifeq ($(ENABLE_FMRADIO_64_108),1)
	CFLAGS += -DENABLE_FMRADIO_64_108
endif
ifeq ($(ENABLE_FMRADIO),1)
	CFLAGS += -DENABLE_FMRADIO
endif
ifeq ($(ENABLE_UART),1)
	CFLAGS += -DENABLE_UART
endif
ifeq ($(ENABLE_UART_DEBUG),1)
	CFLAGS += -DENABLE_UART_DEBUG
endif
ifeq ($(ENABLE_BIG_FREQ),1)
	CFLAGS  += -DENABLE_BIG_FREQ
endif
ifeq ($(ENABLE_SMALL_BOLD),1)
	CFLAGS  += -DENABLE_SMALL_BOLD
endif
ifeq ($(ENABLE_SMALLEST_FONT),1)
	CFLAGS  += -DENABLE_SMALLEST_FONT
endif
ifeq ($(ENABLE_TRIM_TRAILING_ZEROS),1)
	CFLAGS  += -DENABLE_TRIM_TRAILING_ZEROS
endif
ifeq ($(ENABLE_NOAA),1)
	CFLAGS  += -DENABLE_NOAA
endif
ifeq ($(ENABLE_VOICE),1)
	CFLAGS  += -DENABLE_VOICE
endif
ifeq ($(ENABLE_MUTE_RADIO_FOR_VOICE),1)
	CFLAGS  += -DENABLE_MUTE_RADIO_FOR_VOICE
endif
ifeq ($(ENABLE_VOX),1)
	CFLAGS  += -DENABLE_VOX
endif
ifeq ($(ENABLE_VOX_MORE_SENSITIVE),1)
	CFLAGS  += -DENABLE_VOX_MORE_SENSITIVE
endif
ifeq ($(ENABLE_REDUCE_LOW_MID_TX_POWER),1)
	CFLAGS  += -DENABLE_REDUCE_LOW_MID_TX_POWER
endif
ifeq ($(ENABLE_ALARM),1)
	CFLAGS  += -DENABLE_ALARM
endif
ifeq ($(ENABLE_TX1750),1)
	CFLAGS  += -DENABLE_TX1750
endif
ifeq ($(ENABLE_MDC1200),1)
	CFLAGS  += -DENABLE_MDC1200
endif
ifeq ($(ENABLE_MDC1200_SHOW_OP_ARG),1)
	CFLAGS  += -DENABLE_MDC1200_SHOW_OP_ARG
endif
ifeq ($(ENABLE_PWRON_PASSWORD),1)
	CFLAGS  += -DENABLE_PWRON_PASSWORD
endif
ifeq ($(ENABLE_RESET_AES_KEY),1)
	CFLAGS  += -DENABLE_RESET_AES_KEY
endif
ifeq ($(ENABLE_KEEP_MEM_NAME),1)
	CFLAGS  += -DENABLE_KEEP_MEM_NAME
endif
ifeq ($(ENABLE_WIDE_RX),1)
	CFLAGS  += -DENABLE_WIDE_RX
endif
ifeq ($(ENABLE_TX_WHEN_AM),1)
	CFLAGS  += -DENABLE_TX_WHEN_AM
endif
ifeq ($(ENABLE_F_CAL_MENU),1)
	CFLAGS  += -DENABLE_F_CAL_MENU
endif
ifeq ($(ENABLE_TX_UNLOCK),1)
	CFLAGS  += -DENABLE_TX_UNLOCK
endif
ifeq ($(ENABLE_CTCSS_TAIL_PHASE_SHIFT),1)
	CFLAGS  += -DENABLE_CTCSS_TAIL_PHASE_SHIFT
endif
ifeq ($(ENABLE_CONTRAST),1)
	CFLAGS  += -DENABLE_CONTRAST
endif
ifeq ($(ENABLE_BOOT_BEEPS),1)
	CFLAGS  += -DENABLE_BOOT_BEEPS
endif
ifeq ($(ENABLE_DTMF_CALL_FLASH_LIGHT),1)
	CFLAGS  += -DENABLE_DTMF_CALL_FLASH_LIGHT
endif
ifeq ($(ENABLE_FLASH_LIGHT_SOS_TONE),1)
	CFLAGS  += -DENABLE_FLASH_LIGHT_SOS_TONE
endif
ifeq ($(ENABLE_SHOW_CHARGE_LEVEL),1)
	CFLAGS  += -DENABLE_SHOW_CHARGE_LEVEL
endif
ifeq ($(ENABLE_REVERSE_BAT_SYMBOL),1)
	CFLAGS  += -DENABLE_REVERSE_BAT_SYMBOL
endif
ifeq ($(ENABLE_CODE_SEARCH_TIMEOUT),1)
	CFLAGS  += -DENABLE_CODE_SEARCH_TIMEOUT
endif
ifeq ($(ENABLE_SCAN_IGNORE_LIST),1)
	CFLAGS  += -DENABLE_SCAN_IGNORE_LIST
endif
ifeq ($(ENABLE_KILL_REVIVE),1)
	CFLAGS  += -DENABLE_KILL_REVIVE
endif
ifeq ($(ENABLE_FREQ_SEARCH_TIMEOUT),1)
	CFLAGS  += -DENABLE_FREQ_SEARCH_TIMEOUT
endif
ifeq ($(ENABLE_AM_FIX),1)
	CFLAGS  += -DENABLE_AM_FIX
endif
ifeq ($(ENABLE_AM_FIX_SHOW_DATA),1)
	CFLAGS  += -DENABLE_AM_FIX_SHOW_DATA
endif
ifeq ($(ENABLE_AM_FIX_TEST1),1)
	CFLAGS  += -DENABLE_AM_FIX_TEST1
endif
ifeq ($(ENABLE_SQUELCH_MORE_SENSITIVE),1)
	CFLAGS  += -DENABLE_SQUELCH_MORE_SENSITIVE
endif
ifeq ($(ENABLE_SQ_OPEN_WITH_UP_DN_BUTTS),1)
	CFLAGS  += -DENABLE_SQ_OPEN_WITH_UP_DN_BUTTS
endif
ifeq ($(ENABLE_FASTER_CHANNEL_SCAN),1)
	CFLAGS  += -DENABLE_FASTER_CHANNEL_SCAN
endif
ifeq ($(ENABLE_backlight_ON_RX),1)
	CFLAGS  += -DENABLE_backlight_ON_RX
endif
ifeq ($(ENABLE_RX_SIGNAL_BAR),1)
	CFLAGS  += -DENABLE_RX_SIGNAL_BAR
endif
ifeq ($(ENABLE_TX_AUDIO_BAR),1)
	CFLAGS  += -DENABLE_TX_AUDIO_BAR
endif
ifeq ($(ENABLE_COPY_CHAN_TO_VFO_TO_CHAN),1)
	CFLAGS  += -DENABLE_COPY_CHAN_TO_VFO_TO_CHAN
endif
ifeq ($(ENABLE_SIDE_BUTT_MENU),1)
	CFLAGS += -DENABLE_SIDE_BUTT_MENU
endif
ifeq ($(ENABLE_KEYLOCK),1)
	CFLAGS += -DENABLE_KEYLOCK
endif
ifeq ($(ENABLE_SINGLE_VFO_CHAN),1)
	CFLAGS  += -DENABLE_SINGLE_VFO_CHAN
endif
ifeq ($(ENABLE_PANADAPTER),1)
	CFLAGS += -DENABLE_PANADAPTER
endif

LDFLAGS =
ifeq ($(ENABLE_CLANG),0)
	LDFLAGS += -mcpu=cortex-m0 -nostartfiles -Wl,-T,firmware.ld
else
#	Fix warning about implied executable stack
	LDFLAGS += -z noexecstack -mcpu=cortex-m0 -nostartfiles -Wl,-T,firmware.ld
endif

# Use newlib-nano instead of newlib
LDFLAGS += --specs=nano.specs

ifeq ($(ENABLE_LTO),0)
	# Throw away unneeded func/data sections like LTO does
	LDFLAGS += -Wl,--gc-sections
endif

ifeq ($(DEBUG),1)
	ASFLAGS += -g
	CFLAGS  += -g
	LDFLAGS += -g
endif

INC =
INC += -I $(TOP)
INC += -I $(TOP)/external/CMSIS_5/CMSIS/Core/Include/
INC += -I $(TOP)/external/CMSIS_5/Device/ARM/ARMCM0/Include

LIBS =

DEPS = $(OBJS:.o=.d)

ifeq ($(OS), Windows_NT)
	PYTHON = $(shell where python 2>NUL || where python3 2>NUL)
else
	PYTHON = $(shell which python || which python3)
endif

all: $(TARGET)
	$(OBJCOPY) -O binary $< $<.bin

	$(info PYTHON = $(PYTHON))

	-python fw-pack.py $<.bin $(GIT_HASH) $<.packed.bin
	-python3 fw-pack.py $<.bin $(GIT_HASH) $<.packed.bin
#	-$(PYTHON) fw-pack.py $<.bin $(GIT_HASH) $<.packed.bin

	$(SIZE) $<

debug:
	/opt/openocd/bin/openocd -c "bindto 0.0.0.0" -f interface/jlink.cfg -f dp32g030.cfg

flash:
	/opt/openocd/bin/openocd -c "bindto 0.0.0.0" -f interface/jlink.cfg -f dp32g030.cfg -c "write_image firmware.bin 0; shutdown;"

version.o: .FORCE

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@ $(LIBS)

bsp/dp32g030/%.h: hardware/dp32g030/%.def

%.o: %.c | $(BSP_HEADERS)
	$(CC) $(CFLAGS) $(INC) -c $< -o $@

%.o: %.S
	$(AS) $(ASFLAGS) $< -o $@

.FORCE:

-include $(DEPS)

clean:
	rm -f $(TARGET).bin $(TARGET).packed.bin $(TARGET) $(OBJS) $(DEPS)
