#Create rpm for wget enter command

<code>wget http://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz -P $HOME/rpmbuild/SOURCES/</code>

<code>wget https://github.com/zpanel/installers/raw/master/install/CentOS-6_4/create-rpm-file/wget/wget.spec \ </code>

<code>-P $HOME/rpmbuild/SPECS/</code>

<code>rpmbuild -ba $HOME/rpmbuild/SPECS/wget.spec</code>

#Regenerate repo

<code>createrepo --update $HOME/rpmbuild/RPMS/$(uname -m)</code>

#Install (just update lol)

<code>sudo sed -i 's/enabled=1/enabled=0/g' "/etc/yum.repos.d/CentOS-Media.repo"

<code>sudo yum -y update</code>

<code>sudo sed -i 's/enabled=0/enabled=1/g' "/etc/yum.repos.d/CentOS-Media.repo"

<code>sudo yum -y update</code>
