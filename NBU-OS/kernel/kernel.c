#include <stdint.h>

static volatile uint16_t *const vga = (uint16_t *)0xb8000;
static uint16_t cursor;
static char installed_user[32];
static char installed_password[32];

static uint8_t inb(uint16_t port) {
    uint8_t value;
    __asm__ volatile ("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

static void clear_screen(void) {
    for (uint16_t index = 0; index < 80 * 25; ++index) {
        vga[index] = 0x0720;
    }
    cursor = 0;
}

static void putc(char c) {
    if (c == '\n') {
        cursor = (uint16_t)(((cursor / 80) + 1) * 80);
        return;
    }
    vga[cursor++] = (uint16_t)(0x0f00u | (uint8_t)c);
    if (cursor >= 80 * 25) cursor = 0;
}

static void puts(const char *text) {
    while (*text) putc(*text++);
}

static int text_equal(const char *left, const char *right) {
    while (*left && *right && *left == *right) {
        ++left;
        ++right;
    }
    return *left == *right;
}

static char key_to_ascii(uint8_t scan_code) {
    static const char keymap[] = "?1234567890-=qwertyuiop[]?asdfghjkl;\\`?zxcvbnm,./";
    if (scan_code >= 2 && scan_code <= 53) {
        return keymap[scan_code - 1];
    }
    if (scan_code == 57) return 
