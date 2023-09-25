#include "io.h"

char kbd_US[128];

void setup_keymap()
{
	char kmap[128] = {
		0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
				'\t', /* <-- Tab */
				'q', 'w', 'e', 'r', 't', 'z', 'u', 'i', 'o', 'p', '[', ']', '\n',
				0, /* <-- control key */
				'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',  0, '\\', 'y', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',   0,
				'*',
				0,  /* Alt */
				' ',  /* Space bar */
				0,  /* Caps lock */
				0,  /* 59 - F1 key ... > */
				0,   0,   0,   0,   0,   0,   0,   0,
				0,  /* < ... F10 */
				0,  /* 69 - Num lock*/
				0,  /* Scroll Lock */
				0,  /* Home key */
				0,  /* Up Arrow */
				0,  /* Page Up */
				'-',
				0,  /* Left Arrow */
				0,
				0,  /* Right Arrow */
				'+',
				0,  /* 79 - End key*/
				0,  /* Down Arrow */
				0,  /* Page Down */
				0,  /* Insert Key */
				0,  /* Delete Key */
				0,   0,   0,
				0,  /* F11 Key */
				0,  /* F12 Key */
				0,  /* All other keys are undefined */
	};
	*kbd_US = *kmap;
}

char to_scancode(char c)
{
	for (int i = 0; i < 128; i++)
		if (kbd_US[i] == c)
			return i;
	return 0;
}

char to_keycode(char scancode)
{
	if (scancode < 0)
		scancode *= -1;
	return kbd_US[scancode];
}