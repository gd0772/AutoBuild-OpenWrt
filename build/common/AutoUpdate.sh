#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001
# AutoUpdate for Openwrt

Version=V5.6

List_Info() {
	echo -e "\n/overlay 可用:	${Overlay_Available}"
	echo "/tmp 可用:	${TMP_Available}M"
	echo "固件下载位置:	/tmp/Downloads"
	echo "当前设备:	${CURRENT_Device}"
	echo "默认设备:	${DEFAULT_Device}"
	echo "固件作者:	${Author}"
	echo "作者仓库:	${Cangku}"
	echo "固件版本:	${CURRENT_Ver}"
	echo "固件名称:	${Firmware_COMP1}-${CURRENT_Version}${Firmware_SFX}"
	echo "Github 地址:	${Github}"
	echo "解析 API 地址:	${Github_Tags}"
	echo "固件下载地址:	${Github_Download}"
	if [[ ${DEFAULT_Device} == "x86-64" ]];then
		echo "引导模式: 	${EFI_Boot}"
		echo "GZIP压缩:	${Compressed_x86}"
	fi
	echo "固件格式:	${Firmware_GESHI}"
	exit
}

Shell_Helper() {
	echo -e "\n使用方法: bash /bin/AutoUpdate.sh [参数1] [参数2]"
	echo -e "\n支持下列参数:\n"
	echo "	-q	更新固件,不打印备份信息日志 [保留配置]"
	echo "	-n	更新固件 [不保留配置]"
	echo "	-f	强制更新固件,即跳过版本号验证,自动下载以及安装必要软件包 [保留配置]"
	echo "	-u	适用于定时更新 LUCI 的参数 [保留配置]"
	echo "	-c	[更换检测地址,命令 bash /bin/AutoUpdate.sh -c 地址"
	echo "	-b	[转换固件引导格式,命令 bash /bin/AutoUpdate.sh -b Legacy 或 bash /bin/AutoUpdate.sh -b UEFI [危险]"
	echo "	-l	列出所有信息"
	echo "	-d	清除固件下载缓存"
	echo -e "	-h	打印帮助信息\n"
	exit
}

Install_Pkg() {
	PKG_NAME=${1}
	grep "${PKG_NAME}" /tmp/Package_list > /dev/null 2>&1
	if [[ $? -ne 0 ]];then
		TIME && echo "未安装[ ${PKG_NAME} ],执行安装[ ${PKG_NAME} ],请耐心等待..."
		wget -q -c -P /tmp https://downloads.openwrt.org/snapshots/packages/x86_64/packages/gzip_1.10-3_x86_64.ipk
		opkg install /tmp/gzip_1.10-3_x86_64.ipk --force-depends
		if [[ $? -ne 0 ]];then
			TIME && echo "[ ${PKG_NAME} ] 安装失败,正在再次尝试安装...!"
			opkg update > /dev/null 2>&1
			opkg install ${PKG_NAME}
			if [[ $? -ne 0 ]];then
				TIME && echo "再次尝试安装[ ${PKG_NAME} ]失败,请尝试手动安装!"
				exit
			else
				TIME && echo "再次尝试安装[ ${PKG_NAME} ]安装成功!"
				sleep 1
				TIME && echo "开始解压固件,请耐心等待..."
			fi
		else
			TIME && echo "[ ${PKG_NAME} ] 安装成功!"
			sleep 1
			TIME && echo "开始解压固件,请耐心等待...!"
		fi
	fi
}

TIME() {
	echo -ne "\n[$(date "+%H:%M:%S")] "
}

opkg list | awk '{print $1}' > /tmp/Package_list
Input_Option="$1"
Input_Other="$2"
CURRENT_Version="$(awk 'NR==1' /etc/openwrt_info)"
Github="$(awk 'NR==2' /etc/openwrt_info)"
DEFAULT_Device="$(awk 'NR==3' /etc/openwrt_info)"
Firmware_Type="$(awk 'NR==4' /etc/openwrt_info)"
Firmware_COMP1="$(awk 'NR==5' /etc/openwrt_info)"
Firmware_COMP2="$(awk 'NR==6' /etc/openwrt_info)"
Github_Download="${Github}/releases/download/update_Firmware"
Apidz="${Github##*com/}"
Author="${Apidz%/*}"
Cangku="${Github##*${Author}/}"
Github_Tags="https://api.github.com/repos/${Apidz}/releases/tags/update_Firmware"
rm -rf /tmp/Downloads && TMP_Available="$(df -m | grep "/tmp" | awk '{print $4}' | awk 'NR==1' | awk -F. '{print $1}')"
Overlay_Available="$(df -h | grep ":/overlay" | awk '{print $4}' | awk 'NR==1')"
case ${DEFAULT_Device} in
x86-64)
	[[ -z ${Firmware_Type} ]] && Firmware_Type="img"
	if [[ "${Firmware_Type}" == "img.gz" ]];then
		Compressed_x86="YES"
	else
		Compressed_x86="NO"
	fi
	if [ -f /etc/openwrt_boot ];then
		BOOT_Type="-$(cat /etc/openwrt_boot)"
	else
		if [ -d /sys/firmware/efi ];then
			BOOT_Type="-UEFI"
		else
			BOOT_Type="-Legacy"
		fi
	fi
	case "${BOOT_Type}" in
	-Legacy)
		EFI_Boot="Legacy"
	;;
	-UEFI)
		EFI_Boot="UEFI"
	;;
	esac
	CURRENT_Des="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
	CURRENT_Device="${CURRENT_Des} (x86-64)"
	Firmware_SFX="${BOOT_Type}.${Firmware_Type}"
	Firmware_GESHI=".${Firmware_Type}"
	Detail_SFX="${BOOT_Type}.detail"
	Space_Req=480
