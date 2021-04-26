#!/bin/bash
# https://github.com/281677160/build-openwrt
# common Module by 28677160
# matrix.target=${Modelfile}

DIY_GET_COMMON_SH() {
TYZZZ="package/lean/default-settings/files/zzz-default-settings"
LIZZZ="package/default-settings/files/zzz-default-settings"
}

# 全脚本源码通用diy.sh文件
Diy_all() {
DIY_GET_COMMON_SH
git clone https://github.com/gd0772/package package/gd772
chmod +x package/gd772
mv "${PATH1}"/AutoBuild_Tools.sh package/base-files/files/bin
chmod +x package/base-files/files/bin/AutoBuild_Tools.sh
if [[ ${REGULAR_UPDATE} == "true" ]]; then
git clone https://github.com/281677160/luci-app-autoupdate package/luci-app-autoupdate
mv "${PATH1}"/AutoUpdate.sh package/base-files/files/bin
chmod +x package/base-files/files/bin/AutoUpdate.sh
fi
}

# 全脚本源码通用diy2.sh文件
Diy_all2() {
DIY_GET_COMMON_SH

# echo '删除重复多余主题'
rm -rf ./feeds/freifunk/themes
rm -rf ./package/lean/luci-theme-netgear
rm -rf ./package/lean/luci-theme-argon
rm -rf ./feeds/luci/themes/luci-theme-material

# echo '删除重复插件'
rm -rf ./feeds/packages/net/smartdns
rm -rf ./feeds/packages/admin/netdata
rm -rf ./package/lean/luci-app-netdata
rm -rf ./package/lean/luci-app-cpufreq
rm -rf ./package/gd772/luci-app-autoupdate
rm -rf ./package/lean/luci-app-usb-printer
rm -rf ./package/lean/luci-app-jd-dailybonus
rm -rf ./feeds/luci/applications/luci-app-rp-pppoe-server

# echo '替换系统文件'
curl -fsSL https://raw.githubusercontent.com/gd0772/patch/main/zzz-default-settings > ./package/lean/default-settings/files/zzz-default-settings

# echo '添加 SSR Plus+'
git clone https://github.com/fw876/helloworld package/gd772/ssrplus
# echo '添加 小猫咪'
git clone https://github.com/vernesong/OpenClash package/gd772/OpenClash
# echo '添加 Passwall'
git clone https://github.com/xiaorouji/openwrt-passwall package/gd772/passwall
# echo '添加 HelloWorld'
git clone https://github.com/jerrykuku/luci-app-vssr package/gd772/luci-app-vssr
# echo '添加 应用过滤'
git clone https://github.com/destan19/OpenAppFilter package/gd772/OpenAppFilter
# echo '添加 京东签到'
git clone https://github.com/jerrykuku/luci-app-jd-dailybonus package/gd772/luci-app-jd-dailybonus
# echo '添加 SmartDNS'
git clone https://github.com/pymumu/luci-app-smartdns.git -b lede ./package/gd772/luci-app-smartdns
git clone https://github.com/pymumu/openwrt-smartdns.git ./feeds/packages/net/smartdns
# echo '添加 KPR去广告'
git clone https://github.com/project-lede/luci-app-godproxy package/gd772/luci-app-godproxy
# echo '微信推送'
git clone https://github.com/tty228/luci-app-serverchan.git ./package/gd772/luci-app-serverchan
# echo '汉化实时监控'
svn co https://github.com/gd0772/patch/trunk/luci-app-netdata ./package/lean/luci-app-netdata
svn co https://github.com/gd0772/patch/trunk/netdata ./feeds/packages/admin/netdata
# echo '替换USB打印'
svn co https://github.com/gd0772/patch/trunk/luci-app-usb-printer ./package/lean/luci-app-usb-printer
# echo '替换aria2'
rm -rf feeds/luci/applications/luci-app-aria2 && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-aria2 feeds/luci/applications/luci-app-aria2
rm -rf feeds/packages/net/aria2 && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/aria2 feeds/packages/net/aria2
rm -rf feeds/packages/net/ariang && svn co https://github.com/sirpdboy/sirpdboy-package/trunk/ariang feeds/packages/net/ariang
              
# echo '修改插件名称'
sed -i 's/"管理权"/"改密码"/g' feeds/luci/modules/luci-base/po/zh-cn/base.po
sed -i 's/msgstr "Web 管理"/msgstr "Web"/g' package/lean/luci-app-webadmin/po/zh-cn/webadmin.po
sed -i 's/TTYD 终端/命令行/g' package/lean/luci-app-ttyd/po/zh-cn/terminal.po
sed -i 's/ShadowSocksR Plus+/SSR Plus+/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/controller/shadowsocksr.lua
sed -i 's/PassWall/Pass Wall/g' package/gd772/passwall/luci-app-passwall/po/zh-cn/passwall.po
sed -i 's/广告屏蔽大师 Plus+/广告屏蔽/g' package/lean/luci-app-adbyby-plus/po/zh-cn/adbyby.po
sed -i 's/"GodProxy滤广告"/"KPR去广告"/g' package/gd772/luci-app-godproxy/po/zh-cn/koolproxy.po
sed -i 's/GodProxy滤广告/KoolProxyR去广告/g' package/gd772/luci-app-godproxy/luasrc/model/cbi/koolproxy/global.lua
sed -i 's/GodProxy 访问控制/KoolProxyR 访问控制/g' package/gd772/luci-app-godproxy/luasrc/model/cbi/koolproxy/global.lua
sed -i 's/GodProxy 帮助支持/KoolProxyR帮助支持/g' package/gd772/luci-app-godproxy/luasrc/model/cbi/koolproxy/global.lua
sed -i 's/GodProxy是/是/g' package/gd772/luci-app-godproxy/luasrc/model/cbi/koolproxy/global.lua
sed -i 's/GodProxy/KoolProxyR/g' package/gd772/luci-app-godproxy/luasrc/model/cbi/koolproxy/global.lua
sed -i 's/GodProxy滤广告/KPR去广告/g' package/gd772/luci-app-godproxy/luasrc/model/cbi/koolproxy/rss_rule.lua
sed -i 's/Shaoxia的KoolProxyR详细使用说明/关于 KoolProxyR 的详细使用说明/g' package/gd772/luci-app-godproxy/luasrc/view/koolproxy/feedback.htm
sed -i 's/GodProxy/KoolProxyR/g' package/gd772/luci-app-godproxy/luasrc/view/koolproxy/koolproxy_status.htm
sed -i 's/GodProxy滤广告/KoolProxyR去广告/g' package/gd772/luci-app-godproxy/luasrc/view/koolproxy/koolproxy_status.htm
sed -i 's/京东签到服务/京东签到/g' package/gd772/luci-app-jd-dailybonus/luasrc/controller/jd-dailybonus.lua
sed -i 's/msgstr "KMS 服务器"/msgstr "KMS 激活"/g' package/lean/luci-app-vlmcsd/po/zh-cn/vlmcsd.po
sed -i 's/msgstr "UPnP"/msgstr "UPnP设置"/g' feeds/luci/applications/luci-app-upnp/po/zh-cn/upnp.po
sed -i 's/Frp 内网穿透/Frp 客户端/g' package/lean/luci-app-frpc/po/zh-cn/frp.po
sed -i 's/Frps/Frp 服务端/g' package/lean/luci-app-frps/luasrc/controller/frps.lua
sed -i 's/Nps 内网穿透/NPS 客户端/g' package/lean/luci-app-nps/po/zh-cn/nps.po
sed -i 's/解锁网易云灰色歌曲/音乐解锁/g' package/lean/luci-app-unblockmusic/po/zh-cn/unblockmusic.po
sed -i 's/Docker CE 容器/Docker容器/g' package/lean/luci-app-docker/po/zh-cn/docker.po
sed -i 's/UU游戏加速器/UU加速器/g' package/lean/luci-app-uugamebooster/po/zh-cn/uuplugin.po
sed -i 's/网络存储/存储/g' package/lean/luci-app-vsftpd/po/zh-cn/vsftpd.po
sed -i 's/挂载 SMB 网络共享/挂载共享/g' package/lean/luci-app-cifs-mount/po/zh-cn/cifs.po
sed -i 's/"文件浏览器"/"文件浏览"/g' package/gd772/luci-app-filebrowser/po/zh-cn/filebrowser.po
sed -i 's/msgstr "FTP 服务器"/msgstr "FTP 服务"/g' package/lean/luci-app-vsftpd/po/zh-cn/vsftpd.po
sed -i 's/Rclone/网盘挂载/g' package/lean/luci-app-rclone/luasrc/controller/rclone.lua
sed -i 's/msgstr "Aria2"/msgstr "Aria2下载"/g' feeds/luci/applications/luci-app-aria2/po/zh-cn/aria2.po
sed -i 's/_("qBittorrent")/_("BT下载")/g' package/lean/luci-app-qbittorrent/luasrc/controller/qbittorrent.lua
sed -i 's/BaiduPCS Web/百毒网盘/g' package/lean/luci-app-baidupcs-web/luasrc/controller/baidupcs-web.lua
sed -i 's/IPSec VPN 服务器/IPSec 服务/g' package/lean/luci-app-ipsec-vpnd/po/zh-cn/ipsec.po
sed -i 's/V2ray 服务器/V2ray 服务/g' package/lean/luci-app-v2ray-server/po/zh-cn/v2ray_server.po
sed -i 's/SoftEther VPN 服务器/SoftEther/g' package/lean/luci-app-softethervpn/po/zh-cn/softethervpn.po
sed -i 's/"OpenVPN 服务器"/"OpenVPN"/g' package/lean/luci-app-openvpn-server/po/zh-cn/openvpn-server.po
sed -i 's/firstchild(), "VPN"/firstchild(), "GFW"/g' package/lean/luci-app-zerotier/luasrc/controller/zerotier.lua
sed -i 's/firstchild(), "VPN"/firstchild(), "GFW"/g' package/lean/luci-app-ipsec-vpnd/luasrc/controller/ipsec-server.lua
sed -i 's/firstchild(), "VPN"/firstchild(), "GFW"/g' package/lean/luci-app-softethervpn/luasrc/controller/softethervpn.lua
sed -i 's/firstchild(), "VPN"/firstchild(), "GFW"/g' package/lean/luci-app-openvpn-server/luasrc/controller/openvpn-server.lua
sed -i 's/Turbo ACC 网络加速/网络加速/g' package/lean/luci-app-flowoffload/po/zh-cn/flowoffload.po
sed -i 's/Turbo ACC 网络加速/网络加速/g' package/lean/luci-app-sfe/po/zh-cn/sfe.po
sed -i 's/MWAN3 分流助手/分流助手/g' package/lean/luci-app-mwan3helper/po/zh-cn/mwan3helper.po
sed -i 's/运行环境检测失败，请先关闭ACC加速模块!/运行环境检测失败，请关闭 网络加速!/g' package/gd772/OpenAppFilter/luci-app-oaf/luasrc/model/cbi/appfilter/appfilter.lua
sed -i 's/带宽监控/统计/g' feeds/luci/applications/luci-app-nlbwmon/po/zh-cn/nlbwmon.po
sed -i 's/实时流量监测/流量监测/g' package/lean/luci-app-wrtbwmon/po/zh-cn/wrtbwmon.po
sed -i 's/invalid/# invalid/g' package/lean/samba4/files/smb.conf.template

# echo '移动 网络共享 到 存储菜单'
sed -i 's/\"services\"/\"nas\"/g' package/lean/luci-app-samba4/luasrc/controller/samba4.lua
# echo '移动 分流助手 到 网络菜单'
sed -i 's/\"services\"/\"network\"/g' package/lean/luci-app-mwan3helper/luasrc/controller/mwan3helper.lua
curl -fsSL https://raw.githubusercontent.com/gd0772/patch/main/mwan3helper_status.htm > ./package/lean/luci-app-mwan3helper/luasrc/view/mwan3helper/mwan3helper_status.htm

# echo '调整 SSRP 到 GFW 菜单'
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/controller/shadowsocksr.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/advanced.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/client.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/client-config.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/control.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/log.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/server.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/server-config.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/servers.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/model/cbi/shadowsocksr/status.lua
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/certupload.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/check.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/checkport.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/ping.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/refresh.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/reset.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/server_list.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/socket.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/ssrurl.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/status.htm
sed -i 's/services/vpn/g' package/gd772/ssrplus/luci-app-ssr-plus/luasrc/view/shadowsocksr/subscribe.htm
# echo '调整 PassWall 到 GFW 菜单'
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/controller/passwall.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/api/api.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/acl.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/app_update.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/auto_switch.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/global.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/haproxy.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/log.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/node_config.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/node_list.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/node_subscribe.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/other.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/rule.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/rule_list.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/client/shunt_rules.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/server/index.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/model/cbi/passwall/server/user.lua
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/app_update/brook_version.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/app_update/kcptun_version.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/app_update/trojan_go_version.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/app_update/xray_version.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/global/footer.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/global/status.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/global/status2.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/global/tips.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/haproxy/status.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/log/log.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/node_list/link_add_node.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/node_list/link_share_man.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/node_list/node_list.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/rule/rule_version.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/server/log.htm
sed -i 's/services/vpn/g' package/gd772/passwall/luci-app-passwall/luasrc/view/passwall/server/users_list_status.htm
# echo '调整 HelloWorld 到 GFW 菜单'
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/controller/vssr.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/advanced.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/client.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/client-config.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/control.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/log.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/router.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/server.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/server-config.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/servers.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/socks5.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/model/cbi/vssr/subscribe-config.lua
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/view/vssr/cell_valuefooter.htm
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/view/vssr/cell_valueheader.htm
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/view/vssr/licence.htm
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/view/vssr/refresh.htm
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/view/vssr/ssrurl.htm
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/view/vssr/status_bottom.htm
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/view/vssr/status_top.htm
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/view/vssr/tblsection.htm
sed -i 's/services/vpn/g' package/gd772/luci-app-vssr/luasrc/view/vssr/update_subscribe.htm
# echo '调整 OpenClash 到 GFW 菜单'
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/controller/openclash.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/openclash.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/client.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/config.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/config-subscribe.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/config-subscribe-edit.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/game-rules-manage.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/groups-config.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/log.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/other-rules-edit.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/proxy-provider-config.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/proxy-provider-file-manage.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/rule-providers-config.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/rule-providers-file-manage.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/rule-providers-manage.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/rule-providers-settings.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/servers.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/servers-config.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/model/cbi/openclash/settings.lua
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/cfg_check.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/config_editor.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/developer.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/download_rule.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/dvalue.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/log.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/myip.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/other_button.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/ping.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/server_list.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/status.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/switch_mode.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/update.htm
sed -i 's/services/vpn/g' package/gd772/OpenClash/luci-app-openclash/luasrc/view/openclash/upload.htm
# echo '调整 V2ray服务器 到 GFW 菜单'
sed -i 's/services/vpn/g' package/lean/luci-app-v2ray-server/luasrc/controller/v2ray_server.lua
sed -i 's/services/vpn/g' package/lean/luci-app-v2ray-server/luasrc/model/cbi/v2ray_server/index.lua
sed -i 's/services/vpn/g' package/lean/luci-app-v2ray-server/luasrc/model/cbi/v2ray_server/user.lua
sed -i 's/services/vpn/g' package/lean/luci-app-v2ray-server/luasrc/view/v2ray_server/log.htm
sed -i 's/services/vpn/g' package/lean/luci-app-v2ray-server/luasrc/view/v2ray_server/users_list_status.htm
sed -i 's/services/vpn/g' package/lean/luci-app-v2ray-server/luasrc/view/v2ray_server/v2ray.htm

# echo '添加自定义防火墙说明'
curl -fsSL https://raw.githubusercontent.com/gd0772/patch/main/firewall.user > ./package/network/config/firewall/files/firewall.user

# echo '更换内核'
#sed -i 's/KERNEL_PATCHVER:=5.4/KERNEL_PATCHVER:=4.19/g' ./target/linux/x86/Makefile
#sed -i 's/KERNEL_TESTING_PATCHVER:=5.4/KERNEL_TESTING_PATCHVER:=4.19/g' ./target/linux/x86/Makefile

# echo '更新feeds'
./scripts/feeds update -i
}


