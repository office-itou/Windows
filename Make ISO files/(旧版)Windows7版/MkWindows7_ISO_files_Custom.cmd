Rem ***************************************************************************
    @Echo Off
    Cls

Rem *** 作業開始 **************************************************************
:START
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

    If /I "%USERNAME%" NEQ "Administrator" (
        If /I "%SESSIONNAME%" NEQ "" (
            Echo 管理者特権で実行して下さい。
            GoTo :DONE
        )
    )

    If /I "%1" EQU ""  (
        GoTo :INPUT_CPU_TYPE
    )

    If /I "%1" EQU "COMMIT"  (
        Echo *** 作業を有効にしてアンマウントする ******************************************
        Dism /UnMount-Wim /MountDir:"%2" /Commit && GoTo :DONE
    )

    If /I "%1" EQU "DISCARD" (
        Echo *** 作業を中止にしてアンマウントする ******************************************
        Dism /UnMount-Wim /MountDir:"%2" /Discard && GoTo :DONE
    )

:ERROR_MSG
    Echo *** WIM ファイルのマウントを解除する ******************************************
    Echo   MkWindows7_ISO_files_Custom.cmd {Commit ^| Discard} ^<マウントディレクトリ^>
    Echo     変更を保存するには Commit  を指定
    Echo     変更を破棄するには Discard を指定

    GoTo :DONE

Rem --- Windowsのアーキテクチャー設定 -----------------------------------------
:INPUT_CPU_TYPE
    Echo --- Windowsのアーキテクチャー設定 ---------------------------------------------
    Echo 1: 32bit版
    Echo 2: 64bit版
    Set /P IDX_CPU=Windowsのアーキテクチャーを1～2の数字から選んで下さい。

    If /I "%IDX_CPU%" EQU "1" (Set CPU_TYP=x86&Set CPU_BIT=32)
    If /I "%IDX_CPU%" EQU "2" (Set CPU_TYP=x64&Set CPU_BIT=64)
    If /I "%CPU_TYP%" EQU "" (GoTo :INPUT_CPU_TYPE)

Rem --- 環境変数設定 ----------------------------------------------------------
    For /F "usebackq delims=" %%I In (`Echo %0`) Do Set DIR_WRK=%%~dpI

    CD "%DIR_WRK%\.."
    Set WIM_DIR=%CD%
    CD "%DIR_WRK%"

    Set WIM_TYP=w7
Rem Set WIM_DIR=C:\WimWK
    Set WIM_TOP=%WIM_DIR%\%WIM_TYP%
    Set WIM_TMP=%WIM_DIR%.$$$\%WIM_TYP%
    Set WIM_BIN=%WIM_DIR%\bin
    Set WIM_SRC=%WIM_TOP%\src\%CPU_TYP%
    Set WIM_PKG=%WIM_TOP%\pkg\%CPU_TYP%
    Set WIM_DRV=%WIM_TOP%\pkg\drv
    Set WIM_EFI=%WIM_TOP%\pkg\efi
    Set WIM_XML=%WIM_TOP%\pkg\xml
    Set WIM_IMG=%WIM_TMP%\img\%CPU_TYP%
    Set WIM_MNT=%WIM_TMP%\mnt\%CPU_TYP%
    Set WIM_EMP=%WIM_TMP%\emp\%CPU_TYP%
    Set WIM_ESD=C:\$WINDOWS.~BT

Rem --- Oscdimgのパスを設定する -----------------------------------------------
    Set Path=%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%;%Path%
    Oscdimg > NUL 2>&1
    If "%ErrorLevel%" EQU "9009" (
        Echo Windows ADK をインストールして下さい。
        GoTo :DONE
    )

