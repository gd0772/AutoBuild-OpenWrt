# x86 固件在线更新
1. 在Luci里更新 直接在 OP后台 系统--更新固件
2. 命令行 或者 SSH 链接 OP 执行以下命令 更新
- 保留配置更新 **`bash /bin/AutoUpdate.sh`**
- 不保留配置更新 **`bash /bin/AutoUpdate.sh -n`**
- **x86 OpenWrt 固件默认信息**

| 默认登陆IP  | 默认账号 | 默认密码 |
| ---- | ---- | ---- |
| 192.168.123.254 | root | password |

# N1 固件在线更新命令：
1. 直接在 OP后台 **系统--命令行** 或者 **SSH 链接 OP** 执行以下命令 更新
- **update** 然后按提示操作即可！
- 插件安装命令 **app** 然后按提示操作即可！
- **Docker 相关的一键安装** 同样在命令行 或者 SSH 里执行 **n1_docker** 然后按提示操作即可！
- **注：Docker下载镜像(需科学上网环境，也有可能一次不行多尝试几次或者更换魔法节点)**
- **N1 OpenWrt 固件默认信息**

| 默认登陆IP  | 默认账号 | 默认密码 | 默认WIFI | 默认WIFI密码 |
| ---- | ---- | ---- | ---- | ---- |
| 192.168.123.2 | root | password | Phicomm_n1 | password |

固件页面

![image](https://github.com/gd0772/AutoBuild-OpenWrt/blob/main/img/x86.png)

# 感谢
- [大雕 源码仓库](https://github.com/coolsnowwolf/lede.git)
- [Lienol 源码仓库](https://github.com/Lienol/openwrt.git)
- [天灵 源码仓库](https://github.com/project-openwrt/openwrt.git)
- [P3TERX 自动编译脚本](https://github.com/P3TERX/Actions-OpenWrt)
- [Hyy2001X 定时更新脚本](https://github.com/Hyy2001X/AutoBuild-Actions)
- [danshui-git 云编译的说明及DIY](https://github.com/danshui-git/build-actions)
- [同时感谢 unifreq 分享的 N1 打包 及 升级脚本](https://github.com/unifreq/openwrt_packit)
