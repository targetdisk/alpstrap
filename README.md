# Alpstrap
These are my scripts for brining up an Alpine system!

## DEPENDENCIES
- A sane shell like GNU Bash
- BusyBox (for `ash`)
- GNU `make`
- GNU `install` (from coreutils)
- M4
- GNU Autoconf
- `qemu-user-static` and its `binfmt` rules (for cross-chrooting)

You may need to install some Lua dependencies for building `apk`.  If you feel
you've already installed them and it's still failing, double-check the Lua
version that `apk`'s build requires!

## SEE ALSO
* Alpine's [wiki page on bootstrapping](https://wiki.alpinelinux.org/wiki/Bootstrapping_Alpine_Linux)
