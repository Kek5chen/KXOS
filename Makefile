ODIR = obj
NAME = $(ODIR)/kxos.iso

all: $(NAME)

$(NAME): boot/boot.asm boot/mode_switch.asm boot/gdt.asm
# SETUP
	mkdir -p $(ODIR)
# ASSEMBLE
	nasm -f bin boot/boot.asm -o $(ODIR)/boot.bin
# COPY TO ISO FILE
	truncate $(ODIR)/boot.bin -s 1200k
	mkisofs -o $(NAME) -input-charset iso8859-1 -b $(ODIR)/boot.bin .

clean:
	rm -f $(NAME)

run: $(NAME)
	qemu-system-x86_64.exe -hda $(ODIR)/boot.bin

.PHONY: all clean run