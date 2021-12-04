#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoUpdate for Openwrt

Version=V6.5

Shell_Helper() {
echo
echo

echo -e "${Yellow}命令用途：

bash /bin/AutoUpdate.sh				[保留配置更新]
bash /bin/AutoUpdate.sh	-n			[不保留配置更新]
bash /bin/AutoUpdate.sh	-g			[把固件更改成其他作者固件,前提是你编译了有附带定时更新插件的其他作者的固件]
bash /bin/AutoUpdate.sh	-c			[更换Github地址]
bash /bin/AutoUpdate.sh	-t			[执行测试模式(只运行,不安装,查看更新固件操作流程)]
bash /bin/AutoUpdate.sh	-h			[列出帮助信息]
${White}"

echo -e "${Purple}	
===============================================================================================
${White}"
echo
[[ -f /etc/CLOUD_Name ]] && {
	export CLOUD_Name="$(egrep -o "${LUCI_Name}-${CURRENT_Version}${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" /etc/CLOUD_Name | awk 'END {print}')" > /dev/null 2>&1
} || {
	wget -q -P ${Download_Path} https://ghproxy.com/${Github_Tagstwo} -O ${Download_Path}/Github_Tags > /dev/null 2>&1
	export CLOUD_Name="$(egrep -o "${LUCI_Name}-${CURRENT_Version}${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${Download_Tags} | awk 'END {print}')" > /dev/null 2>&1
	[[ ! -f /etc/CLOUD_Name ]] && [[ ${CLOUD_Name} ]] && echo "${CLOUD_Name}" > /etc/CLOUD_Name
}
echo -e "${Green}详细参数：

/overlay 可用:					${Overlay_Available}
/tmp 可用:					${TMP_Available}M
固件下载位置:					${Download_Path}
当前设备名称:					${CURRENT_Device}
固件上的名称:					${DEFAULT_Device}
当前固件版本:					${CURRENT_Version}
Github 地址:					${Github}
解析 API 地址:					${Github_Tags}
固件下载地址:					${Github_Release}
更新运行日志:					${AutoUpdate_Log_Path}/AutoUpdate.log
固件作者:					${Author}
作者仓库:					${CangKu}
固件名称:					${CLOUD_Name}
固件格式:					${EFI_Mode}${Firmware_SFX}
${White}"
exit 0
}
White="\033[0;37m"
Yellow="\033[0;33m"
Red="\033[1;91m"
Blue="\033[0;94m"
BLUEB="\033[1;94m"
BCyan="\033[1;36m"
Grey="\033[1;34m"
Green="\033[0;92m"
Purple="\033[1;95m"
[ -f /bin/openwrt_info ] && {
	chmod +x /bin/openwrt_info
	source /bin/openwrt_info 
} || {
	echo -e "\n${Red}未检测到更新插件所需文件,无法运行更新程序!${White}"
	echo
	exit 1
}
export Input_Option=$1
export Input_Other=$2
export Apidz="${Github##*com/}"
export Author="${Apidz%/*}"
export CangKu="${Apidz##*/}"
export Github_Tags="https://api.github.com/repos/${Apidz}/releases/tags/AutoUpdate"
export Github_Tagstwo="${Github}/releases/download/AutoUpdate/Github_Tags"
export Kernel="$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+" /usr/lib/opkg/info/kernel.control)"
export Overlay_Available="$(df -h | grep ":/overlay" | awk '{print $4}' | awk 'NR==1')"
rm -rf "${Download_Path}" && export TMP_Available="$(df -m | grep "/tmp" | awk '{print $4}' | awk 'NR==1' | awk -F. '{print $1}')"
[ ! -d "${Download_Path}" ] && mkdir -p ${Download_Path}
opkg list | awk '{print $1}' > ${Download_Path}/Installed_PKG_List
export PKG_List="${Download_Path}/Installed_PKG_List"
export AutoUpdate_Log_Path="/tmp"
GET_PID() {
	local Result
	while [[ $1 ]];do
		Result=$(busybox ps | grep "$1" | grep -v "grep" | awk '{print $1}' | awk 'NR==1')
		[[ -n ${Result} ]] && echo ${Result}
	shift
	done
}
TIME() {
	local Color
	[[ -z $1 ]] && {
		echo -ne "\n${Grey}[$(date "+%H:%M:%S")]${White} "
	} || {
	case $1 in
		r) Color="${Red}";;
		g) Color="${Green}";;
		b) Color="${Blue}";;
		B) Color="${BLUEB}";;
		y) Color="${Yellow}";;
		h) Color="${BCyan}";;
		z) Color="${Purple}";;
		x) Color="${Grey}";;
	esac
		[[ $# -lt 2 ]] && {
			echo -e "\n${Grey}[$(date "+%H:%M:%S")]${White} $1"
			LOGGER $1
		} || {
			echo -e "\n${Grey}[$(date "+%H:%M:%S")]${White} ${Color}$2${White}"
			LOGGER $2
		}
	}
}

