# Pass --without docs to rpmbuild if you don't want the documentation

Name: 		git
Version: 	1.9.rc.0
Release: 	1%{?dist}
Summary:  	Core git tools
License: 	GPL
Group: 		Development/Tools
URL: 		http://kernel.org/pub/software/scm/git/
Source: 	http://kernel.org/pub/software/scm/git/%{name}-1.9-rc0.tar.gz
BuildRequires:	zlib-devel >= 1.2, openssl-devel, curl-devel, expat-devel, gettext  %{!?_without_docs:, xmlto, asciidoc > 6.0.3}
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

Requires:	perl-Git = %{version}-%{release}
Requires:	zlib >= 1.2, rsync, less, openssh-clients, expat
Provides:	git-core = %{version}-%{release}
Obsoletes:	git-core <= 1.5.4.2
Obsoletes:	git-p4

%description
Git is a fast, scalable, distributed revision control system with an
unusually rich command set that provides both high-level operations
and full access to internals.

The git rpm installs the core tools with minimal dependencies.  To
install all git packages, including tools for integrating with other
SCMs, install the git-all meta-package.

%package all
Summary:	Meta-package to pull in all git tools
Group:		Development/Tools
Requires:	git = %{version}-%{release}
Requires:	git-svn = %{version}-%{release}
Requires:	git-cvs = %{version}-%{release}
Requires:	git-arch = %{version}-%{release}
Requires:	git-email = %{version}-%{release}
Requires:	gitk = %{version}-%{release}
Requires:	gitweb = %{version}-%{release}
Requires:	git-gui = %{version}-%{release}
Obsoletes:	git <= 1.5.4.2

%description all
Git is a fast, scalable, distributed revision control system with an
unusually rich command set that provides both high-level operations
and full access to internals.

This is a dummy package which brings in all subpackages.

%package svn
Summary:        Git tools for importing Subversion repositories
Group:          Development/Tools
Requires:       git = %{version}-%{release}, subversion
%description svn
Git tools for importing Subversion repositories.

%package cvs
Summary:        Git tools for importing CVS repositories
Group:          Development/Tools
Requires:       git = %{version}-%{release}, cvs, cvsps
%description cvs
Git tools for importing CVS repositories.

%package arch
Summary:        Git tools for importing Arch repositories
Group:          Development/Tools
Requires:       git = %{version}-%{release}, tla
%description arch
Git tools for importing Arch repositories.

%package email
Summary:        Git tools for sending email
Group:          Development/Tools
Requires:	git = %{version}-%{release}
%description email
Git tools for sending email.

%package gui
Summary:        Git GUI tool
Group:          Development/Tools
Requires:       git = %{version}-%{release}, tk >= 8.4
%description gui
Git GUI tool

%package -n gitk
Summary:        Git revision tree visualiser ('gitk')
Group:          Development/Tools
Requires:       git = %{version}-%{release}, tk >= 8.4
%description -n gitk
Git revision tree visualiser ('gitk')

%package -n gitweb
Summary:	Git web interface
Group:          Development/Tools
Requires:       git = %{version}-%{release}
%description -n gitweb
Browsing git repository on the web

%package -n perl-Git
Summary:        Perl interface to Git
Group:          Development/Libraries
Requires:       git = %{version}-%{release}
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
BuildRequires:  perl(Error)
BuildRequires:  perl(ExtUtils::MakeMaker)

%description -n perl-Git
Perl interface to Git

%define path_settings ETC_GITCONFIG=/etc/gitconfig prefix=%{_prefix} mandir=%{_mandir} htmldir=%{_docdir}/%{name}-%{version}
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")}

%prep
%setup -n git-1.9-rc0

%build
make %{_smp_mflags} CFLAGS="$RPM_OPT_FLAGS" \
     %{path_settings} \
     all %{!?_without_docs: doc}

%install
rm -rf $RPM_BUILD_ROOT
make %{_smp_mflags} CFLAGS="$RPM_OPT_FLAGS" DESTDIR=$RPM_BUILD_ROOT \
     %{path_settings} \
     INSTALLDIRS=vendor install %{!?_without_docs: install-doc}
test ! -d $RPM_BUILD_ROOT%{python_sitelib} || rm -fr $RPM_BUILD_ROOT%{python_sitelib}
find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} ';'
find $RPM_BUILD_ROOT -type f -name '*.bs' -empty -exec rm -f {} ';'
find $RPM_BUILD_ROOT -type f -name perllocal.pod -exec rm -f {} ';'

