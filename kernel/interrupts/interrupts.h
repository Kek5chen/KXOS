#pragma once

#include <stdint.h>

void load_idt(uint32_t *idt);


void idt_set_gate(uint8_t num, uintptr_t base, uint16_t selector, uint8_t flags);
void install_idt();

void system_halt();
void kernel_panic(const char *message);