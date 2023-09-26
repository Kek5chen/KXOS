#include "interrupts.h"

#include "memory.h"

struct idt_entry {
	unsigned short base_low;
	unsigned short selector;
	unsigned char always0;
	unsigned char flags;
	unsigned short base_high;
} __attribute__((packed));

static struct idt_entry idt[256];

struct idt_ptr {
	unsigned short limit;
	unsigned int base;
} __attribute__((packed));

static struct idt_ptr idtp;

void idt_set_gate(uint8_t num, uintptr_t base, uint16_t selector, uint8_t flags) {
	idt[num].base_low = (base & 0xFFFF);
	idt[num].base_high = (base >> 16) & 0xFFFF;
	idt[num].selector = selector;
	idt[num].always0 = 0;
	idt[num].flags = flags;
}

void install_idt() {
	idtp.limit = (sizeof(struct idt_entry) * 256) - 1;
	idtp.base = (uintptr_t)&idt;

	memset(&idt, 0, sizeof(struct idt_entry) * 256);

	for (int i = 0; i < 256; ++i) {
		idt_set_gate(i, (uintptr_t) kernel_panic, 0x08, 0x8E);
	}

	asm volatile("lidt %0" : : "m"(idtp));
}

