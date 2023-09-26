#include "interrupts.h"
#include "utils/virtprint.h"

void system_halt() {
	print_string("OS HALTED! ", 0x0C, MAKE_XY(0, 1));
	while(1) asm volatile ("cli; hlt;");
}

void kernel_panic(const char *message) {
	print_string("Kernel Panic: ", 0x0C, MAKE_XY(0, 0));
	// TODO: just prints gibberish message for now, need to fix that
	print_string(message, 0x0C, MAKE_XY(14, 0));

	system_halt();
}