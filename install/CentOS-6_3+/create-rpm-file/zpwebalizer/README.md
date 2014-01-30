#zpwebalizer

<code>cd $HOME/rpmbuild/SOURCES</code>

<code>wget ftp://ftp.redhat.com/redhat/linux/enterprise/6Workstation/en/os/SRPMS/webalizer-2.21_02-3.3.el6.src.rpm</code>

<code>rpm2cpio webalizer-2.21_02-3.3.el6.src.rpm | cpio -ivd</code>

<code>rm -f webalizer-2.21_02-3.3.el6.src.rpm</code>

<code>tar -xvf webalizer-2.21-02-src.tar.bz2</code>

<code>rm -f webalizer-2.21-02-src.tar.bz2</code>

<code>rm -f webalizer.spec</code>

<code>mv webalizer-2.21-02 zpwebalizer-2.21-02</code>

<code>tar -cvf zpwebalizer-2.21-02.tar.bz2 zpwebalizer-2.21-02</code>

<code>rm -rf zpwebalizer-2.21-02/ </code>

<code>wget https://github.com/zpanel/installers/raw/master/install/CentOS-6_4/create-rpm-file/zpwebalizer/zpwebalizer.spec \ </code>

<code>-P $HOME/rpmbuild/SPECS</code>

<code>rpmbuild -ba $HOME/rpmbuild/SPECS/zpwebalizer.spec</code>

#Regenerate repo

<code>createrepo --update $HOME/rpmbuild/RPMS/$(uname -m)</code>

#Install

<code>sudo sed -i 's/enabled=1/enabled=0/g' "/etc/yum.repos.d/CentOS-Media.repo"</code>

<code>sudo yum -y update</code>

<code>sudo sed -i 's/enabled=0/enabled=1/g' "/etc/yum.repos.d/CentOS-Media.repo"</code>

<code>sudo yum -y update</code>

<code>sudo yum -y install zpwebalizer</code>
