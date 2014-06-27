#!/usr/bin/env bash

# OS VERSION: CentOS 6.4+ Minimal
# ARCH: x32_64

ZPX_VERSION=10.1.1
ZPX_VERSION_ACTUAL=$(setso --show dbversion)

# Official ZPanel Automated Upgrade Script
# =============================================
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# First we check if the user is 'root' before allowing the upgrade to commence
if [ $UID -ne 0 ]; then
    echo "Upgrade failed! To upgrade you must be logged in as 'root', please try again"
    exit 1;
fi

# Ensure the upgrade script is launched and can only be launched on CentOs 6.4
BITS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
if [ -f /etc/centos-release ]; then
  OS="CentOs"
  VER=$(cat /etc/centos-release | sed 's/^.*release //;s/ (Fin.*$//')
else
  OS=$(uname -s)
  VER=$(uname -r)
fi
echo "Detected : $OS $VER $BITS"
if [ "$OS" = "CentOs" ] && [ "$VER" = "6.0" ] || [ "$VER" = "6.1" ] || [ "$VER" = "6.2" ] || [ "$VER" = "6.3" ] || [ "$VER" = "6.4" ] || [ "$VER" = "6.5" ] ||[ "$VER" = "6.6" ] ; then
  echo "Ok."
else
  echo "Sorry, this upgrade script only supports ZPanel on CentOS 6.x."
  exit 1;
fi



#check zpanel version

if [ "$ZPX_VERSION" != "$ZPX_VERSION_ACTUAL" ] ; then
echo "your version of ZPanel not updated"
echo "execut bash <(curl -Ss https://raw.github.com/zpanel/installers/master/upgrade/CentOS-6_4/10_1_1.sh)"
exit
fi

# Set custom logging methods so we create a log file in the current working directory.
logfile=$$.log
exec > >(tee $logfile)
exec 2>&1

# Check that ZPanel has been detected on the server if not, we'll exit!
if [ ! -d /etc/zpanel ]; then
    echo "ZPanel has not been detected on this server, the upgrade script can therefore not continue!"
    exit 1;
fi

# Lets check that the user wants to continue first and recommend they have a backup!
echo ""
echo "The ZPanel Upgrade script is now ready to start, we recommend that before"
echo "continuing that you first backup your ZPanel server to enable a restore"
echo "in the event that something goes wrong during the upgrade process!"
echo ""
while true; do
read -e -p "Would you like to continue with the upgrade now (y/n)? " yn
    case $yn in
[Yy]* ) break;;
[Nn]* ) exit;
esac
done

# get mysql root password, check it works or ask it
mysqlpassword=$(cat /etc/zpanel/panel/cnf/db.php | grep "pass =" | sed -s "s|.*pass \= '\(.*\)';.*|\1|")
while ! mysql -u root -p$mysqlpassword -e ";" ; do
 read -p "Can't connect to mysql, please give root password or press ctrl-C to abort: " mysqlpassword
done
echo -e "Connection mysql ok"

wget https://github.com/zpanel/installers/raw/master/upgrade/beta/CentOS_6/httpd24.sql

cat httpd24.sql | mysql -u root -p$mysqlpassword


# add lamp scl depot
wget https://github.com/zpanel/installers/raw/master/install/beta/CentOS_6/lamp_scl.repo -P /etc/yum.repos.d
service httpd stop
chkconfig httpd off
yum -y install http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
yum -y --enablerepo=remi update
yum -y --enablerepo=remi install httpd24 httpd24-httpd php55 php55-php php55-php-devel php55-php-gd php55-php-mbstring php55-php-mcrypt php55-php-intl php55-php-imap php55-php-mysql php55-php-xml php55-php-xmlrpc httpd24-httpd-devel
# install suhosin
git clone https://github.com/stefanesser/suhosin.git
cd suhosin
scl enable php55 "phpize"
scl enable php55 "./configure"
scl enable php55 "make"
scl enable php55 "make install"
cp suhosin.ini /opt/rh/php55/root/etc/php.d
cd ..
rm -rf suhosin
rm -f rm -f /etc/zpanel/panel/modules/apache_admin/hooks/OnDaemonRun.hook.php
wget https://github.com/andykimpe/zpanelx/raw/master/modules/apache_admin/hooks/OnDaemonRun.hook.php_u14 -O /etc/zpanel/panel/modules/apache_admin/hooks/OnDaemonRun.hook.php
sed -i 's/NameVirtualHost *:80/#NameVirtualHost *:80/g' "/etc/zpanel/configs/apache/httpd-vhosts.conf"
rm -f "/etc/zpanel/configs/apache/httpd.conf"
wget https://github.com/zpanel/zpanelx/raw/10.1.1/etc/build/config_packs/centos_6_5/apache/httpd.conf -O "/etc/zpanel/configs/apache/httpd.conf"
if ! grep -q "Include /etc/zpanel/configs/apache/httpd.conf" /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf; then echo "Include /etc/zpanel/configs/apache/httpd.conf" >> /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf; fi
sed -i 's|<Directory "/opt/rh/httpd24/root/var/www">|<Directory "/etc/zpanel/panel">|' /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf
sed -i 's|DocumentRoot "/opt/rh/httpd24/root/var/www/html"|DocumentRoot "/etc/zpanel/panel"|' /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf
sed -i "s|KeepAlive Off|KeepAlive On|" /opt/rh/httpd24/root/etc/httpd/conf/httpd.conf
# PHP specific installation tasks...
tz=`cat /etc/timezone`
sed -i "s|;date.timezone =|date.timezone = $tz|" /opt/rh/php55/root/etc/php.ini
sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /opt/rh/php55/root/etc/php.ini
#Disable php signature in headers to hide it from hackers
sed -i "s|expose_php = On|expose_php = Off|" /opt/rh/php55/root/etc/php.ini
if ! grep -q "umask 002" /etc/sysconfig/httpd; then echo "umask 002" >> /opt/rh/httpd24/root/etc/sysconfig/httpd; fi
# Enable system services and start/restart them as required.
chkconfig httpd24-httpd on
chkconfig php55-php-fpm on
service httpd24-httpd start
service php55-php-fpm start
rm -f /usr/bin/php
cat > /usr/bin/php <<EOF
#!/bin/bash
source /opt/rh/php55/enable
/opt/rh/php55/root/usr/bin/php "\$@"
EOF
chmod +x /usr/bin/php
cat > /usr/bin/httpd24 <<EOF
#!/bin/bash
source /opt/rh/httpd24/enable
/opt/rh/httpd24/root/usr/sbin/httpd "\$@"
EOF
chmod +x /usr/bin/httpd24
php -f /etc/zpanel/panel/bin/daemon.php
# restart all service
service httpd24-httpd restart
service postfix restart
service dovecot restart
service crond restart
service mysqld restart
service named restart
service proftpd restart
service atd restart
