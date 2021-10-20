#!/bin/bash
# https://github.com/gd0772/AutoBuild-OpenWrt
# common Module by gd0772
# matrix.target=${Modelfile}

TIME() {
Compte=$(date +%Y年%m月%d号%H时%M分)
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31m";;
	g) export Color="\e[32m";;
	b) export Color="\e[34m";;
	y) export Color="\e[33m";;
	z) export Color="\e[35m";;
	l) export Color="\e[36m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}

################################################################################################################
# LEDE源码通用diy.sh文件
################################################################################################################
Diy_lede() {
find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-theme-argon' | xargs -i rm -rf {}

git clone https://github.com/gd0772/package package/gd772
wget https://raw.githubusercontent.com/gd0772/patch/main/x86.sh
bash x86.sh

if [[ "${Modelfile}" == "Lede_source" ]]; then
	sed -i '/IMAGES_GZIP/d' "${PATH1}/${CONFIG_FILE}" > /dev/null 2>&1
	echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${PATH1}/${CONFIG_FILE}"
fi
if [[ "${Modelfile}" == "openwrt_amlogic" ]]; then
	# 修复NTFS格式优盘不自动挂载
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

	# luci-app-cpufreq修改一些代码适配amlogic
	sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile
	# 为 armvirt 添加 autocore 支持
	sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile
fi
}


################################################################################################################
# LIENOL源码通用diy.sh文件
################################################################################################################
Diy_lienol() {
find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-theme-argon' -o -name 'luci-app-fileassistant' | xargs -i rm -rf {}
rm -rf feeds/packages/libs/libcap

git clone https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall

}


################################################################################################################
# 天灵源码21.02 diy.sh文件
################################################################################################################
Diy_mortal() {

find . -name 'luci-app-argon-config' -o -name 'luci-theme-argon' -o -name 'luci-light' -o -name 'luci-app-fileassistant'  | xargs -i rm -rf {}
find . -name 'luci-app-netdata' -o -name 'netdata' -o -name 'luci-theme-openwrt' | xargs -i rm -rf {}
}


