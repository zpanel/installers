#!/usr/bin/env bash

# OS VERSION: Ubuntu Server 14.04.x LTS
# ARCH: x32_64

ZPX_VERSION=10.1.1

# Official ZPanel Automated Installation Script
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

# First we check if the user is 'root' before allowing installation to commence
if [ $UID -ne 0 ]; then
    echo "Install failed! To install you must be logged in as 'root', please try again."
    exit 1
fi

# Lets check for some common control panels that we know will affect the installation/operating of ZPanel.
if [ -e /usr/local/cpanel ] || [ -e /usr/local/directadmin ] || [ -e /usr/local/solusvm/www ] || [ -e /usr/local/home/admispconfig ] || [ -e /usr/local/lxlabs/kloxo ] ; then
    echo "You appear to have a control panel already installed on your server; This installer"
    echo "is designed to install and configure ZPanel on a clean OS installation only!"
    echo ""
    echo "Please re-install your OS before attempting to install using this script."
    exit
fi

# Lets check for some common packages that we know will affect the installation/operating of ZPanel.
# We expect a clean OS so no apache/mySQL/bind/postfix/php!
#if dpkg -s php apache mysql bind postfix dovecot; then
#    echo "You appear to have a server with apache/mysql/bind/postfix already installed; "
#    echo "This installer is designed to install and configure ZPanel on a clean OS "
#    echo "installation only!"
#    echo ""
#    echo "Please re-install your OS before attempting to install using this script."
#    exit
#fi

# Ensure the installer is launched and can only be launched on Ubuntu 14.04
#BITS=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
#if [ -f /etc/os-release ]; then
#  OS=$(cat /etc/os-release | grep ID_LIKE | sed 's/^.*=//')
#  VER=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
#else
#  OS=$(uname -s)
#  VER=$(uname -r)
#fi
#echo "Detected : $OS $VER $BITS"
#if [ "$OS" = ""suse"" ] && [ "$VER" = "openSUSE 13.1 (x86_64)" ]; then
#  echo "Ok."
#else
#  echo "Sorry, this installer only supports the installation of ZPanel on Opensuse 13.1 x86_64 online"
#  exit 1;
#fi

ZPX_VERSION=10.1.1

# ***************************************
# * Common installer functions *
# ***************************************

# Generates random passwords for the 'zadmin' account as well as Postfix and MySQL root account.
passwordgen() {
     l=$1
           [ "$l" == "" ] && l=16
          tr -dc A-Za-z0-9 < /dev/urandom | head -c ${l} | xargs
}

# Display the 'welcome' splash/user warning info..
echo -e ""
echo -e "##############################################################"
echo -e "# Official ZPanel Automated Installation Script BETA 1 #"
echo -e "# Welcome to the Official ZPanelX Installer for OpenSuse #"
echo -e "# Server 13.1 #"
echo -e "# #"
echo -e "# Please make sure your VPS provider hasn't pre-installed #"
echo -e "# any packages required by ZPanelX. #"
echo -e "# #"
echo -e "# If you are installing on a physical machine where the OS #"
echo -e "# has been installed by yourself please make sure you only #"
echo -e "# installed OpenSuse Server with no extra packages. #"
echo -e "# #"
echo -e "# If you selected additional options during the Ubuntu #"
echo -e "# install please consider reinstalling without them. #"
echo -e "# #"
echo -e "##############################################################"
echo -e ""

# Set some installation defaults/auto assignments
fqdn=`/bin/hostname`
publicip=`wget -qO- http://api.zpanelcp.com/ip.txt`

# Lets check that the user wants to continue first as obviously otherwise we'll be removing AppArmor for no reason.
while true; do
read -e -p "Would you like to continue (y/n)? " yn
    case $yn in
[Yy]* ) break;;
[Nn]* ) exit;
esac
done

#a selection list for the time zone is not better now?
zypper up &>/dev/null
zypper lu  &>/dev/null
yast2 -i timezone &>/dev/null
echo "echo \$TZ > /etc/timezone" >> /usr/bin/tzselect

# Installer options
while true; do
#echo -e "Find your timezone from : http://php.net/manual/en/timezones.php e.g Europe/London"
#read -e -p "Enter your timezone: " -i "Europe/London" tz
tzselect
tz=`cat /etc/timezone`
echo -e "Enter the FQDN you will use to access ZPanel on your server."
echo -e "- It MUST be a sub-domain of you main domain, it MUST NOT be your main domain only. Example: panel.yourdomain.com"
echo -e "- Remember that the sub-domain ('panel' in the example) MUST be setup in your DNS nameserver."
read -e -p "FQDN for zpanel: " -i $fqdn fqdn
read -e -p "Enter the public (external) server IP: " -i $publicip publicip
    read -e -p "ZPanel is now ready to install, do you wish to continue (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;
    esac
