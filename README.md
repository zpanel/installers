ZPanel Installers
=================

Welcome to the ZPanel installation and upgrade script Git repository, this provides a central place to store, version and distribute ZPanel installers and upgrade scripts from.

## How to install/upgrade ZPanel ##

The new installers and upgrade scripts enable you to install/upgrade  ZPanel directly from the command line with a single command, you no longer need to manually download the file, *CHMOD* it and then execute it etc.

> The following commands are published on the official ZPanel download page.

Installation is now as simple as:-

```curl -Ss
https://raw.github.com/zpanel/installers/master/install/CentOS-6_3+/10_1_1.sh | bash```

...and to upgrade your server (for example from ZPanel 10.1.0 to 10.1.1):-

```curl -Ss
https://raw.github.com/zpanel/installers/master/upgrade/CentOS-6_3+/10_1_1.sh | bash```

*The above examples demonstrate the installation of ZPanel 10.1.1 and upgrading a server running CentOS 6.4*

## Officially supported Operating Systems ##

As a relatively small team of guys and due to the time required to keep installation packages updated and tested we have officially decided to support and maintain the following operating systems/distributions.

- Latest Ubuntu Server LTS release (currently 12.04 LTS)
- CentOS (minimal) release version 6.3 or above

> By officially supported we refer to the fact that we ensure that prior to any release of ZPanel that the official ZPanel team have released and fully tested installer scripts and upgrade scripts for the OS versions listed above.

## Official maintainers ##

The officially supported operating system installer and upgrade scripts are maintained internally by members of the official ZPanel team.

We do encourage third-party installation scripts of which we will happily host on this repository and promote the use of in the event that we get interest by community members. If you are interested in maintaining an installation and upgrade script for another OS/distribution please see the *Want to contribute* section below for more information.

## Want to contribute ##

There are a couple of ways in which you can contribute, firstly you can make improvements or fix 'bugs' in the existing 'officially maintained' installers of which we feel will usually be minimal as we keep on top of these installer/upgrade scripts and frequently review them.

The other way in which you can contribute is to become an 'community maintainer' this means that you are responsible for the creation and maintenance of installation and upgrade scripts for non-official supported OSes.

In most cases you'll simply be able to copy and paste our official installer and upgrade scripts and just make the required OS/distribution specific changes such as file/directory paths and operating system/distribution specific package configuration amendments.

If you are interested in becoming an community maintainer please email [ballen@zpanelcp.com](mailto:ballen@zpanelcp.com) stating your interest in becoming a community maintainer and the OS/distribution that you wish to maintain.

Please be aware that community supported install and upgrade scripts that we will host and promote must adhere to the following rules:

- Must be kept up to date with the latest release of the OS.
- Will be licensed under the GPL and hosted on this repository.
- Must maintain the same user interface as our official install/upgrade scripts (eg. shell script echo's and 'read' statements must match the same wording to ensure that the installation experience across all OSes and distributions give the same user experience.)

If you have any queries regarding the above rules please feel free to contact me at: [ballen@zpanelcp.com](mailto:ballen@zpanelcp.com).
