bin = 88tris
img = 88tris.img

$(img): $(bin)
	dd if=/dev/zero of=$@ bs=512 count=720
	dd if=$< of=$@ bs=512 conv=notrunc

$(bin): src/main.asm
	nasm -o $@ -f bin $<

.PHONY: clean
clean:
	rm -f $(bin) $(img)

.PHONY: run
run: $(img)
	qemu-system-i386 -fda $<

.PHONY: debug
debug: $(img)
	qemu-system-i386 -S -s -fda $<

.PHONY: disasm
disasm: $(bin)
	ndisasm -o 0x7c00 $< >dis