################################################################################################################
# LEDE源码通用diy1.sh文件
################################################################################################################
Diy_lede() {
DIY_GET_COMMON_SH
if [[ "${Modelfile}" == "Lede_x86_64" ]]; then
sed -i '/IMAGES_GZIP/d' "${PATH1}/${CONFIG_FILE}" > /dev/null 2>&1
echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${PATH1}/${CONFIG_FILE}"
fi
}
################################################################################################################
# LEDE源码通用diy2.sh文件
Diy_lede2() {
DIY_GET_COMMON_SH
cp -Rf "${Home}"/build/common/LEDE/files "${Home}"
cp -Rf "${Home}"/build/common/LEDE/diy/* "${Home}"
}


################################################################################################################
# LIENOL源码通用diy1.sh文件
################################################################################################################
Diy_lienol() {
DIY_GET_COMMON_SH
rm -rf package/diy/luci-app-adguardhome
rm -rf package/lean/{luci-app-netdata,luci-theme-argon,k3screenctrl}
git clone https://github.com/fw876/helloworld package/danshui/luci-app-ssr-plus
git clone https://github.com/xiaorouji/openwrt-passwall package/danshui/luci-app-passwall
git clone https://github.com/jerrykuku/luci-app-vssr package/danshui/luci-app-vssr
git clone https://github.com/vernesong/OpenClash package/danshui/luci-app-openclash
git clone https://github.com/frainzy1477/luci-app-clash package/danshui/luci-app-clash
}
################################################################################################################
# LIENOL源码通用diy2.sh文件
Diy_lienol2() {
DIY_GET_COMMON_SH
cp -Rf "${Home}"/build/common/LIENOL/files "${Home}"
cp -Rf "${Home}"/build/common/LIENOL/diy/* "${Home}"
}


################################################################################################################
# 天灵源码通用diy1.sh文件
################################################################################################################
Diy_immortalwrt() {
DIY_GET_COMMON_SH
}

################################################################################################################
# 天灵源码通用diy2.sh文件
Diy_immortalwrt2() {
DIY_GET_COMMON_SH
cp -Rf "${Home}"/build/common/PROJECT/files "${Home}"
cp -Rf "${Home}"/build/common/PROJECT/diy/* "${Home}"
}


################################################################################################################
# 判断脚本是否缺少主要文件（如果缺少settings.ini设置文件在检测脚本设置就运行错误了）

Diy_settings() {
DIY_GET_COMMON_SH
rm -rf ${Home}/build/QUEWENJIANerros
if [ -z "$(ls -A "$PATH1/${CONFIG_FILE}" 2>/dev/null)" ]; then
	echo
	echo "编译脚本缺少[${CONFIG_FILE}]名称的配置文件,请在[build/${Modelfile}]文件夹内补齐"
	echo "errors" > ${Home}/build/QUEWENJIANerros
	echo
fi
if [ -z "$(ls -A "$PATH1/${DIY_P1_SH}" 2>/dev/null)" ]; then
	echo
	echo "编译脚本缺少[${DIY_P1_SH}]名称的自定义设置文件,请在[build/${Modelfile}]文件夹内补齐"
	echo "errors" > ${Home}/build/QUEWENJIANerros
	echo
fi
if [ -z "$(ls -A "$PATH1/${DIY_P2_SH}" 2>/dev/null)" ]; then
	echo
	echo "编译脚本缺少[${DIY_P2_SH}]名称的自定义设置文件,请在[build/${Modelfile}]文件夹内补齐"
	echo "errors" > ${Home}/build/QUEWENJIANerros
	echo
fi
if [ -n "$(ls -A "${Home}/build/QUEWENJIANerros" 2>/dev/null)" ]; then
rm -rf ${Home}/build/QUEWENJIANerros
exit 1
fi
}


################################################################################################################
# 判断插件冲突

Diy_chajian() {
DIY_GET_COMMON_SH
echo
echo "				插件冲突信息" > ${Home}/CHONGTU

if [[ `grep -c "CONFIG_TARGET_ROOTFS_EXT4FS=y" .config` -eq '1' ]]; then
	echo " 请注意，您选择了ext4安装的固件格式" > ${Home}/EXT4
	echo " 请在Target Images  --->里面的下面两项的数值调整" >> ${Home}/EXT4
	echo " （16）Kernel partition size (in MB) " >> ${Home}/EXT4
	echo " （160）Root filesystem partition size (in MB)" >> ${Home}/EXT4
	echo " 请把（16）Kernel partition size (in MB) 设置成（30）Kernel partition size (in MB) 或者更高数值 " >> ${Home}/EXT4
	echo " 请把（160）Root filesystem partition size (in MB) 设置成（950）Root filesystem partition size (in MB) 或者更高数值" >> ${Home}/EXT4
	echo " （160）Root filesystem partition size (in MB) 这项设置数值请避免使用‘128’、‘256’、‘512’、‘1024’等之类的数值" >> ${Home}/EXT4
	echo " 选择了ext4安装格式的固件，（160）Root filesystem partition size (in MB) 这项数值太低容易造成插件空间不足编译错误" >> ${Home}/EXT4
	echo " " >> ${Home}/EXT4
fi
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	echo "" >>CHONGTU
	echo "   插件冲突会导致编译失败，以上操作如非您所需，请关闭此次编译，重新开始编译，避开冲突重新选择插件" >>CHONGTU
	echo "" >>CHONGTU
else
	rm -rf CHONGTU
fi
}


################################################################################################################
# 判断是否选择AdGuard Home是就指定机型给内核

Diy_adgu() {
DIY_GET_COMMON_SH
grep -i CONFIG_PACKAGE_luci-app .config | grep  -v \# > Plug-in
grep -i CONFIG_PACKAGE_luci-theme .config | grep  -v \# >> Plug-in
sed -i "s/=y//g" Plug-in
sed -i "s/CONFIG_PACKAGE_//g" Plug-in
sed -i '/INCLUDE/d' Plug-in > /dev/null 2>&1
cat -n Plug-in > Plugin
sed -i 's/	luci/、luci/g' Plugin
awk '{print "  " $0}' Plugin > Plug-in
if [ `grep -c "CONFIG_TARGET_x86_64=y" ${Home}/.config` -eq '1' ]; then
	TARGET_ADG="x86-64"
else
	TARGET_ADG="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
fi

case "${REPO_URL}" in
"${LEDE}")

;;
"${LIENOL}") 

;;
"${PROJECT}") 

;;
esac
rm -rf {LICENSE,README,README.md,CONTRIBUTED.md,README_EN.md}
rm -rf ./*/{LICENSE,README,README.md}
rm -rf ./*/*/{LICENSE,README,README.md}
rm -rf ./*/*/*/{LICENSE,README,README.md}
}


