# Floppy Image
echo -n "Assembling FAT Bootloader..." 
nasm bootf.asm && echo " [Done]"

echo -n "Assembling Second Stage..." 
nasm stage2.asm && echo " [Done]" 

dd if=/dev/zero of=./fd.img bs=512 count=2880
dd if=./bootf of=./fd.img bs=512 count=1 conv=notrunc
dd if=./stage2 of=./fd.img bs=512 count=1 conv=notrunc seek=1

# Hd Image
echo -n "Assembling Ibox MBR"
nasm mbr.asm && echo " [Done]"  

echo -n "Assembling IBOX VBR"
nasm vbr.asm && echo " [Done]"

dd if=/dev/zero of=./hd.img bs=516096c count=1000
#(echo g; echo n; echo p; echo 1; echo ; echo; echo t; echo 0c; echo a; echo p; echo w) | fdisk -u -C1000 -S63 -H16 ./hd.img
(echo o; echo n; echo p; echo 1; echo ; echo; echo t; echo 0c; echo a; echo p; echo w) | fdisk -u -C1000 -S63 -H16 ./hd.img
dd if=./mbr of=./hd.img bs=446 count=1 conv=notrunc
#dd if=./vbr of=./hd.img bs=512 count=1 conv=notrunc seek=1

sudo losetup -o1048576 /dev/loop0 ./hd.img
sudo mkfs.vfat -F 32 /dev/loop0
sudo dd if=./vbr of=/dev/loop0 bs=1 count=3 conv=notrunc
sudo dd if=./vbr of=/dev/loop0 bs=1 skip=90 seek=90 count=934 conv=notrunc
sudo losetup -d /dev/loop0