LOGGER() {
	[[ ! -d ${AutoUpdate_Log_Path} ]] && mkdir -p ${AutoUpdate_Log_Path}
	[[ ! -f ${AutoUpdate_Log_Path}/AutoUpdate.log ]] && touch ${AutoUpdate_Log_Path}/AutoUpdate.log
	echo "[$(date "+%Y-%m-%d-%H:%M:%S")] [$(GET_PID AutoUpdate.sh)] $*" >> ${AutoUpdate_Log_Path}/AutoUpdate.log
}
case ${DEFAULT_Device} in
x86-64)
	[ -d /sys/firmware/efi ] && {
		export BOOT_Type="-UEFI"
		export EFI_Mode="UEFI"
	} || {
		export BOOT_Type="-Legacy"
		export EFI_Mode="Legacy"
	}
	export CURRENT_Device="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
  	export Firmware_SFX=".${Firmware_Type}"
	[[ -z "${Firmware_Type}" ]] && export Firmware_SFX=".img.gz"
;;
*)
	export CURRENT_Device="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
	export Firmware_SFX=".${Firmware_Type}"
	export BOOT_Type="-Sysupg"
	export EFI_Mode=""
	[[ -z "${Firmware_Type}" ]] && export Firmware_SFX=".bin"
esac
export CURRENT_Ver="${CURRENT_Version}${BOOT_Type}"
echo "CURRENT_Version=${CURRENT_Version}" > /etc/openwrt_ver
echo -e "\nCURRENT_Model=${EFI_Mode}${Firmware_SFX}" >> /etc/openwrt_ver
echo -e "\nNEI_Luci=${Kernel} - ${Luci_Edition}" >> /etc/openwrt_ver
cd /etc
clear && echo "Openwrt-AutoUpdate Script ${Version}"
echo
if [[ -z "${Input_Option}" ]];then
	export Upgrade_Options="sysupgrade -q"
	export Update_Mode=1
	TIME h "执行: 保留配置更新固件[静默模式]"
else
	case ${Input_Option} in
	-t | -n | -f | -u | -N | -s | -w)
		case ${Input_Option} in
		-t)
			export Input_Other="-t"
			TIME h "执行: 测试模式"
			TIME z "测试模式(只运行,不安装,查看更新固件操作流程是否正确)"
		;;
		-w)
			export Input_Other="-w"
		;;
		-n | -N)
			export Upgrade_Options="sysupgrade -n"
			TIME h "执行: 更新固件(不保留配置)"
		;;
		-s)
			export Upgrade_Options="sysupgrade -F -n"
			TIME h "执行: 强制更新固件(不保留配置)"
		;;
		-u)
			export AutoUpdate_Mode=1
			export Upgrade_Options="sysupgrade -q"
		;;
		esac
	;;
	-c)
			source /bin/openwrt_info
			TIME h "执行：更换[Github地址]操作"
			TIME y "地址格式：https://github.com/帐号/仓库"
			TIME z  "正确地址示例：https://github.com/281677160/AutoBuild-OpenWrt"
			TIME h  "现在所用地址为：${Github}"
			echo
			read -p "请输入新的Github地址：" Input_Other
			Input_Other="${Input_Other:-"$Github"}"
			Github_uci=$(uci get autoupdate.@login[0].github 2>/dev/null)
			[[ -n "${Github_uci}" ]] && [[ "${Github_uci}" != "${Input_Other}" ]] && {
				uci set autoupdate.@login[0].github=${Input_Other}
				uci commit autoupdate
				TIME y "Github 地址已更换为: ${Input_Other}"
				TIME y "UCI 设置已更新!"
				echo
			}
			Input_Other="${Input_Other:-"$Github"}"
			[[ "${Github}" != "${Input_Other}" ]] && {
				sed -i "s?${Github}?${Input_Other}?g" /bin/openwrt_info
				unset Input_Other
				exit 0
			} || {
				TIME g "INPUT: ${Input_Other}"
				TIME r "输入的 Github 地址相同,无需修改!"
				echo
				exit 1
			}
	;;
	-h | -H | -l | -L)
		Shell_Helper
	;;
	-g | -G)
		bash /bin/replace.sh
		sleep 1
		exit 0
	;;
	*)
		echo -e "\nERROR INPUT: [$*]"
		Shell_Helper
	;;
	esac