;;
*)
	CURRENT_Device="$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')"
	Firmware_SFX=".${Firmware_Type}"
	Firmware_GESHI=".${Firmware_Type}"
	[[ -z ${Firmware_SFX} ]] && Firmware_SFX=".${Firmware_Type}"
	Detail_SFX=".detail"
	Space_Req=0
esac
CURRENT_Ver="${CURRENT_Version}${BOOT_Type}"
cd /etc
clear && echo "Openwrt-AutoUpdate Script ${Version}"
if [[ -z "${Input_Option}" ]];then
	Upgrade_Options="-q" && TIME && echo "执行：保留配置更新固件[静默模式]"
	TIME && echo "检测网络环境中,请稍后..."
else
	case ${Input_Option} in
	-n | -f | -u)
		case ${Input_Option} in
		-n)
			Upgrade_Options="-n"
			TIME && echo "执行：更新固件(不保留配置)"
			TIME && echo "检测网络环境中,请稍后..."
		;;
		-f)
			Force_Update=1
			Upgrade_Options="-q"
			TIME && echo "执行：强制更新固件(保留配置)"
			TIME && echo "检测网络环境中,请稍后..."
		;;
		-u)
			AutoUpdate_Mode=1
			Upgrade_Options="-q"
		;;
		esac
	;;
	-c)
		if [[ ! -z "${Input_Other}" ]];then
			sed -i "s?${Github}?${Input_Other}?g" /etc/openwrt_info > /dev/null 2>&1
			echo -e "\nGithub 地址已更换为：${Input_Other}"
			unset Input_Other
		else
			Shell_Helper
		fi
		exit
	;;
	-l | -L)
		List_Info
	;;
	-d)
		rm -f /tmp/Downloads/* /tmp/Github_Tags
		TIME && echo "固件下载缓存清理完成!"
		sleep 1
		exit
	;;
	-h | -H | --help)
		Shell_Helper
	;;
	-b)
		[[ -z "${Input_Other}" ]] && Shell_Helper
		case "${Input_Other}" in
		UEFI | Legacy)
			echo "${Input_Other}" > openwrt_boot
			sed -i '/openwrt_boot/d' /etc/sysupgrade.conf
			echo -e "\n/etc/openwrt_boot" >> /etc/sysupgrade.conf
			TIME && echo "固件引导方式已指定为：${Input_Other}!"
		;;
		*)
			echo -e "\n错误的参数：[${Input_Other}],当前支持的选项: [UEFI/Legacy] !"
		;;
		esac
		exit
	;;
	*)
		echo -e "\nERROR INPUT：[$*]"
		Shell_Helper
	;;
	esac
fi
if [[ ! "${Force_Update}" == "1" ]];then
	grep "curl" /tmp/Package_list > /dev/null 2>&1
	if [[ ! $? -ne 0 ]];then
		Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
		if [ ! "$Google_Check" == 301 ];then
			TIME && echo "梯子翻墙失败,优先使用[ FastGit镜像加速 ]下载,如果失败再转换成[ 普通方式 ]下载!"
			PROXY_URL="https://download.fastgit.org"
		else
			TIME && echo "梯子翻墙成功,优先使用[ 普通方式 ]下载,如果失败再转换成[ FastGit镜像加速 ]下载!"
			PROXY_URL="https://github.com"
		fi
	fi
	if [[ "${TMP_Available}" -lt "${Space_Req}" ]];then
		TIME && echo "/tmp 空间不足：tmp空间不足[${Space_Req}M],无法执行更新!"
		exit
	fi
fi
Install_Pkg wget
if [[ -z "${CURRENT_Version}" ]];then
	TIME && echo "警告：当前固件版本获取失败!"
	CURRENT_Version="未知"
fi
if [[ -z "${CURRENT_Device}" ]];then
	[[ "${Force_Update}" == "1" ]] && exit
	TIME && echo "当前设备名称获取失败,使用预设名称：[$DEFAULT_Device]"
	CURRENT_Device="${DEFAULT_Device}"
fi
TIME && echo "正在获取固件版本信息..."
wget -q ${Github_Tags} -O - > /tmp/Github_Tags
if [[ ! "$?" == 0 ]];then
	TIME && echo "获取固件版本信息失败,请稍后重试!"
	exit
fi
TIME && echo "正在比对云端固件和本地安装固件版本..."
GET_Firmware="$(cat /tmp/Github_Tags | egrep -o "${Firmware_COMP1}-${Firmware_COMP2}-${DEFAULT_Device}-[a-zA-Z0-9_-]+.*?[0-9]+${Firmware_SFX}" | awk 'END {print}')"
GET_Version="$(echo ${GET_Firmware} | egrep -o "${Firmware_COMP2}-${DEFAULT_Device}-[a-zA-Z0-9_-]+.*?[0-9]+${BOOT_Type}")"
if [[ -z "${GET_Firmware}" ]] || [[ -z "${GET_Version}" ]];then
	TIME && echo "比对固件版本失败!"
	exit
fi
Firmware_Info="$(echo ${GET_Firmware} | egrep -o "${Firmware_COMP1}-${Firmware_COMP2}-${DEFAULT_Device}-[a-zA-Z0-9_-]+.*?[0-9]+")"
Firmware="${GET_Firmware}"
Firmware_Detail="${Firmware_Info}${Detail_SFX}"
echo -e "\n本地版本：${CURRENT_Ver}"
echo "云端版本：${GET_Version}"
if [[ ! ${Force_Update} == 1 ]];then
	if [[ ${CURRENT_Version} -gt ${GET_Version} ]];then
		TIME && echo "检测到有可更新的固件版本,立即更新固件!"
		sleep 2
		TIME && echo "读取固件信息..."
		sleep 1
	fi
	if [[ ${CURRENT_Version} -eq ${GET_Version} ]];then
		[[ "${AutoUpdate_Mode}" == "1" ]] && exit
		TIME && read -p "当前版本和云端最新版本一致，是否还要重新安装固件?[Y/n]:" Choose
		if [[ "${Choose}" == Y ]] || [[ "${Choose}" == y ]];then
			TIME && echo "开始重新安装固件..."
			sleep 1
			TIME && echo "读取固件信息..."
			sleep 1
		else
			TIME && echo "已取消重新安装固件,即将退出程序..."
			sleep 2
			exit
		fi
	fi
	if [[ ${CURRENT_Version} -lt ${GET_Version} ]];then
		[[ "${AutoUpdate_Mode}" == "1" ]] && exit
		TIME && read -p "当前版本高于云端最新版,是否使用云端版本覆盖现有固件?[Y/n]:" Choose
		if [[ "${Choose}" == Y ]] || [[ "${Choose}" == y ]];then
			TIME && echo "开始使用云端版本覆盖现有固件..."
			sleep 1
			TIME && echo "读取固件信息..."
			sleep 1
		else
			TIME && echo "已取消覆盖固件,退出程序..."
			sleep 2
			exit
		fi
	fi
fi
echo -e "\n云端固件名称：${Firmware}"
echo "[MD5-SHA256]：${Firmware_Detail}"
echo -e "\n固件作者：${Author}"
echo "设备名称：${CURRENT_Device}"
echo "固件格式：${Firmware_GESHI}"
if [[ ${DEFAULT_Device} == "x86-64" ]];then
	echo "引导模式：${EFI_Boot}"
fi
if [ "${PROXY_URL}" == "https://github.com" ];then
	Github_Download="${PROXY_URL}/${Apidz}/releases/download/update_Firmware"
	PROXY_URLE="https://download.fastgit.org"
	FastGit="[ FastGit镜像加速 ]"
	TIME && echo "正在使用[ 普通方式 ]下载云端固件,请耐心等待..."
	TIME && echo "固件保存位置：/tmp/Downloads"
else
	Github_Download="${PROXY_URL}/${Apidz}/releases/download/update_Firmware"
	PROXY_URLE="https://github.com"
	FastGit="[ 普通方式 ]"
	TIME && echo "正在使用[ FastGit镜像加速 ]下载云端固件,请耐心等待..."
	TIME && echo "固件保存位置：/tmp/Downloads"
fi
[ ! -d "/tmp/Downloads" ] && mkdir -p /tmp/Downloads
cd /tmp/Downloads
wget -q --no-check-certificate -T 20 -t 3 "${Github_Download}/${Firmware}" -O ${Firmware}
if [[ $? -ne 0 ]];then
	TIME && echo "下载云端固件失败,转换成"${FastGit}"下载,请耐心等待... !"
	Github_Download="${PROXY_URLE}/${Apidz}/releases/download/update_Firmware"
	wget -q --no-check-certificate -T 20 -t 3 "${Github_Download}/${Firmware}" -O ${Firmware}
	if [[ $? -ne 0 ]];then
		TIME && echo "下载云端固件失败,请尝试手动安装!"
		exit
	else
		TIME && echo "使用"${FastGit}"下载云端固件成功!"
		sleep 1
	fi
else
	TIME && echo "云端固件下载成功!"
	sleep 1
fi
Github_Download="${PROXY_URL}/${Apidz}/releases/download/update_Firmware"
TIME && echo "正在下载云端[ MD5-SHA256 ],请耐心等待..."
TIME && echo "[ MD5-SHA256 ]保存位置：/tmp/Downloads"
curl -fsSL "${Github_Download}/${Firmware_Detail}" -o ${Firmware_Detail}
if [[ $? -ne 0 ]];then
	TIME && echo "curl方式下载失败,转换成wget方式下载,请耐心等待..."
	wget -q --no-check-certificate -T 60 -t 2 "${Github_Download}/${Firmware_Detail}" -O ${Firmware_Detail}
	if [[ $? -ne 0 ]];then
		TIME && echo "[ MD5-SHA256 ]下载失败,转换成"${FastGit}"下载,请耐心等待... !"
		Github_Download="${PROXY_URLE}/${Apidz}/releases/download/update_Firmware"
		wget -q --no-check-certificate -T 25 -t 3 ${Github_Download}/${Firmware_Detail} -O ${Firmware_Detail}
		if [[ $? -ne 0 ]];then
			TIME && echo "下载[ MD5-SHA256 ]失败,请检查网络再尝试!"
			exit
		else
			TIME && echo "使用"${FastGit}"下载[ MD5-SHA256 ]成功!"
			sleep 1
			TIME && echo "开始对比[ MD5 ] !"
		fi
	else
		TIME && echo "云端[ MD5-SHA256 ]下载成功!"
		sleep 1
		TIME && echo "开始对比[ MD5 ] !"
	fi
else
	TIME && echo "云端[ MD5-SHA256 ]下载成功!"
	sleep 1
	TIME && echo "开始对比[ MD5 ] !"
fi
GET_MD5=$(awk -F '[ :]' '/MD5/ {print $2;exit}' ${Firmware_Detail})
CURRENT_MD5=$(md5sum ${Firmware} | cut -d ' ' -f1)
echo -e "\n本地MD5：${CURRENT_MD5}"
echo "云端MD5：${GET_MD5}"
if [[ -z "${GET_MD5}" ]] || [[ -z "${CURRENT_MD5}" ]];then
	TIME && echo "[ MD5 ]获取失败,请自行下载${Firmware_Detail}检查!"
	exit
fi
if [[ ! "${GET_MD5}" == "${CURRENT_MD5}" ]];then
	TIME && echo "[ MD5 ]对比失败,请检查网络后重试!"
	exit
else
	sleep 1
	TIME && echo "[ MD5 ]对比成功,开始对比[ SHA256 ] !"
	sleep 1
fi
GET_SHA256=$(awk -F '[ :]' '/SHA256/ {print $2;exit}' ${Firmware_Detail})
CURRENT_SHA256=$(sha256sum ${Firmware} | cut -d ' ' -f1)
echo -e "\n本地SHA256：${CURRENT_SHA256}"
echo "云端SHA256：${GET_SHA256}"
if [[ "${GET_SHA256}" == "${CURRENT_SHA256}" ]];then
	TIME && echo "[ SHA256 ]对比成功,开始安装固件!"
	sleep 1
else
	TIME && echo "[ SHA256 ]对比失败!"
	exit
fi
if [[ ${Compressed_x86} == YES ]];then
	TIME && echo "检测到固件为[ .img.gz ]压缩格式,开始解压固件..."
	Install_Pkg gzip
	gzip -dk ${Firmware} > /dev/null 2>&1
	Firmware="${Firmware_Info}${BOOT_Type}.img"
	if [ -f "${Firmware}" ];then
		TIME && echo "固件解压成功,继续安装固件..."
		sleep 1
	else
		TIME && echo "固件解压失败!"
		exit
	fi
fi
TIME && echo -e "一切准备就绪,1秒后开始刷写固件..."
sleep 1
sysupgrade ${Upgrade_Options} ${Firmware}
if [[ $? -ne 0 ]];then
	TIME && echo "固件正在刷写中,请耐心等候..."
	exit
else
	TIME && echo "固件刷写失败,请尝试手动下载更新固件!"
	exit
fi
