**x86 固件更新 方式：**

1. 在**OP后台 系统--更新固件 点击 手动更新** 稍等几分钟 路由重启即可
2. **命令行** 或 **SSH 链接** OP **执行以下命令** 完成固件更新
- 执行 **`bash /bin/AutoUpdate.sh`** 保留配置更新
- 执行 **`bash /bin/AutoUpdate.sh -n`** 不保留配置更新

**注意：升级不会保留原有自己安装的 app ，还需升级后自行按需安装**

| 默认登陆IP  | 默认账号 | 默认密码 |
| ---- | ---- | ---- |
| 192.168.123.254 | root | 空 或者 password |

固件页面

![image](https://raw.githubusercontent.com/gd0772/AutoBuild-OpenWrt/main/img/opimg.png)

# 感谢
- [大雕 源码仓库](https://github.com/coolsnowwolf/lede.git)
- [Lienol 源码仓库](https://github.com/Lienol/openwrt.git)
- [天灵 源码仓库](https://github.com/project-openwrt/openwrt.git)
- [P3TERX 自动编译脚本](https://github.com/P3TERX/Actions-OpenWrt)
- [Hyy2001X 定时更新脚本](https://github.com/Hyy2001X/AutoBuild-Actions)
- [danshui-git 云编译的说明及DIY](https://github.com/danshui-git/build-actions)
