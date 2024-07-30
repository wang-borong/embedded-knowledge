# Mount samba in linux

## 挂载步骤

1. 创建 credentials 文件

   ```
   username=target-user
   password=target-user-password
   domain=domain
   ```

2. 挂载 Samba

   ```
   sudo mount -t cifs -o credentials=/your/credentials //192.168.4.100/share tmp
   ```