Rem --- Windowsのエディション設定 ---------------------------------------------
    Echo --- Windowsのエディション設定 -------------------------------------------------
    Echo 1: Windows 7 Starter (32bit版のみ)
    Echo 2: Windows 7 HomeBasic
    Echo 3: Windows 7 HomePremium
    Echo 4: Windows 7 Professional
    Echo 5: Windows 7 Ultimate
    Set /P IDX_WIN=Windowsのエディションを1～5の数字から選んで下さい。

    If /I "%IDX_WIN%" EQU "1" (Set WIN_TYP=Windows 7 Starter)
    If /I "%IDX_WIN%" EQU "2" (Set WIN_TYP=Windows 7 HomeBasic)
    If /I "%IDX_WIN%" EQU "3" (Set WIN_TYP=Windows 7 HomePremium)
    If /I "%IDX_WIN%" EQU "4" (Set WIN_TYP=Windows 7 Professional)
    If /I "%IDX_WIN%" EQU "5" (Set WIN_TYP=Windows 7 Ultimate)

Rem --- DVDのドライブ名設定 ---------------------------------------------------
    Echo --- DVDのドライブ名設定 -------------------------------------------------------
    Set /P DRV_DVD=DVDのドライブ名を入力して下さい。 [A-Z]
    If /I "%DRV_DVD:~1,1%" NEQ ":" (Set DRV_DVD=%DRV_DVD:~0,1%:)

Rem --- 環境変数設定 ----------------------------------------------------------
    Set DVD_SRC=%DRV_DVD%\\
    Set DVD_DST=%WIM_TOP%\windows_7_with_sp1_%CPU_TYP%_dvd_custom_VER_.iso
    Set DRV_CHP=%WIM_DRV%\CHP\
    Set DRV_VGA=%WIM_DRV%\VGA\
    Set DRV_SND=%WIM_DRV%\SND\
    Set DRV_LAN=%WIM_DRV%\LAN\
    Set DRV_RST=%WIM_DRV%\RST\
    Set DRV_MEI=%WIM_DRV%\MEI\
    Set DRV_USB=%WIM_DRV%\USB\Intel(R)_USB_3.0_eXtensible_Host_Controller_Driver_5.0.4.43_v2\Intel(R)_USB_3.0_eXtensible_Host_Controller_Driver_5.0.4.43_v2\Drivers\Win7\%CPU_TYP%

Rem *** 作業フォルダーの作成 **************************************************
    Echo *** 作業フォルダーの作成 ******************************************************
    If Exist "%WIM_MNT%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Discard)
    If Exist "%WIM_TMP%" (RmDir /S /Q "%WIM_TMP%" || GoTo :DONE)

    If Not Exist "%WIM_BIN%" (MkDir "%WIM_BIN%")
Rem If Not Exist "%WIM_SRC%" (MkDir "%WIM_SRC%")
    If Not Exist "%WIM_PKG%" (MkDir "%WIM_PKG%")
    If Not Exist "%WIM_DRV%" (MkDir "%WIM_DRV%")
    If Not Exist "%WIM_EFI%" (MkDir "%WIM_EFI%")
    If Not Exist "%WIM_IMG%" (MkDir "%WIM_IMG%")
    If Not Exist "%WIM_MNT%" (MkDir "%WIM_MNT%")
Rem If Not Exist "%WIM_EMP%" (MkDir "%WIM_EMP%")

Rem *** ファイル・ダウンロード ************************************************
    CScript "%WIM_BIN%\download.vbs" "/timezone:utc" /function:fncDownload /winsppm:"C:\winsppm" /list:"%WIM_DIR%\lst\Windows7aik_Rollup_202001.lst" /update:"%WIM_TOP%\pkg\upd"
    CScript "%WIM_BIN%\download.vbs" "/timezone:utc" /function:fncDownload /winsppm:"C:\winsppm" /list:"%WIM_DIR%\lst\Windows7drv_Rollup_202001.lst" /update:"%WIM_TOP%\pkg\drv\USB"
    CScript "%WIM_BIN%\download.vbs" "/timezone:utc" /function:fncDownload /winsppm:"C:\winsppm" /list:"%WIM_DIR%\lst\Windows7x%CPU_BIT%_Rollup_202001.lst" /update:"%WIM_TOP%\pkg\%CPU_TYP%"

