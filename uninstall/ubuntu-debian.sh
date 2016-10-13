#!/bin/bash

# First we check if the user is 'root' before uninstalling the software
if [ $UID -ne 0 ]; then
    echo "Action failed! To unstall you must be logged in as 'root', please try again"
  exit 1
fi

apt-get -y purge mysql-server mysql-server apache2 libapache2-mod-php5 libapache2-mod-bw php5-common php5-suhosin php5-cli php5-mysql php5-gd php5-mcrypt php5-curl php-pear php5-imap php5-xmlrpc php5-xsl db4.7-util zip webalizer build-essential bash-completion dovecot-mysql dovecot-imapd dovecot-pop3d dovecot-common dovecot-managesieved dovecot-lmtpd postfix postfix-mysql libsasl2-modules-sql libsasl2-modules proftpd-mod-mysql bind9 bind9utils
apt-get -y autoremove
rm -rf /etc/zpanel
rm -rf /var/zpanel
rm -f /root/passwords.txt
