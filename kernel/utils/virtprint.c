#include "virtprint.h"

void clear_screen()
{
	telechar_t *p = (telechar_t *)PTR_VMB;
	for(int i = 0; i < MAKE_XY(80, 24); i++) {
		p[i].c = 0;
		p[i].a = 0;
	}
}

void print_character(char c, unsigned char color, int pos)
{
	telechar_t *p = (telechar_t *)PTR_VMB + pos;
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