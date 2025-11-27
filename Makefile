ISO = archlinux.iso
IMG = archlinux.qcow2
FMT = qcow2

MEM = 8192
CPU = 8


$(IMG): $(ISO)
	qemu-img create -f $(FMT) -o compat=1.1 $(IMG) 20G

.PHONY: clean boot dev

clean:
	rm -fv $(IMG)

boot: $(IMG)
	qemu-system-x86_64 \
		-m $(MEM) \
		-smp $(CPU) \
		-drive file="$(IMG)",format=$(FMT),if=none,id=drive0 \
		-device virtio-blk-pci,drive=drive0,bootindex=1 \
		-drive file="$(ISO)",media=cdrom,if=none,format=raw,id=cdrom0 \
		-device ide-cd,drive=cdrom0,bootindex=2 \
		-netdev user,id=net0,hostfwd=tcp::2222-:22 \
		-device virtio-net-pci,netdev=net0 \
		-boot menu=on

dev: $(IMG)
	python3 -m http.server


