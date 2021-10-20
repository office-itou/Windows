Rem ***************************************************************************
@Echo Off
    Cls

Rem *** 作業開始 **************************************************************
:START
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableExtensions
    SetLocal EnableDelayedExpansion

Rem --- 作業環境確認 ----------------------------------------------------------
    If /I "%USERNAME%" NEQ "Administrator" (
        If /I "%SESSIONNAME%" NEQ "" (
            Echo 管理者特権で実行して下さい。
            GoTo DONE
        )
    )

Rem --- 環境変数設定 ----------------------------------------------------------
    For /F "usebackq delims=" %%I In (`Echo %0`) Do (
        Set WRK_DIR=%%~dpI
        Set WRK_DIR=!WRK_DIR:~0,-1!
        Set WRK_FIL=%%~nxI
        Set WRK_NAM=%%~nI
    )

    Set NOW_DAY=%date:~0,4%%date:~5,2%%date:~8,2%

    If /I "%time:~0,1%" EQU " " (
        Set NOW_TIM=0%time:~1,1%%time:~3,2%%time:~6,2%
    ) Else (
        Set NOW_TIM=%time:~0,2%%time:~3,2%%time:~6,2%
    )

    For /F "tokens=1-2 usebackq delims=\" %%I In ('!WRK_DIR!') Do (Set WRK_TOP=%%~I\%%~J)

    Set DVD_SRC=F:\
    Set WIM_TOP=!WRK_TOP!
    Set WIM_BIN=!WIM_TOP!\bin
    Set WIM_IMG=!WIM_TOP!\img
    Set WIM_MNT=!WIM_TOP!\mnt

    If /I "!DRV_DVD:~3!" NEQ "" (
        Set DVD_VOL=
    ) Else (
        For /F "Usebackq Tokens=5 Delims= " %%I In (`Vol "!DRV_DVD:~0,2!" ^| FindStr  /C:"ボリューム ラベル"`) Do (Set DVD_VOL=%%~I)
    )

    Set Path=!WIM_BIN!;!WIM_BIN!\Oscdimg\%PROCESSOR_ARCHITECTURE%;%Path%

Rem ===========================================================================
    If Not Exist "!WIM_IMG!"  (MkDir "!WIM_IMG!")
    If Not Exist "!WIM_MNT!"  (MkDir "!WIM_MNT!")
    Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS /NFL "!DVD_SRC!\" "!WIM_IMG!"
Rem ===========================================================================
Rem Dism /Get-WimInfo /WimFile:"!WIM_IMG!\sources\boot.wim"
Rem Dism /Get-WimInfo /WimFile:"!WIM_IMG!\sources\install.wim"
Rem === Microsoft Windows PE ==================================================
Rem Dism /Quiet /Mount-WIM /WimFile:"!WIM_IMG!\sources\boot.wim" /Index:1 /MountDir:"!WIM_MNT!"
Rem REG LOAD HKEY_LOCAL_MACHINE\MNT_SYSTEM "!WIM_MNT!\Windows\System32\config\SYSTEM"
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\MoSetup /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f
Rem REG QUERY HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\MoSetup
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f
Rem REG QUERY HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig
Rem REG UNLOAD HKEY_LOCAL_MACHINE\MNT_SYSTEM
Rem Dism /Quiet /Unmount-Image /MountDir:"!WIM_MNT!" /Commit
Rem === Microsoft Windows Setup ===============================================
    Dism /Quiet /Mount-WIM /WimFile:"!WIM_IMG!\sources\boot.wim" /Index:2 /MountDir:"!WIM_MNT!"
    REG LOAD HKEY_LOCAL_MACHINE\MNT_SYSTEM "!WIM_MNT!\Windows\System32\config\SYSTEM"
Rem REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\MoSetup /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f
Rem REG QUERY HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\MoSetup
    REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f
    REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f
    REG ADD HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f
Rem REG QUERY HKEY_LOCAL_MACHINE\MNT_SYSTEM\Setup\LabConfig
    REG UNLOAD HKEY_LOCAL_MACHINE\MNT_SYSTEM
    Dism /Quiet /Unmount-Image /MountDir:"!WIM_MNT!" /Commit
Rem ===========================================================================
Rem Dism /Get-WimInfo /WimFile:"!WIM_IMG!\sources\boot.wim"
Rem Dism /Get-WimInfo /WimFile:"!WIM_IMG!\sources\install.wim"
Rem ===========================================================================
    Oscdimg -m -o -u1 -h -l!DVD_VOL! -bootdata:2#p0,e,b"!WIM_IMG!\boot\etfsboot.com"#pEF,e,b"!WIM_IMG!\efi\microsoft\boot\efisys.bin" "!WIM_IMG!" "D:\Win11\Win11_Japanese_x64_custom.iso"
Rem ===========================================================================

Rem *** 作業終了 **************************************************************
:DONE
    Set FLG_BAT=0
:EXIT
    CD "!CUR_DIR!"
Rem EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    If !FLG_BAT! EQU 0 (Pause > Nul 2>&1)
    If !FLG_BAT! NEQ 0 (Exit)
    Echo On
