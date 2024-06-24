#/bin/bash
#
# cp file and diff file 
#
cd /mnt/data
rm -rf dd.img
cp /mnt/data/test/yolo.tar.gz /mnt/data/
diff -s yolo.tar.gz /mnt/data/test/yolo.tar.gz  >> yolo_diff.txt
rm -rf /mnt/data/yolo.tar.gz 
dd if=/dev/zero of=dd.img bs=1048576 count=2000 conv=fsync
sync