################################################################################################################
# 全部作者源码公共diy.sh文件
################################################################################################################
Diy_all() {

if [[ ${REGULAR_UPDATE} == "true" ]]; then
	git clone https://github.com/gd0772/luci-app-autoupdate feeds/luci/applications/luci-app-autoupdate
	cp -Rf "${PATH1}"/{AutoUpdate.sh,replace.sh} package/base-files/files/bin
	sed -i 's/"定时更新"/"更新固件"/g' feeds/luci/applications/luci-app-autoupdate/po/zh-cn/autoupdate.po
	sed -i 's/定时更新 LUCI/固件更新 LUCI/g' feeds/luci/applications/luci-app-autoupdate/po/zh-cn/autoupdate.po
fi
if [[ "${REPO_BRANCH}" == "master" ]]; then
	cp -Rf "${Home}"/build/common/LEDE/files "${Home}"
	cp -Rf "${Home}"/build/common/LEDE/diy/* "${Home}"
	cp -Rf "${Home}"/build/common/LEDE/patches/* "${PATH1}/patches"
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
	cp -Rf "${Home}"/build/common/LIENOL/files "${Home}"
	cp -Rf "${Home}"/build/common/LIENOL/diy/* "${Home}"
	cp -Rf "${Home}"/build/common/LIENOL/patches/* "${PATH1}/patches"
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
	cp -Rf "${Home}"/build/common/MORTAL/files "${Home}"
	cp -Rf "${Home}"/build/common/MORTAL/diy/* "${Home}"
	cp -Rf "${Home}"/build/common/MORTAL/patches/* "${PATH1}/patches"
	chmod -R 777 ${Home}/build/common/Convert
	cp -Rf ${Home}/build/common/Convert/* "${Home}"
	/bin/bash Convert.sh
fi
if [ -n "$(ls -A "${PATH1}/diy" 2>/dev/null)" ]; then
	cp -Rf "${PATH1}"/diy/* "${Home}"
fi
if [ -n "$(ls -A "${PATH1}/files" 2>/dev/null)" ]; then
	cp -Rf "${PATH1}/files" "${Home}" && chmod -R +x ${Home}/files
fi
if [ -n "$(ls -A "${PATH1}/patches" 2>/dev/null)" ]; then
	find "${PATH1}/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward --no-backup-if-mismatch"
fi
}

################################################################################################################
# s905x3_s905x2_s905x_s905d_s922x_s912 一键打包脚本
################################################################################################################
Diy_amlogic() {
svn co https://github.com/ophub/amlogic-s9xxx-openwrt/trunk/amlogic-s9xxx $GITHUB_WORKSPACE/amlogic-s9xxx > /dev/null 2>&1
curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/make >$GITHUB_WORKSPACE/make
source $GITHUB_WORKSPACE/amlogic_openwrt
if [[ ${amlogic_kernel} == "5.4.155_5.14.14" ]]; then
	curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/.github/workflows/build-openwrt-lede.yml > open.yml
	Make_kernel="$(cat open.yml | grep ./make | cut -d "k" -f3 | sed s/[[:space:]]//g)"
	amlogic_kernel="${Make_kernel}"
else
	amlogic_kernel="${amlogic_kernel}"
fi
if [[ -z "${Make_kernel}" ]];then
	amlogic_kernel="5.4.155_5.14.14"
fi
minsize="$(egrep -o "ROOT_MB=+.*?[0-9]" $GITHUB_WORKSPACE/make)"
rootfssize="ROOT_MB=${rootfs_size}"
sed -i "s/"${minsize}"/"${rootfssize}"/g" $GITHUB_WORKSPACE/make
mkdir -p $GITHUB_WORKSPACE/openwrt-armvirt
cp -Rf ${Home}/bin/targets/*/*/*.tar.gz $GITHUB_WORKSPACE/openwrt-armvirt/ && sync
sudo chmod +x make
sudo ./make -d -b "${amlogic_model}" -k "${amlogic_kernel}"
cp -Rf $GITHUB_WORKSPACE/out/* ${Home}/bin/targets/*/*
}

################################################################################################################
# 判断脚本是否缺少主要文件（如果缺少settings.ini设置文件在检测脚本设置就运行错误了）
################################################################################################################
Diy_settings() {
rm -rf ${Home}/build/QUEWENJIANerros
if [ -z "$(ls -A "$PATH1/${CONFIG_FILE}" 2>/dev/null)" ]; then
	echo
	TIME r "错误提示：编译脚本缺少[${CONFIG_FILE}]名称的配置文件,请在[build/${Modelfile}]文件夹内补齐"
	echo "errors" > ${Home}/build/QUEWENJIANerros
	echo
fi
if [ -z "$(ls -A "$PATH1/${DIY_PART_SH}" 2>/dev/null)" ]; then
	echo
	TIME r "错误提示：编译脚本缺少[${DIY_PART_SH}]名称的自定义设置文件,请在[build/${Modelfile}]文件夹内补齐"
	echo "errors" > ${Home}/build/QUEWENJIANerros
	echo
fi
if [ -n "$(ls -A "${Home}/build/QUEWENJIANerros" 2>/dev/null)" ]; then
rm -rf ${Home}/build/QUEWENJIANerros
exit 1
fi
rm -rf {build,README.md}
}


