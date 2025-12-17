# Setup tftpd

在调试嵌入式设备时经常需要通过 U-Boot 加载内核，而通过网络 TFTP 的方式是比较快速的。
下文讲述如何搭建 TFTP 服务。

## Ubuntu or Debian

1. Install TFTP server

   ```bash
   sudo apt update
   sudo apt install tftpd-hpa
   ```

2. Configure TFTP server

   tftp 服务的配置文件一般为 /etc/default/tftpd-hpa，配置参数都是自明的。

   ```
   TFTP_USERNAME="tftp"
   TFTP_DIRECTORY="/srv/tftp"
   TFTP_ADDRESS="0.0.0.0:69"
   TFTP_OPTIONS="--secure"
   ```

3. Create tftp directory

   ```bash
   sudo mkdir /srv/tftp
   sudo chmod -R nobody:nogroup /srv/tftp
   sudo chmod -R 777 /srv/tftp

   sudo systemctl restart tftpd-hpa
   ```

4. Test the tftp server

   安装客户端 tftp-hpa，并连接服务。

   ```bash
   sudo apt install tftp-hpa

   tftp 192.168.1.100
   ```

   查看 tftp 状态以及获取与存放文件。

   ```
   tftp> status
   tftp> get file.name
   tftp> put file.name
   ```

## Arch Linux

与上述步骤类似，只是包管理工具换成 pacman 或 yay。
另外，服务端的报名为 tftp-hpa。
