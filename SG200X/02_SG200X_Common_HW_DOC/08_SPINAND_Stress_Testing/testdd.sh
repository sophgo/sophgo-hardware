#!/bin/bash
i=1;
while [ $i != 5001 ]
do
#     report "time dd if=$BENCHMARK_DD_BLOCK_DEVICE of=/dev/null bs=2048 count=1"
dd if=/dev/zero of=dd.img bs=2048 count=1
sync; echo 3 > /proc/sys/vm/drop_caches
dd if=dd.img of=/dev/null bs=2048
echo i=$i
   i=$(($i+1))
done
