#!/usr/bin/env bash
set -Eeuo pipefail

find -not -name '*.tcz' \
	| cpio --create --format newc --dot \
	| xz -9 --format=lzma --verbose --verbose --threads=0 --extreme \
	> /tmp/iso/boot/initrd.img

# volume label (https://github.com/boot2docker/boot2docker/issues/1347)
volumeLabel="b2d-v$DOCKER_VERSION"

xorriso \
	-as mkisofs -o /tmp/boot2docker.iso \
	-A 'Boot2Docker' \
	-V "$volumeLabel" \
	-isohybrid-mbr /tmp/isohdpfx.bin \
	-b isolinux/isolinux.bin \
	-c isolinux/boot.cat \
	-no-emul-boot \
	-boot-load-size 4 \
	-boot-info-table \
	/tmp/iso

mkdir -p /tmp/stats
(
	cd /tmp
	echo '```console'
	for cmd in sha512sum sha256sum sha1sum md5sum; do
		echo "\$ $cmd boot2docker.iso"
		"$cmd" boot2docker.iso
	done
	echo '```'
) | tee /tmp/stats/sums.md
{
	echo "- Docker [v$DOCKER_VERSION](https://github.com/docker/docker-ce/releases/tag/v$DOCKER_VERSION)"

	echo "- Linux [v$LINUX_VERSION](https://cdn.kernel.org/pub/linux/kernel/v4.x/ChangeLog-$LINUX_VERSION)"

	echo "- Tiny Core Linux [v$TCL_VERSION](http://forum.tinycorelinux.net/index.php?board=31.0)"
} | tee /tmp/stats/state.md
