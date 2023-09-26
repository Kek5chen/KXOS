#include "io/io.h"
#include "utils/virtprint.h"
#include "utils/string.h"

__attribute__((section(".text.kernel_entry")))
int	_start(void)
{
	clear_screen();
	char *str = "Welcome to KXOS";
	print_string(str, 0x0A, MAKE_XY(40 - strlen(str) / 2, 12));

	print_string("Scancode: ", 0x0A, MAKE_XY(34, 14));
	print_string("Keycode: ", 0x0A, MAKE_XY(34, 15));
	print_string("Character:", 0x0A, MAKE_XY(34, 16));
	print_number(0, 0x0A, MAKE_XY(45, 14));
	print_number(0, 0x0A, MAKE_XY(45, 15));
	print_character(' ', 0x0A, MAKE_XY(45, 16));
	while (1) {
		unsigned char read = read_character_async();
		if (read == 0)
			continue;

		if (read >= 128)
			continue;

		char keycode = to_keycode(read);
		print_string("   ", 0x0A, MAKE_XY(45, 14));
		print_string("   ", 0x0A, MAKE_XY(45, 15));
		print_character(' ', 0x0A, MAKE_XY(45, 16));
		print_number(read, 0x0A, MAKE_XY(45, 14));
		print_number(keycode, 0x0A, MAKE_XY(45, 15));
		print_character(keycode, 0x0A, MAKE_XY(45, 16));
	}
	return 0xABC;
}