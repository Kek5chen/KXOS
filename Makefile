# Variables
ODIR := obj
BDIR := bin
NAME := $(BDIR)/kxos.iso
WD := $(shell pwd)
REMOTE_SERVER_IP :=
KERNEL_DIR := kernel
KERNEL_SRC := $(wildcard $(KERNEL_DIR)/*.c)
KERNEL_SRC_ASM := $(wildcard $(KERNEL_DIR)/*.asm)
KERNEL_OBJ := $(patsubst %.c, $(ODIR)/%.o, $(KERNEL_SRC))
KERNELOBJ_NOENTRY := $(filter-out $(ODIR)/kernel/entry.o, $(KERNEL_OBJ))
KERNEL_OBJ_ASM := $(patsubst %.asm, $(ODIR)/%.o, $(KERNEL_SRC_ASM))

# Compilation Flags
CFLAGS := -ffreestanding -m32 -fno-pie -fno-stack-protector -g
NASMFLAGS := -f elf32 -g

# Main Targets
all: $(NAME)

$(NAME): bootloader kernel
	@mkdir -p $(BDIR)
	@cat $(ODIR)/boot.bin $(ODIR)/kernel.bin > $(ODIR)/combined.bin
	@truncate $(ODIR)/combined.bin -s 1200k
	@genisoimage -o $(NAME) -input-charset iso8859-1 -b $(ODIR)/combined.bin .
	@echo "ISO image compiled successfully!"

# Bootloader Targets
bootloader:
	@mkdir -p $(ODIR)
	@nasm -f bin boot/boot.asm -o $(ODIR)/boot.bin
	@echo "Compiled boot.asm"
	@echo "Bootloader compiled successfully!"

# Kernel Targets
kernel: $(KERNEL_OBJ) $(KERNEL_OBJ_ASM)
	@ld -o $(ODIR)/kernel.elf -T linker.ld $(KERNEL_OBJ) $(KERNEL_OBJ_ASM) -m elf_i386
	@objcopy -O binary $(ODIR)/kernel.elf $(ODIR)/kernel.bin
	@echo "Kernel compiled successfully!"

$(ODIR)/$(KERNEL_DIR)/%.o: $(KERNEL_DIR)/%.c
	@mkdir -p $(ODIR)/$(KERNEL_DIR)
	@gcc $(CFLAGS) -c $< -o $@
	@echo "Compiled $<"

$(ODIR)/$(KERNEL_DIR)/%.o: $(KERNEL_DIR)/%.asm
	@mkdir -p $(ODIR)/$(KERNEL_DIR)
	@nasm $(NASMFLAGS) $< -o $@
	@echo "Compiled $<"

# Utility Targets
clean:
	@rm -rf $(ODIR)
	@rm -rf $(BDIR)
	@echo "Cleaned up project!"

re: clean all

debug: $(NAME)
	@qemu-system-i386 -s -S -cdrom $(NAME)

run: $(NAME)
	@qemu-system-i386 -cdrom $(NAME)

upload:
	@rsync -avz -e 'ssh' $(WD) $(REMOTE_SERVER_IP):/tmp
	@ssh $(REMOTE_SERVER_IP) "cd /tmp/KXOS && make fclean && make"
	@rsync -avz -e 'ssh' $(REMOTE_SERVER_IP):/tmp/KXOS/$(ODIR) $(WD)
	@rsync -avz -e 'ssh' $(REMOTE_SERVER_IP):/tmp/KXOS/$(BDIR) $(WD)

uploadandrun: upload run

.PHONY: all clean fclean re run kernel bootloader upload uploadandrun
.NOTPARALLEL: uploadandrun