################################################################################################################
# 判断插件冲突
################################################################################################################
Diy_chajian() {
echo
echo "TIME b \"					插件冲突信息\"" > ${Home}/CHONGTU

if [[ `grep -c "CONFIG_PACKAGE_luci-app-docker=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_PACKAGE_luci-app-dockerman=y" ${Home}/.config` -eq '1' ]]; then
		sed -i 's/CONFIG_PACKAGE_luci-app-docker=y/# CONFIG_PACKAGE_luci-app-docker=y is not set/g' ${Home}/.config
		sed -i 's/CONFIG_PACKAGE_luci-i18n-docker-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-docker-zh-cn=y is not set/g' ${Home}/.config
		echo "TIME r \"您同时选择luci-app-docker和luci-app-dockerman，插件有冲突，相同功能插件只能二选一，已删除luci-app-docker\"" >>CHONGTU
		echo "TIME z \"\"" >>CHONGTU
		echo "TIME b \"插件冲突信息\"" > ${Home}/Chajianlibiao
	fi
	
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-i18n-qbittorrent-zh-cn=y" ${Home}/.config` -eq '0' ]]; then
	sed -i 's/CONFIG_PACKAGE_luci-app-qbittorrent_static=y/# CONFIG_PACKAGE_luci-app-qbittorrent_static is not set/g' ${Home}/.config
	sed -i 's/CONFIG_DEFAULT_luci-app-qbittorrent=y/# CONFIG_DEFAULT_luci-app-qbittorrent is not set/g' ${Home}/.config
	sed -i 's/CONFIG_PACKAGE_luci-app-qbittorrent_dynamic=y/# CONFIG_PACKAGE_luci-app-qbittorrent_dynamic is not set/g' ${Home}/.config
	sed -i 's/CONFIG_PACKAGE_qBittorrent-static=y/# CONFIG_PACKAGE_qBittorrent-static is not set/g' ${Home}/.config
	sed -i 's/CONFIG_PACKAGE_qbittorrent=y/# CONFIG_PACKAGE_qbittorrent is not set/g' ${Home}/.config
fi
if [[ `grep -c "CONFIG_TARGET_ROOTFS_EXT4FS=y" ${Home}/.config` -eq '1' ]]; then
	if [[ `grep -c "CONFIG_TARGET_ROOTFS_PARTSIZE" ${Home}/.config` -eq '0' ]]; then
		sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' ${Home}/.config > /dev/null 2>&1
		echo -e "\nCONFIG_TARGET_ROOTFS_PARTSIZE=950" >> ${Home}/.config
	fi
	egrep -o "CONFIG_TARGET_ROOTFS_PARTSIZE=+.*?[0-9]" ${Home}/.config > ${Home}/EXT4PARTSIZE
	sed -i 's|CONFIG_TARGET_ROOTFS_PARTSIZE=||g' ${Home}/EXT4PARTSIZE
	PARTSIZE="$(cat EXT4PARTSIZE)"
	if [[ "${PARTSIZE}" -lt "950" ]];then
		sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' ${Home}/.config > /dev/null 2>&1
		echo -e "\nCONFIG_TARGET_ROOTFS_PARTSIZE=950" >> ${Home}/.config
		echo "TIME g \" \"" > ${Home}/EXT4
		echo "TIME r \"EXT4提示：请注意，您选择了ext4安装的固件格式,而检测到您的分配的固件系统分区过小\"" >> ${Home}/EXT4
		echo "TIME y \"为避免编译出错,建议修改成950或者以上比较好,已帮您修改成950M\"" >> ${Home}/EXT4
		echo "TIME g \" \"" >> ${Home}/EXT4
	fi
	rm -rf ${Home}/EXT4PARTSIZE
fi
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	echo "TIME y \"  插件冲突会导致编译失败，以上操作如非您所需，请关闭此次编译，重新开始编译，避开冲突重新选择插件\"" >>CHONGTU
	echo "TIME z \"\"" >>CHONGTU
else
	rm -rf CHONGTU
fi
}


