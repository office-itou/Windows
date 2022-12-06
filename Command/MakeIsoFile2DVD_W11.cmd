Rem ***************************************************************************
@Echo Off
    Cls

Rem *** ��ƊJ�n **************************************************************
:START
    Echo *** ��ƊJ�n ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableExtensions
    SetLocal EnableDelayedExpansion

Rem --- ��Ɗ��m�F ----------------------------------------------------------
    If /I "%USERNAME%" NEQ "Administrator" (
        If /I "%SESSIONNAME%" NEQ "" (
            Echo �Ǘ��ғ����Ŏ��s���ĉ������B
            GoTo DONE
        )
    )

Rem --- ���ϐ��ݒ� ----------------------------------------------------------
    For /F "usebackq delims=" %%I In (`Echo %0`) Do (
        Set WRK_DIR=%%~dpI
        Set WRK_DIR=!WRK_DIR:~0,-1!
        Set WRK_FIL=%%~nxI
        Set WRK_NAM=%%~nI
	    Set WRK_BIN=!WRK_DIR!\bin
    )

Rem Set Path=!WRK_BIN!;!WRK_BIN!\Oscdimg\%PROCESSOR_ARCHITECTURE%;%Path%
    Set NOW_DAY=%date:~0,4%%date:~5,2%%date:~8,2%

    If /I "%time:~0,1%" EQU " " (
        Set NOW_TIM=0%time:~1,1%%time:~3,2%%time:~6,2%
    ) Else (
        Set NOW_TIM=%time:~0,2%%time:~3,2%%time:~6,2%
    )

    For /F "tokens=1-2 usebackq delims=\" %%I In ('!WRK_DIR!') Do (Set WRK_TOP=%%~I\%%~J)

    Set ARG_LST=%*
    Set FLG_OPT=0
    Set FLG_FMT=0

    For %%I In (!ARG_LST!) Do (
        Set ARG_PRM=%%~I
               If /I "!ARG_PRM!" EQU ""            (GoTo SETTING
        ) Else If /I "!ARG_PRM!" EQU "Help"        (GoTo HELP
        ) Else If /I "!ARG_PRM!" EQU "No-Format"   (Set FLG_OPT=1&Set FLG_FMT=1
        ) Else                                     (GoTo HELP
        )
    )

    GoTo SETTING

:HELP
    Echo !WRK_FIL! [Help] [No-Format]
    GoTo DONE

:SETTING
Rem *** ��Ɗ��ݒ� **********************************************************
Rem --- DVD��USB�̃h���C�u���ݒ� ----------------------------------------------
:CHK_DVD_DRIVE
    Echo --- DVD�̃h���C�u���ݒ� -------------------------------------------------------
    Set DRV_DVD=
    Set /P DRV_DVD=DVD�̃h���C�u��[A-Z] ���̓C���[�W�t�H���_�[������͂��ĉ������B
    If /I "!DRV_DVD!" EQU "" (GoTo CHK_DVD_DRIVE)

    If /I "!DRV_DVD:~1,1!" EQU "" (
        Set DRV_DVD=!DRV_DVD!:\)
    )

    For %%I in (!DRV_DVD!\) Do (
        Set DVD_SRC=%%~dpI
        If /I "!DVD_SRC:~-1!" EQU "\" (
            Set DVD_SRC=!DVD_SRC:~0,-1!
        )
    )

:SET_DVD_DRIVE
    If Not Exist "!DRV_DVD!\sources\install.wim" If Not Exist "!DRV_DVD!\sources\install.swm" (
        Echo �]������DVD��"!DRV_DVD!"�ɃZ�b�g���ĉ������B
        Echo �������ł�����[Enter]���������ĉ������B
        Pause > Nul 2>&1
        GoTo SET_DVD_DRIVE
    )

Rem --- ���ϐ��ݒ� ----------------------------------------------------------
    Set WRK_IMG=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!\img
    Set WRK_MNT=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!\mnt

Rem --- ��ƃt�H���_�[�̍쐬 --------------------------------------------------
    If Not Exist "!WRK_IMG!"  (MkDir "!WRK_IMG!")
    If Not Exist "!WRK_MNT!"  (MkDir "!WRK_MNT!")

Rem ===========================================================================
:EDIT
    Echo.
    Echo --- �t�@�C���]�� [DVD �� HDD] -------------------------------------------------
    Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS /NFL "!DVD_SRC!\\" "!WRK_IMG!"

Rem ---------------------------------------------------------------------------
Rem Dism /Get-WimInfo /WimFile:"!WRK_IMG!\sources\boot.wim"
Rem Dism /Get-WimInfo /WimFile:"!WRK_IMG!\sources\install.wim"

Rem --- Microsoft Windows PE --------------------------------------------------
Rem Dism /Quiet /Mount-WIM /WimFile:"!WRK_IMG!\sources\boot.wim" /Index:1 /MountDir:"!WRK_MNT!"
Rem REG LOAD HKEY_LOCAL_MACHINE\MNT_SYSTEM "!WRK_MNT!\Windows\System32\config\SYSTEM"
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\MoSetup /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f
Rem REG QUERY HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\MoSetup
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f
Rem REG QUERY HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig
Rem REG UNLOAD HKEY_LOCAL_MACHINE\MNT_SYSTEM
Rem Dism /Quiet /Unmount-Image /MountDir:"!WRK_MNT!" /Commit

Rem --- Microsoft Windows Setup -----------------------------------------------
    Dism /Quiet /Mount-WIM /WimFile:"!WRK_IMG!\sources\boot.wim" /Index:2 /MountDir:"!WRK_MNT!"
    REG LOAD HKEY_LOCAL_MACHINE\MNT_SYSTEM "!WRK_MNT!\Windows\System32\config\SYSTEM"
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\MoSetup /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f
Rem REG QUERY HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\MoSetup
    REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f
    REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f
    REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f
Rem REG QUERY HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig
    REG UNLOAD HKEY_LOCAL_MACHINE\MNT_SYSTEM
    Dism /Quiet /Unmount-Image /MountDir:"!WRK_MNT!" /Commit

Rem ---------------------------------------------------------------------------
Rem Dism /Get-WimInfo /WimFile:"!WRK_IMG!\sources\boot.wim"
Rem Dism /Get-WimInfo /WimFile:"!WRK_IMG!\sources\install.wim"

Rem ===========================================================================
:TRANSFER
    Echo.
    If Exist "!WRK_DIR!\autounattend.xml" (
        Copy "!WRK_DIR!\autounattend.xml" "!WRK_IMG!\\"
    )

Rem ===========================================================================
    !WRK_BIN!\Oscdimg\!PROCESSOR_ARCHITECTURE!\Oscdimg -m -o -u1 -h -l!DVD_VOL! -bootdata:2#p0,e,b"!WRK_IMG!\boot\etfsboot.com"#pEF,e,b"!WRK_IMG!\efi\microsoft\boot\efisys.bin" "!WRK_IMG!" "!WRK_DIR!\Win11_Japanese_x64_custom.iso"

Rem CD /D "!DRV_DVD!\boot"
Rem BootSect /NT60 !DRV_USB:~0,2! || GoTo DONE

Rem --- ��ƃt�@�C���̍폜 ----------------------------------------------------
    If Exist "!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!" (RmDir /S /Q "!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!" || GoTo DONE)

Rem *** ��ƏI�� **************************************************************
:DONE
    EndLocal
    Echo *** ��ƏI�� ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]���������ĉ������B
    Pause > Nul 2>&1
    Echo On
