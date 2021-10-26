#!/bin/bash

sed -i 's/<a href="https:\/\/github/<!--<a href="https:\/\/github/g' /usr/lib/lua/luci/view/themes/*/footer.htm
sed -i 's/luciversion %>)<\/a> \//luciversion %>)<\/a> \/-->/g' /usr/lib/lua/luci/view/themes/*/footer.htm

[[ ! -f /mnt/network ]] && chmod +x /etc/networkip && source /etc/networkip

cp -Rf /etc/config/network /mnt/network

if [[ `grep -c "x86_64" /etc/openwrt_release` -eq '0' ]]; then
  source /etc/openwrt_release
  sed -i "s/x86_64/${DISTRIB_TARGET}/g" /etc/banner
fi

echo "0 1 * * 1 rm /tmp/luci-indexcache > /dev/null 2>&1" >> /etc/crontabs/root

if [[ -e /usr/share/AdGuardHome ]] && [[ -e /etc/init.d/AdGuardHome ]]; then
 chmod -R +x /usr/share/AdGuardHome /etc/init.d/AdGuardHome
fi

chmod -R +x /etc/init.d /usr/share

rm -rf /etc/networkip
rm -rf /etc/webweb.sh
exit 0