(find $RPM_BUILD_ROOT%{_bindir} -type f | grep -vE "archimport|svn|cvs|email|gitk|git-gui|git-citool" | sed -e s@^$RPM_BUILD_ROOT@@)               > bin-man-doc-files
(find $RPM_BUILD_ROOT%{_libexecdir}/git-core -type f | grep -vE "archimport|svn|cvs|email|gitk|git-gui|git-citool" | sed -e s@^$RPM_BUILD_ROOT@@)               >> bin-man-doc-files
(find $RPM_BUILD_ROOT%{perl_vendorlib} -type f | sed -e s@^$RPM_BUILD_ROOT@@) >> perl-files
%if %{!?_without_docs:1}0
(find $RPM_BUILD_ROOT%{_mandir} $RPM_BUILD_ROOT/Documentation -type f | grep -vE "archimport|svn|git-cvs|email|gitk|git-gui|git-citool" | sed -e s@^$RPM_BUILD_ROOT@@ -e 's/$/*/' ) >> bin-man-doc-files
%else
rm -rf $RPM_BUILD_ROOT%{_mandir}
%endif
rm -rf $RPM_BUILD_ROOT%{_datadir}/locale

mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}/bash_completion.d
install -m 644 -T contrib/completion/git-completion.bash $RPM_BUILD_ROOT%{_sysconfdir}/bash_completion.d/git

%clean
rm -rf $RPM_BUILD_ROOT

