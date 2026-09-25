#ifndef NBU_SECURITY_H
#define NBU_SECURITY_H

#include <stdint.h>

void nbu_password_hash(const char *password, uint8_t digest[32]);
int nbu_secure_equal(const uint8_t *left, const uint8_t *right, uint32_t length);

#endif
