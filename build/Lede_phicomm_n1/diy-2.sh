#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# echo '修改 主机名'
sed -i "s/'OpenWrt'/'N1'/g" package/base-files/files/bin/config_generate
