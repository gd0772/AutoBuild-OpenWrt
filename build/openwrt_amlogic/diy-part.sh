#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件
# 自行拉取插件之前请SSH连接进入固件配置里面确认过没有你要的插件再单独拉取你需要的插件
# 不要一下就拉取别人一个插件包N多插件的，多了没用，增加编译错误，自己需要的才好
# 修改IP项的EOF于EOF之间请不要插入其他扩展代码，可以删除或注释里面原本的代码

# 修改 主机名为 N1
sed -i "s/'OpenWrt'/'N1'/g" package/base-files/files/bin/config_generate

# 设置打包固件的机型，内核组合（请看说明）
cat >$GITHUB_WORKSPACE/amlogic_openwrt <<-EOF
rootfs_size=944
amlogic_model=s905d
amlogic_kernel=5.4.152
EOF