fi
[[ -z ${CURRENT_Version} ]] && TIME r "本地固件版本获取失败,请检查/bin/openwrt_info文件的值!" && exit 1
[[ -z ${Github} ]] && TIME r "Github地址获取失败,请检查/bin/openwrt_info文件的值!" && exit 1
TIME g "正在获取云端固件版本信息..."
[ ! -d ${Download_Path} ] && mkdir -p ${Download_Path}
wget -q ${Github_Tags} -O ${Download_Tags} > /dev/null 2>&1
if [[ $? -ne 0 ]];then
	wget -q -P ${Download_Path} https://pd.zwc365.com/${Github_Tagstwo} -O ${Download_Path}/Github_Tags > /dev/null 2>&1
	if [[ $? -ne 0 ]];then
		wget -q -P ${Download_Path} https://ghproxy.com/${Github_Tagstwo} -O ${Download_Path}/Github_Tags > /dev/null 2>&1
	fi
	if [[ $? -ne 0 ]];then
		TIME r "获取固件版本信息失败,请检测网络,或者您更改的Github地址为无效地址,或者您的仓库是私库,或者发布已被删除!"
		echo
		exit 1
	fi
fi
export CLOUD_Name="$(egrep -o "${LUCI_Name}-${CURRENT_Version}${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${Download_Tags} | awk 'END {print}')"
[[ ! -f /etc/CLOUD_Name ]] && echo "${CLOUD_Name}" > /etc/CLOUD_Name
TIME g "正在比对云端固件和本地安装固件版本..."
export CLOUD_Firmware="$(egrep -o "${Egrep_Firmware}-[0-9]+${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${Download_Tags} | awk 'END {print}')"
export CLOUD_sion="$(echo ${CLOUD_Firmware} | egrep -o "${REPO_Name}-${DEFAULT_Device}-[0-9]+")"
export CLOUD_Version="$(echo ${CLOUD_Firmware} | egrep -o "${REPO_Name}-${DEFAULT_Device}-[0-9]+${BOOT_Type}")"
[[ -z "${CLOUD_Version}" ]] && {
	TIME r "比对固件版本失败!"
	exit 1
}
[[ "${Input_Other}" == "-w" ]] && {
	echo -e "\nCLOUD_Version=${CLOUD_sion}" > /tmp/Version_Tags
	echo -e "\nCURRENT_Version=${CURRENT_Version}" >> /tmp/Version_Tags
	exit 0
}
export Firmware_Name="$(echo ${CLOUD_Firmware} | egrep -o "${Egrep_Firmware}-[0-9]+${BOOT_Type}-[a-zA-Z0-9]+")"
export Firmware="${CLOUD_Firmware}"
export CLOUD_Name="$(egrep -o "${LUCI_Name}-${CURRENT_Version}${BOOT_Type}-[a-zA-Z0-9]+${Firmware_SFX}" ${Download_Tags} | awk 'END {print}')"
let X=$(grep -n "${Firmware}" ${Download_Tags} | tail -1 | cut -d : -f 1)-4
let CLOUD_Firmware_Size=$(sed -n "${X}p" ${Download_Tags} | egrep -o "[0-9]+" | awk '{print ($1)/1048576}' | awk -F. '{print $1}')+1
echo -e "\n本地版本：${CURRENT_Ver}"
echo "云端版本：${CLOUD_Version}"	
[[ "${TMP_Available}" -lt "${CLOUD_Firmware_Size}" ]] && {
	TIME g "tmp 剩余空间: ${TMP_Available}M"
	TIME r "tmp空间不足[${CLOUD_Firmware_Size}M],不够下载固件所需,请清理tmp空间或者增加运行内存!"
	echo
	exit 1
}
if [[ ! "${Force_Update}" == 1 ]];then
  	if [[ "${CURRENT_Version}" -gt "${CLOUD_Version}" ]];then
		TIME r "检测到有可更新的固件版本,立即更新固件!"
	fi
  	if [[ "${CURRENT_Version}" -eq "${CLOUD_Version}" ]];then
		[[ "${AutoUpdate_Mode}" == 1 ]] && exit 0
		TIME && read -p "当前版本和云端最新版本一致，是否还要重新安装固件?[Y/n]:" Choose
		[[ "${Choose}" == Y ]] || [[ "${Choose}" == y ]] && {
			TIME z "正在开始重新安装固件..."
		} || {
			TIME r "已取消重新安装固件,即将退出程序..."
			sleep 2
			exit 0
		}
	fi
  	if [[ "${CURRENT_Version}" -lt "${CLOUD_Version}" ]];then
		[[ "${AutoUpdate_Mode}" == 1 ]] && exit 0
		TIME && read -p "云端最高版本,低于您现在的版本,是否强制覆盖现有固件?[Y/n]:" Choose
		[[ "${Choose}" == Y ]] || [[ "${Choose}" == y ]] && {
			TIME z "正在开始使用云端版本覆盖现有固件..."
		} || {
			TIME r "已取消覆盖固件,退出程序..."
			sleep 2
			exit 0
		}
	fi
