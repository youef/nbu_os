# NBU-OS installation and first boot

Install the build dependencies:

```sh
sudo apt-get update
sudo apt-get install -y build-essential binutils grub-pc-bin grub-common xorriso qemu-system-x86
```

Build the ISO with ./scripts/build.sh, then attach dist/NBU-OS.iso to a new UTM x86_64 VM. On iPhone/iPad choose Emulate, assign at least 512 MB RAM, attach the ISO, and boot.

Press Enter at the installer screen, create the first username and password, then log in. The prototype desktop appears after successful login. The account is currently kept in memory for the current boot; persistent storage and password hashing are planned for a later filesystem phase.

The GitHub Actions workflow builds the ISO and uploads it as an artifact on every push.
