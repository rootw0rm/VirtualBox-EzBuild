@rem VirtualBox for Windows EZ-Build by rootw0rm, https://github.com/rootw0rm/VirtualBox-EzBuild
@echo off
cd /d %~dp0
set "_build_dir=%cd%"
set "_install_path=%_build_dir%\output"
set "_7z=%_build_dir%\tools\7z\7za.exe"
set "_curl=%_build_dir%\tools\curl\curl.exe"
set _openssl_link="https://www.openssl.org/source/openssl-1.1.0e.tar.gz"
set _curl_link="https://curl.haxx.se/download/curl-7.52.1.tar.gz"
set _qt_link="https://download.qt.io/archive/qt/5.6/5.6.2/single/qt-everywhere-opensource-src-5.6.2.tar.gz"
set _vbox_sdk_link="http://download.virtualbox.org/virtualbox/5.1.14/VirtualBoxSDK-5.1.14-112924.zip"
set _vbox_link="http://download.virtualbox.org/virtualbox/5.1.14/VirtualBox-5.1.14.tar.bz2"
set _mingw64_link="https://sourceforge.net/projects/mingw-w64/files/Toolchains targetting Win64/Personal Builds/mingw-builds/4.9.3/threads-posix/sjlj/x86_64-4.9.3-release-posix-sjlj-rt_v4-rev1.7z/download"
set _nasm_link="http://www.nasm.us/pub/nasm/releasebuilds/2.12.02/win64/nasm-2.12.02-win64.zip"
set _ruby_link="https://dl.bintray.com/oneclick/rubyinstaller/ruby-2.3.3-x64-mingw32.7z"
set _jom_link="http://download.qt.io/official_releases/jom/jom.zip"
set _python_link="https://www.python.org/ftp/python/2.7.13/python-2.7.13.msi"
set _perl_link="http://downloads.activestate.com/ActivePerl/releases/5.24.1.2402/ActivePerl-5.24.1.2402-MSWin32-x64-401627.exe"
set _dxsdk_link="https://download.microsoft.com/download/A/E/7/AE743F1F-632B-4809-87A9-AA1BB3458E31/DXSDK_Jun10.exe"
set _sdk71_link="http://download.microsoft.com/download/F/1/0/F10113F5-B750-4969-A255-274341AC6BCE/GRMSDKX_EN_DVD.iso"
set _wdk71_link="https://download.microsoft.com/download/4/A/2/4A25C7D5-EFBE-4182-B6A9-AE6850409A78/GRMWDK_EN_7600_1.ISO"
rem main variables to work with, listed here for others:
set _python_path=
set _wdk_path=
set _sdk_path=
set _dxsdk_path=
set _vs10_path=
set _wdk_path_unix=
set _sdk_path_unix=
set _dxsdk_path_unix=
set _vs10_path_unix=
set _build_dir_unix=
set _python_path_unix=
:_main
setlocal
set _error_state=
net session >nul 2>&1
if %errorlevel% neq 0 call :_print_error Administrative rights required for certificate creation and installers.
call :_find_WDK
rem call :_find_SDK_71A
call :_find_SDK_71
call :_find_DXSDK
call :_openssl
call :_libcurl
call :_qt
call :_vbox_sdk
call :_vbox
call :_mingw64
call :_nasm
call :_jom
call :_python
call :_perl
call :_ruby
call :_make_cert
call :_find_VS10
call :_create_symlinks
call :_build_openssl_x86
call :_build_openssl_x64
call :_build_libcurl_x86
call :_build_libcurl_x64
call :_build_qt
call :_fix_slashes
call :_build_vbox
if defined _error_state (goto _error)
call :_print_ok Finished with no errors!
call :_clean_temp
endlocal
pause
exit /b
:_fix_slashes
set _wdk_path_unix=%_wdk_path:\=/%
set _sdk_path_unix=%_sdk_path:\=/%
set _dxsdk_path_unix=%_dxsdk_path:\=/%
set _vs10_path_unix=%_vs10_path:\=/%
set _build_dir_unix=%_build_dir:\=/%
set _python_path_unix=%_python_path:\=/%
exit /b
:_print_error
if defined _error_state (goto _error) else echo !!! [ Error: %* ] !!!
goto _error
:_print_ok
if defined _error_state (goto _error) else echo +++ [ OK: %* ] +++
exit /b
:_print_cfg
>>"%_build_dir%\vbox\LocalConfig.kmk" echo %*
exit /b
:_print_msg
echo === [ %* ] ===
exit /b
:_create_symlinks
if defined _error_state (goto _error)
if exist "%_build_dir%\VS_LINK" rd /s /q "%_build_dir%\VS_LINK"
if exist "%_build_dir%\WDK_LINK" rd /s /q "%_build_dir%\WDK_LINK"
if exist "%_build_dir%\SDK_LINK" rd /s /q "%_build_dir%\SDK_LINK"
if exist "%_build_dir%\DXSDK_LINK" rd /s /q "%_build_dir%\DXSDK_LINK"
mklink /D "%_build_dir%\VS_LINK" "%_vs10_path%"
mklink /D "%_build_dir%\WDK_LINK" "%_wdk_path%"
mklink /D "%_build_dir%\SDK_LINK" "%_sdk_path%"
mklink /D "%_build_dir%\DXSDK_LINK" %_dxsdk_path%
set "_vs10_path=%_build_dir%\VS_LINK"
set "_wdk_path=%_build_dir%\WDK_LINK"
set "_sdk_path=%_build_dir%\SDK_LINK"
set "_dxsdk_path=%_build_dir%\DXSDK_LINK"
exit /b
:_clean_temp
if exist "%_build_dir%\temp" (rd /s /q "%_build_dir%\temp")
exit /b
:_get_default_reg_value
set _reg_value=
for /f "tokens=2,* usebackq" %%g in (`reg query %* /ve`) do set "_reg_value=%%h"
if not defined _reg_value (exit /b)
rem remove trailing slash
if "%_reg_value:~-1%"=="\" set "_reg_value=%_reg_value:~0,-1%"
exit /b
:_get_reg_value
set _reg_value=
for /f "tokens=2,* usebackq" %%g in (`reg query %1 /v %2`) do set "_reg_value=%%h"
if not defined _reg_value (exit /b)
rem remove trailing slash
if "%_reg_value:~-1%"=="\" set "_reg_value=%_reg_value:~0,-1%"
exit /b
:_make_cert
if defined _error_state (goto _error)
if exist vboxtest.cer (
	call :_print_ok Code signing certificate located.
	exit /b
)
set "_signtool_path=%_wdk_path%\bin\amd64"
"%_signtool_path%\makecert.exe" -r -pe -ss my -n "CN=VBoxTest" vboxtest.cer
if %errorlevel% neq 0 call :_print_error Certificate creation failed.
"%_signtool_path%\certmgr.exe" -add vboxtest.cer -s root
if %errorlevel% neq 0 call :_print_error Adding to certificate store failed.
"%_signtool_path%\certmgr.exe" -add vboxtest.cer -s trustedpublisher
if %errorlevel% neq 0 call :_print_error Adding to certificate store failed.
if exist vboxtest.cer call :_print_ok Code signing certificate created.
exit /b
:_check_files_exist
set _files_exist=
:_check_top
if [%1] == [] goto _check_bottom
if exist "%1" (set _files_exist=1) else (
	set _files_exist=
	goto _check_bottom
)
shift
goto _check_top
:_check_bottom
exit /b
:_set_path
set PATH=
set VSINSTALLDIR=%_vs10_path%
set PATH=%_vs10_path%\Common7\Tools;%PATH%
set PATH=%_vs10_path%\Common7\IDE;%PATH%
set PATH=%_vs10_path%\VC\vcpackages;%PATH%
set PATH=%_build_dir%\perl\bin;%PATH%
set PATH=%_python_path%;%_python_path%\Tools\Scripts;%PATH%
set PATH=%_build_dir%\jom;%PATH%
set PATH=%_build_dir%\nasm;%PATH%
set PATH=%_build_dir%\ruby\bin;%PATH%
set PATH=%_build_dir%\mingw64\bin;%PATH%
set PATH=%windir%\system32;%windir%;%windir%\System32\Wbem;%windir%\System32\WindowsPowerShell\v1.0;%PATH%
exit /b
:_build_openssl_x86
if defined _error_state (goto _error)
call :_check_files_exist "%_build_dir%\openssl\x86\lib\libcrypto.lib" "%_build_dir%\openssl\x86\lib\libssl.lib" "%_build_dir%\openssl\x86\bin\libcrypto-1_1.dll" "%_build_dir%\openssl\x86\bin\libssl-1_1.dll"
if defined _files_exist (
	call :_print_ok OpenSSL x86 libs and binaries found.
	exit /b
)
setlocal
call :_set_path
call "%_vs10_path%\VC\vcvarsall.bat" x86
cd "%_build_dir%\openssl"
nmake clean
perl Configure VC-WIN32 --prefix="%_build_dir%\openssl\x86"
nmake
nmake install
endlocal
cd "%_build_dir%"
call :_check_files_exist "%_build_dir%\openssl\x86\lib\libcrypto.lib" "%_build_dir%\openssl\x86\lib\libssl.lib" "%_build_dir%\openssl\x86\bin\libcrypto-1_1.dll" "%_build_dir%\openssl\x86\bin\libssl-1_1.dll"
if not defined _files_exist (
	call :_print_error Error building OpenSSL x86.
	exit /b
)
call :_print_ok OpenSSL x86 successfully built.
exit /b
:_build_openssl_x64
if defined _error_state (goto _error)
call :_check_files_exist "%_build_dir%\openssl\x64\lib\libcrypto.lib" "%_build_dir%\openssl\x64\lib\libssl.lib" "%_build_dir%\openssl\x64\bin\libcrypto-1_1-x64.dll" "%_build_dir%\openssl\x64\bin\libssl-1_1-x64.dll"
if defined _files_exist (
	call :_print_ok OpenSSL x64 libs and binaries found.
	exit /b
)
setlocal
call :_set_path
call "%_vs10_path%\VC\vcvarsall.bat" x64
cd "%_build_dir%\openssl"
nmake clean
perl Configure VC-WIN64A --prefix="%_build_dir%\openssl\x64"
nmake
nmake install
endlocal
cd "%_build_dir%"
call :_check_files_exist "%_build_dir%\openssl\x64\lib\libcrypto.lib" "%_build_dir%\openssl\x64\lib\libssl.lib" "%_build_dir%\openssl\x64\bin\libcrypto-1_1-x64.dll" "%_build_dir%\openssl\x64\bin\libssl-1_1-x64.dll"
if not defined _files_exist (
	call :_print_error Error building OpenSSL x64.
	exit /b
)
call :_print_ok OpenSSL x64 successfully built.
exit /b
:_build_libcurl_x86
if defined _error_state (goto _error)
call :_check_files_exist "%_build_dir%\libcurl\builds\libcurl-vc10-x86-release-dll-ipv6-sspi-winssl\lib\libcurl.lib"
if defined _files_exist (
	call :_print_ok libcurl x86 libs found.
	exit /b
)
setlocal
call :_set_path
call "%_vs10_path%\VC\vcvarsall.bat" x86
cd "%_build_dir%\libcurl\winbuild"
nmake /f Makefile.vc mode=dll VC=10 MACHINE=x86
endlocal
cd "%_build_dir%"
call :_check_files_exist "%_build_dir%\libcurl\builds\libcurl-vc10-x86-release-dll-ipv6-sspi-winssl\lib\libcurl.lib"
if not defined _files_exist (
	call :_print_error Error building libcurl x86.
	exit /b
)
call :_print_ok libcurl x86 successfully built.
exit /b
:_build_libcurl_x64
if defined _error_state (goto _error)
call :_check_files_exist "%_build_dir%\libcurl\builds\libcurl-vc10-x64-release-dll-ipv6-sspi-winssl\lib\libcurl.lib"
if defined _files_exist (
	call :_print_ok libcurl x64 libs found.
	exit /b
)
setlocal
call :_set_path
call "%_vs10_path%\VC\vcvarsall.bat" x64
cd "%_build_dir%\libcurl\winbuild"
nmake /f Makefile.vc mode=dll VC=10 MACHINE=x64
endlocal
cd "%_build_dir%"
call :_check_files_exist "%_build_dir%\libcurl\builds\libcurl-vc10-x64-release-dll-ipv6-sspi-winssl\lib\libcurl.lib"
if not defined _files_exist (
	call :_print_error Error building libcurl x64.
	exit /b
)
call :_print_ok libcurl x64 successfully built.
exit /b
:_build_qt
if defined _error_state (goto _error)
set "_bin=%_build_dir%\qt\qtbase\bin"
call :_check_files_exist "%_bin%\Qt5Core.dll" "%_bin%\Qt5Gui.dll" "%_bin%\Qt5OpenGL.dll" "%_bin%\Qt5PrintSupport.dll" "%_bin%\Qt5Widgets.dll" "%_bin%\Qt5WinExtras.dll"
if defined _files_exist (
	call :_print_ok Qt binaries found.
	exit /b
)
setlocal
call :_set_path
call "%_vs10_path%\VC\vcvarsall.bat" x64
call "%_dxsdk_path%\Utilities\bin\dx_setenv.cmd" amd64
SET PATH=%_build_dir%\qt\qtbase\bin;%_build_dir%\qt\gnuwin32\bin;%PATH%
SET QTDIR="%_build_dir%\qt\qtbase"
cd "%_build_dir%\qt"
SET QMAKESPEC=win32-msvc2010
nmake distclean
call configure.bat -release -confirm-license -mp -opensource -opengl dynamic -openvg -no-compile-examples -nomake examples -nomake tests
nmake
endlocal
cd "%_build_dir%"
call :_check_files_exist "%_bin%\Qt5Core.dll" "%_bin%\Qt5Gui.dll" "%_bin%\Qt5OpenGL.dll" "%_bin%\Qt5PrintSupport.dll" "%_bin%\Qt5Widgets.dll" "%_bin%\Qt5WinExtras.dll"
if not defined _files_exist (
	call :_print_error Error building Qt.
	exit /b
)
call :_print_ok Qt successfully built.
exit /b
:_gen_vbox_config
if defined _error_state (goto _error)
if exist "%_build_dir%\vbox\LocalConfig.kmk" del "%_build_dir%\vbox\LocalConfig.kmk"
call :_print_cfg VBOX_OSE := 1
call :_print_cfg PATH_SDK_WINDDK71 := %_wdk_path_unix%
call :_print_cfg PATH_TOOL_VCC100 := %_vs10_path_unix%/VC
call :_print_cfg PATH_SDK_WINPSDK71 := %_sdk_path_unix%
call :_print_cfg PATH_TOOL_VCC100X86 := $(PATH_TOOL_VCC100)
call :_print_cfg PATH_TOOL_VCC100AMD64 := $(PATH_TOOL_VCC100)
call :_print_cfg VBOX_WINPSDK := WINPSDK71
call :_print_cfg VBOX_MAIN_IDL := %_sdk_path_unix%/bin/Midl.exe
call :_print_cfg PATH_TOOL_MINGWW64 := %_build_dir_unix%/mingw64
call :_print_cfg PATH_SDK_QT5 := %_build_dir_unix%/qt/qtbase
call :_print_cfg PATH_TOOL_QT5 := $(PATH_SDK_QT5)
call :_print_cfg VBOX_PATH_QT := $(PATH_SDK_QT5)
call :_print_cfg VBOX_BLD_PYTHON := %_python_path_unix%/python.exe
call :_print_cfg VBOX_PATH_SDK := %_build_dir_unix%/vbox_sdk
call :_print_cfg SDK_VBOX_LIBCURL-x86_INCS := %_build_dir_unix%/libcurl/builds/libcurl-vc10-x86-release-dll-ipv6-sspi-winssl/include
call :_print_cfg SDK_VBOX_LIBCURL-x86_LIBS.x86 := %_build_dir_unix%/libcurl/builds/libcurl-vc10-x86-release-dll-ipv6-sspi-winssl/lib/libcurl.lib
call :_print_cfg SDK_VBOX_LIBCURL_INCS := %_build_dir_unix%/libcurl/builds/libcurl-vc10-x64-release-dll-ipv6-sspi-winssl/include
call :_print_cfg SDK_VBOX_LIBCURL_LIBS := %_build_dir_unix%/libcurl/builds/libcurl-vc10-x64-release-dll-ipv6-sspi-winssl/lib/libcurl.lib
call :_print_cfg SDK_VBOX_OPENSSL-x86_INCS := %_build_dir_unix%/openssl/x86/include
call :_print_cfg SDK_VBOX_OPENSSL-x86_LIBS := %_build_dir_unix%/openssl/x86/lib/libcrypto.lib %_build_dir_unix%/openssl/x86/lib/libssl.lib
call :_print_cfg SDK_VBOX_OPENSSL_INCS := %_build_dir_unix%/openssl/x64/include
call :_print_cfg SDK_VBOX_OPENSSL_LIBS := %_build_dir_unix%/openssl/x64/lib/libcrypto.lib %_build_dir_unix%/openssl/x64/lib/libssl.lib
call :_print_cfg VBOX_NM := nm -p
call :_print_cfg VBOX_WITH_HARDENING :=
call :_print_cfg VBOX_WITH_RAW_MODE := 1
call :_print_cfg VBOX_WITH_OPEN_WATCOM :=
call :_print_cfg VBOX_WITHOUT_ADDITIONS := 1
call :_print_cfg VBOX_WITH_ADDITIONS :=
call :_print_cfg VBOX_WITH_VBOXDRV := 1
call :_print_cfg VBOX_WITH_VALIDATIONKIT :=
call :_print_cfg VBOX_WITH_TESTCASES :=
call :_print_cfg VBOX_WITH_LIBCURL := 1
call :_print_cfg VBOX_WITH_VBOXSDL :=
call :_print_cfg VBOX_WITH_DOCS :=
call :_print_cfg VBOX_WITH_DOCS_CHM :=
call :_print_cfg VBOX_WITH_VIDEOHWACCEL := 1
call :_print_cfg VBOX_WITH_QTGUI := 1
call :_print_cfg VBOX_WITH_QTGUI_V5 := 1
call :_print_cfg VBOX_GUI_USE_QGL := 1
call :_print_cfg VBOX_WITHOUT_NATIVE_R0_LOADER :=
call :_print_cfg VBOX_SIGNING_MODE := test
call :_print_cfg VBOX_CERTIFICATE_SUBJECT_NAME := VBoxTest
call :_print_cfg VBOX_CERTIFICATE_STORE := my
call :_print_cfg VBOX_CERTIFICATE_SUBJECT_NAME_ARGS := /a /n "$(VBOX_CERTIFICATE_SUBJECT_NAME)"
call :_print_cfg VBOX_PATH_SIGN_TOOLS := %_wdk_path_unix%/bin/amd64
call :_print_cfg VBOX_PATH_SELFSIGN := %_wdk_path_unix%/bin/selfsign
call :_print_cfg VBOX_WINDDK := WINDDK71
call :_print_cfg VBOX_WITH_WARNINGS_AS_ERRORS :=
exit /b
:_build_vbox
if defined _error_state (goto _error)
net stop vboxdrv
net stop vboxnetlwf
net stop vboxnetadp
net stop vboxusbmon
net stop vboxnetlwf
if not exist "%_build_dir%\vbox\LocalConfig.kmk" call :_gen_vbox_config
if exist "%_build_dir%\vbox\out" rd /s /q "%_build_dir%\vbox\out"
cd "%_build_dir%\vbox"
call :_set_path
rem call "%_vs10_path%\VC\vcvarsall.bat" x64
set INCLUDE=%_build_dir%\openssl\include;%_build_dir%\qt\qtwinextras\include;%_build_dir%\qt\qtwinextras\include\QtWinExtras;%INCLUDE%
set PATH=%_build_dir%\vbox\tools\win.amd64\bin;%PATH%
call kBuild\envwin.cmd --win64 --release
rem parallel builds never work right for me....
kmk -j 1
if not exist "%_build_dir%\vbox\out\win.amd64\release\obj\VBoxDrv\VBoxDrv.sys" (
	call :_print_error Error building VirtualBox.
	goto :_end_build
)
call :_install_vbox
:_end_build
exit /b
:_install_vbox
if exist "%_install_path%" rd /s /q "%_install_path%"
mkdir "%_install_path%"
xcopy /k /e /y /q "%_build_dir%\vbox\out\win.amd64\release\bin" "%_install_path%"
REM copy "%_build_dir%\vbox\out\win.amd64\release\obj\VBoxDrv\VBoxDrv.sys" "%_install_path%"
REM copy "%_build_dir%\vbox\out\win.amd64\release\obj\VBoxNetAdp\VBoxNetAdp.sys" "%_install_path%"
REM copy "%_build_dir%\vbox\out\win.amd64\release\obj\VBoxNetAdp6\VBoxNetAdp6.sys" "%_install_path%"
REM copy "%_build_dir%\vbox\out\win.amd64\release\obj\VBoxNetFlt\VBoxNetFlt.sys" "%_install_path%"
REM copy "%_build_dir%\vbox\out\win.amd64\release\obj\VBoxNetLwf\VBoxNetLwf.sys" "%_install_path%"
REM copy "%_build_dir%\vbox\out\win.amd64\release\obj\VBoxUSB\VBoxUSB.sys" "%_install_path%"
REM copy "%_build_dir%\vbox\out\win.amd64\release\obj\VBoxUSBMon\VBoxUSBMon.sys" "%_install_path%"
REM copy "%_build_dir%\vbox\src\VBox\HostDrivers\Support\win\VBoxDrv.inf" "%_install_path%"
REM copy "%_build_dir%\vbox\src\VBox\HostDrivers\VBoxNetAdp\win\VBoxNetAdp6.inf" "%_install_path%"
REM copy "%_build_dir%\vbox\src\VBox\HostDrivers\VBoxNetFlt\win\drv\VBoxNetAdp.inf" "%_install_path%"
REM copy "%_build_dir%\vbox\src\VBox\HostDrivers\VBoxNetFlt\win\drv\VBoxNetFlt.inf" "%_install_path%"
REM copy "%_build_dir%\vbox\src\VBox\HostDrivers\VBoxNetFlt\win\drv\VBoxNetLwf.inf" "%_install_path%"
REM copy "%_build_dir%\vbox\src\VBox\HostDrivers\VBoxUSB\win\dev\VBoxUSB.inf" "%_install_path%"
REM copy "%_build_dir%\vbox\src\VBox\HostDrivers\VBoxUSB\win\mon\VBoxUSBMon.inf" "%_install_path%"
copy "%_build_dir%\qt\qtbase\bin\Qt5Core.dll" "%_install_path%"
copy "%_build_dir%\qt\qtbase\bin\Qt5Gui.dll" "%_install_path%"
copy "%_build_dir%\qt\qtbase\bin\Qt5OpenGL.dll" "%_install_path%"
copy "%_build_dir%\qt\qtbase\bin\Qt5PrintSupport.dll" "%_install_path%"
copy "%_build_dir%\qt\qtbase\bin\Qt5Widgets.dll" "%_install_path%"
copy "%_build_dir%\qt\qtbase\bin\Qt5WinExtras.dll" "%_install_path%"
copy "%_build_dir%\libcurl\builds\libcurl-vc10-x64-release-dll-ipv6-sspi-winssl\bin\libcurl.dll" "%_install_path%"
copy "%_build_dir%\openssl\x64\bin\libcrypto-1_1-x64.dll" "%_install_path%"
copy "%_build_dir%\openssl\x64\bin\libssl-1_1-x64.dll" "%_install_path%"
copy "%_build_dir%\vbox\src\VBox\HostDrivers\win\loadall.cmd" "%_install_path%"
copy "%_build_dir%\vbox\src\VBox\HostDrivers\win\loadall.sh" "%_install_path%"
copy "%_build_dir%\vbox\src\VBox\Main\src-all\win\comregister.cmd" "%_install_path%"
copy "%_build_dir%\vbox\kBuild\bin\win.amd64\kmk_ash.exe" "%_install_path%"
copy "%_build_dir%\vbox\kBuild\bin\win.amd64\kmk_sed.exe" "%_install_path%"
call "%_install_path%\loadall.cmd"
call "%_install_path%\comregister.cmd"
rd /s /q "%_build_dir%\vbox\out"
call :_print_ok VirtualBox successfully installed at %_install_path%
exit /b
:_find_VS10
if defined _error_state (goto _error)
if defined VS100COMNTOOLS (goto _vs10_env)
call :_get_reg_value "HKEY_CURRENT_USER\SOFTWARE\Microsoft\VisualStudio\10.0_Config" "ShellFolder"
if not defined _reg_value (
	call :_print_error Visual Studio 2010 not found.
	exit /b
)
set "_vs10_path=%_reg_value%"
:_vs10_found
call :_print_ok Visual Studio 2010 located.
exit /b
:_vs10_env
set "_vs10_path=%VS100COMNTOOLS:~0,-15%"
goto _vs10_found
:_get_DXSDK
if defined _error_state (goto _error)
call :_print_msg DirectX SDK not found, attempting to download...
call :_download %_dxsdk_link%
for /f "tokens=1 usebackq" %%g in (`dir "%_build_dir%\temp\*" /b`) do set "_temp_file=%%g"
if defined _temp_file "%_build_dir%\temp\%_temp_file%" /U /P "%_build_dir%\DXSDK"
set "_dxsdk_path=%_build_dir%\DXSDK"
if not exist "%_dxsdk_path%\Include\D3D10.h" (
call :_print_error DirectX SDK download/installation failed.
exit /b
)
call :_print_ok DirectX SDK installed.
exit /b
:_find_DXSDK
if defined _error_state (goto _error)
if defined DXSDK_DIR set _dxsdk_path="%DXSDK_DIR%"
if [%_dxsdk_path%] neq [] goto _DXSDK_found
call :_get_reg_value "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\DirectX\Microsoft DirectX SDK (June 2010)" "InstallPath"
if not defined _reg_value goto _DXSDK_not_found
set "_dxsdk_path=%_reg_value%"
goto _DXSDK_found
:_DXSDK_not_found
call :_get_DXSDK
exit /b
:_DXSDK_found
if exist "%_dxsdk_path%\Include\D3D10.h" (
	call :_print_ok DirectX SDK located.
	exit /b
)
call :_get_DXSDK
call :_find_DXSDK
exit /b
:_find_WDK
if defined _error_state (goto _error)
call :_get_reg_value "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\KitSetup\configured-kits\{B4285279-1846-49B4-B8FD-B9EAF0FF17DA}\{68656B6B-555E-5459-5E5D-6363635E5F61}" "kit-version-major"
if not "%_reg_value%" == "0x7" call :_print_error Microsoft WDK 7.1 not found.
call :_get_reg_value "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\KitSetup\configured-kits\{B4285279-1846-49B4-B8FD-B9EAF0FF17DA}\{68656B6B-555E-5459-5E5D-6363635E5F61}" "kit-version-minor"
if not "%_reg_value%" == "0x1" call :_print_error Microsoft WDK 7.1 not found.
call :_get_reg_value "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\KitSetup\configured-kits\{B4285279-1846-49B4-B8FD-B9EAF0FF17DA}\{68656B6B-555E-5459-5E5D-6363635E5F61}" "setup-install-location"
if not defined _reg_value call :_print_error Microsoft WDK 7.1 not found.
set "_wdk_path=%_reg_value%"
call :_print_ok Microsoft WDK 7.1 located.
exit /b
:_find_SDK_71A
if defined _error_state (goto _error)
call :_get_reg_value "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v7.1A" "InstallationFolder"
if not defined _reg_value (
	call :_print_msg Microsoft SDK 7.1A not found.
	exit /b
)
set "_sdk_path=%_reg_value%"
call :_print_ok Microsoft SDK 7.1A located.
exit /b
:_find_SDK_71
if defined _error_state (goto _error)
call :_get_reg_value "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SDKs\Windows\v7.1" "InstallationFolder"
if not defined _reg_value (
	call :_print_error Microsoft SDK 7.1 not found.
	exit /b
)
set "_sdk_path=%_reg_value%"
call :_print_ok Microsoft SDK 7.1 located.
exit /b
:_download
call :_clean_temp
mkdir "%_build_dir%\temp"
PUSHD "%_build_dir%\temp"
%_curl% -L -k -O -J %*
POPD
if %errorlevel% neq 0 call :_print_error Downloading %* failed.
exit /b
:_decompress_next
if defined _error_state (goto _error)
setlocal enabledelayedexpansion
set _mkdir=
if exist "%_build_dir%\%1" rd /s /q "%_build_dir%\%1"
for /f "tokens=1 usebackq" %%g in (`dir "%_build_dir%\temp\*" /b`) do set "_temp_file=%%g"
for /f "tokens=1 usebackq" %%g in (`echo %_temp_file% ^| findstr /R /I ".*\.tar\..*"`) do set "_GTARD=%%g"
if [%2] neq [] (
	set "_mkdir=\%1"
	mkdir "%_build_dir%\temp\%1"
)
if not defined _GTARD for /f "tokens=1 usebackq" %%g in (`echo !_temp_file! ^| findstr /R /I ".*\.tgz\>"`) do set "_GTARD=%%g"
if defined _GTARD (
	rem %_7z% x -aoa -so "%_build_dir%\temp\%_temp_file%" | %_7z% x -o"%_build_dir%\temp%_mkdir%" -aoa -si -ttar
	%_7z% x -o"%_build_dir%\temp" -aoa "%_build_dir%\temp\!_temp_file!"
	del "%_build_dir%\temp\!_temp_file!"
	for /f "tokens=1 usebackq" %%g in (`dir "%_build_dir%\temp\*" /b`) do set "_temp_file=%%g"
	%_7z% x -o"%_build_dir%\temp%_mkdir%" -aoa "%_build_dir%\temp\!_temp_file!"
) else (
	%_7z% x -o"%_build_dir%\temp%_mkdir%" -aoa "%_build_dir%\temp\!_temp_file!"
)
if %errorlevel% neq 0 call :_print_error Decompressing %1 failed.
del "%_build_dir%\temp\!_temp_file!"
for /f "tokens=1 usebackq" %%g in (`dir "%_build_dir%\temp\*" /b`) do set "_temp_dir=%%g"
if not defined _temp_dir (call :_print_error Decompressing %1 failed.) else (move /y "%_build_dir%\temp\!_temp_dir!" "%_build_dir%\%1")
call :_clean_temp
endlocal
exit /b
:_openssl
if defined _error_state (goto _error)
if exist "openssl\Configure" (
	call :_print_ok OpenSSL found!
	exit /b
) else call :_print_msg Downloading OpenSSL...
call :_download %_openssl_link%
call :_decompress_next openssl
exit /b
:_libcurl
if defined _error_state (goto _error)
if exist "libcurl\Makefile" (
	call :_print_ok libCurl found!
	exit /b
) else call :_print_msg Downloading libCurl...
call :_download %_curl_link%
call :_decompress_next libcurl
exit /b
:_qt
if defined _error_state (goto _error)
if exist "qt\configure" (
	call :_print_ok Qt found!
	exit /b
) else call :_print_msg Downloading Qt...
call :_download %_qt_link%
call :_decompress_next qt
exit /b
:_vbox_sdk
if defined _error_state (goto _error)
if exist "vbox_sdk\bindings\c" (
	call :_print_ok VBox SDK found!
	exit /b
) else call :_print_msg Downloading VBox SDK...
call :_download %_vbox_sdk_link%
call :_decompress_next vbox_sdk
exit /b
:_vbox
if defined _error_state (goto _error)
if exist "vbox\configure" (
	call :_print_ok VBox OSE found!
	exit /b
) else call :_print_msg Downloading VBox OSE...
call :_download %_vbox_link%
call :_decompress_next vbox
exit /b
:_mingw64
if defined _error_state (goto _error)
if exist "mingw64\bin\gcc.exe" (
	call :_print_ok mingw64 found!
	exit /b
) else call :_print_msg Downloading mingw64...
call :_download %_mingw64_link%
call :_decompress_next mingw64
exit /b
:_nasm
if defined _error_state (goto _error)
if exist "nasm\nasm.exe" (
	call :_print_ok nasm found!
	exit /b
) else call :_print_msg Downloading nasm...
call :_download %_nasm_link%
call :_decompress_next nasm
exit /b
:_jom
if defined _error_state (goto _error)
if exist "jom\jom.exe" (
	call :_print_ok jom found!
	exit /b
) else call :_print_msg Downloading jom...
call :_download %_jom_link%
call :_decompress_next jom 1
exit /b
:_find_python
if defined _error_state (goto _error)
if exist "python\python.exe" (
	set "_python_path=%_build_dir%\python"
	exit /b
)
call :_get_default_reg_value "HKEY_CURRENT_USER\SOFTWARE\Python\PythonCore\2.7\InstallPath"
if defined _reg_value (
	if "%_reg_value:~-1%"=="\" set "_reg_value=%_reg_value:~0,-1%"
	set "_python_path=%_reg_value%"
	exit /b
)
exit /b
:_python
if defined _error_state (goto _error)
call :_find_python
if defined _reg_value (
	call :_print_ok Python found!
	exit /b
) else call :_print_msg Downloading Python...
call :_download %_python_link%
if %errorlevel% neq 0 call :_print_error Downloading Python failed.
for /f "tokens=1 usebackq" %%g in (`dir "%_build_dir%\temp\*" /L /b`) do set "_temp_file=%%g"
if defined _temp_file (msiexec /i %_build_dir%\temp\%_temp_file% TARGETDIR="%_build_dir%\python" /quiet /passive /norestart) else (call :_print_error Locating Python failed.)
if %errorlevel% neq 0 call :_print_error Installing Python failed.
call :_find_python
call :_clean_temp
exit /b
:_perl
if defined _error_state (goto _error)
if exist "perl\bin\perl.exe" (
	call :_print_ok Perl found!
	exit /b
) else call :_print_msg Downloading ActivePerl...
call :_download %_perl_link%
if %errorlevel% neq 0 call :_print_error Downloading ActivePerl failed.
for /f "tokens=1 usebackq" %%g in (`dir "%_build_dir%\temp\*" /b`) do set "_temp_file=%%g"
if defined _temp_file (%_build_dir%\temp\%_temp_file% /extract /exenoui "%_build_dir%\temp") else (call :_print_error Locating ActivePerl failed.)
if %errorlevel% neq 0 call :_print_error Unpacking ActivePerl failed.
del %_build_dir%\temp\%_temp_file%
for /f "tokens=1 usebackq" %%g in (`dir "%_build_dir%\temp\*" /b`) do set "_temp_dir=%%g"
if not defined _temp_dir (call :_print_error Locating ActivePerl failed.) else (move /y "%_build_dir%\temp\%_temp_dir%" "%_build_dir%\perl")
call :_clean_temp
exit /b
:_ruby
if defined _error_state (goto _error)
if exist "ruby\bin\ruby.exe" (
	call :_print_ok Ruby found!
	exit /b
) else call :_print_msg Downloading Ruby...
call :_download %_ruby_link%
call :_decompress_next ruby
exit /b
:_error
if defined _error_state (
	exit /b 1
	) else set _error_state=1
pause
exit /b 1
@rem VirtualBox for Windows EZ-Build by rootw0rm, https://github.com/rootw0rm/VirtualBox-EzBuild