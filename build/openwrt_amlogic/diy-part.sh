#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件

# sed -i '/CYXluq4wUazHjmCDBCqXF/d' $ZZZ                                                            # 设置密码为空

sed -i "s/'OpenWrt'/'N1'/g" package/base-files/files/bin/config_generate                            # 设置主机名

# 设置打包固件的机型，内核组合（可用内核是时时变化的,过老的内核就删除的，所以要选择什么内核请看说明)
cat >$GITHUB_WORKSPACE/amlogic_openwrt <<-EOF
rootfs_size=671
amlogic_model=s905d
amlogic_kernel=5.4.155
EOF
