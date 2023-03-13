ODIR = obj
BDIR = bin
NAME = $(BDIR)/kxos.iso

WD = $(shell pwd)
REMOTE_SERVER_IP =

KERNEL_DIR = kernel
KERNEL_SRC = $(wildcard $(KERNEL_DIR)/*.c)
KERNEL_SRC_ASM = $(wildcard $(KERNEL_DIR)/*.asm)
KERNEL_OBJ = $(patsubst %.c, $(ODIR)/%.o, $(KERNEL_SRC))
KERNELOBJ_NOENTRY=$(patsubst $(ODIR)/kernel/entry.o,,$(KERNEL_OBJ))
KERNEL_OBJ_ASM = $(patsubst %.asm, $(ODIR)/%.o, $(KERNEL_SRC_ASM))

all: $(NAME)

$(NAME): kernel boot/boot.asm boot/mode_switch.asm boot/gdt.asm
# SETUP
	mkdir -p $(BDIR)
	mkdir -p $(ODIR)
# ASSEMBLE
	nasm -f bin boot/boot.asm -o $(ODIR)/boot.bin
# APPEND
	cat $(ODIR)/kernel.bin >> $(ODIR)/boot.bin
# COPY TO ISO FILE
	truncate $(ODIR)/boot.bin -s 1200k
	genisoimage -o $(NAME) -input-charset iso8859-1 -b $(ODIR)/boot.bin .

kernel: $(KERNEL_OBJ) $(KERNEL_OBJ_ASM)
# LINK
	ld -o $(ODIR)/kernel.bin -Ttext 0x7e00 $(ODIR)/kernel/entry.o $(KERNELOBJ_NOENTRY) $(KERNEL_OBJ_ASM) --oformat binary -m elf_i386

$(ODIR)/$(KERNEL_DIR)/%.o: $(KERNEL_DIR)/%.c
	mkdir -p $(ODIR)/$(KERNEL_DIR)
	gcc -ffreestanding -c $< -o $@ -m32 -fno-pie

$(ODIR)/$(KERNEL_DIR)/%.o: $(KERNEL_DIR)/%.asm
	mkdir -p $(ODIR)/$(KERNEL_DIR)
	nasm -f elf32 $< -o $@

clean:
	rm -rf $(ODIR)

fclean: clean
	rm -rf $(BDIR)

run:
	qemu-system-x86_64 -hda $(ODIR)/boot.bin

upload:
	rsync -avz -e 'ssh' $(WD) $(REMOTE_SERVER_IP):/tmp
	ssh $(REMOTE_SERVER_IP) "cd /tmp/KXOS && make fclean && make"
	rsync -avz -e 'ssh' $(REMOTE_SERVER_IP):/tmp/KXOS/obj $(WD)
	rsync -avz -e 'ssh' $(REMOTE_SERVER_IP):/tmp/KXOS/bin $(WD)

uploadandrun: upload run

.PHONY: all clean run kernel
.NOTPARALLEL: uploadandrun
