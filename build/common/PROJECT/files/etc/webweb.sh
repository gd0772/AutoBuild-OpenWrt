#!/bin/sh

if [ -n "$(ls -A "/etc/openwrt_gxqm" 2>/dev/null)" ]; then
  Opgxqm="$(awk 'NR==1' /etc/openwrt_gxqm)"
  sed -i '/DESCRIPTION/d' /etc/openwrt_release
  echo "DISTRIB_DESCRIPTION='"${Opgxqm}" @ ImmortalWrt 18.06-SNAPSHOT'" >> /etc/openwrt_release
  rm -rf /etc/openwrt_gxqm
fi
sed -i 's/<%=pcdata(ver.distversion)%>/<%=pcdata(ver.distversion)%><!--/g' /usr/lib/lua/luci/view/admin_status/index.htm
sed -i 's/(<%=pcdata(ver.luciversion)%>)/(<%=pcdata(ver.luciversion)%>)-->/g' /usr/lib/lua/luci/view/admin_status/index.htm
sed -i '/github.com/d' /usr/lib/lua/luci/view/admin_status/index.htm
sed -i '/coremark.sh/d' /etc/crontabs/root
sed -i '/webweb.sh/d' /etc/crontabs/root
rm -rf /etc/webweb.sh