done

# Start log creation.
echo -e ""
echo -e "# Generating installation log and debug info..."
uname -a
echo -e ""
rpm -qa

# Install some standard utility packages required by the installer and/or ZPX.
yast2 -i sudo wget vim make zip unzip git

# We now clone the ZPX software from GitHub
echo "Downloading ZPanel, Please wait, this may take several minutes, the installer will continue after this is complete!"
git clone https://github.com/zpanel/zpanelx.git
cd zpanelx/
git checkout $ZPX_VERSION
mkdir ../zp_install_cache/
git checkout-index -a -f --prefix=../zp_install_cache/
cd ../zp_install_cache/

# We now update the server software packages.
zypper up
zypper lu

# Install required software and dependencies required by ZPanel.


yast2 -i at mysql-community-server mysql-community-server-client apache2 php5-mysql php5-bcmath php5-bz2 php5-calendar php5-ctype php5-curl php5-dom php5-ftp php5-gd php5-gettext php5-gmp php5-iconv php5-imap php5-ldap php5-mbstring php5-mcrypt php5-odbc php5-openssl php5-pcntl php5-pgsql php5-posix php5-shmop php5-snmp php5-soap php5-sockets php5-sqlite php5-sysvsem php5-tokenizer php5-wddx php5-xmlrpc php5-xsl php5-zlib php5-exif php5-fastcgi php5-pear php5-sysvmsg php5-sysvshm zip webalizer bash-completion dovecot postfix postfix-mysql bind php5-suhosin

# Generation of random passwords
password=`passwordgen`;
postfixpassword=`passwordgen`;
zadminNewPass=`passwordgen`;


echo $password
echo $postfixpassword
echo $zadminNewPass


chown root:root /tmp
chmod 1777 /tmp

# Set-up ZPanel directories and configure directory permissions as required.
mkdir /etc/zpanel
mkdir /etc/zpanel/configs
mkdir /etc/zpanel/panel
mkdir /etc/zpanel/docs
mkdir /var/zpanel
mkdir /var/zpanel/hostdata
mkdir /var/zpanel/hostdata/zadmin
mkdir /var/zpanel/hostdata/zadmin/public_html
mkdir /var/zpanel/logs
mkdir /var/zpanel/logs/proftpd
mkdir /var/zpanel/backups
mkdir /var/zpanel/temp
cp -R . /etc/zpanel/panel/
chmod -R 777 /etc/zpanel/
chmod -R 777 /var/zpanel/
chmod -R 770 /var/zpanel/hostdata/
chown -R www-data:www-data /var/zpanel/hostdata/
chmod 644 /etc/zpanel/panel/etc/apps/phpmyadmin/config.inc.php
ln -s /etc/zpanel/panel/bin/zppy /usr/bin/zppy
ln -s /etc/zpanel/panel/bin/setso /usr/bin/setso
ln -s /etc/zpanel/panel/bin/setzadmin /usr/bin/setzadmin
chmod +x /etc/zpanel/panel/bin/zppy
chmod +x /etc/zpanel/panel/bin/setso
cp -R /etc/zpanel/panel/etc/build/config_packs/ubuntu_12_04/. /etc/zpanel/configs
## FILES UPDATE ## ZCWORLD
#ubuntu update on the apache / sql and the default Vhost for ZPX!
rm -f /etc/zpanel/panel/modules/apache_admin/hooks/OnDaemonRun.hook.php /etc/zpanel/configs/zpanelx-install/sql/zpanel_core.sql /etc/zpanel/configs/apache/httpd.conf
wget --no-check-certificate https://raw.githubusercontent.com/andykimpe/zpanelx/master/modules/apache_admin/hooks/OnDaemonRun.hook.php_u14 -O /etc/zpanel/panel/modules/apache_admin/hooks/OnDaemonRun.hook.php
wget --no-check-certificate https://raw.githubusercontent.com/zcworld/zpanelx/master/etc/build/config_packs/ubuntu_12_04/zpanelx-install/sql/zpanel_core.sql -O /etc/zpanel/configs/zpanelx-install/sql/zpanel_core.sql
# Set server tokens (security??)
#ServerTokens Major
wget --no-check-certificate https://github.com/andykimpe/zpanelx/raw/master/etc/build/config_packs/ubuntu_12_04/apache/httpd.conf -O /etc/zpanel/configs/apache/httpd.conf
# set password after test connexion
cc -o /etc/zpanel/panel/bin/zsudo /etc/zpanel/configs/bin/zsudo.c
sudo chown root /etc/zpanel/panel/bin/zsudo
chmod +s /etc/zpanel/panel/bin/zsudo


