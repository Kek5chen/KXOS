#include "io.h"

#define	VMB	0xB8000							// Video Memory Base
#define MAKE_XY(x, y) ((y) * 80 + (x))		// Make XY coordinate

void print_string(const char *s, unsigned char color, int pos);
void print_character(char c, unsigned char color, int pos);
void clear_screen();

typedef struct __attribute__((packed)) telechar_s
{
	char c;
	unsigned char a;
} telechar_t;

int strlen(const char *s)
{
	int i = 0;
	while (s[i])
		i++;
	return i;
}

void print_number(int n, unsigned char color, int pos);
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

void clear_screen()
{
	telechar_t *p = (telechar_t *)VMB;
	for(int i = 0; i < MAKE_XY(80, 24); i++) {
		p[i].c = 0;
		p[i].a = 0;
	}
}

void print_character(char c, unsigned char color, int pos)
{
	telechar_t *p = (telechar_t *)VMB + pos;
	p->c = c;
	p->a = color;
}

void print_string(const char *s, unsigned char color, int pos)
{
	while (*s)
	{
		print_character(*s, color, pos);
		s++;
		pos++;
	}
}

// Function to recursively print the digits
int print_number_recursive(int num, unsigned char col, int position) {
	if (num == 0) return position;

	position = print_number_recursive(num / 10, col, position);
	print_character((num % 10) + '0', col, position);
	return position + 1;
}

void print_number(int n, unsigned char color, int pos)
{
	if (n < 0) {
		print_character('-', color, pos);
		n = -n;
		pos++;
	}
	if (n == 0) {
		print_character('0', color, pos);
		return;
	}

	print_number_recursive(n, color, pos);
}