#Create rpm for zphttpd

<code>sudo yum -y install pcre-devel lua-devel libxml2-devel</code>

<code>wget https://github.com/zpanel/installers/raw/master/install/CentOS-6_4/create-rpm-file/zphttpd/zphttpd.spec \ </code>

<code>-P $HOME/rpmbuild/SPECS</code>

<code>cd $HOME/rpmbuild/SOURCES</code>

<code>git clone https://github.com/apache/httpd.git zphttpd-2.2.26</code>

<code>cd zphttpd-2.2.26</code>

<code>git checkout 2.2.26</code>

<code>cd ..</code>

<code>tar cvjf zphttpd-2.2.26.tar.bz2 zphttpd-2.2.26</code>

<code>rm -rf zphttpd-2.2.26/</code>

<code>rpmbuild -ba $HOME/rpmbuild/SPECS/zphttpd.spec</code>

#Regenerate repo

<code>createrepo --update $HOME/rpmbuild/RPMS/$(uname -m)</code>

#Install

<code>sudo sed -i 's/enabled=1/enabled=0/g' "/etc/yum.repos.d/CentOS-Media.repo"</code>

<code>sudo yum -y update</code>

<code>sudo sed -i 's/enabled=0/enabled=1/g' "/etc/yum.repos.d/CentOS-Media.repo"</code>

<code>sudo yum -y update</code>

<code>sudo yum -y install zphttpd</code>

#Info

service auto starting

service zphttpd help for information
