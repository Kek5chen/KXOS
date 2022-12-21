ODIR = obj
BDIR = bin
NAME = $(BDIR)/kxos.iso

KERNEL_DIR = kernel
KERNEL_SRC = $(wildcard $(KERNEL_DIR)/*/*.c)
KERNEL_OBJ = $(patsubst %.c, $(ODIR)/%.o, $(KERNEL_SRC))

all: $(NAME)

$(NAME): kernel boot/boot.asm boot/mode_switch.asm boot/gdt.asm
# SETUP
	mkdir -p $(BDIR)
	mkdir -p $(ODIR)
# ASSEMBLE
	nasm -f bin boot/boot.asm -o $(ODIR)/boot.bin
# COPY TO ISO FILE
	truncate $(ODIR)/boot.bin -s 1200k
	mkisofs -o $(NAME) -input-charset iso8859-1 -b $(ODIR)/boot.bin .

kernel: $(KERNEL_OBJ)

$(ODIR)/%.o: $(KERNEL_DIR)/%.c
	mkdir -p $@
	gcc -ffreestanding -c -o $@ $<

clean:
	rm -rf $(ODIR)

fclean: clean
	rm -rf $(BDIR)

run: $(NAME)
	qemu-system-x86_64.exe -hda $(ODIR)/boot.bin

.PHONY: all clean run kernel