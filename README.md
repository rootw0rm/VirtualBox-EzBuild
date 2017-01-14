VirtualBox for Windows EZ-Build by rootw0rm, https://github.com/rootw0rm/VirtualBox-EzBuild

Version: 0.2, a few bugfixes completed

---

What it does:

Downloads all required tools and library sources (and their dependencies)
for building VirtualBox and builds them.  It then builds VirtualBox and
installs it.  Ultimately, the goal is to also automatically patch the
source code with randomized machine information, but that is not implemented
yet.  The tools and libraries downloaded include:

* mingw64 (4.9.3)
* nasm (2.12.02)
* python (2.7.13)
* perl (ActivePerl 5.24)
* ruby (2.3.3)
* jom (latest)
* libcurl (7.52.1)
* openssl (1.1.0c)
* qt (5.6.2)
* virtualbox (5.1.12)
* virtualbox sdk (5.1.12)

---

What it consists of:

* BUILDVBOX.bat
* 7-zip, from http://7-zip.org/a/7z1604-extra.7z
* curl, from https://bintray.com/artifact/download/vszakats/generic/curl-7.52.1-win64-mingw.7z
* Microsoft Visual Studio 2015 project files, for coding, not building, see README.txt

---

Details of the VirtualBox build:

* 64-bit release binaries, test signed, with x86 guest support
* No SDL support, Qt5 only
* Hardening disabled
* Tested on version 5.1.12

---

Requirements:

* 64 bit version of Windows in TEST MODE("bcdedit /set testsigning on"), only tested on Windows 10
* Visual Studio 2010 full version
* Windows Driver Kit 7.1
https://download.microsoft.com/download/4/A/2/4A25C7D5-EFBE-4182-B6A9-AE6850409A78/GRMWDK_EN_7600_1.ISO
* Windows SDK 7.1
http://download.microsoft.com/download/F/1/0/F10113F5-B750-4969-A255-274341AC6BCE/GRMSDKX_EN_DVD.iso
* DirectX SDK June 2010 (will be downloaded and installed if not found)
https://download.microsoft.com/download/A/E/7/AE743F1F-632B-4809-87A9-AA1BB3458E31/DXSDK_Jun10.exe
* At least 7GB of drive space

---

Limitations:

* Cannot build from a path which contains spaces (kbuild limitation)
* Cannot build from a path which contains exclamation mark (make/qmake limitation)
* Cannot build from a path which contains a set of parentheses (Windows limitation)
* Building VirtualBox is limited to 1 core right now, as parallel hasn't been reliable for me

---

Instructions:

* Extract tools to a reasonably short path with NO SPACES or EXCLAMATION MARK and execute
BUILDVBOX.bat with administrative priveleges.
* Admin rights are required for tool installation & certificate generation.
* VirtualBox will be installed to "\output".
* To move VirtualBox installation, stop the VBoxDrv services ("net stop vboxdrv"),
move the folder where you want it, and run "loadall.cmd" and "comregister.cmd"

---

Notes:

Building everything will take up to a few hours, a VirtualBox rebuild should take 1-2 hours.
To update library versions or VirtualBox version, updating the link at the top of
BUILDVBOX.bat should suffice as long as an archive link (.7z, .tgz, etc.) is
changed to another archive link.  Archive type shouldn't matter.  Exe links
will have to be compatible with the existing method for installing them.
Downloads are not resumed, but once tools and library sources are acquired
and/or built, those steps won't be repeated.  Clean manually if necessary.
Once you run this tool, always keep "vboxtest.cer" in the root folder.
If you move or delete the build folder after using it and don't save "vboxtest.cer", 
you'll need to run certmgr and remove the "VboxTest" certificate from Personal, 
Trusted Publisher, and Trusted Root Certification Authorities stores.