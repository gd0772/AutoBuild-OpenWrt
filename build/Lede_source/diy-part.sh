#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展 在此脚本 增加插件

wget https://raw.githubusercontent.com/gd0772/patch/main/gd772.sh
bash gd772.sh
sed -i 's/02b79d5e2b07b5e64cd28f1fe84395ee11eef95fc49fd923a9ab93022b148be6/skip/g' feeds/packages/utils/containerd/Makefile
