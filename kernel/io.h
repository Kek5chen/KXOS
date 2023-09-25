#ifndef IO_H
# define IO_H

extern char kbd_US[128];

char	read_character();
void	setup_keymap();
char	to_scancode(char c);
char	to_keycode(char scancode);

#endif //IO_H
