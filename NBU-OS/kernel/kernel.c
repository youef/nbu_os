#include <stdint.h>
#include <nbu/security.h>
#include <nbu/system.h>

static volatile uint16_t *const vga = (uint16_t *)0xb8000;
static uint16_t cursor;
static char installed_user[32];
static uint8_t installed_password_hash[32];

typedef void (*program_entry_t)(void);

typedef struct {
    const char *path;
    program_entry_t entry;
} nbu_program_t;

static uint8_t inb(uint16_t port) {
    uint8_t value;
    __asm__ volatile ("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

static void clear_screen(void) {
    for (uint16_t index = 0; index < 80 * 25; ++index) vga[index] = 0x0720;
    cursor = 0;
}

static void putc(char character) {
    if (character == '\n') {
        cursor = (uint16_t)(((cursor / 80) + 1) * 80);
        return;
    }
    vga[cursor++] = (uint16_t)(0x0f00u | (uint8_t)character);
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
    if (scan_code >= 2 && scan_code <= 53) return keymap[scan_code - 1];
    if (scan_code == 57) return ' ';
    return 0;
}

static char read_key(void) {
    for (;;) {
        uint8_t scan_code;
        if (!(inb(0x64) & 1)) continue;
        scan_code = inb(0x60);
        if (scan_code & 0x80) continue;
        if (scan_code == 28) return '\n';
        if (scan_code == 14) return '\b';
        return key_to_ascii(scan_code);
    }
}

static void read_line(char *buffer, uint32_t capacity, int secret) {
    uint32_t length = 0;
    for (;;) {
        char key = read_key();
        if (key == '\n') {
            putc('\n');
            buffer[length] = 0;
            return;
        }
        if (key == '\b') {
            if (length > 0) {
                --length;
                if (cursor > 0) --cursor;
                vga[cursor] = 0x0720;
            }
            continue;
        }
        if (key && length + 1 < capacity) {
            buffer[length++] = key;
            putc(secret ? '*' : key);
        }
    }
}

static void hello_program(void) {
    clear_screen();
    puts("NBU EXEC PROGRAM\n\n");
    puts("Program: /system/hello\n");
    puts("ABI: NBU-EXEC-1\n");
    puts("This program is owned by NBU-OS and is not a Linux process.\n\n");
    puts("Press ENTER to return to the desktop.");
    while (read_key() != '\n') { }
}

static const nbu_program_t program_table[] = {
    { "/system/hello", hello_program },
};

static int nbu_exec(const char *path) {
    for (uint32_t index = 0; index < sizeof(program_table) / sizeof(program_table[0]); ++index) {
        if (text_equal(path, program_table[index].path)) {
            program_table[index].entry();
            return 0;
        }
    }
    return -1;
}

static void installer(void) {
    clear_screen();
    puts("NBU-OS INSTALLER\n");
    puts("NBU-EXEC-1 private kernel edition\n\n");
    puts("Create the first local account.\n");
    puts("Username: ");
    read_line(installed_user, sizeof(installed_user), 0);
    char password[32];
    puts("Password: ");
    read_line(password, sizeof(password), 1);
    nbu_password_hash(password, installed_password_hash);
    for (uint32_t index = 0; index < sizeof(password); ++index) password[index] = 0;
    puts("\nInstalling NBU-OS core... OK\n");
    puts("Registering private program ABI... OK\n");
    puts("Installation complete. Press ENTER to continue.");
    while (read_key() != '\n') { }
}

static int login(void) {
    char username[32];
    char password[32];
    uint8_t password_hash[32];
    clear_screen();
    puts("NBU-OS LOGIN\n\n");
    puts("User: ");
    read_line(username, sizeof(username), 0);
    puts("Password: ");
    read_line(password, sizeof(password), 1);
    nbu_password_hash(password, password_hash);
    for (uint32_t index = 0; index < sizeof(password); ++index) password[index] = 0;
    if (text_equal(username, installed_user) && nbu_secure_equal(password_hash, installed_password_hash, sizeof(password_hash))) return 1;
    puts("\nLogin failed. Press ENTER to retry.");
    while (read_key() != '\n') { }
    return 0;
}

static void desktop_banner(void) {
    clear_screen();
    puts("+------------------------------------------------------------------------------+\n");
    puts("| NBU-OS DESKTOP                 Yusuf Alhazmi                 [ONLINE]       |\n");
    puts("+------------------------------------------------------------------------------+\n\n");
    puts("  Private kernel terminal | Type help for commands.\n\n");
    puts("  Northern Borders University\n");
    puts("  General Administration of Digital Transformation\n\n");
    puts("  Private kernel ready. NBU-EXEC-1 program ABI active.\n");
}

static void desktop(void) {
    char command[64];
    desktop_banner();
    for (;;) {
        puts("\nnbu> ");
        read_line(command, sizeof(command), 0);
        if (text_equal(command, "help")) {
            puts("Commands: help, exec /system/hello, clear, shutdown\n");
        } else if (text_equal(command, "exec /system/hello")) {
            if (nbu_exec("/system/hello") != 0) puts("exec: program not found\n");
        } else if (text_equal(command, "clear")) {
            desktop_banner();
        } else if (text_equal(command, "shutdown")) {
            clear_screen();
            puts("NBU-OS is safe to power off.\n");
            for (;;) __asm__ volatile ("hlt");
        } else if (command[0] != 0) {
            puts("nbu: unknown command. Type help.\n");
        }
    }
}

void kernel_main(uint32_t multiboot_magic, uint32_t multiboot_info) {
    (void)multiboot_info;
    if (multiboot_magic != 0x36d76289) {
        clear_screen();
        puts("NBU-OS: invalid Multiboot2 magic.\n");
        for (;;) __asm__ volatile ("hlt");
    }
    clear_screen();
    puts(NBU_SYSTEM_NAME " | " NBU_DEVELOPER "\n");
    puts("Private kernel | " NBU_EXEC_ABI "\n");
    puts("Press ENTER to start the installer.\n");
    while (read_key() != '\n') { }
    installer();
    while (!login()) { }
    desktop();
}
