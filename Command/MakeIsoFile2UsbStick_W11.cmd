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
Rem *** 作業環境設定 **********************************************************
Rem --- DVDとUSBのドライブ名設定 ----------------------------------------------
:CHK_DVD_DRIVE
    Echo --- DVDのドライブ名設定 -------------------------------------------------------
    Set DRV_DVD=
    Set /P DRV_DVD=DVDのドライブ名[A-Z] 又はイメージフォルダー名を入力して下さい。
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

:CHK_USB_DRIVE
    Echo --- USBのドライブ名設定 -------------------------------------------------------
    Set DRV_USB=
    Set /P DRV_USB=USBのドライブ名[A-Z]を入力して下さい。
    If /I "!DRV_USB!" EQU "" (GoTo CHK_USB_DRIVE)

    If /I "!DRV_USB:~1,1!" EQU "" (
        Set DRV_USB=!DRV_USB!:\)
    )

    For %%I in (!DRV_USB!\) Do (
        Set USB_DST=%%~dpI
        If /I "!USB_DST:~-1!" EQU "\" (
            Set USB_DST=!USB_DST:~0,-1!
        )
    )

:SET_USB_FORMAT
    Echo --- USBのフォーマット設定 -----------------------------------------------------
    Echo 1: FAT32
    Echo 2: NTFS
    Echo 3: exFAT
    Set IDX_USB=1
    Set /P IDX_USB=USBのフォーマット[1-3]を入力して下さい。（規定値[!IDX_USB!]）

           If /I "!IDX_USB!" EQU "1" (Set FMT_USB=FAT32
    ) Else If /I "!IDX_USB!" EQU "2" (Set FMT_USB=NTFS
    ) Else If /I "!IDX_USB!" EQU "3" (Set FMT_USB=exFAT
    ) Else                           (GoTo SET_USB_FORMAT
    )

:SET_DVD_DRIVE
    If Not Exist "!DRV_DVD!\sources\install.wim" If Not Exist "!DRV_DVD!\sources\install.swm" (
        Echo 転送するDVDを"!DRV_DVD!"にセットして下さい。
        Echo 準備ができたら[Enter]を押下して下さい。
        Pause > Nul 2>&1
        GoTo SET_DVD_DRIVE
    )

Rem --- 環境変数設定 ----------------------------------------------------------
    Set CMD_WK1=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!.DiskPart1.txt
    Set CMD_WK2=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!.DiskPart2.txt
    Set CMD_EXC=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!.Exclude.txt
    Set WRK_IMG=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!\img
    Set WRK_MNT=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!\mnt

Rem --- 作業フォルダーの作成 --------------------------------------------------
    If Not Exist "!WRK_IMG!"  (MkDir "!WRK_IMG!")
    If Not Exist "!WRK_MNT!"  (MkDir "!WRK_MNT!")

:MAKE
Rem *** USBメモリーを作成する *************************************************
    If !FLG_FMT! EQU 0 (
        Echo> "!CMD_WK1!" Rem DiskPart1
        Echo>>"!CMD_WK1!" List Vol
        Echo>>"!CMD_WK1!" List Disk
        Echo>>"!CMD_WK1!" Exit

        DiskPart /S "!CMD_WK1!" || GoTo DONE

        Set /P IDX_DRV=USBメモリーのディスク・インデックス番号を入力して下さい。

        Echo> "!CMD_WK2!" Rem DiskPart2
        Echo>>"!CMD_WK2!" Select Disk !IDX_DRV!
        Echo>>"!CMD_WK2!" Clean
        Echo>>"!CMD_WK2!" Convert MBR
        Echo>>"!CMD_WK2!" Create Partition Primary
        Echo>>"!CMD_WK2!" Select Partition 1
        Echo>>"!CMD_WK2!" Format FS=!FMT_USB! Quick
        Echo>>"!CMD_WK2!" Active
        Echo>>"!CMD_WK2!" Assign Letter=!DRV_USB:~0,1!
        Echo>>"!CMD_WK2!" Exit

        Echo -------------------------------------------------------------------------------
        Type "!CMD_WK2!"
        Echo -------------------------------------------------------------------------------
        Echo 以上のパラメーターでUSBメモリーを作成します。
        Set /P INP_ANS=実行してよろしいでしょうか？ [Y/N/E] ^(Yes/No/Exit^)
        If /I "!INP_ANS!" EQU "E" (GoTo DONE)
        If /I "!INP_ANS!" NEQ "Y" (GoTo MAKE)

        DiskPart /S "!CMD_WK2!" || GoTo DONE
    )

