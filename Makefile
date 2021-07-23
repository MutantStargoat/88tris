# -- options --------------
# select bootable image type: 360 for 5.25" DD (360KB), 1440 for 3.5" HD (1.44MB)
# DOS build is not affected by this setting
disktype = 360
# disktype = 1440
# -------------------------

ifeq ($(disktype), 360)
	def = -DFLOPPY360
	nsec = 720
else
	def = -DFLOPPY1440
	nsec = 2880
endif

src = src/main.asm src/game.asm src/disp.asm src/timer.asm src/intr.asm src/keyb.asm

bin = 88tris
img = 88tris.img
com = 88tris.com

AS = nasm
ASFLAGS = -f bin

$(img): $(bin)
	dd if=/dev/zero of=$@ bs=512 count=$(nsec)
	dd if=$< of=$@ bs=512 conv=notrunc

$(bin): $(src)
	$(AS) $(ASFLAGS) $(def) -o $@ $<

$(com): $(src)
	$(AS) $(ASFLAGS) -DDOS -o $@ $<

.PHONY: dos
dos: $(com)

.PHONY: clean
clean:
	rm -f $(bin) $(img) $(com)

.PHONY: run
run: $(img)
	qemu-system-i386 -fda $<

.PHONY: rundos
rundos: $(com)
	dosbox $(com)

.PHONY: debug
debug: $(img)
	qemu-system-i386 -S -s -fda $<

.PHONY: disasm
disasm: $(bin)
	ndisasm -o 0x7c00 $< >dis
