# Mount image file in linux

## Mounting steps

1. 查看 image 文件的分区信息（可选）

   ```bash
   fdisk -l image.file
   ```

2. 使用 losetup 命令映射分区到 loop 设备文件中

   ```bash
   sudo losetup -f -P image.file
   ```

3. 使用 lsblk 查看已映射的 loop block

   ```bash
   sudo lsblk
   ```

4. 挂在分区

   ```bash
   sudo mount -o iocharset=utf8 /dev/loop0p1 mnt
   ```

   注意，挂载分区后可能出现文件名乱码的情况。
   所以挂载命令中添加了 -o iocharset=utf8 指定编码为 UTF-8。

5. 卸载已挂载的分区，并解除 loop 设备映射。

   ```bash
   sudo umount /mnt
   sudo losetup -d /dev/loop0
   ```
