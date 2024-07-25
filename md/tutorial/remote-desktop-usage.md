# How to use remote desktop between windows and linux

1. install xrdp and xorgxrdp

   xrdp only supports Xvnc as the backend.
   **If you want to use xorg, install xorgxrdp.**

2. configure /etc/xrdp/xrdp.ini optionally.

3. configure /etc/xrdp/sesman.ini for Xorg and Xvnc backends.

4. copy ~/.xinitrc to ~/.xrdpinitrc and modify /etc/xrdp/startwm.sh to use it.

   modify ~/.xrdpinitrc to remove `--exit-with-session`.

   ```
   get_session(){
   	 local dbus_args=(--sh-syntax)
   ```

   and

   ```
   xrdb ~/.Xresources-xrdp
   exec $(get_session "$1")
   ```

   where ~/.Xresources-xrdp contains one line:

   ```
   Xcursor.core:1
   ```

   modify startwm.sh as:

   ```
   # arch user
   if [ -r ~/.xrdpinitrc ]; then
     pre_start
     . ~/.xrdpinitrc xfce
     post_start
     exit 0
   fi
   ```

5. configure non-root user in /etc/X11/Xwrapper.config.

   ```
   allowed_users=anybody
   needs_root_rights=no
   ```

6. open tcp port 3389 in the firewall

   For example when using firewalld,

   ```bash
   sudo firewall-cmd --permanent --add-port=3389/tcp
   sudo firewall-cmd --reload
   ```

7. start session

   ```bash
   sudo systemctl start xrdp xrdp-sesman
   ```
