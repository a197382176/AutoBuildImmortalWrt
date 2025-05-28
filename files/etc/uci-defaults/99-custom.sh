#!/bin/sh
# 99-custom.sh — immortalwrt 首次启动时运行
env >> /tmp/uci-defaults-env.log
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE

# 1. 默认防火墙放行规则
uci set firewall.@zone[1].input='ACCEPT'
\ n# 2. 主机名映射（解决 Android TV 联网问题）
uci add dhcp domain
uci set "dhcp.@domain[-1].name=time.android.com"
uci set "dhcp.@domain[-1].ip=203.107.6.88"

# 3. 原有 PPPoE 设置（如果有 /etc/config/pppoe-settings）
SETTINGS_FILE="/etc/config/pppoe-settings"
if [ -f "$SETTINGS_FILE" ]; then
    . "$SETTINGS_FILE"
    echo "Loaded PPPoE settings." >> $LOGFILE
else
    echo "PPPoE settings file not found; skipping." >> $LOGFILE
fi

# 4. 网络接口：固定将 eth0 + wlan0 设为 LAN 桥接
echo "Configuring LAN bridge on eth0 & wlan0" >> $LOGFILE
uci set network.lan=interface
uci set network.lan.ifname='eth0 wlan0'
uci set network.lan.type='bridge'
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.100.1'
uci set network.lan.netmask='255.255.255.0'

# 5. DHCP Server 只在 LAN 上开启
echo "Configuring DHCP on LAN" >> $LOGFILE
uci set dhcp.lan=dhcp
uci set dhcp.lan.interface='lan'
uci set dhcp.lan.start='100'
uci set dhcp.lan.limit='150'
uci set dhcp.lan.leasetime='12h'

# 6. 保留原始 WAN 接口设定（不在此脚本内改动 USB Wi-Fi）
echo "Skipping WAN configuration; will be set later via GUI" >> $LOGFILE

# 7. 配置 AP：将 wlan0 设为开放 SSID pi-openwrt
echo "Configuring wlan0 as open AP with SSID 'pi-openwrt'" >> $LOGFILE

# 确保 radio0 (即 wlan0) 已启用
uci set wireless.radio0.disabled='0'

# 修改第一条 wifi-iface 为 AP 模式
uci set wireless.@wifi-iface[0].device='radio0'
uci set wireless.@wifi-iface[0].mode='ap'
uci set wireless.@wifi-iface[0].ssid='pi-openwrt'
uci set wireless.@wifi-iface[0].encryption='none'
uci set wireless.@wifi-iface[0].network='lan'

# 提交并重载 Wi-Fi
uci commit wireless
wifi reload

# 8. 允许所有接口上的 LuCI ttyd 与 Dropbear SSH
uci delete ttyd.@ttyd[0].interface
uci set dropbear.@dropbear[0].Interface=''

# 9. 编译信息标记
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Compiled by wukongdaily"
sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH"

# 10. 提交所有 UCI 更改
uci commit network\ nuci commit dhcp
uci commit firewall
uci commit dropbear

echo "99-custom.sh completed at $(date)" >> $LOGFILE
exit 0
