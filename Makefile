src = src/main.asm src/game.asm src/disp.asm

bin = 88tris
img = 88tris.img
com = 88tris.com

AS = nasm
ASFLAGS = -f bin

$(img): $(bin)
	dd if=/dev/zero of=$@ bs=512 count=720
	dd if=$< of=$@ bs=512 conv=notrunc

$(bin): $(src)
	$(AS) $(ASFLAGS) -o $@ $<

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
