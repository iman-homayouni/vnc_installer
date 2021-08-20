#! /bin/bash
# Programming and idea by : Iman Homayouni
# Gitbub : https://github.com/iman-homayouni
# Email : homayouni.iman@Gmail.com
# Website : http://www.homayouni.info
# License : GPL v2.0
# Last update : Fri, 20 Aug 2021 12:20:48 +0430
# vnc.installer v1.0.2
# ------------------------------------------------------------------------------------------------------- #
# SUCCESSFULLY TESTED IN UBUNTU 18.04 [BIONIC]   [XFCE and Mate Desktop]
# SUCCESSFULLY TESTED IN UBUNTU 20.04 [FOCAL]    [Only XFCE Desktop]
# SUCCESSFULLY TESTED IN DEBIAN 10.X  [BUSTER]   [XFCE and Mate Desktop]
# ------------------------------------------------------------------------------------------------------- #


# CHECK USER PRIVILEGE # -------------------------------------------------------------------------------- #
if [ "$UID" != "0" ] ; then
    echo "[!] USE ROOT USER"
    exit 1
fi
# ------------------------------------------------------------------------------------------------------- #


# UPDATE AND UPGRADE SYSTEM # --------------------------------------------------------------------------- #
apt-get -y update
apt-get -y dist-upgrade
apt -y autoremove
apt-get -y -f install
# ------------------------------------------------------------------------------------------------------- #


# SELECT DESKTOP ENVIRONMENT # -------------------------------------------------------------------------- #
echo -e  "[>] --------------------------------------------------------------------------------- [<]"
echo -e  "[1] INSTALL MATE DESKTOP"
echo -e  "[2] INSTALL XFCE DESKTOP"
echo -en "[?] WHICH ONE ? [1/2] : " ; read q

if [ "$q" = "1" ] ; then
    which lsb_release &> /dev/null
    if [ "$?" = "0" ] ; then
        if [ "$(lsb_release -cs)" = "focal" ] ; then
            echo -e "[>] CAN NOT INSTALL MATE DESKTOP ON FOCAL"
            exit 1
        fi
    fi
    echo -e "[>] --------------------------------------------------------------------------------- [<]"
    apt-get install -y mate-desktop-environment-extra
elif [ "$q" = "2" ] ; then
    echo -e "[>] --------------------------------------------------------------------------------- [<]"
    apt-get install -y xfce4 xfce4-goodies
    apt-get install -y xfonts-base
else
    echo -e "[>] BAD OPTION"
    echo -e "[>] --------------------------------------------------------------------------------- [<]"
    exit 1
fi
# ------------------------------------------------------------------------------------------------------- #


# INSTALL NECESSARY PACKAGES # -------------------------------------------------------------------------- #
apt-get install -y net-tools
apt-get install -y tightvncserver
apt-get install -y firefox
apt-get install -y firefox-esr
apt-get install -y terminator
apt-get install -y tigervnc-standalone-server
apt-get install -y libxss1
# ------------------------------------------------------------------------------------------------------- #


# CREATE VNC DIRECTORY # -------------------------------------------------------------------------------- #
mkdir ~/.vnc/ &> /dev/null
# ------------------------------------------------------------------------------------------------------- #


# CREATE xstartup FILE # -------------------------------------------------------------------------------- #
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak &> /dev/null

if [ "$q" = "1" ] ; then

    echo '#!/bin/bash'                                            > ~/.vnc/xstartup
    echo -e 'unset DBUS_SESSION_BUS_ADDRESS'                     >> ~/.vnc/xstartup
    echo -e '[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup' >> ~/.vnc/xstartup
    echo -e '[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources' >> ~/.vnc/xstartup
    echo -e 'xsetroot -solid grey'                               >> ~/.vnc/xstartup
    echo -e 'vncconfig -iconic &'                                >> ~/.vnc/xstartup
    echo -e 'x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &' \
    >> ~/.vnc/xstartup
    echo -e 'x-window-manager &'                                 >> ~/.vnc/xstartup
    echo -e 'mate-session &'                                     >> ~/.vnc/xstartup

