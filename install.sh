#!/bin/sh

SERVICE_NAME="wifi-fix.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
IFACE="wlan0"

install_service() {
    echo ">> Installing systemd service (WiFi stability fix)"

    cat << EOF > $SERVICE_PATH
[Unit]
Description=WiFi stability fix (disable power save, MTU 1400)
After=network-pre.target
Before=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/iw dev $IFACE set power_save off
ExecStart=/sbin/ip link set $IFACE mtu 1400
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable $SERVICE_NAME
    systemctl start $SERVICE_NAME

    echo ">> Service installed and started"
}

uninstall_service() {
    echo ">> Removing systemd service"

    systemctl stop $SERVICE_NAME 2>/dev/null
    systemctl disable $SERVICE_NAME 2>/dev/null
    sudo rm -f $SERVICE_PATH
    systemctl daemon-reload

    /usr/sbin/iw dev $IFACE set power_save on
    /sbin/ip link set $IFACE mtu 1500

    echo ">> Service removed, default settings restored"
}

readme() {
echo ""
}

while true; do
    echo ""
    echo "====== WiFi FIX (Ubuntu Touch) ======"
    echo "1) install   (enable fix at boot)"
    echo "3) uninstall (remove systemd service)"
    echo "9) exit"
    echo "===================================="
    printf "Select option: "
    read choice

    case "$choice" in
        1|install)
            install_service
            ;;
        3|uninstall)
            uninstall_service
            ;;
         7|readme)
            readme
            ;;
        9|exit)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid option!"
            ;;
    esac
done
