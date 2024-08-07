# Variables
ODIR := obj
BDIR := bin
NAME := $(BDIR)/kxos.iso
WD := $(shell pwd)
REMOTE_SERVER_IP :=
KERNEL_DIR := kernel
KERNEL_SRC := $(shell find $(KERNEL_DIR) -name '*.c')
KERNEL_SRC_ASM := $(shell find $(KERNEL_DIR) -name '*.asm')
KERNEL_OBJ := $(patsubst $(KERNEL_DIR)/%.c,$(ODIR)/%.o,$(KERNEL_SRC))
KERNEL_OBJ_ASM := $(patsubst $(KERNEL_DIR)/%.asm,$(ODIR)/%.o,$(KERNEL_SRC_ASM))

# Compilation Flags
CFLAGS := -ffreestanding -m32 -fno-pie -fno-stack-protector -g -mgeneral-regs-only -mno-red-zone
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
	@echo "Linking " $(KERNEL_OBJ) $(KERNEL_OBJ_ASM) " into kernel.elf..."
	@ld -o $(ODIR)/kernel.elf -T linker.ld $(KERNEL_OBJ) $(KERNEL_OBJ_ASM) -m elf_i386
	@echo "Converting kernel.elf to kernel.bin..."
	@objcopy -O binary $(ODIR)/kernel.elf $(ODIR)/kernel.bin
	@echo "Kernel compiled successfully!"

$(ODIR)/%.o: $(KERNEL_DIR)/%.c
	@echo "Compiling $<..."
	@mkdir -p $(@D)
	@gcc -Ikernel $(CFLAGS) -c $< -o $@

$(ODIR)/%.o: $(KERNEL_DIR)/%.asm
	@echo "Compiling $<..."
	@mkdir -p $(@D)
	@nasm $(NASMFLAGS) $< -o $@

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
