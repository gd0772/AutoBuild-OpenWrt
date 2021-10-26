#!/bin/bash


TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\033[1;91m";;
	g) export Color="\033[0;92m";;
	B) export Color="\033[1;36m";;
	y) export Color="\033[0;33m";;
	z) export Color="\033[1;95m";;
	h) export Color="\033[1;34m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
source /bin/openwrt_info
[ ! -d ${Download_Path} ] && mkdir -p ${Download_Path}
wget -q --no-cookie --no-check-certificate -T 15 -t 4 ${Github_Tags} -O ${Download_Tags}
[[ ! $? == 0 ]] && {
	TIME r "获取固件版本信息失败,请检测网络或您的网络需要翻墙,或者您更改的Github地址为无效地址!"
	exit 1
}
Kernel="$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+" /usr/lib/opkg/info/kernel.control)"
clear && echo "Openwrt-AutoUpdate Script ${Version}"
echo
echo
TIME h "执行：转换成其他源码固件"
echo
echo
TIME y "当前源码：${REPO_Name}  /  ${Luci_Edition} / ${Kernel}"
TIME y "固件格式：${EFI_Mode}${Firmware_SFX}"
TIME y "设备型号：${DEFAULT_Device}"
echo
if [[ "${REPO_Name}" == "lede" ]]; then
	if [[ `cat ${Download_Tags} | grep -c "19.07-lienol-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG1="1"
	fi
	if [[ `cat ${Download_Tags} | grep -c "21.02-mortal-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG2="2"
	fi
	if [[ -z "${ZHUANG1}" ]] && [[ -z "${ZHUANG2}" ]]; then
		TIME r "没有检测到有其他作者相同机型的固件版本,或者固件格式不相同!"
		echo
		exit 1
	fi
	if [[ -n "${ZHUANG1}" ]] && [[ -n "${ZHUANG2}" ]]; then
		ZHUANG1="3"
		ZHUANG2="3"
		ZHUANG3="3"
	fi
fi
if [[ "${REPO_Name}" == "lienol" ]]; then
	if [[ `cat ${Download_Tags} | grep -c "18.06-lede-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG1="1"
	fi
	if [[ `cat ${Download_Tags} | grep -c "21.02-mortal-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG2="2"
	fi
	if [[ -z "${ZHUANG1}" ]] && [[ -z "${ZHUANG2}" ]]; then
		TIME r "没有检测到有其他作者相同机型的固件版本,或者固件格式不相同!"
		echo
		exit 1
	fi
	if [[ -n "${ZHUANG1}" ]] && [[ -n "${ZHUANG2}" ]]; then
		ZHUANG1="3"
		ZHUANG2="3"
		ZHUANG3="3"
	fi
fi
if [[ "${REPO_Name}" == "mortal" ]]; then
	if [[ `cat ${Download_Tags} | grep -c "18.06-lede-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG1="1"
	fi
	if [[ `cat ${Download_Tags} | grep -c "19.07-lienol-${DEFAULT_Device}-.*${BOOT_Type}-.*${Firmware_SFX}"` -ge '1' ]]; then
		ZHUANG2="2"
	fi
	if [[ -z "${ZHUANG1}" ]] && [[ -z "${ZHUANG2}" ]]; then
		TIME r "没有检测到有其他作者相同机型的固件版本,或者固件格式不相同!"
		echo
		exit 1
	fi
	if [[ -n "${ZHUANG1}" ]] && [[ -n "${ZHUANG2}" ]]; then
		ZHUANG1="3"
		ZHUANG2="3"
		ZHUANG3="3"
	fi
fi
echo
TIME z "请注意：选择更换其他源码固件后,立即执行不保留配置安装新固件!"
echo
echo
echo
if [[ "${REPO_Name}" == "lede" ]]; then
	if [[ "${ZHUANG1}" == "1" ]]; then
		TIME B "1. 转换成 Lienol 19.07 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=19.07
			CURRENT_Version=lienol-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=19.07
			REPO_Name=lienol
			Github_Release=${Github_Release}
			Egrep_Firmware=19.07-lienol-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			TIME r "您退出了固件转换程序"
			echo
			sleep 2
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG2}" == "2" ]]; then
		TIME B "1. 转换成 mortal 21.02 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=21.02
			CURRENT_Version=mortal-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=21.02
			REPO_Name=mortal
			Github_Release=${Github_Release}
			Egrep_Firmware=21.02-mortal-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			echo
			TIME r "您退出了固件转换程序"
			echo
			sleep 1
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG3}" == "3" ]]; then
		TIME B "1. 转换成 Lienol 19.07 其他内核版本?"
		echo
		TIME B "2. 转换成 mortal 21.02 其他内核版本?"
		echo
		TIME B "3. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2、3 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=19.07
			CURRENT_Version=lienol-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=19.07
			REPO_Name=lienol
			Github_Release=${Github_Release}
			Egrep_Firmware=19.07-lienol-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=21.02
			CURRENT_Version=mortal-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=21.02
			REPO_Name=mortal
			Github_Release=${Github_Release}
			Egrep_Firmware=21.02-mortal-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		3)
			echo
			TIME r "您退出了固件转换程序"
			echo
			sleep 1
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	fi

fi
if [[ "${REPO_Name}" == "lienol" ]]; then
	if [[ "${ZHUANG1}" == "1" ]]; then
		TIME B "1. 转换成 Lede 18.06 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=18.06
			CURRENT_Version=lede-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=18.06
			REPO_Name=lede
			Github_Release=${Github_Release}
			Egrep_Firmware=18.06-lede-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			echo
			TIME r "您退出了固件转换程序"
			echo
			sleep 1
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG2}" == "2" ]]; then
		TIME B "1. 转换成 mortal 21.02 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=21.02
			CURRENT_Version=mortal-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=21.02
			REPO_Name=mortal
			Github_Release=${Github_Release}
			Egrep_Firmware=21.02-mortal-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			echo
			TIME r "您退出了固件转换程序"
			echo
			sleep 1
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG3}" == "3" ]]; then
		TIME B "1. 转换成 Lede 18.06 其他内核版本?"
		echo
		TIME B "2. 转换成 mortal 21.02 其他内核版本?"
		echo
		TIME B "3. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2、3 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=18.06
			CURRENT_Version=lede-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=18.06
			REPO_Name=lede
			Github_Release=${Github_Release}
			Egrep_Firmware=18.06-lede-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=21.02
			CURRENT_Version=mortal-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=21.02
			REPO_Name=mortal
			Github_Release=${Github_Release}
			Egrep_Firmware=21.02-mortal-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		3)
			echo
			TIME r "您退出了固件转换程序"
			echo
			sleep 1
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	fi

fi
if [[ "${REPO_Name}" == "mortal" ]]; then
	if [[ "${ZHUANG1}" == "1" ]]; then
		TIME B "1. 转换成 Lede 18.06 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=18.06
			CURRENT_Version=lede-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=18.06
			REPO_Name=lede
			Github_Release=${Github_Release}
			Egrep_Firmware=18.06-lede-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			echo
			TIME r "您退出了固件转换程序"
			echo
			sleep 1
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG2}" == "2" ]]; then
		TIME B "1. 转换成 lienol 19.07 其他内核版本?"
		echo
		TIME B "2. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=19.07
			CURRENT_Version=lienol-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=19.07
			REPO_Name=lienol
			Github_Release=${Github_Release}
			Egrep_Firmware=19.07-lienol-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			echo
			TIME r "您退出了固件转换程序"
			echo
			sleep 1
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	elif [[ "${ZHUANG3}" == "3" ]]; then
		TIME B "1. 转换成 Lede 18.06 其他内核版本?"
		echo
		TIME B "2. 转换成 lienol 19.07 其他内核版本?"
		echo
		TIME B "3. 退出固件转换程序?"
		echo
		echo
		echo
	while :; do
	TIME g "请选序列号[ 1、2、3 ]输入，然后回车确认您的选择！"
	echo
	read -p " 请输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=18.06
			CURRENT_Version=lede-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=18.06
			REPO_Name=lede
			Github_Release=${Github_Release}
			Egrep_Firmware=18.06-lede-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		2)
			cat >/bin/openwrt_info <<-EOF
			Github=${Github}
			Luci_Edition=19.07
			CURRENT_Version=lienol-${DEFAULT_Device}-202107010100
			DEFAULT_Device=${DEFAULT_Device}
			Firmware_Type=${Firmware_Type}
			LUCI_Name=19.07
			REPO_Name=lienol
			Github_Release=${Github_Release}
			Egrep_Firmware=19.07-lienol-${DEFAULT_Device}
			Download_Path=${Download_Path}
			Version=${Version}
			Download_Tags=${Download_Tags}
			EOF
			echo
			TIME y "转换固件成功，开始安装新源码的固件,请稍后...！"
			sleep 2
			bash /bin/AutoUpdate.sh	-s
			exit 0
		break
		;;
		3)
			echo
			TIME r "您退出了固件转换程序"
			echo
			sleep 1
			exit 0
		break
    		;;
    		*)
			TIME r "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
	fi

fi
exit 0