################################################################################################################
# 为编译做最后处理
################################################################################################################
Diy_chuli() {

grep -i CONFIG_PACKAGE_luci-app .config | grep  -v \# > Plug-in
grep -i CONFIG_PACKAGE_luci-theme .config | grep  -v \# >> Plug-in
if [[ `grep -c "CONFIG_PACKAGE_luci-i18n-qbittorrent-zh-cn=y" ${Home}/.config` -eq '0' ]]; then
	sed -i '/qbittorrent/d' Plug-in
fi
sed -i '/INCLUDE/d' Plug-in > /dev/null 2>&1
sed -i 's/CONFIG_PACKAGE_/、/g' Plug-in
sed -i 's/=y/\"/g' Plug-in
awk '$0=NR$0' Plug-in > Plug-2
awk '{print "	" $0}' Plug-2 > Plug-in
sed -i "s/^/TIME g \"/g" Plug-in
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c > CPU
cat /proc/cpuinfo | grep "cpu cores" | uniq >> CPU
sed -i 's|[[:space:]]||g; s|^.||' CPU && sed -i 's|CPU||g; s|pucores:||' CPU
CPUNAME="$(awk 'NR==1' CPU)" && CPUCORES="$(awk 'NR==2' CPU)"
rm -rf CPU
find . -name 'LICENSE' -o -name 'README' -o -name 'README.md' | xargs -i rm -rf {}
find . -name 'CONTRIBUTED.md' -o -name 'README_EN.md' -o -name 'DEVICE_NAME' | xargs -i rm -rf {}
if [[ `grep -c "KERNEL_PATCHVER:=" ${Home}/target/linux/${TARGET_BOARD}/Makefile` -eq '1' ]]; then
	PATCHVER=$(grep KERNEL_PATCHVER:= ${Home}/target/linux/${TARGET_BOARD}/Makefile | cut -c18-100)
elif [[ `grep -c "KERNEL_PATCHVER=" ${Home}/target/linux/${TARGET_BOARD}/Makefile` -eq '1' ]]; then
	PATCHVER=$(grep KERNEL_PATCHVER= ${Home}/target/linux/${TARGET_BOARD}/Makefile | cut -c17-100)
else
	PATCHVER=unknown
fi
if [[ "${PATCHVER}" != "unknown" ]]; then
	PATCHVER=$(egrep -o "${PATCHVER}.[0-9]+" ${Home}/include/kernel-version.mk)
fi
[[ -e $GITHUB_WORKSPACE/amlogic_openwrt ]] && source $GITHUB_WORKSPACE/amlogic_openwrt
[[ "${amlogic_kernel}" == "5.12.12_5.4.127" ]] && {
	curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/.github/workflows/build-openwrt-lede.yml > open.yml
	Make_ker="$(cat open.yml | grep ./make | cut -d "k" -f3 | sed s/[[:space:]]//g)"
	TARGET_kernel="${Make_ker}"
	TARGET_model="${amlogic_model}"
} || {
	TARGET_kernel="${amlogic_kernel}"
	TARGET_model="${amlogic_model}"
}
}


