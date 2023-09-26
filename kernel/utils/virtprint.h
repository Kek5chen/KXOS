#pragma once

#define	PTR_VMB	0xB8000							// Video Memory Base
#define MAKE_XY(x, y) ((y) * 80 + (x))		// Make XY coordinate

typedef struct __attribute__((packed)) telechar_s
{
	char c;
	unsigned char a;
} telechar_t;

void print_string(const char *s, unsigned char color, int pos);
void print_character(char c, unsigned char color, int pos);
void clear_screen();
void print_number(int n, unsigned char color, int pos);
