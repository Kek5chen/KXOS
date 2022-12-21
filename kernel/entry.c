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
	char *s = "Welcome to KXOS!";
	char *b = "We're in!";
	char *spacer = "|||||||||||||||||||||||||||||||||||||||||||||||";

	clear_screen();
	print_string(spacer, 0x30, MAKE_XY(15, 8));
	print_string(s, 0x30, MAKE_XY(31, 10));
	print_string(b, 0x30, MAKE_XY(35, 11));
	print_string(spacer, 0x30, MAKE_XY(15, 13));
	return 0xABC;
}

void clear_screen()
{
	telechar_t *p = (telechar_t *)VMB;
	for(int i = 0; i < 80 * 20; i++) {
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
