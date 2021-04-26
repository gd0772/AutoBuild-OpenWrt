#!/bin/sh

if [ -n "$(ls -A "/etc/openwrt_gxqm" 2>/dev/null)" ]; then
  Opgxqm="$(awk 'NR==1' /etc/openwrt_gxqm)"
  sed -i '/DESCRIPTION/d' /etc/openwrt_release
  echo "DISTRIB_DESCRIPTION='"${Opgxqm}" @ ImmortalWrt 18.06-SNAPSHOT'" >> /etc/openwrt_release
  rm -rf /etc/openwrt_gxqm
fi
if [ -n "$(ls -A "/etc/closedhcp" 2>/dev/null)" ]; then
  sed -i "s/option start '100'/option ignore '1'/g" /etc/config/dhcp
  sed -i '/limit/d' /etc/config/dhcp
  sed -i '/leasetime/d' /etc/config/dhcp
  rm -rf /etc/closedhcp
fi
sed -i 's/<%=pcdata(ver.distversion)%>/<%=pcdata(ver.distversion)%><!--/g' /usr/lib/lua/luci/view/admin_status/index.htm
sed -i 's/(<%=pcdata(ver.luciversion)%>)/(<%=pcdata(ver.luciversion)%>)-->/g' /usr/lib/lua/luci/view/admin_status/index.htm
sed -i '/github.com/d' /usr/lib/lua/luci/view/admin_status/index.htm
sleep 60
if [[ `grep -c "<!--" /usr/lib/lua/luci/view/admin_status/index.htm` -eq '0' ]]; then
  sed -i 's/<%=pcdata(ver.distversion)%>/<%=pcdata(ver.distversion)%><!--/g' /usr/lib/lua/luci/view/admin_status/index.htm
  sed -i 's/(<%=pcdata(ver.luciversion)%>)/(<%=pcdata(ver.luciversion)%>)-->/g' /usr/lib/lua/luci/view/admin_status/index.htm
  sed -i '/github.com/d' /usr/lib/lua/luci/view/admin_status/index.htm
fi
sed -i '/coremark.sh/d' /etc/crontabs/root
sed -i '/webweb.sh/d' /etc/rc.local
