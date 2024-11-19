**x86 固件更新 方式：**
**x86 firmware update Method:**
1. 在**OP后台 系统--更新固件 点击 手动更新** 稍等几分钟 路由重启即可
   In the OP background system - update firmware, click on Manual update. Wait a few minutes for the router to restart
2. **命令行** 或 **SSH 链接** OP **执行以下命令** 完成固件更新
   Command line or SSH link OP execute the following command to complete the firmware update
- 执行 **`bash /bin/AutoUpdate.sh`** 保留配置更新
- Execute bash /bin/AutoUpdate.sh Keep configuration updates
- 执行 **`bash /bin/AutoUpdate.sh -n`** 不保留配置更新
- Execute bash /bin/AutoUpdate.sh -n Do not keep configuration updates

**注意：升级不会保留原有自己安装的 app ，还需升级后自行按需安装**
Note: The upgrade will not retain the original self-installed apps, and you will need to install them yourself after the upgrade as needed
Default login IP address, default account, default password
192.168.123.254 root password
| 默认登陆IP  | 默认账号 | 默认密码 |
| ---- | ---- | ---- |
| 192.168.123.254 | root | password |

固件页面
Firmware page
![image](https://raw.githubusercontent.com/gd0772/AutoBuild-OpenWrt/main/img/opimg.png)

# 感谢
thank
- [大雕 源码仓库](https://github.com/coolsnowwolf/lede.git)
- [Lienol 源码仓库](https://github.com/Lienol/openwrt.git)
- [天灵 源码仓库](https://github.com/project-openwrt/openwrt.git)
- [P3TERX 自动编译脚本](https://github.com/P3TERX/Actions-OpenWrt)
- [Hyy2001X 定时更新脚本](https://github.com/Hyy2001X/AutoBuild-Actions)
- [danshui-git 云编译的说明及DIY](https://github.com/danshui-git/build-actions)