service mysql start
/usr/bin/mysqladmin -u root password $password
mysqladmin -u root password $password
until mysql -u root -p$password -e ";" > /dev/null 2>&1 ; do
read -s -p "enter your root mysql password : " password
done




sed -i "s|YOUR_ROOT_MYSQL_PASSWORD|$password|" /etc/zpanel/panel/cnf/db.php
mysql -u root -p$password -e "DROP DATABASE test";
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User='root' AND Host != 'localhost'";
mysql -u root -p$password -e "DELETE FROM mysql.user WHERE User=''";
mysql -u root -p$password -e "FLUSH PRIVILEGES";
mysql -u root -p$password -e "CREATE SCHEMA zpanel_roundcube";
cat /etc/zpanel/configs/zpanelx-install/sql/*.sql | mysql -u root -p$password
mysql -u root -p$password -e "UPDATE mysql.user SET Password=PASSWORD('$postfixpassword') WHERE User='postfix' AND Host='localhost';";
mysql -u root -p$password -e "FLUSH PRIVILEGES";
sed -i "/ssl-key=/a \secure-file-priv = /var/tmp" /etc/mysql/my.cnf

# Set some ZPanel custom configuration settings (using. setso and setzadmin)
setzadmin --set "$zadminNewPass";
/etc/zpanel/panel/bin/setso --set zpanel_domain $fqdn
/etc/zpanel/panel/bin/setso --set server_ip $publicip
/etc/zpanel/panel/bin/setso --set apache_changed "true"

# We'll store the passwords so that users can review them later if required.
touch /root/passwords.txt;
echo "zadmin Password: $zadminNewPass" >> /root/passwords.txt;
echo "MySQL Root Password: $password" >> /root/passwords.txt
echo "MySQL Postfix Password: $postfixpassword" >> /root/passwords.txt
echo "IP Address: $publicip" >> /root/passwords.txt
echo "Panel Domain: $fqdn" >> /root/passwords.txt

# Postfix specific installation tasks...
mkdir /var/zpanel/vmail
chmod -R 770 /var/zpanel/vmail
useradd -r -u 150 -g mail -d /var/zpanel/vmail -s /sbin/nologin -c "Virtual maildir" vmail
chown -R vmail:mail /var/zpanel/vmail
mkdir -p /var/spool/vacation
useradd -r -d /var/spool/vacation -s /sbin/nologin -c "Virtual vacation" vacation
chmod -R 770 /var/spool/vacation
ln -s /etc/zpanel/configs/postfix/vacation.pl /var/spool/vacation/vacation.pl
postmap /etc/postfix/transport
chown -R vacation:vacation /var/spool/vacation
if ! grep -q "127.0.0.1 autoreply.$fqdn" /etc/hosts; then echo "127.0.0.1 autoreply.$fqdn" >> /etc/hosts; fi
sed -i "s|myhostname = control.yourdomain.com|myhostname = $fqdn|" /etc/zpanel/configs/postfix/main.cf
sed -i "s|mydomain = control.yourdomain.com|mydomain = $fqdn|" /etc/zpanel/configs/postfix/main.cf
rm -rf /etc/postfix/main.cf /etc/postfix/master.cf
ln -s /etc/zpanel/configs/postfix/master.cf /etc/postfix/master.cf
ln -s /etc/zpanel/configs/postfix/main.cf /etc/postfix/main.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-relay_domains_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_alias_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_domains_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_limit_maps.cf
sed -i "s|password \= postfix|password \= $postfixpassword|" /etc/zpanel/configs/postfix/mysql-virtual_mailbox_maps.cf
sed -i "s|\$db_password \= 'postfix';|\$db_password \= '$postfixpassword';|" /etc/zpanel/configs/postfix/vacation.conf

# Dovecot specific installation tasks (includes Sieve)
mkdir -p /var/zpanel/sieve
chown -R vmail:mail /var/zpanel/sieve
mkdir -p /var/lib/dovecot/sieve/
touch /var/lib/dovecot/sieve/default.sieve
ln -s /etc/zpanel/configs/dovecot2/globalfilter.sieve /var/zpanel/sieve/globalfilter.sieve
rm -rf /etc/dovecot/dovecot.conf
ln -s /etc/zpanel/configs/dovecot2/dovecot.conf /etc/dovecot/dovecot.conf
sed -i "s|postmaster_address = postmaster@your-domain.tld|postmaster_address = postmaster@$fqdn|" /etc/dovecot/dovecot.conf
sed -i "s|password=postfix|password=$postfixpassword|" /etc/zpanel/configs/dovecot2/dovecot-dict-quota.conf
sed -i "s|password=postfix|password=$postfixpassword|" /etc/zpanel/configs/dovecot2/dovecot-mysql.conf
touch /var/log/dovecot.log
touch /var/log/dovecot-info.log
touch /var/log/dovecot-debug.log
chown vmail:mail /var/log/dovecot*
chmod 660 /var/log/dovecot*

# ProFTPD specific installation tasks
groupadd -g 2001 ftpgroup
useradd -u 2001 -s /bin/false -d /bin/null -c "proftpd user" -g ftpgroup ftpuser
sed -i "s|#SQLConnectInfo zpanel_proftpd@localhost root password_here|SQLConnectInfo zpanel_proftpd@localhost root $password|" /etc/zpanel/configs/proftpd/proftpd-mysql.conf
rm -rf /etc/proftpd/proftpd.conf
touch /etc/proftpd/proftpd.conf
if ! grep -q "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" /etc/proftpd/proftpd.conf; then echo "include /etc/zpanel/configs/proftpd/proftpd-mysql.conf" >> /etc/proftpd/proftpd.conf; fi
chmod -R 644 /var/zpanel/logs/proftpd
serverhost=`hostname`

# Apache HTTPD specific installation tasks...
if ! grep -q "Include /etc/zpanel/configs/apache/httpd.conf" /etc/apache2/apache2.conf; then echo "Include /etc/zpanel/configs/apache/httpd.conf" >> /etc/apache2/apache2.conf; fi
sed -i 's|DocumentRoot /var/www/html|DocumentRoot /etc/zpanel/panel|' /etc/apache2/sites-enabled/000-default.conf
sed -i 's|<Directory /var/www/>|<Directory /etc/zpanel/panel>|' /etc/apache2/apache2.conf
chown -R www-data:www-data /var/zpanel/temp/
if ! grep -q "127.0.0.1 "$fqdn /etc/hosts; then echo "127.0.0.1 "$fqdn >> /etc/hosts; fi
if ! grep -q "apache ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" /etc/sudoers; then echo "apache ALL=NOPASSWD: /etc/zpanel/panel/bin/zsudo" >> /etc/sudoers; fi
a2enmod rewrite
service apache2 restart

# PHP specific installation tasks...
sed -i "s|;date.timezone =|date.timezone = $tz|" /etc/php5/cli/php.ini
sed -i "s|;date.timezone =|date.timezone = $tz|" /etc/php5/apache2/php.ini
sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /etc/php5/cli/php.ini
sed -i "s|;upload_tmp_dir =|upload_tmp_dir = /var/zpanel/temp/|" /etc/php5/apache2/php.ini
sed -i "s|expose_php = On|expose_php = Off|" /etc/php5/apache2/php.ini

# Permissions fix for Apache and ProFTPD (to enable them to play nicely together!)
if ! grep -q "umask 002" /etc/apache2/envvars; then echo "umask 002" >> /etc/apache2/envvars; fi
if ! grep -q "127.0.0.1 $serverhost" /etc/hosts; then echo "127.0.0.1 $serverhost" >> /etc/hosts; fi
usermod -a -G www-data ftpuser
usermod -a -G ftpgroup www-data

# BIND specific installation tasks...
chmod -R 777 /etc/zpanel/configs/bind/zones/
mkdir /var/zpanel/logs/bind
mkdir -p /var/named/dynamic
touch /var/named/dynamic/managed-keys.bind
touch /var/zpanel/logs/bind/bind.log
chown root:root /etc/bind/rndc.key
chown -R bind:bind /var/named/
chmod 755 /etc/bind/rndc.key
chmod -R 777 /var/zpanel/logs/bind/bind.log
chmod -R 777 /etc/zpanel/configs/bind/etc
rm -rf /etc/bind/named.conf /etc/bind/rndc.conf /etc/bind/rndc.key
rndc-confgen -a
ln -s /etc/zpanel/configs/bind/named.conf /etc/bind/named.conf
ln -s /etc/zpanel/configs/bind/rndc.conf /etc/bind/rndc.conf
if ! grep -q "include \"/etc/zpanel/configs/bind/etc/log.conf\";" /etc/bind/named.conf; then echo "include \"/etc/zpanel/configs/bind/etc/log.conf\";" >> /etc/bind/named.conf; fi
ln -s /usr/sbin/named-checkconf /usr/bin/named-checkconf
ln -s /usr/sbin/named-checkzone /usr/bin/named-checkzone
ln -s /usr/sbin/named-compilezone /usr/bin/named-compilezone
cat /etc/bind/rndc.key | cat - /etc/bind/named.conf > /etc/bind/named.conf.new && mv /etc/bind/named.conf.new /etc/bind/named.conf
cat /etc/bind/rndc.key | cat - /etc/bind/rndc.conf > /etc/bind/rndc.conf.new && mv /etc/bind/rndc.conf.new /etc/bind/rndc.conf
rm -rf /etc/bind/rndc.key

# CRON specific installation tasks...
mkdir -p /var/spool/cron/crontabs/
mkdir -p /etc/cron.d/
touch /var/spool/cron/crontabs/www-data
touch /etc/cron.d/www-data
crontab -u www-data /var/spool/cron/crontabs/www-data
cp /etc/zpanel/configs/cron/zdaemon /etc/cron.d/zdaemon
chmod -R 644 /var/spool/cron/crontabs/
chmod 744 /var/spool/cron/crontabs
chmod -R 644 /etc/cron.d/
chown -R www-data:www-data /var/spool/cron/crontabs/

# Webalizer specific installation tasks...
rm -rf /etc/webalizer/webalizer.conf

# Roundcube specific installation tasks...
sed -i "s|YOUR_MYSQL_ROOT_PASSWORD|$password|" /etc/zpanel/configs/roundcube/db.inc.php
sed -i "s|#||" /etc/zpanel/configs/roundcube/db.inc.php
rm -rf /etc/zpanel/panel/etc/apps/webmail/config/main.inc.php
ln -s /etc/zpanel/configs/roundcube/main.inc.php /etc/zpanel/panel/etc/apps/webmail/config/main.inc.php
ln -s /etc/zpanel/configs/roundcube/config.inc.php /etc/zpanel/panel/etc/apps/webmail/plugins/managesieve/config.inc.php
ln -s /etc/zpanel/configs/roundcube/db.inc.php /etc/zpanel/panel/etc/apps/webmail/config/db.inc.php

# enable start service
chkconfig apache2 on
chkconfig postfix on
chkconfig dovecot on
chkconfig cron on
chkconfig mysql on
chkconfig bind on
chkconfig proftpd on
chkconfig atd on

# Enable system services and start/restart them as required.
service apache2 start
service postfix restart
service dovecot start
service cron reload
service mysql start
service bind start
service proftpd start
service atd start
php /etc/zpanel/panel/bin/daemon.php
# restart service after daemon
service apache2 restart
service postfix restart
service dovecot restart
service cron restart
service mysql restart
service bind restart
service proftpd restart
service atd restart

# We'll now remove the temporary install cache.
cd ../
rm -rf zp_install_cache/ zpanelx/

# Advise the user that ZPanel is now installed and accessible.
echo -e "##############################################################" &>/dev/tty
echo -e "# Congratulations ZpanelX has now been installed on your #" &>/dev/tty
echo -e "# server. Please review the log file left in /root/ for #" &>/dev/tty
echo -e "# any errors encountered during installation. #" &>/dev/tty
echo -e "# #" &>/dev/tty
echo -e "# Save the following information somewhere safe: #" &>/dev/tty
echo -e "# MySQL Root Password : $password" &>/dev/tty
echo -e "# MySQL Postfix Password : $postfixpassword" &>/dev/tty
echo -e "# ZPanelX Username : zadmin #" &>/dev/tty
echo -e "# ZPanelX Password : $zadminNewPass" &>/dev/tty
echo -e "# #" &>/dev/tty
echo -e "# ZPanelX Web login can be accessed using your server IP #" &>/dev/tty
echo -e "# inside your web browser. #" &>/dev/tty
echo -e "# #" &>/dev/tty
echo -e "##############################################################" &>/dev/tty
echo -e "" &>/dev/tty

# We now request that the user restarts their server...
read -e -p "You Must Restart your server now to complete the install (y/n)? " rsn
while true; do
case $rsn in
[Yy]* ) break;;
[Nn]* ) exit;
esac
done
shutdown -r now