Rem --- USBドライバー ---------------------------------------------------------
    If Not Exist "%DRV_USB%" (
        Echo "USBドライバーを展開して下さい。"
        Echo [Enter]を押下して下さい。
        Pause > Nul 2>&1
    )

Rem --- Windows Management Framework 5.1 --------------------------------------
    If /I "%CPU_TYP%" EQU "x64" (
        If Not Exist "%WIM_PKG%\Win7AndW2K8R2-KB3191566-x64\Win7AndW2K8R2-KB3191566-x64.msu" (
            Echo "Win7AndW2K8R2-KB3191566-x64.zipを展開して下さい。"
            Echo [Enter]を押下して下さい。
            Pause > Nul 2>&1
        )
    ) Else (
        If Not Exist "%WIM_PKG%\Win7-KB3191566-x86\Win7-KB3191566-x86.msu" (
            Echo "Win7-KB3191566-x86.zipを展開して下さい。"
            Echo [Enter]を押下して下さい。
            Pause > Nul 2>&1
        )
    )

Rem *** 統合パッケージの準備 **************************************************
    If Not Exist "%WIM_PKG%\windows6.1-kb3125574-v4-%CPU_TYP%.msu" (
        Echo 統合するパッケージを"%WIM_PKG%"にコピーして下さい。
        GoTo :DONE
    )

Rem === Internet Explorer 11 ==================================================
    Echo === Internet Explorer 11 ======================================================
    If Not Exist "%WIM_PKG%\ie11\IE-Win7.CAB" (
Rem     "%WIM_PKG%\ie11_ja-jp_wol_win7-%CPU_TYP%.exe" /c /t:"%WIM_PKG%\ie11.tmp" || GoTo :DONE
Rem     "%WIM_PKG%\ie11.tmp\IE-REDIST.EXE" /x:"%WIM_PKG%\ie11"                   || GoTo :DONE
        "%WIM_PKG%\IE11-Windows6.1-%CPU_TYP%-ja-jp.exe" /x:"%WIM_PKG%\ie11"
    )

Rem === NDP 4.7.2 =============================================================
Rem Echo === NDP 4.7.2 =================================================================
Rem If Not Exist "%WIM_PKG%\kb4054541\Setup.exe" (
Rem     If Not Exist "%WIM_PKG%\ndp472\kb4054541" (MkDir "%WIM_PKG%\ndp472\kb4054541")
Rem     If Not Exist "%WIM_PKG%\ndp472\kb4054530" (MkDir "%WIM_PKG%\ndp472\kb4054530")
Rem     If Not Exist "%WIM_PKG%\ndp472\kb4087364" (MkDir "%WIM_PKG%\ndp472\kb4087364")
Rem     "%WIM_PKG%\ndp472-kb4054541-x86-x64-enu.exe"       /extract:"%WIM_PKG%\ndp472\kb4054541" /q
Rem     "%WIM_PKG%\ndp472-kb4054530-x86-x64-allos-jpn.exe" /extract:"%WIM_PKG%\ndp472\kb4054530" /q
Rem     "%WIM_PKG%\ndp472-kb4087364-x64.exe"               /extract:"%WIM_PKG%\ndp472\kb4087364" /q
Rem )

Rem *** 原本から作業フォルダーにコピーする ************************************
    Echo *** 原本から作業フォルダーにコピーする ****************************************
    If Not Exist "%DRV_DVD%\sources\install.wim" (
        Echo 統合する%CPU_TYP%版のDVDを"%DRV_DVD%"にセットして下さい。
        GoTo :DONE
    )

    If Exist "%DRV_DVD%\efi\microsoft\boot\efisys.bin" (
        If /I "%CPU_TYP%" NEQ "x64" (
            Echo DVDがx64[64bit]版です。
            Echo 統合する%CPU_TYP%版のDVDを"%DRV_DVD%"にセットして下さい。
            GoTo :DONE
        )
    ) Else (
        If /I "%CPU_TYP%" NEQ "x86" (
            Echo DVDがx86[32bit]版です。
            Echo 統合する%CPU_TYP%版のDVDを"%DRV_DVD%"にセットして下さい。
            GoTo :DONE
        )
    )

