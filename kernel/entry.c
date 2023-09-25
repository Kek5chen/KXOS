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

__attribute__((section(".text.kernel_entry")))
int	_start(void)
{
	clear_screen();
	char *str = "Welcome to KXOS";
	print_string(str, 0x0A, MAKE_XY(40 - strlen(str) / 2, 12));
	while (1)
		;
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
