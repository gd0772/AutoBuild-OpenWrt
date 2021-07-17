#/bin/bash

TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
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
XTbit=`getconf LONG_BIT`
[[ ( $UbuntuName != *$XTName* ) || ( $XTbit != 64 ) ]] && {
	clear
	echo
	TIME y "请使用Ubuntu 64bit，推荐 Ubuntu 18 LTS 或 Ubuntu 20 LTS"
	echo
	exit 1
}
[[ "$USER" == "root" ]] && {
	clear
	echo
	TIME g "警告：请勿使用root用户编译，换一个普通用户吧~~"
	echo
	exit 1
}
[[ ! -e .compile ]] && {
	clear
	echo
	echo
	echo
	TIME z "|*******************************************|"
	TIME g "|                                           |"
	TIME y "|    首次编译,请输入Ubuntu密码继续下一步    |"
	TIME g "|                                           |"
	TIME z "|              编译环境部署                 |"
	TIME g "|                                           |"
	TIME r "|*******************************************|"
	sleep 2s
	sudo apt-get update -y
	sudo apt-get full-upgrade -y
	sudo apt-get install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 lib32stdc++6 subversion flex uglifyjs gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler libpcap0.8-dev g++-multilib antlr3 gperf wget curl swig rsync
	[[ $? -ne 0 ]] && {
		clear
		echo
		TIME r "环境部署失败，请检测网络或更换节点再尝试!"
		exit 1
	} || {
	sudo apt-get autoremove --purge
	sudo apt-get clean
	sudo timedatectl set-timezone Asia/Shanghai
	echo "compile" > .compile
	}
}
if [[ -n "$(ls -A "openwrt/.bf_config" 2>/dev/null)" ]]; then
	if [[ -n "$(ls -A "openwrt/.Lede_core" 2>/dev/null)" ]]; then
		firmware="Lede_source"
		Core=".Lede_core"
		source openwrt/.Lede_core
	elif [[ -n "$(ls -A "openwrt/.Lienol_core" 2>/dev/null)" ]]; then
		firmware="Lienol_source"
		Core=".Lienol_core"
		source openwrt/.Lienol_core
	elif [[ -n "$(ls -A "openwrt/.Mortal_core" 2>/dev/null)" ]]; then
		firmware="Mortal_source"
		Core=".Mortal_core"
		source openwrt/.Mortal_core
	elif [[ -n "$(ls -A "openwrt/.amlogic_core" 2>/dev/null)" ]]; then
		firmware="openwrt_amlogic"
		Core=".amlogic_core"
		source openwrt/.amlogic_core
	else
		clear
		echo
		echo
		echo
		TIME r "没检测到openwrt文件夹有执行文件，自动转换成首次编译命令编译固件，请稍后..."
		rm -rf {openwrt,openwrtl,dl,.bf_config,compile.sh}
		rm -rf {.Lede_core,.Lienol_core,.amlogic_core}
		bash <(curl -fsSL git.io/JcGDV)
	fi
	echo
	if [[ `grep -c "CONFIG_TARGET_x86_64=y" openwrt/.bf_config` -eq '1' ]]; then
          	TARGET_PROFILE="x86-64"
	elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" openwrt/.bf_config` -eq '1' ]]; then
          	TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" openwrt/.bf_config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
	else
          	TARGET_PROFILE="armvirt"
	fi
	[[ ${firmware} == "openwrt_amlogic" ]] && {
		clear
		echo
		echo
		echo
		TIME g "正在使用[ ${firmware} ]源码编译[ N1和晶晨系列盒子专用固件 ],是否更换源码?"
	} || {
		clear
		echo
		echo
		echo
		TIME g "正在使用[ ${firmware} ]源码编译[ ${TARGET_PROFILE}固件 ],是否更换源码编译?"
	}
	read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " GHYM
	case $GHYM in
		[Yy])
			clear
			echo
			echo
			TIME r "您选择更改源码，正在清理旧文件中，请稍后..."
			rm -rf {openwrt,openwrtl,dl,.bf_config,compile.sh}
			rm -rf {.Lede_core,.Lienol_core,.amlogic_core}
			bash <(curl -fsSL git.io/JcGDV)
		;;
		*)
			YUAN_MA="false"
			TIME y "您已关闭更换源码编译固件，保存配置中，请稍后..."
			cp -Rf openwrt/{.bf_config,compile.sh,${Core},dl} ./
		;;
	esac