%files -f bin-man-doc-files
%defattr(-,root,root)
%{_datadir}/git-core/
%doc README COPYING Documentation/*.txt
%{!?_without_docs: %doc Documentation/*.html Documentation/howto}
%{!?_without_docs: %doc Documentation/technical}
%{_sysconfdir}/bash_completion.d

%files svn
%defattr(-,root,root)
%{_libexecdir}/git-core/*svn*
%doc Documentation/*svn*.txt
%{!?_without_docs: %{_mandir}/man1/*svn*.1*}
%{!?_without_docs: %doc Documentation/*svn*.html }

%files cvs
%defattr(-,root,root)
%doc Documentation/*git-cvs*.txt
%{_bindir}/git-cvsserver
%{_libexecdir}/git-core/*cvs*
%{!?_without_docs: %{_mandir}/man1/*cvs*.1*}
%{!?_without_docs: %doc Documentation/*git-cvs*.html }

%files arch
%defattr(-,root,root)
%doc Documentation/git-archimport.txt
%{_libexecdir}/git-core/git-archimport
%{!?_without_docs: %{_mandir}/man1/git-archimport.1*}
%{!?_without_docs: %doc Documentation/git-archimport.html }

%files email
%defattr(-,root,root)
%doc Documentation/*email*.txt
%{_libexecdir}/git-core/*email*
%{!?_without_docs: %{_mandir}/man1/*email*.1*}
%{!?_without_docs: %doc Documentation/*email*.html }

%files gui
%defattr(-,root,root)
%{_libexecdir}/git-core/git-gui
%{_libexecdir}/git-core/git-citool
%{_libexecdir}/git-core/git-gui--askpass
%{_datadir}/git-gui/
%{!?_without_docs: %{_mandir}/man1/git-gui.1*}
%{!?_without_docs: %doc Documentation/git-gui.html}
%{!?_without_docs: %{_mandir}/man1/git-citool.1*}
%{!?_without_docs: %doc Documentation/git-citool.html}

%files -n gitk
%defattr(-,root,root)
%doc Documentation/*gitk*.txt
%{_bindir}/*gitk*
%{_datadir}/gitk/
%{!?_without_docs: %{_mandir}/man1/*gitk*.1*}
%{!?_without_docs: %doc Documentation/*gitk*.html }

%files -n gitweb
%defattr(-,root,root)
%doc gitweb/README gitweb/INSTALL Documentation/*gitweb*.txt
%{_datadir}/gitweb
%{!?_without_docs: %{_mandir}/man1/*gitweb*.1*}
%{!?_without_docs: %{_mandir}/man5/*gitweb*.5*}
%{!?_without_docs: %doc Documentation/*gitweb*.html }

%files -n perl-Git -f perl-files
%defattr(-,root,root)

%files all
# No files for you!

%changelog
* Sun Sep 18 2011 Jakub Narebski <jnareb@gmail.com>
- Add gitweb manpages to 'gitweb' subpackage

* Wed Jun 30 2010 Junio C Hamano <gitster@pobox.com>
- Add 'gitweb' subpackage.

* Fri Mar 26 2010 Ian Ward Comfort <icomfort@stanford.edu>
- Ship bash completion support from contrib/ in the core package.

* Sun Jan 31 2010 Junio C Hamano <gitster@pobox.com>
- Do not use %define inside %{!?...} construct.

* Sat Jan 30 2010 Junio C Hamano <gitster@pobox.com>
- We don't ship Python bits until a real foreign scm interface comes.

* Mon Feb 04 2009 David J. Mellor <dmellor@whistlingcat.com>
- fixed broken git help -w after renaming the git-core package to git.

* Fri Sep 12 2008 Quy Tonthat <qtonthat@gmail.com>
- move git-cvsserver to bindir.

* Sun Jun 15 2008 Junio C Hamano <gitster@pobox.com>
- Remove curl from Requires list.

* Fri Feb 15 2008 Kristian Høgsberg <krh@redhat.com>
- Rename git-core to just git and rename meta package from git to git-all.

* Sun Feb 03 2008 James Bowes <jbowes@dangerouslyinc.com>
- Add a BuildRequires for gettext

* Fri Jan 11 2008 Junio C Hamano <gitster@pobox.com>
- Include gitk message files

* Sun Jan 06 2008 James Bowes <jbowes@dangerouslyinc.com>
- Make the metapackage require the same version of the subpackages.

* Wed Dec 12 2007 Junio C Hamano <gitster@pobox.com>
- Adjust htmldir to point at /usr/share/doc/git-core-$version/

* Sun Jul 15 2007 Sean Estabrooks <seanlkml@sympatico.ca>
- Removed p4import.

* Tue Jun 26 2007 Quy Tonthat <qtonthat@gmail.com>
- Fixed problems looking for wrong manpages.

* Thu Jun 21 2007 Shawn O. Pearce <spearce@spearce.org>
- Added documentation files for git-gui

* Tue May 13 2007 Quy Tonthat <qtonthat@gmail.com>
- Added lib files for git-gui
- Added Documentation/technical (As needed by Git Users Manual)

* Tue May 8 2007 Quy Tonthat <qtonthat@gmail.com>
- Added howto files

* Tue Mar 27 2007 Eygene Ryabinkin <rea-git@codelabs.ru>
- Added the git-p4 package: Perforce import stuff.

* Mon Feb 13 2007 Nicolas Pitre <nico@fluxnic.net>
- Update core package description (Git isn't as stupid as it used to be)

* Mon Feb 12 2007 Junio C Hamano <junkio@cox.net>
- Add git-gui and git-citool.

* Mon Nov 14 2005 H. Peter Anvin <hpa@zytor.com> 0.99.9j-1
- Change subpackage names to git-<name> instead of git-core-<name>
- Create empty root package which brings in all subpackages
- Rename git-tk -> gitk

* Thu Nov 10 2005 Chris Wright <chrisw@osdl.org> 0.99.9g-1
- zlib dependency fix
- Minor cleanups from split
- Move arch import to separate package as well

* Tue Sep 27 2005 Jim Radford <radford@blackbean.org>
- Move programs with non-standard dependencies (svn, cvs, email)
  into separate packages

* Tue Sep 27 2005 H. Peter Anvin <hpa@zytor.com>
- parallelize build
- COPTS -> CFLAGS

* Fri Sep 16 2005 Chris Wright <chrisw@osdl.org> 0.99.6-1
- update to 0.99.6

* Fri Sep 16 2005 Horst H. von Brand <vonbrand@inf.utfsm.cl>
- Linus noticed that less is required, added to the dependencies

* Sun Sep 11 2005 Horst H. von Brand <vonbrand@inf.utfsm.cl>
- Updated dependencies
- Don't assume manpages are gzipped

* Thu Aug 18 2005 Chris Wright <chrisw@osdl.org> 0.99.4-4
- drop sh_utils, sh-utils, diffutils, mktemp, and openssl Requires
- use RPM_OPT_FLAGS in spec file, drop patch0

* Wed Aug 17 2005 Tom "spot" Callaway <tcallawa@redhat.com> 0.99.4-3
- use dist tag to differentiate between branches
- use rpm optflags by default (patch0)
- own %{_datadir}/git-core/

* Mon Aug 15 2005 Chris Wright <chrisw@osdl.org>
- update spec file to fix Buildroot, Requires, and drop Vendor

* Sun Aug 07 2005 Horst H. von Brand <vonbrand@inf.utfsm.cl>
- Redid the description
- Cut overlong make line, loosened changelog a bit
- I think Junio (or perhaps OSDL?) should be vendor...

* Thu Jul 14 2005 Eric Biederman <ebiederm@xmission.com>
- Add the man pages, and the --without docs build option

* Wed Jul 7 2005 Chris Wright <chris@osdl.org>
- initial git spec file
