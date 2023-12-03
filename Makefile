CODEDIRS=. ./os/boot/ ./os/kernel/
INCDIRS=.
BINARY=./os/boot/boot.bin

CC=gcc # compiler
OPT=-O0

# generate files that encode Make rules for header file dependencies
DEPFLAGS=-MP -MP

CC_FLAGS=-Wall -Wextra $(foreach D,$(INCDIRS),-I$(D)) $(OPT) $(DEPFLAGS)
SA_FLAGS=-m32 -fno-pie -ffreestanding
CFILES=$(foreach D,$(CODEDIRS),$(wildcard $(D)/*.c))
# pattern substitution
OBJ=$(patsubst %.c,%.o,$(CFILES))
DEP=$(patsubst %.c,%.d,$(CFILES)) # allows dependency tracking


all: bootsector.bin


#os.img: bootsector.bin
save: clean
	git add *
	git commit -m "save progress"
	git push -u origin main

run: bootsector.bin
	qemu-system-i386 ./bootsector.bin

bootsector.bin: bootsector.elf
	objcopy -S -O binary -j .text $< $@
	python3 ./os/boot/pad_bootsector.py

bootsector.elf: ./os/boot/boot.bin ./os/boot/bootmain.o
	ld -m elf_i386 --entry=start -Ttext 0x7c00 -T ./os/boot/bootlink.ld -o $@ $^
	


%.bin : %.asm
	nasm ./$< -f elf32 -o ./$@

%.o : %.c
	$(CC) $(SA_FLAGS) -c $< -o $@

# @ symbol hides console output
stat:
	@git status
	@git diff --stat

# remove binaries, object files, and dependencies
clean:
	rm -rf $(BINARY) $(OBJ) $(DEP) ./boot*