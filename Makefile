ODIR = obj
NAME = $(ODIR)/boot.img

all: $(NAME)

$(NAME): boot/boot.asm
# SETUP
	mkdir -p $(ODIR)
# ASSEMBLE
	nasm -f bin boot/boot.asm -o $(ODIR)/boot.bin
# COPY TO ISO FILE
	dd if=/dev/zero of=$(NAME) bs=1024 count=20480
	mkfs.ext3 -F -b 1024 $(NAME) 20480
	dd if=$(ODIR)/boot.bin of=$(NAME) conv=notrunc

clean:
	rm -f $(NAME)

run: $(NAME)
	qemu-system-x86_64.exe -hda $(NAME)

.PHONY: all clean run