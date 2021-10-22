#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件


# 修改 主机名为 N1
sed -i "s/'OpenWrt'/'N1'/g" package/base-files/files/bin/config_generate

# 设置打包固件的机型，内核组合（请看说明）
cat >$GITHUB_WORKSPACE/amlogic_openwrt <<-EOF
rootfs_size=944
amlogic_model=s905d
amlogic_kernel=5.4.155
EOF