fi
Ubuntu_mz="$(cat /etc/group | grep adm | cut -f2 -d,)"
Ubuntu_kj="$(df -h | grep "/dev/*/" | awk '{print $4}' | awk 'NR==1' | sed 's/.$//g')"
if [[ "${Ubuntu_kj}" -lt "20" ]];then
	echo
	TIME z "您当前系统可用空间为${Ubuntu_kj}G"
	echo ""
	TIME r "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
	echo
	read -p " [回车退出，Y/y确认继续]： " YN
	case ${YN} in
		[Yy]) 
			TIME g  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
			echo
		;;
		*)
			TIME y  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
			echo ""
			sleep 2s
			exit 0
	esac
fi
[[ ! ${YUAN_MA} == "false" ]] && {
	clear
	echo
	echo
	echo
	TIME l " 1. Lede_5.10内核,LUCI 18.06版本"
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
	TIME g "请选择编译源码,输入[ 1、2、3、4、5 ]然后回车确认您的选择！"
	read -p " 输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			firmware="Lede_source"
			TIME y "您选择了：Lede_5.10内核,LUCI 18.06版本"
		break
		;;
		2)
			firmware="Lienol_source"
			TIME y "您选择了：Lienol_4.14内核,LUCI 19.07版本"
		break
		;;
		3)
			firmware="Mortal_source"
			TIME y "您选择了：Immortalwrt_5.4内核,LUCI 21.02版本"
		break
		;;
		4)
			firmware="openwrt_amlogic"
			TIME y "您选择了：N1和晶晨系列CPU盒子专用"
		break
		;;
		5)
			rm -rf compile.sh
			TIME r "您选择了退出编译程序"
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
}
echo
echo
[[ ! ${YUAN_MA} == "false" ]] && ipdz="192.168.1.1"
TIME g "设置openwrt的后台IP地址[ 回车默认 $ipdz ]"
read -p " 请输入后台IP地址：" ip
ip=${ip:-"$ipdz"}
TIME y "您的后台地址为：$ip"
echo
echo
TIME g "是否需要选择机型和增删插件?"
read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " MENU
case $MENU in
	[Yy])
		Menuconfig="YES"
		TIME y "您执行机型和增删插件命令,请耐心等待程序运行至窗口弹出进行机型和插件配置!"
	;;
	*)
		TIME r "您已关闭选择机型和增删插件设置！"
	;;
esac
echo
echo
[[ ! $firmware == "openwrt_amlogic" ]] && {
	TIME g "是否把定时更新插件编译进固件?"
	read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " RELE
	case $RELE in
		[Yy])
			REG_UPDATE="true"
		;;
		*)
			TIME r "您已关闭把‘定时更新插件’编译进固件！"
			Github="https://github.com/281677160/AutoBuild-OpenWrt"
		;;
	esac
}
[[ "${REG_UPDATE}" == "true" ]] && {
	[[ ! ${YUAN_MA} == "false" ]] && Git="https://github.com/281677160/AutoBuild-OpenWrt"
	TIME g "设置Github地址,定时更新固件需要把固件传至对应地址的Releases"
	TIME z "回车默认为：$Git"
	read -p " 请输入Github地址：" Github
	Github=${Github:-"$Git"}
	TIME y "您的Github地址为：$Github"
	Apidz="${Github##*com/}"
	Author="${Apidz%/*}"
	CangKu="${Apidz##*/}"
}
echo
[[ -f ${Core} ]] && {
	echo -e "\nipdz=$ip" > ${Core}
	echo -e "\nGit=$Github" >> ${Core}
}
Begin="$(TZ=UTC-8 date "+%Y/%m/%d-%H.%M")"
echo
TIME g "正在下载源码中,请耐心等候~~~"
echo
if [[ $firmware == "Lede_source" ]]; then
	[[ -d openwrt ]] && {
		rm -rf openwrtl && git clone https://github.com/coolsnowwolf/lede openwrtl
	} || {
		git clone https://github.com/coolsnowwolf/lede openwrt
	}
	[[ $? -ne 0 ]] && {
		TIME r "源码下载失败，请检测网络或更换节点再尝试!"
		rm -rf openwrtl
		echo
	 	exit 1
	} || {
	[[ -d openwrtl ]] && rm -rf openwrt && mv openwrtl openwrt
	}
	ZZZ="package/lean/default-settings/files/zzz-default-settings"
	OpenWrt_name="18.06"
	echo -e "\nipdz=$ip" > openwrt/.Lede_core
	echo -e "\nGit=$Github" >> openwrt/.Lede_core
