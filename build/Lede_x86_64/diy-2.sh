#!/bin/bash
# https://github.com/gd0772/AutoBuild-OpenWrt
# common Module by gd0772

# echo '替换系统文件'
curl -fsSL https://raw.githubusercontent.com/gd0772/patch/main/index.htm > ./package/lean/autocore/files/x86/index.htm
