#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件

git clone https://github.com/gd0772/package package/gd772
wget https://raw.githubusercontent.com/gd0772/patch/main/n1.sh
bash n1.sh

# 设置打包固件的机型，内核组合（可用内核是时时变化的,过老的内核就删除的，所以要选择什么内核请看说明)
cat >$GITHUB_WORKSPACE/amlogic_openwrt <<-EOF
rootfs_size=944
amlogic_model=s905d
amlogic_kernel=5.4.155
EOF