elif [[ $firmware == "Lienol_source" ]]; then
	[[ -d openwrt ]] && {
		rm -rf openwrtl && git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt openwrtl
	} || {
		git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt openwrt
	}
	[[ $? -ne 0 ]] && {
		TIME r "源码下载失败，请检测网络或更换节点再尝试!"
		rm -rf openwrtl
		echo
	 	exit 1
	} || {
	[[ -d openwrtl ]] && rm -rf openwrt && mv openwrtl openwrt
	}
	ZZZ="package/default-settings/files/zzz-default-settings"
	OpenWrt_name="19.07"
	echo -e "\nipdz=$ip" > openwrt/.Lienol_core
	echo -e "\nGit=$Github" >> openwrt/.Lienol_core
elif [[ $firmware == "Mortal_source" ]]; then
	[[ -d openwrt ]] && {
		rm -rf openwrtl && git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt openwrtl
	} || {
		git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
	}
	[[ $? -ne 0 ]] && {
		TIME r "源码下载失败，请检测网络或更换节点再尝试!"
		rm -rf openwrtl
		echo
	 	exit 1
	} || {
	[[ -d openwrtl ]] && rm -rf openwrt && mv openwrtl openwrt
	}
	ZZZ="package/emortal/default-settings/files/zzz-default-settings"
	OpenWrt_name="21.02"
	echo -e "\nipdz=$ip" > openwrt/.Mortal_core
	echo -e "\nGit=$Github" >> openwrt/.Mortal_core
elif [[ $firmware == "openwrt_amlogic" ]]; then
	[[ -d openwrt ]] && {
		rm -rf openwrtl && git clone https://github.com/coolsnowwolf/lede openwrtl
	} || {
		git clone https://github.com/coolsnowwolf/lede openwrt
		
	}
	[[ $? -eq 0 ]] && {
		cp -Rf compile.sh openwrt/compile.sh
	} || {
		TIME r "源码下载失败，请检测网络或更换节点再尝试!"
		rm -rf openwrtl
		echo
	 	exit 1
	}
	echo
	TIME g "正在下载打包所需的内核,请耐心等候~~~"
	echo
	rm -rf amlogic-s9xxx && svn co https://github.com/ophub/amlogic-s9xxx-openwrt/trunk/amlogic-s9xxx amlogic-s9xxx
	[[ $? -ne 0 ]] && {
		rm -rf {amlogic-s9xxx,openwrtlede}
		TIME r "内核下载失败，请检测网络或更换节点再尝试!"
		echo
		exit 1
	} || {
	[[ -d openwrtl ]] && rm -rf openwrt && mv openwrtl openwrt
	mv amlogic-s9xxx openwrt/amlogic-s9xxx
	curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/make > openwrt/make
	mkdir -p openwrt/openwrt-armvirt
	chmod 777 openwrt/make
	}
	ZZZ="package/lean/default-settings/files/zzz-default-settings"
	OpenWrt_name="18.06"
	echo -e "\nipdz=$ip" > openwrt/.amlogic_core
	echo -e "\nGit=$Github" >> openwrt/.amlogic_core
