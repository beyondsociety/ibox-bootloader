echo "Building IBOX Bootloader"
echo 

cd bios
sh ./run.sh

echo
echo "Runing IBOX Bootloader"
qemu-system-x86_64 -m 512 -vga std -hda ./hd.img
