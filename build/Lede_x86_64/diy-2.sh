#!/bin/bash
# https://github.com/gd0772/AutoBuild-OpenWrt
# common Module by gd0772

ZZZ="package/lean/default-settings/files/zzz-default-settings"

sed -i "s/R21.4.18/R21.4.18 $(TZ=UTC-8 date "+%Y.%m.%d") Build by gd772/g" $ZZZ                   # 添加固件编译日期及固件编译者
#sed -i "/uci commit system/i\uci set system.@system[0].hostname='N1'" $ZZZ                       # 修改主机名称为N1

# echo '替换系统文件'
curl -fsSL https://raw.githubusercontent.com/gd0772/patch/main/index.htm > ./package/lean/autocore/files/x86/index.htm
