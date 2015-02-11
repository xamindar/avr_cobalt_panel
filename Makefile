DEVICE_CC = atmega328p
DEVICE_DUDE = ATMEGA328P

# PROGRAMMER_DUDE = -Pusb -c dragon_isp
PROGRAMMER_DUDE = -P /dev/ttyACM0 -c arduino -b 115200

AVRDUDE=avrdude
OBJCOPY=avr-objcopy
OBJDUMP=avr-objdump
CC=avr-gcc
LD=avr-gcc

LDFLAGS=-Wall -g -mmcu=$(DEVICE_CC)
CPPFLAGS=
CFLAGS=-mmcu=$(DEVICE_CC) -Os -Wall -g -DF_CPU=16000000UL -Wno-deprecated-declarations -D__PROG_TYPES_COMPAT__

MYNAME=avr-cobalt-panel

OBJS=$(MYNAME).o hd44780.o cobalt_buttons.o cobalt_leds.o \
	serial.o menu.o protocol.o

all : $(MYNAME).hex $(MYNAME).lst

$(MYNAME).bin : $(OBJS)

%.hex : %.bin
	$(OBJCOPY) -j .text -j .data -O ihex $^ $@ || (rm -f $@ ; false )

%.lst : %.bin
	$(OBJDUMP) -S $^ >$@ || (rm -f $@ ; false )

%.bin : %.o
	$(LD) $(LDFLAGS) -o $@ $^

include $(OBJS:.o=.d)

%.d : %.c
	$(CC) -o $@ -MM $^

.PHONY : clean burn
burn : $(MYNAME).hex
	$(AVRDUDE) $(PROGRAMMER_DUDE) -p $(DEVICE_DUDE) -U flash:w:$^
clean :
	rm -f *.bak *~ *.bin *.hex *.lst *.o *.d