################################################################################################################
# 编译信息
################################################################################################################
Diy_xinxi_Base() {
GET_TARGET_INFO
if [[ "${TARGET_PROFILE}" =~ (friendlyarm_nanopi-r2s|friendlyarm_nanopi-r4s|armvirt) ]]; then
	REGULAR_UPDATE="false"
fi
echo
TIME b "编译源码: ${CODE}"
TIME b "源码链接: ${REPO_URL}"
TIME b "源码分支: ${REPO_BRANCH}"
TIME b "源码作者: ${ZUOZHE}"
TIME b "默认内核: ${PATCHVER}"
TIME b "Luci版本: ${OpenWrt_name}"
[[ "${Modelfile}" == "openwrt_amlogic" ]] && {
	TIME b "编译机型: ${TARGET_model}"
	TIME b "打包内核: ${TARGET_kernel}"
} || {
	TIME b "编译机型: ${TARGET_PROFILE}"
}
TIME b "固件作者: ${Author}"
TIME b "仓库地址: ${Github}"
TIME b "启动编号: #${Run_number}（${CangKu}仓库第${Run_number}次启动[${Run_workflow}]工作流程）"
TIME b "编译时间: ${Compte}"
[[ "${Modelfile}" == "openwrt_amlogic" ]] && {
	TIME g "提示：您当前使用【${Modelfile}】文件夹编译【${TARGET_model}】固件"
} || {
	TIME g "提示：您当前使用【${Modelfile}】文件夹编译【${TARGET_PROFILE}】固件"
}
echo
if [[ ${UPLOAD_FIRMWARE} == "true" ]]; then
	TIME y "上传固件: 开启"
else
	TIME r "上传固件: 关闭"
fi
if [[ ${UPLOAD_CONFIG} == "true" ]]; then
	TIME y "上传配置文件: 开启"
else
	TIME r "上传配置文件: 关闭"
fi
if [[ ${UPLOAD_BIN_DIR} == "true" ]]; then
	TIME y "上传BIN文件: 开启"
else
	TIME r "上传BIN文件: 关闭"
fi
if [[ ${UPLOAD_COWTRANSFER} == "true" ]]; then
	TIME y "上传固件至【奶牛快传】和【WETRANSFER】: 开启"
else
	TIME r "上传固件至【奶牛快传】和【WETRANSFER】: 关闭"
fi
if [[ ${UPLOAD_RELEASE} == "true" ]]; then
	TIME y "发布固件: 开启"
else
	TIME r "发布固件: 关闭"
fi
if [[ ${SERVERCHAN_SCKEY} == "true" ]]; then
	TIME y "微信/电报通知: 开启"
else
	TIME r "微信/电报通知: 关闭"
fi
if [[ ${SSH_ACTIONS} == "true" ]]; then
	TIME y "SSH远程连接: 开启"
else
	TIME r "SSH远程连接: 关闭"
fi
if [[ ${BY_INFORMATION} == "true" ]]; then
	TIME y "编译信息显示: 开启"
fi
if [[ ${SSHYC} == "true" ]]; then
	TIME y "SSH远程连接临时开关: 开启"
fi
if [[ ${REGULAR_UPDATE} == "true" ]]; then
	TIME y "在线更新 固件: 开启"
else
	TIME r "在线更新 固件: 关闭"
fi
if [[ ${REGULAR_UPDATE} == "true" ]]; then
	echo
	TIME l "在线更新 固件信息"
	TIME z "插件版本: ${AutoUpdate_Version}"
	if [[ ${TARGET_PROFILE} == "x86-64" ]]; then
		TIME b "传统固件: ${Legacy_Firmware}"
		TIME b "UEFI固件: ${UEFI_Firmware}"
		TIME b "固件后缀: ${Firmware_sfx}"
	else
		TIME b "固件名称: ${Up_Firmware}"
		TIME b "固件后缀: ${Firmware_sfx}"
	fi
	TIME b "固件版本: ${Openwrt_Version}"
	TIME b "云端路径: ${Github_UP_RELEASE}"
	echo
else
	echo
fi
echo
TIME z " 系统空间      类型   容量  已用  可用 使用率"
cd ../ && df -hT $PWD && cd openwrt
echo
TIME z "  本编译 服务器的 CPU型号为 [ ${CPUNAME} ]"
echo
TIME z "  使用 核心数 为 [ ${CPUCORES} ], 线程数为 [ $(nproc) ]"
echo
TIME z "  随机分配到 E5系列CPU 编译是 最慢的, 8171M 的CPU 快很多，8272CL 的又比 8171M 快些！"
echo
TIME z "  如果编译的插件较多，而又分配到 E5系列 的 CPU，建议关闭 重新再来！"
echo
TIME z "  下面将使用 [ $(nproc) 线程 ] 编译固件"
if [ -n "$(ls -A "${Home}/EXT4" 2>/dev/null)" ]; then
	echo
	chmod -R +x ${Home}/EXT4
	source ${Home}/EXT4
	rm -rf EXT4
fi
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	echo
	chmod -R +x ${Home}/CHONGTU
	source ${Home}/CHONGTU
	rm -rf {CHONGTU,Chajianlibiao}
fi
if [ -n "$(ls -A "${Home}/Plug-in" 2>/dev/null)" ]; then
	echo
	TIME r "	      已选插件列表"
	chmod -R +x ${Home}/Plug-in
	source ${Home}/Plug-in
	rm -rf {Plug-in,Plug-2}
	echo
fi
}
