# x86 固件在线更新
1. 在Luci里更新 直接在 OP后台 系统--更新固件
2. 命令行 或者 SSH 链接 OP 执行以下命令 更新
- 保留配置更新 bash /bin/AutoUpdate.sh
- 不保留配置更新 bash /bin/AutoUpdate.sh -n

# N1 固件更新命令：(注意：需科学上网环境)
1. 直接在 OP后台 系统--命令行 或者 SSH 链接 OP 执行以下命令 更新
- 5.4 内核：bash <(curl -s -S -L https://git.io/update_5.4.y.sh)
- 5.10 内核：bash <(curl -s -S -L https://git.io/JRjsw)

固件页面

![image](https://github.com/gd0772/AutoBuild-OpenWrt/blob/main/img/%E5%9B%BA%E4%BB%B6%E9%A1%B5%E9%9D%A2.png)

# 感谢
- [大雕 源码仓库](https://github.com/coolsnowwolf/lede.git)
- [Lienol 源码仓库](https://github.com/Lienol/openwrt.git)
- [天灵 源码仓库](https://github.com/project-openwrt/openwrt.git)
- [P3TERX 自动编译脚本](https://github.com/P3TERX/Actions-OpenWrt)
- [Hyy2001X 定时更新脚本](https://github.com/Hyy2001X/AutoBuild-Actions)
- [danshui-git 云编译的说明及修改](https://github.com/danshui-git/Build-OpenWrt)
- 同时感谢 flippy 分享的 N1 打包 及 升级脚本
