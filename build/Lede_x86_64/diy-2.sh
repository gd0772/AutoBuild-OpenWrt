#!/bin/bash
# https://github.com/gd0772/AutoBuild-OpenWrt
# common Module by gd0772

ZZZ="package/lean/default-settings/files/zzz-default-settings"

sed -i "/uci commit fstab/a\uci commit network" $ZZZ
sed -i "/uci commit network/i\uci set network.lan.ipaddr='192.168.123.2'" $ZZZ                    # IPv4 地址(openwrt后台地址)
sed -i "/uci commit network/i\uci set network.lan.netmask='255.255.255.0'" $ZZZ                   # IPv4 子网掩码
sed -i "/uci commit network/i\uci set network.lan.gateway='192.168.123.1'" $ZZZ                   # IPv4 网关
sed -i "/uci commit network/i\uci set network.lan.broadcast='192.168.123.255'" $ZZZ               # IPv4 广播
sed -i "/uci commit network/i\uci set network.lan.dns='192.168.123.1'" $ZZZ                       # DNS(多个DNS要用空格分开)
#sed -i "/uci commit network/i\uci set network.lan.delegate='0'" $ZZZ                             # 去掉LAN口使用内置的 IPv6 管理
#echo "close_dhcp" > package/base-files/files/etc/closedhcp                                       # 关闭DHCP服务
sed -i "s/R21.4.18/R21.4.18 $(TZ=UTC-8 date "+%Y.%m.%d") Build by gd772/g" $ZZZ                   #
#sed -i "/uci commit system/i\uci set system.@system[0].hostname='N1'" $ZZZ                       # 修改主机名称为N1

# echo '替换系统文件'
curl -fsSL https://raw.githubusercontent.com/gd0772/patch/main/index.htm > ./package/lean/autocore/files/x86/index.htm