fi
TIME g "列出详细信息..."
sleep 1
echo -e "\n固件作者：${Author}"
echo "设备名称：${CURRENT_Device}"
echo "固件格式：${Firmware_SFX}"
[[ "${DEFAULT_Device}" == x86-64 ]] && {
	echo "引导模式：${EFI_Mode}"
}
echo "固件名称：${Firmware}"
echo "下载保存：${Download_Path}"
echo "固件体积：${CLOUD_Firmware_Size}M"
cd ${Download_Path}
[[ "$(cat ${Download_Path}/Installed_PKG_List)" =~ curl ]] && {
	export Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
	if [ ! "$Google_Check" == 301 ];then
		TIME g "正在下载云端固件,请耐心等待..."
		wget -q "https://ghproxy.com/${Github_Release}/${Firmware}" -O ${Firmware}
		if [[ $? -ne 0 ]];then
			wget -q "https://pd.zwc365.com/${Github_Release}/${Firmware}" -O ${Firmware}
			if [[ $? -ne 0 ]];then
				TIME r "下载云端固件失败,请尝试手动安装!"
				echo
				exit 1
			else
				TIME y "下载云端固件成功!"
			fi
		else
			TIME y "下载云端固件成功!"
		fi
	else
		TIME g "正在下载云端固件,请耐心等待..."
		wget -q "${Github_Release}/${Firmware}" -O ${Firmware}
		if [[ $? -ne 0 ]];then
			wget -q "https://ghproxy.com/${Github_Release}/${Firmware}" -O ${Firmware}
			if [[ $? -ne 0 ]];then
				TIME r "下载云端固件失败,请尝试手动安装!"
				echo
				exit 1
			else
				TIME y "下载云端固件成功!"
			fi
		else
			TIME y "下载云端固件成功!"
		fi
	fi
}
export CLOUD_MD5=$(md5sum ${Firmware} | cut -c1-3)
export CLOUD_256=$(sha256sum ${Firmware} | cut -c1-3)
export MD5_256=$(echo ${Firmware} | egrep -o "[a-zA-Z0-9]+${Firmware_SFX}" | sed -r "s/(.*)${Firmware_SFX}/\1/")
export CURRENT_MD5="$(echo "${MD5_256}" | cut -c1-3)"
export CURRENT_256="$(echo "${MD5_256}" | cut -c 4-)"
[[ ${CURRENT_MD5} != ${CLOUD_MD5} ]] && {
	TIME r "MD5对比失败,固件可能在下载时损坏,请检查网络后重试!"
	exit 1
}
[[ ${CURRENT_256} != ${CLOUD_256} ]] && {
	TIME r "SHA256对比失败,固件可能在下载时损坏,请检查网络后重试!"
	exit 1
}
chmod 777 ${Firmware}
TIME g "准备更新固件,更新期间请不要断开电源或重启设备 ..."
[[ "${Input_Other}" == "-t" ]] && {
	TIME z "测试模式运行完毕!"
	rm -rf "${Download_Path}"
	echo
	exit 0
}
sleep 2
TIME g "正在更新固件,请耐心等待 ..."
[[ "$(cat ${PKG_List})" =~ gzip ]] && opkg remove gzip > /dev/null 2>&1
if [[ "${AutoUpdate_Mode}" == 1 ]] || [[ "${Update_Mode}" == 1 ]]; then
	source /etc/deletefile
	cp -Rf /etc/config/network /mnt/network
	mv -f /etc/config/luci /etc/config/luci-
	sysupgrade -b /mnt/back.tar.gz
	[[ $? == 0 ]] && {
		mv -f /etc/config/luci- /etc/config/luci
		export Upgrade_Options="sysupgrade -f /mnt/back.tar.gz"
	} || {
		mv -f /etc/config/luci- /etc/config/luci
		export Upgrade_Options="sysupgrade -q"
	}
fi

${Upgrade_Options} ${Firmware}

exit 0

