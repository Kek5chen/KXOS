NAME = boot.iso

all: $(NAME)

$(NAME): boot/boot.asm
	nasm -f bin boot/boot.asm -o boot.img
	dd if=boot.img of=$(NAME) bs=512 conv=sync
	mkisofs -o $(NAME) -b boot.img

clean:
	rm -f boot.img $(NAME)

run: $(NAME)
	qemu-system-x86_64.exe -cdrom $(NAME)

.PHONY: all clean run