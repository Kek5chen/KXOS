#include "io.h"

#define	VMB	0xB8000							// Video Memory Base
#define MAKE_XY(x, y) ((y) * 80 + (x))		// Make XY coordinate

void print_string(const char *s, unsigned char color, int pos);
void print_character(char c, unsigned char color, int pos);
void clear_screen();

typedef struct telechar_s
{
	char c;
	unsigned char a;
} telechar_t;

int	kernel_entry(void)
{
	int i = MAKE_XY(3, 4);
	char key;
	char key_code;
	char keys[128];
	setup_keymap();
	print_string("> ", 0x30, MAKE_XY(0, 4));
	while (1)
	{
		if (i >= MAKE_XY(80, 20)) {
			clear_screen();
			i = 0;
		}
		key = read_character();
		if (!(key & 0xFF))
			continue;
		key_code = to_keycode(key);
		if (!key_code)
			continue;
		if(keys[key] && key_code > 0)
			continue;
		if (!keys[key] && key_code < 0) {
			keys[key] = 0;
			continue;
		}
		keys[key] = 1;
		if (key_code == '\b') {
			if (i > 0) {
				i--;
				print_character(' ', 0x30, i);
			}
		} else if (key == '\n') {
			i += 80 - i % 80;
		} else {
			print_character(key, 0x30, i);
			i++;
		}
	}
	return 0xABC;
}

void clear_screen()
{
	telechar_t *p = (telechar_t *)VMB;
	for(int i = 0; i < MAKE_XY(80, 20); i++) {
		p[i].c = 0;
	}
}

void print_character(char c, unsigned char color, int pos)
{
	telechar_t *p = (telechar_t *)VMB;
	p += pos;
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
