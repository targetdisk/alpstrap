# Alpstrap
These are my scripts for bringing up an Alpine system!

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

## USING

### TL;DR, where's the cheat sheet?
Set your `PLATFORM`, `ARCH`, and `BLKDEV` to bootstrap to:
```bash
export PLATFORM=raspi ARCH=aarch64 BLKDEV=/dev/sdb
```

> <h3>Note</h3>
>
> I like to use the `lsblk` command when locating a `BLKDEV`.

If your system has `doas` instead of `sudo`, be sure to also `export`
an appropriate `DOSU` environment variable for `make` to use:
```bash
export DOSU=doas
```

Format your `BLKDEV`:
```bash
make format
```

Then, install to the `BLKDEV` of your choosing:
```bash
make install
```

### Bootstrapping the base Alpine system
The Alpstrap system first bootstraps the base Alpine system to a `DESTROOT`
directory (an automatically-created `destroot` directory in this repository's
root) for maximum speed.

The system supports bootstrapping to
[any architecture supported by Alpine](https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/)
and will support *even more* in the future once rebuilding the Alpine ports tree
is automated!  All you have to do is specify your desired `PLATFORM` and `ARCH`
on the GNU `make` command line as environment variables.  The currently
supported `PLATFORM`s are `uefi` (default) and `raspi`.

If you want only to bootstrap, there's a `make` target for that:
```bash
make bootstrap
```

## TODO
- [ ] Add bootloader installation on UEFI (starting with GRUB)
- [ ] Automate cross-compiling ports tree on non-Alpine hosts with only Git
      submodules.
- [ ] Add Bcachefs support
- [ ] Make self-hosted installer
- [ ] Add PXE-netbooted installer and ad-hoc TFTP server
- [ ] Finish raspi `/boot` partition.
- [ ] Share helper scripts with upstream Alpine??

## SEE ALSO
* Alpine's [wiki page on bootstrapping](https://wiki.alpinelinux.org/wiki/Bootstrapping_Alpine_Linux)
* Alpine's [wiki page on bootloaders](https://wiki.alpinelinux.org/wiki/Bootloaders)
