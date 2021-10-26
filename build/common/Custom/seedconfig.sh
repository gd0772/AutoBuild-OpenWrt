#/bin/bash

TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
UbuntuName=`cat /etc/issue`
XTName="Ubuntu"
[[ $UbuntuName != *$XTName* ]] && {
	clear
	echo
	TIME y "请使用 Ubuntu 系统，推荐 Ubuntu 18 LTS 或 Ubuntu 20 LTS"
	echo
	exit 1
}
[[ ! -e .compile ]] && {
	clear
	echo
	echo
	echo
	TIME l "|*******************************************|"
	TIME z "|     欢迎使用一键提取.config配置程序      |"
	TIME g "|                                           |"
	TIME y "|    请输入Ubuntu密码继续下一步, 环境部署   |"
	TIME r "|*******************************************|"
	sleep 2s
	sudo apt-get update -y
	sudo apt-get full-upgrade -y
	sudo apt-get install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 lib32stdc++6 subversion flex uglifyjs gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync
	[[ $? -ne 0 ]] && {
		clear
		echo
		TIME r "环境部署失败，请检测网络或更换节点再尝试!"
		exit 1
	} || {
	sudo apt-get clean
	sudo timedatectl set-timezone Asia/Shanghai
	echo "compile" > .compile
	}
}
clear
echo
echo
echo
TIME l " 1. Lede_5.4内核,LUCI 18.06版本"
echo
TIME l " 2. Lienol_4.14内核,LUCI 19.07版本"
echo
TIME l " 3. Immortalwrt_5.4内核,LUCI 21.02版本"
echo
TIME l " 4. N1和晶晨系列CPU盒子专用"
echo
TIME l " 5. 退出编译程序"
echo
echo
echo
while :; do
TIME z "友情提示：本脚本提取的.config为我仓库云编译脚本专用,请正确选择对应源码!"
echo
echo
TIME g "请选择编译源码，提取对应的配置文件,输入[ 1、2、3、4、5 ]然后回车确认您的选择！"
echo
read -p " 输入您的选择： " CHOOSE
case $CHOOSE in
	1)
		REPO_URL="https://github.com/coolsnowwolf/lede"
		REPO_BRANCH="master"
		CONFIG="Lede_5.4内核,LUCI 18.06版本"
		echo
		TIME y "您选择了：${CONFIG}"
		echo
		TIME y "请耐心等待程序运行至窗口弹出进行机型和插件配置"
	break
	;;
	2)
		REPO_URL="https://github.com/Lienol/openwrt"
		REPO_BRANCH="19.07"
		CONFIG="Lienol_4.14内核,LUCI 19.07版本"
		echo
		TIME y "您选择了：${CONFIG}"
		echo
		TIME y "请耐心等待程序运行至窗口弹出进行机型和插件配置"
	break
	;;
	3)
		REPO_URL="https://github.com/immortalwrt/immortalwrt"
		REPO_BRANCH="openwrt-21.02"
		CONFIG="Immortalwrt_5.4内核,LUCI 21.02版本"
		echo
		TIME y "您选择了：${CONFIG}"
		echo
		TIME y "请耐心等待程序运行至窗口弹出进行机型和插件配置"
	break
	;;
	4)
		REPO_URL="https://github.com/coolsnowwolf/lede"
		REPO_BRANCH="master"
		firmware="openwrt_amlogic"
		CONFIG="N1和晶晨系列CPU盒子专用源码"
		echo
		TIME y "您选择了：${CONFIG}"
		echo
		TIME y "请耐心等待程序运行至窗口弹出进行机型和插件配置"
	break
	;;
	5)
		rm -rf seedconfig.sh
		TIME r "您选择了退出编译程序"
		exit 0
	break
    	;;
    	*)
		TIME r "警告：输入错误,请输入正确的编号"
	;;
esac
done
echo
echo
TIME g "正在下载源码和同步Github脚本的插件,请耐心等候~~~"
echo
rm -rf seedconfig && git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" seedconfig
[[ $? -ne 0 ]] && {
	echo
	TIME r "源码下载失败，请检测网络或更换节点!"
	echo
	exit 1
}
Home="$PWD/seedconfig"
cd $Home
./scripts/feeds update -a > /dev/null 2>&1
git clone -b "$REPO_BRANCH" --single-branch https://github.com/281677160/openwrt-package
[[ $? -ne 0 ]] && {
	echo
	rm -rf ../seedconfig.sh
	rm -rf ../seedconfig
	TIME r "插件下载失败，请检测网络或更换节点再尝试!"
	echo
	exit 1
} || {
cp -Rf openwrt-package/* "${Home}" && rm -rf ${Home}/openwrt-package
}
svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/luci-app-ssr-plus > /dev/null 2>&1
[[ $? -ne 0 ]] && {
	echo
	rm -rf ../seedconfig.sh
	rm -rf ../seedconfig
	TIME r "luci-app-ssr-plus下载失败，请检测网络或更换节点再尝试!"
	echo
	exit 1
}
svn co https://github.com/xiaorouji/openwrt-passwall/trunk/luci-app-passwall package/luci-app-passwall > /dev/null 2>&1
[[ $? -ne 0 ]] && {
	echo
	rm -rf ../seedconfig.sh
	rm -rf ../seedconfig
	TIME r "luci-app-passwall下载失败，请检测网络或更换节点再尝试!"
	echo
	exit 1
}
./scripts/feeds update -a
./scripts/feeds install -a
[[ $firmware == "openwrt_amlogic" ]] && {
cat >.config <<-EOF
CONFIG_TARGET_armvirt=y
CONFIG_TARGET_armvirt_64=y
CONFIG_TARGET_armvirt_64_Default=y
CONFIG_PACKAGE_luci-app-amlogic=y
EOF
}
make menuconfig
make defconfig
./scripts/diffconfig.sh > ../config.txt
clear
echo
echo
echo
TIME y "[ ${CONFIG} ]的.config配置文件提取工作完成！"
echo
TIME g "请用WinSCP工具连接你的ubuntu，在ubuntu根目录有一份config.txt文件。"
echo
TIME g "把config.txt文件内容全选复制，然后覆盖对应机型.config里面原来的内容就可以了！"
echo
TIME g "或者可以使用 cat config.txt 命令来查看！"
echo
echo
echo
rm -rf ../seedconfig.sh
rm -rf ../seedconfig

exit 0