Rem --- install.wimの上書き確認 -----------------------------------------------
    Set WIM_FLG=Y
    If Exist "%WIM_IMG%\sources\install.wim" (
        Echo --- install.wimの上書き確認 ---------------------------------------------------
        Set /P WIM_FLG=install.wimをDVDのファイルで上書きしますか？ [Y/N] ^(Yes/No^)
    )

    If /I "%WIM_FLG%" EQU "Y" (Set CPY_PRM=) Else (Set CPY_PRM=/XF Install.wim)
    Robocopy /MIR /A-:RHS /NDL /NFL "%DVD_SRC%" "%WIM_IMG%" %CPY_PRM%

Rem === UEFIブート準備 ========================================================
    If /I "%CPU_TYP%" EQU "x64" (
        If Not Exist "%WIM_EFI%\bootx64.efi" (
            If Exist "%WinPERoot%\amd64\Media\EFI\Boot\bootx64.efi" (
                Robocopy /A-:RHS /NDL /NFL "%WinPERoot%\amd64\Media\EFI\Boot" "%WIM_EFI%" "bootx64.efi"
                GoTo :COPY_EFI
            )
            If Exist "%ProgramFiles%\Windows AIK\Tools\PETools\amd64\efi\boot\bootx64.efi" (
                Robocopy /A-:RHS /NDL /NFL "%ProgramFiles%\Windows AIK\Tools\PETools\amd64\efi\boot" "%WIM_EFI%" "bootx64.efi"
                GoTo :COPY_EFI
            )
            Echo bootx64.efiファイルが見当たりません。
            GoTo :DONE
        )
:COPY_EFI
        Robocopy /A-:RHS /NDL /NFL "%WIM_EFI%" "%WIM_IMG%\EFI\boot" "bootx64.efi"
    )

    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"%WIM_IMG%\Sources\Install.wim" /Name:"%WIN_TYP%" ^| FindStr /C:"バージョン :"`) Do Set WIM_VER=%%I
    Set DVD_DST=%DVD_DST:_VER_=_!WIM_VER!%

:UNATTEND
Rem === Unattend ==============================================================
    If Exist "%WIM_XML%\autounattend.xml" (
        Echo *** autounattend.xml のコピー *************************************************
        Robocopy /A-:RHS /NDL /NFL "%WIM_XML%" "%WIM_IMG%" "autounattend.xml"
    )
Rem ---------------------------------------------------------------------------
    Echo *** options.cmd の作成 *********************************************************
    Set OPT_DIR=autounattend\options
    Set OPT_PKG=%OPT_DIR%\wupd
    Set OPT_CMD=%WIM_IMG%\%OPT_DIR%\options.cmd
    mkdir "%WIM_IMG%\%OPT_DIR%"
Rem ---------------------------------------------------------------------------
    Echo> "%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" Rem %DATE% %TIME% maked
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" Echo ^%%DATE^%% ^%%TIME^%% Start
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"      ^"^%%configsetroot^%%\%OPT_PKG%\silverlight.exe^" /q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"      ^"^%%configsetroot^%%\%OPT_PKG%\ndp48-x86-%CPU_TYP%-enu.exe^"        /q /norestart
    Echo>>"%OPT_CMD%"      ^"^%%configsetroot^%%\%OPT_PKG%\ndp48-kb4503575-%CPU_TYP%.exe^"      /q /norestart
    Echo>>"%OPT_CMD%"      ^"^%%configsetroot^%%\%OPT_PKG%\ndp48-x86-%CPU_TYP%-allos-jpn.exe^"  /q /norestart
    Echo>>"%OPT_CMD%"      ^"^%%configsetroot^%%\%OPT_PKG%\ndp48-kb4515847-%CPU_TYP%.exe^"      /q /norestart
    If /I "%CPU_TYP%" EQU "x64" (
        Echo>>"%OPT_CMD%" Wusa ^"^%%configsetroot^%%\%OPT_PKG%\Win7AndW2K8R2-KB3191566-x64.msu^" /quiet /norestart
    ) Else (
        Echo>>"%OPT_CMD%" Wusa ^"^%%configsetroot^%%\%OPT_PKG%\Win7-KB3191566-x86.msu^"             /quiet /norestart
    )
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" Wusa ^"^%%configsetroot^%%\%OPT_PKG%\windows6.1-kb2533552-%CPU_TYP%.msu^" /quiet /norestart
    Echo>>"%OPT_CMD%" Wusa ^"^%%configsetroot^%%\%OPT_PKG%\windows6.1-kb2984976-%CPU_TYP%.msu^" /quiet /norestart
    Echo>>"%OPT_CMD%" Wusa ^"^%%configsetroot^%%\%OPT_PKG%\windows6.1-kb4534310-%CPU_TYP%.msu^" /quiet /norestart
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"      ^"^%%configsetroot^%%\%OPT_PKG%\windows-kb890830-%CPU_TYP%-v5.79.exe^" /Q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"      ^"^%%configsetroot^%%\%OPT_PKG%\mpas-fe-%CPU_TYP%.exe^" -q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"      ^"^%%configsetroot^%%\%OPT_PKG%\MSEInstall-%CPU_TYP%.exe^" /s /runwgacheck /o
    Echo>>"%OPT_CMD%"      ^"^%%configsetroot^%%\%OPT_PKG%\mpam-fe-%CPU_TYP%.exe^" -q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" Rem Cmd /C RmDel /S /Q ^"^%%configsetroot^%%^"
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" shutdown /r
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" Echo ^%%DATE^%% ^%%TIME^%% End
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
Rem ---------------------------------------------------------------------------
    Robocopy /A-:RHS /NDL "%WIM_PKG%" "%WIM_IMG%\%OPT_PKG%" ^
        "windows-kb890830-%CPU_TYP%-v5.79.exe"              ^
        "mpas-fe-%CPU_TYP%.exe"                             ^
        "MSEInstall-%CPU_TYP%.exe"                          ^
        "mpam-fe-%CPU_TYP%.exe"                             ^
        "silverlight.exe"                                   ^
        "ndp48-x86-%CPU_TYP%-enu.exe"                       ^
        "ndp48-kb4503575-%CPU_TYP%.exe"                     ^
        "ndp48-x86-%CPU_TYP%-allos-jpn.exe"                 ^
        "ndp48-kb4515847-%CPU_TYP%.exe"                     ^
        "windows6.1-kb2533552-%CPU_TYP%.msu"                ^
        "windows6.1-kb4534310-%CPU_TYP%.msu"                
    If /I "%CPU_TYP%" EQU "x64" (
        Robocopy /A-:RHS /NDL "%WIM_PKG%\Win7AndW2K8R2-KB3191566-x64" "%WIM_IMG%\%OPT_PKG%" "Win7AndW2K8R2-KB3191566-x64.msu"
    ) Else (
        Robocopy /A-:RHS /NDL "%WIM_PKG%\Win7-KB3191566-x86"          "%WIM_IMG%\%OPT_PKG%" "Win7-KB3191566-x86.msu"
    )
Rem ===========================================================================

:UPDATE
Rem === Windows Update ファイルの統合 =========================================
    Set ADD_PAC=/Image:^"%WIM_MNT%^" /Add-Package /IgnoreCheck
    Set ADD_DRV=/Image:^"%WIM_MNT%^" /Add-Driver /ForceUnsigned /Recurse

Rem *** install.wimを更新する *************************************************
    Echo *** install.wimを更新する *****************************************************
    Dism /Mount-WIM /WimFile:"%WIM_IMG%\sources\install.wim" /Name:"%WIN_TYP%" /MountDir:"%WIM_MNT%" || GoTo :DONE
Rem ===========================================================================
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb947821-v34-%CPU_TYP%.msu"           || GoTo :DONE
Rem === Internet Explorer 11 ==================================================
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2670838-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2834140-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2729094-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\ie11\IE-Win7.CAB"                                || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\ie11\ielangpack-ja-JP.CAB"                       || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\ie11\IE-Spelling-en.MSU"                         || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\ie11\IE-Hyphenation-en.MSU"                      || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\ie11-windows6.1-kb3185319-%CPU_TYP%.msu"         || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\ie11-windows6.1-kb4534251-%CPU_TYP%.msu"         || GoTo :DONE
Rem === Convenience rollup update =============================================
Rem Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2533552-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb4474419-v3-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb4490628-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb4536952-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3020369-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3125574-v4-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3172605-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3179573-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb4534310-%CPU_TYP%.msu"              || GoTo :DONE
Rem === Security and Update ===================================================
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3021917-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3068708-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3080149-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3138612-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3150513-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3184143-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2984972-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2574819-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2592687-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3020387-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2830477-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3020388-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3075226-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2923545-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2900986-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2667402-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2698365-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2862330-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3004375-v3-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3046269-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3059317-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3156016-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3159398-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3161949-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3031432-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3042058-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3155178-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2545698-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2547666-%CPU_TYP%.msu"              || GoTo :DONE
    If /I "%CPU_TYP%" EQU "x64" (
        Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2603229-%CPU_TYP%.msu"          || GoTo :DONE
    )
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2732059-v5-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2750841-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2761217-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2773072-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2919469-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2970228-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3006137-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3102429-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3161102-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb4019990-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2818604-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb3170735-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2685811-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2685813-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb4040980-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb4507004-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2894844-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb2898851-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_PKG%\windows6.1-kb4532945-%CPU_TYP%.msu"              || GoTo :DONE
Rem ===========================================================================

:DRIVERS
Rem === 各種ドライバー ========================================================
    Dism %ADD_DRV% /Driver:"%DRV_USB%"                                                      || GoTo :DONE

Rem === install.wimを更新してアンマウントする =================================
    Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Commit                                         || GoTo :DONE

Rem *** boot.wimを更新する ****************************************************
    Echo *** boot.wimを更新する [1] ****************************************************
    Dism /Mount-WIM /WimFile:"%WIM_IMG%\sources\boot.wim" /Index:1 /MountDir:"%WIM_MNT%"    || GoTo :DONE
    Dism %ADD_DRV% /Driver:"%DRV_USB%"                                                      || GoTo :DONE
    Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Commit                                         || GoTo :DONE

    Echo *** boot.wimを更新する [2] ****************************************************
    Dism /Mount-WIM /WimFile:"%WIM_IMG%\sources\boot.wim" /Index:2 /MountDir:"%WIM_MNT%"    || GoTo :DONE
    Dism %ADD_DRV% /Driver:"%DRV_USB%"                                                      || GoTo :DONE
    Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Commit                                         || GoTo :DONE

:MAKE
Rem *** DVDイメージを作成する *************************************************
    Echo *** DVDイメージを作成する *****************************************************
    If /I "%CPU_TYP%" EQU "x64" (
        Set MAK_IMG=-m -o -u1 -h -bootdata:2#p0,e,b"%WIM_IMG%\boot\etfsboot.com"#pEF,e,b"%WIM_IMG%\efi\microsoft\boot\efisys.bin"
    ) Else (
        Set MAK_IMG=-m -o -u1 -h -bootdata:1#p0,e,b"%WIM_IMG%\boot\etfsboot.com"
    )
    Oscdimg %MAK_IMG% "%WIM_IMG%" "%DVD_DST%" || GoTo :DONE

Rem --- 作業フォルダーの削除 --------------------------------------------------
Rem Echo --- 作業フォルダーの削除 ------------------------------------------------------
    If Exist "%WIM_TMP%" (RmDir /S /Q "%WIM_TMP%" || GoTo :DONE)

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
