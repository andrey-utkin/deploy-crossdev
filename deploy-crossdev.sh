#!/bin/bash
set -e
MYDIR="$(dirname $0)"
EO="-vq"

# deploy config files
cp -av "$MYDIR"/files/* /

emerge $EO --update crossdev
crossdev -t aarch64-my-linux-gnu
#crossdev -t x86_64-my-linux-gnu
#crossdev -t i686-my-linux-gnu

# for cross-chroot to work
emerge $EO --update qemu
rc-update add qemu-binfmt
rc-service qemu-binfmt start
cp /usr/bin/qemu-aarch64 /usr/aarch64-my-linux-gnu/usr/bin
#cp /usr/bin/qemu-x86_64 /usr/x86_64-my-linux-gnu/usr/bin
#cp /usr/bin/qemu-i386 /usr/i686-my-linux-gnu/usr/bin

# already doing sth useful!
#aarch64-my-linux-gnu-emerge $EO --update sys-devel/gdb
#x86_64-my-linux-gnu-emerge $EO --update sys-devel/gdb
#i686-my-linux-gnu-emerge $EO --update sys-devel/gdb

# workaround: building native gcc fails due to missing sys/sdt.h
aarch64-my-linux-gnu-emerge $EO --update dev-util/systemtap

# setting up full-fledged system for ultimate fun
aarch64-my-linux-gnu-emerge $EO \
	--update --deep --changed-use --keep-going @system || true
aarch64-my-linux-gnu-emerge $EO \
	--update --oneshot --keep-going \
	$(grep -E '^[a-z]+' /usr/portage/profiles/default/linux/packages.build) || true

/usr/local/bin/chroot-crossdev /usr/aarch64-my-linux-gnu locale-gen

/usr/local/bin/chroot-crossdev /usr/aarch64-my-linux-gnu emerge-chroot \
	$EO --update --deep --changed-use --keep-going @system || true
/usr/local/bin/chroot-crossdev /usr/aarch64-my-linux-gnu emerge-chroot \
	$EO --update --oneshot --keep-going \
	$(grep -E '^[a-z]+' /usr/portage/profiles/default/linux/packages.build) || true