elif [ "$q" = "2" ] ; then

    echo '#!/bin/bash'                                            > ~/.vnc/xstartup
    echo 'PATH=/usr/bin:/usr/sbin'                               >> ~/.vnc/xstartup
    echo 'unset SESSION_MANAGER'                                 >> ~/.vnc/xstartup
    echo 'unset DBUS_SESSION_BUS_ADDRESS'                        >> ~/.vnc/xstartup
    echo 'xrdb $HOME/.Xresources'                                >> ~/.vnc/xstartup
    echo 'startxfce4 &'                                          >> ~/.vnc/xstartup

fi
# ------------------------------------------------------------------------------------------------------- #


# SET EXECUTE PERMISSIONS FOR ~/.vnc/xstartup # --------------------------------------------------------- #
chmod +x ~/.vnc/xstartup
# ------------------------------------------------------------------------------------------------------- #


# RUN vncserver COMMAND # ------------------------------------------------------------------------------- #
for (( ;; )) ; do
    vncserver
    if [ "$?" = "0" ] ; then
        break
    fi
done
# ------------------------------------------------------------------------------------------------------- #


# CLOSE OTHER VNC SESSIONS # ---------------------------------------------------------------------------- #
for (( i=1 ; i <= 10 ; i++ )) ; do
    vncserver -kill :$i &> /dev/null
done
# ------------------------------------------------------------------------------------------------------- #


# CREATE vnc.kill SCRIPT # ------------------------------------------------------------------------------ #
echo 'for (( i=1 ; i <= 10 ; i++ )) ; do'    > /root/vnc.kill
echo '    vncserver -kill :$i &> /dev/null' >> /root/vnc.kill
echo 'done' >> /root/vnc.kill
# ------------------------------------------------------------------------------------------------------- #


# CHANGE vnc.kill SCRIPT PERMISSIONS # ------------------------------------------------------------------ #
chmod +x /root/vnc.kill
# ------------------------------------------------------------------------------------------------------- #


# CREATE vnc.start FILE # ------------------------------------------------------------------------------- #
echo '/usr/bin/vncserver -localhost -depth 24 -geometry 1250x750' > /root/vnc.start
chmod +x /root/vnc.start
# ------------------------------------------------------------------------------------------------------- #


# CLEANUP SHELL # --------------------------------------------------------------------------------------- #
clear
# ------------------------------------------------------------------------------------------------------- #


# CREATE BACKUP FROM motd FILE # ------------------------------------------------------------------------ #
mv /etc/motd /etc/motd.backup &> /dev/null
# ------------------------------------------------------------------------------------------------------- #


# CREATE /etc/motd FILE # ------------------------------------------------------------------------------- #
cat << EOF > /etc/motd
[>] --------------------------------------------------------------------------------- [<]
[>] To start vnc server : bash /root/vnc.start
[>] To stop vnc server  : bash /root/vnc.kille
[>] VNC server run in localhost:5901
[>] Connect to server using ssh tunnel
EOF
# ------------------------------------------------------------------------------------------------------- #


# CREATE /etc/motd FILE # ------------------------------------------------------------------------------- #
for ip in $(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p') ; do
    echo -e "[>] ssh -L 5901:localhost:5901 root@$ip" >> /etc/motd
done
# ------------------------------------------------------------------------------------------------------- #


# CREATE /etc/motd FILE # ------------------------------------------------------------------------------- #
cat << EOF >> /etc/motd
[>] Open remmina in your client [laptop or pc] and connect to localhost:5901
[>] --------------------------------------------------------------------------------- [<]
EOF
# ------------------------------------------------------------------------------------------------------- #


# PRINT MSG TO TERMINAL # ------------------------------------------------------------------------------- #
echo -en "\e[92m"
cat /etc/motd
echo -en "\e[0m"
# ------------------------------------------------------------------------------------------------------- #


# CLEANUP APT CACHE # ----------------------------------------------------------------------------------- #
apt-get -y clean
# ------------------------------------------------------------------------------------------------------- #


# DISABLE GDM3 OR LIGHTDM # ----------------------------------------------------------------------------- #
systemctl set-default multi-user.target
# ------------------------------------------------------------------------------------------------------- #
