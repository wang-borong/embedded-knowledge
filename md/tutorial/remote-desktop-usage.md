# How to use remote desktop between windows and linux

## install and configure

1. install xrdp and xorgxrdp

   xrdp only supports Xvnc as the backend.
   **If you want to use xorg, install xorgxrdp.**

2. configure /etc/xrdp/xrdp.ini optionally.

3. configure /etc/xrdp/sesman.ini for Xorg and Xvnc backends optionally.

4. copy ~/.xinitrc to ~/.xrdpinitrc and modify /etc/xrdp/startwm.sh to use it.

   modify ~/.xrdpinitrc to remove `--exit-with-session`.

   ```
   get_session(){
   	 local dbus_args=(--sh-syntax)
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

5. configure non-root user in /etc/X11/Xwrapper.config (optional).

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

## xrdpinitrc example

```bash
#!/bin/bash
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

SESSION=${1:-xfce}

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

get_session(){
	local dbus_args=(--sh-syntax)
	case "$SESSION" in
		awesome) dbus_args+=(awesome) ;;
		bspwm) dbus_args+=(bspwm-session) ;;
		budgie) dbus_args+=(budgie-desktop) ;;
		cinnamon) dbus_args+=(cinnamon-session) ;;
		deepin) dbus_args+=(startdde) ;;
		enlightenment) dbus_args+=(enlightenment_start) ;;
		fluxbox) dbus_args+=(startfluxbox) ;;
		gnome) dbus_args+=(gnome-session) ;;
		i3|i3wm) dbus_args+=(i3 --shmlog-size 0) ;;
		jwm) dbus_args+=(jwm) ;;
		kde) dbus_args+=(startkde) ;;
		lxde) dbus_args+=(startlxde) ;;
		lxqt) dbus_args+=(lxqt-session) ;;
		mate) dbus_args+=(mate-session) ;;
		xfce) dbus_args+=(xfce4-session) ;;
		openbox) dbus_args+=(openbox-session) ;;
		*) dbus_args+=("$SESSION") ;;
	esac

	echo "dbus-launch ${dbus_args[*]}"
}

exec $(get_session)
```

## Tips

1. change $HOME/thinclient_drives to $HOME/.thinclient_drives.

   change /etc/xrdp/sesman.ini as:

   ```ini
   [Chansrv]
   ; drive redirection
   ; See sesman.ini(5) for the format of this parameter
   #FuseMountName=/run/user/%u/thinclient_drives
   #FuseMountName=/media/thinclient_drives/%U/thinclient_drives
   #FuseMountName=thinclient_drives
   FuseMountName=.thinclient_drives
   ```
