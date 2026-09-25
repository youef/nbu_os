# NBU-OS security

The current credential path stores only a SHA-256 digest in memory and clears the temporary password buffer after hashing. Credentials are not persistent yet.

Before production use, add a salted password KDF, encrypted persistent account storage, lockout policy, secure boot, audit logging, and recovery-key handling.
