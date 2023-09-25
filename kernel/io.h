#ifndef IO_H
# define IO_H

unsigned char inb(unsigned short port);
void outb(unsigned short port, unsigned char value);

unsigned int inl(unsigned short port);
void outl(unsigned short port, unsigned int value);

unsigned char	read_character();
unsigned char	read_character_async();
char			to_scancode(char c);
char			to_keycode(unsigned char scancode);

#endif //IO_H