Rem ===========================================================================
:EDIT
    Echo.
    Echo --- ファイル転送 [DVD → HDD] -------------------------------------------------
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
    If /I "!FMT_USB!" EQU "NTFS" (
        Echo --- ファイル転送 [HDD → USB] NTFS --------------------------------------------
        If Exist "!WRK_IMG!\sources\install.swm" (Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!WRK_IMG!" "!USB_DST!" /XD "System Volume Information" "$Recycle.Bin" /XF install.wim
        ) Else                                   (Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!WRK_IMG!" "!USB_DST!" /XD "System Volume Information" "$Recycle.Bin"
        )
    ) Else If /I "!FMT_USB!" EQU "exFAT" (
        Echo --- ファイル転送 [HDD → USB] exFAT -------------------------------------------
        Echo>>"!CMD_EXC!" System Volume Information
        Echo>>"!CMD_EXC!" $Recycle.Bin
        If Exist "!WRK_IMG!\sources\install.swm" (Echo>>"!CMD_EXC!" install.wim)
        Xcopy /J /E /H /R /Y "!WRK_IMG!\*.*" "!USB_DST!\\" /EXCLUDE:!CMD_EXC!
    ) Else (
        For %%I In ("!WRK_IMG!\sources\install.wim") Do (Set WIM_SIZ=%%~zI)
        Set WIM_SIZ=!WIM_SIZ:~0,-6!
        Set /A WIM_SIZ=!WIM_SIZ!+1
        If !WIM_SIZ! LSS 4095 (
            Echo --- ファイル転送 [HDD → USB] FAT32 -------------------------------------------
            Echo>>"!CMD_EXC!" System Volume Information
            Echo>>"!CMD_EXC!" $Recycle.Bin
            Xcopy /J /E /H /R /Y "!WRK_IMG!\*.*" "!USB_DST!\\" /EXCLUDE:!CMD_EXC!
        ) Else (
            Echo --- ファイル転送 [HDD → USB] FAT32 -------------------------------------------
            Echo --- ファイル分割 --------------------------------------------------------------
            Dism /Split-Image /ImageFile:"!WRK_IMG!\sources\install.wim" /SWMFile:"!WRK_IMG!\sources\install.swm" /FileSize:4095 || GoTo DONE
            Echo>>"!CMD_EXC!" System Volume Information
            Echo>>"!CMD_EXC!" $Recycle.Bin
            Echo>>"!CMD_EXC!" install.wim
            Xcopy /J /E /H /R /Y "!WRK_IMG!\*.*" "!USB_DST!\\" /EXCLUDE:!CMD_EXC!
        )
    )

    If Exist "!WRK_DIR!\autounattend.xml" (
        Copy "!WRK_DIR!\autounattend.xml" "!USB_DST!\\"
    )

Rem ===========================================================================
Rem !WRK_BIN!\Oscdimg\!PROCESSOR_ARCHITECTURE!\Oscdimg -m -o -u1 -h -l!DVD_VOL! -bootdata:2#p0,e,b"!WRK_IMG!\boot\etfsboot.com"#pEF,e,b"!WRK_IMG!\efi\microsoft\boot\efisys.bin" "!WRK_IMG!" "!WRK_DIR!\Win11_Japanese_x64_custom.iso"

Rem CD /D "!DRV_DVD!\boot"
    BootSect /NT60 !DRV_USB:~0,2! || GoTo DONE

Rem --- 作業ファイルの削除 ----------------------------------------------------
    If Exist "!CMD_WK1!" (Del /F "!CMD_WK1!" || GoTo DONE)
    If Exist "!CMD_WK2!" (Del /F "!CMD_WK2!" || GoTo DONE)
    If Exist "!CMD_EXC!" (Del /F "!CMD_EXC!" || GoTo DONE)
    If Exist "!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!" (RmDir /S /Q "!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!" || GoTo DONE)

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