################################################################################################################
# 编译信息

Diy_xinxi_Base() {
GET_TARGET_INFO
if [[ "${TARGET_PROFILE}" =~ (x86-64|phicomm-k3|d-team_newifi-d2|phicomm_k2p|k2p|phicomm_k2p-32m) ]]; then
	Firmware_mz="${TARGET_PROFILE}自动适配"
	Firmware_hz="${TARGET_PROFILE}自动适配"
else
	Firmware_mz="${Up_Firmware}"
	Firmware_hz="${Firmware_sfx}"
fi
if [[ "${Modelfile}" =~ (Lede_phicomm_n1|Project_phicomm_n1) ]]; then
	TARGET_PROFILE="N1,Vplus,Beikeyun,L1Pro,S9xxx"
fi
echo
echo " 编译源码: ${COMP2}"
echo " 源码链接: ${REPO_URL}"
echo " 源码分支: ${REPO_BRANCH}"
echo " 源码作者: ${ZUOZHE}"
echo " 编译机型: ${TARGET_PROFILE}"
echo " 固件作者: ${Author}"
echo " 仓库地址: ${Github_Repo}"
echo " 启动编号: #${Run_number}（${CangKu}仓库第${Run_number}次启动[${Run_workflow}]工作流程）"
echo " 编译时间: $(TZ=UTC-8 date "+%Y年%m月%d号-%H时%M分")"
echo " 您当前使用【${Modelfile}】文件夹编译【${TARGET_PROFILE}】固件"
echo
if [[ ${UPLOAD_FIRMWARE} == "true" ]]; then
	echo " 上传固件在github actions: 开启"
else
	echo " 上传固件在github actions: 关闭"
fi
if [[ ${UPLOAD_CONFIG} == "true" ]]; then
	echo " 上传[.config]配置文件: 开启"
else
	echo " 上传[.config]配置文件: 关闭"
fi
if [[ ${UPLOAD_BIN_DIR} == "true" ]]; then
	echo " 上传BIN文件夹(固件+IPK): 开启"
else
	echo " 上传BIN文件夹(固件+IPK): 关闭"
fi
if [[ ${UPLOAD_COWTRANSFER} == "true" ]]; then
	echo " 上传固件到到【奶牛快传】和【WETRANSFER】: 开启"
else
	echo " 上传固件到到【奶牛快传】和【WETRANSFER】: 关闭"
fi
if [[ ${UPLOAD_RELEASE} == "true" ]]; then
	echo " 发布固件: 开启"
else
	echo " 发布固件: 关闭"
fi
if [[ ${SERVERCHAN_SCKEY} == "true" ]]; then
	echo " 微信/电报通知: 开启"
else
	echo " 微信/电报通知: 关闭"
fi
if [[ ${SSH_ACTIONS} == "true" ]]; then
	echo " SSH远程连接: 开启"
else
	echo " SSH远程连接: 关闭"
fi
if [[ ${SSHYC} == "true" ]]; then
	echo " SSH远程连接临时开关: 开启"
fi
if [[ ${REGULAR_UPDATE} == "true" ]]; then
	echo
	echo " 把定时自动更新插件编译进固件: 开启"
	echo " 插件版本: ${AutoUpdate_Version}"
	echo " 固件名称: ${Firmware_mz}"
	echo " 固件后缀: ${Firmware_hz}"
	echo " 固件版本: ${Openwrt_Version}"
	echo " 云端路径: ${Github_UP_RELEASE}"
	echo " 《x86设置安装固件时候请最少分配2G内存，要不然内存太低，自动更新不了》"
	echo
else
	echo " 把定时自动更新插件编译进固件: 关闭"
	echo
fi
if [ -n "$(ls -A "${Home}/EXT4" 2>/dev/null)" ]; then
	[ -s EXT4 ] && cat EXT4
	rm -rf EXT4
fi
echo "  系统空间      类型   容量  已用  可用 使用率"
cd ../ && df -hT $PWD && cd openwrt
echo
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	echo
	[ -s CHONGTU ] && cat CHONGTU
fi
if [ -n "$(ls -A "${Home}/Plug-in" 2>/dev/null)" ]; then
	echo
	echo "	   已选插件列表"
	[ -s Plug-in ] && cat Plug-in
	echo
fi
rm -rf {CHONGTU,Plug-in,Plugin,Chajianlibiao}
}