fi
Home="$PWD/openwrt"
PATH1="$PWD/openwrt/build/${firmware}"
[[ -e ${Core} ]] && cp -Rf {.bf_config,compile.sh,${Core},dl} $Home
rm -rf {.bf_config,compile.sh,dl}
rm -rf {.Lede_core,.Lienol_core,.amlogic_core}
echo "Compile_Date=$(date +%Y%m%d%H%M)" > $Home/Openwrt.info
[ -f $Home/Openwrt.info ] && . $Home/Openwrt.info
svn co https://github.com/281677160/AutoBuild-OpenWrt/trunk/build $Home/build > /dev/null 2>&1
[[ $? -ne 0 ]] && {
	TIME r "编译脚本下载失败，请检测网络或更换节点再尝试!"
	exit 1
}
git clone https://github.com/281677160/common $Home/build/common
[[ $? -ne 0 ]] && {
	TIME r "脚本扩展下载失败，请检测网络或更换节点再尝试!"
	exit 1
}
chmod -R +x $Home/build/common
chmod -R +x $Home/build/${firmware}
source $Home/build/${firmware}/settings.ini
REGULAR_UPDATE="${REG_UPDATE}"
cp -Rf $Home/build/common/Custom/compile.sh openwrt/compile.sh
cp -Rf $Home/build/common/*.sh openwrt/build/${firmware}
echo
TIME g "正在加载自定义文件和下载插件,请耐心等候~~~"
echo
cd $Home
./scripts/feeds update -a > /dev/null 2>&1
if [[ "${REPO_BRANCH}" == "master" ]]; then
          source build/${firmware}/common.sh && Diy_lede
          cp -Rf build/common/LEDE/files ./
          cp -Rf build/common/LEDE/diy/* ./
	  cp -Rf build/common/LEDE/patches/* "${PATH1}/patches"
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
          source build/${firmware}/common.sh && Diy_lienol
          cp -Rf build/common/LIENOL/files ./
          cp -Rf build/common/LIENOL/diy/* ./
	  cp -Rf build/common/LIENOL/patches/* "${PATH1}/patches"
fi
source build/${firmware}/common.sh && Diy_all
[[ $? -ne 0 ]] && {
	TIME r "插件包下载失败，请检测网络或更换节点再尝试!"
	echo
	exit 1
}
if [[ $firmware == "openwrt_amlogic" ]]; then
	packages=" \
	brcmfmac-firmware-43430-sdio brcmfmac-firmware-43455-sdio kmod-brcmfmac wpad \
	kmod-fs-ext4 kmod-fs-vfat kmod-fs-exfat dosfstools e2fsprogs ntfs-3g \
	kmod-usb2 kmod-usb3 kmod-usb-storage kmod-usb-storage-extras kmod-usb-storage-uas \
	kmod-usb-net kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 \
	blkid lsblk parted fdisk cfdisk losetup resize2fs tune2fs pv unzip \
	lscpu htop iperf3 curl lm-sensors python3 luci-app-amlogic
	"
	sed -i '/FEATURES+=/ { s/cpiogz //; s/ext4 //; s/ramdisk //; s/squashfs //; }' \
    	target/linux/armvirt/Makefile
	for x in $packages; do
    	sed -i "/DEFAULT_PACKAGES/ s/$/ $x/" target/linux/armvirt/Makefile
	done
	sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile
	sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile
fi
if [ -n "$(ls -A "build/$firmware/diy" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/diy/* ./
fi
if [ -n "$(ls -A "build/$firmware/files" 2>/dev/null)" ]; then
          cp -Rf build/$firmware/files ./ && chmod -R +x files
fi
if [ -n "$(ls -A "build/$firmware/patches" 2>/dev/null)" ]; then
          find "build/$firmware/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward"
fi
echo
TIME g "正在加载源和安装源,请耐心等候~~~"
echo
sed -i "/uci commit fstab/a\uci commit network" $ZZZ
sed -i "/uci commit network/i\uci set network.lan.ipaddr='$ip'" $ZZZ
sed -i "s/OpenWrt /${Ubuntu_mz} Compiled in $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" $ZZZ
sed -i '/CYXluq4wUazHjmCDBCqXF/d' $ZZZ
echo
sed -i 's/"管理权"/"改密码"/g' `grep "管理权" -rl ./feeds/luci/modules/luci-base`
sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./feeds/luci/applications`
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./feeds/luci/applications`
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds install -a
[[ ! -e ${Home}/.bf_config ]] && {
	cp -rf ${Home}/build/${firmware}/.config ${Home}/.config
} || {
	cp -rf ${Home}/.bf_config ${Home}/.config
}
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
	  source build/$firmware/upgrade.sh && Diy_Part1
fi
find . -name 'LICENSE' -o -name 'README' -o -name 'README.md' -o -name '*.git*' | xargs -i rm -rf {}
find . -name 'CONTRIBUTED.md' -o -name 'README_EN.md' -o -name 'README.cn.md' | xargs -i rm -rf {}
[ "${Menuconfig}" == "YES" ] && {
make menuconfig
}
make defconfig
cp -rf ${Home}/.config ${Home}/.bf_config
TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)"
TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)"
if [[ `grep -c "CONFIG_TARGET_x86_64=y" .config` -eq '1' ]]; then
          TARGET_PROFILE="x86-64"
elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" .config` -eq '1' ]]; then
          TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
          TARGET_PROFILE="armvirt"
fi
if [ "${REGULAR_UPDATE}" == "true" ]; then
          source build/$firmware/upgrade.sh && Diy_Part2
fi
if [[ "${REPO_BRANCH}" == "master" ]]; then
	sed -i 's/distversion)%>/distversion)%><!--/g' package/lean/autocore/files/*/index.htm
	sed -i 's/luciversion)%>)/luciversion)%>)-->/g' package/lean/autocore/files/*/index.htm
fi
echo
TIME g "正在下载DL文件,请耐心等待..."
echo
[[ -d $Home/dl ]] && {
	make -j8 download 2>&1 |tee build.log
	find dl -size -1024c -exec ls -l {} \;
	find dl -size -1024c -exec rm -f {} \;
	if [[ `grep -c "make with -j1 V=s or V=sc" build.log` -ge '1' ]]; then
		TIME y "下载DL有错误，正在重新下载..."
		rm -rf build.log
		echo
		make -j8 download 2>&1 |tee build.log
		find dl -size -1024c -exec ls -l {} \;
		find dl -size -1024c -exec rm -f {} \;
	
	fi
	if [[ `grep -c "make with -j1 V=s or V=sc" build.log` -ge '1' ]]; then
		echo
		TIME r "下载DL失败，请检查网络或者更换节点后再尝试编译!"
		echo
		exit 1
	fi
	
} || {
	make download -j8 V=s
	find dl -size -1024c -exec ls -l {} \;
	find dl -size -1024c -exec rm -f {} \;
	make -j8 download 2>&1 |tee build.log
	if [[ `grep -c "make with -j1 V=s or V=sc" build.log` -ge '1' ]]; then
		echo
		TIME r "下载DL失败，请检查网络或者更换节点后再尝试编译!"
		echo
		exit 1
	fi
}
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c > CPU
cat /proc/cpuinfo | grep "cpu cores" | uniq >> CPU
sed -i 's|[[:space:]]||g; s|^.||' CPU && sed -i 's|CPU||g; s|pucores:||' CPU
CPUNAME="$(awk 'NR==1' CPU)" && CPUCORES="$(awk 'NR==2' CPU)"
rm -rf CPU
clear
echo
echo
echo
TIME y "您的CPU型号为[ ${CPUNAME} ]"
echo
echo
TIME y "在Ubuntu使用核心数为[ ${CPUCORES} ],线程数为[ $(nproc) ]"
echo
echo
if [[ "$(nproc)" == "1" ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[3.5]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (2|3) ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[3]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (4|5) ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[2.5]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (6|7) ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[2]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (8|9) ]]; then
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[1.5]小时左右,请耐心等待..."
else
	TIME y "正在使用[$(nproc)线程]编译固件,预计要[1]小时左右,请耐心等待..."
fi
sleep 15s
make -j$(nproc) V=s 2>&1 |tee build.log

if [ "$?" == "0" ]; then
	End="$(TZ=UTC-8 date "+%Y/%m/%d-%H.%M")"
	rm -rf $Home/build.log
	clear
	echo
	echo
	echo
	[[ ${firmware} == "openwrt_amlogic" ]] && {
		TIME y "使用[ ${firmware} ]文件夹，编译[ N1和晶晨系列盒子专用固件 ]顺利编译完成~~~"
	} || {
		TIME y "使用[ ${firmware} ]文件夹，编译[ ${TARGET_PROFILE} ]顺利编译完成~~~"
	}
	echo
	TIME y "后台地址: $ip"
	echo
	TIME y "用户名: root"
	echo
	TIME y "密 码: 无"
	echo
	TIME g "开始时间：${Begin}"
	echo
	TIME g "结束时间：${End}"
	echo
	TIME y "固件已经存入openwrt/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}文件夹中"
	echo
	if [[ "${REGULAR_UPDATE}" == "true" ]]; then
		[ -f $Home/Openwrt.info ] && . $Home/Openwrt.info
		cp -Rf ${Home}/bin/targets/*/* ${Home}/upgrade
		source build/${firmware}/upgrade.sh && Diy_Part3
		TIME g "加入‘定时升级固件插件’的固件已经放入[bin/Firmware]文件夹中"
		echo
	fi
	rm -rf $Home/Openwrt.info
	rm -rf ${Home}/upgrade
	if [[ $firmware == "openwrt_amlogic" ]]; then
		cp -Rf ${Home}/bin/targets/*/*/*.tar.gz ${Home}/openwrt-armvirt/ && sync
		TIME l "请输入一键打包命令进行打包固件，打包成功后，固件存放在[openwrt/out]文件夹中"
	fi
else
	echo
	echo
	TIME r "编译失败~~!"
	echo
	TIME y "请用WinSCP工具连接ubuntu然后把openwrt文件夹里面的[build.log]文件拖至电脑上"
	echo
	TIME y "在电脑上查看build.log文件日志详情！"
	echo
fi
cd ../
rm -rf compile.sh
sleep 2s
echo
echo
exit 0
