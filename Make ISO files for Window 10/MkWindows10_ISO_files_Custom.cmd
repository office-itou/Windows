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
    Echo   MkWindows10_ISO_files_Custom.cmd {Commit ^| Discard} ^<マウントディレクトリ^>
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

    Set WIM_TYP=w10
Rem Set WIM_DIR=C:\WimWK
    Set WIM_TOP=%WIM_DIR%\%WIM_TYP%
    Set WIM_BIN=%WIM_DIR%\bin
    Set WIM_CFG=%WIM_DIR%\cfg
    Set WIM_LST=%WIM_DIR%\lst
    Set WIM_PKG=%WIM_TOP%\pkg
    Set WIM_ADK=%WIM_PKG%\adk
    Set WIM_DRV=%WIM_PKG%\drv
    Set WIM_EFI=%WIM_PKG%\efi
    Set WIM_WUD=%WIM_PKG%\%CPU_TYP%
    Set WIM_X64=%WIM_PKG%\x64
    Set WIM_X86=%WIM_PKG%\x86
    Set WIM_BAK=%WIM_PKG%\bak\%CPU_TYP%
    Set WIM_TMP=%WIM_DIR%.$$$\%WIM_TYP%\%CPU_TYP%
    Set WIM_IMG=%WIM_TMP%\img
    Set WIM_MNT=%WIM_TMP%\mnt
    Set WIM_WRE=%WIM_TMP%\wre
    Set WIM_EMP=%WIM_TMP%\emp
    Set DIR_LST=adk drv zip x%CPU_BIT%

Rem --- Oscdimgのパスを設定する -----------------------------------------------
    If Not Exist "%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%" (
        If Not Exist "%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\%PROCESSOR_ARCHITECTURE%\Oscdimg" (
            Echo Windows ADK をインストールして下さい。
            GoTo :DONE
        )
        Robocopy /J /MIR /A-:RHS /NDL /NFL "%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\%PROCESSOR_ARCHITECTURE%\Oscdimg" "%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%"
    )
    Set Path=%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%;%Path%
    Oscdimg > NUL 2>&1
    If "%ErrorLevel%" EQU "9009" (
        Echo Windows ADK をインストールして下さい。
        GoTo :DONE
    )

Rem --- DVDのドライブ名設定 ---------------------------------------------------
    Echo --- DVDのドライブ名設定 -------------------------------------------------------
    Set /P DRV_DVD=DVDのドライブ名を入力して下さい。 [A-Z]
    If /I "%DRV_DVD:~1,1%" NEQ ":" (Set DRV_DVD=%DRV_DVD:~0,1%:)
Rem --- 環境変数設定 ----------------------------------------------------------
    Set DVD_SRC=%DRV_DVD%\\
    Set DVD_DST=%WIM_TOP%\windows_10_%CPU_TYP%_dvd_custom_VER_.iso

Rem *** 作業フォルダーの作成 **************************************************
    Echo *** 作業フォルダーの作成 ******************************************************
    If Exist "%WIM_WRE%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_WRE%" /Discard)
    If Exist "%WIM_MNT%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Discard)
    If Exist "%WIM_TMP%" (RmDir /S /Q "%WIM_TMP%" || GoTo :DONE)

    If Not Exist "%WIM_BIN%" (MkDir "%WIM_BIN%")
    If Not Exist "%WIM_CFG%" (MkDir "%WIM_CFG%")
    If Not Exist "%WIM_LST%" (MkDir "%WIM_LST%")
    If Not Exist "%WIM_ADK%" (MkDir "%WIM_ADK%")
    If Not Exist "%WIM_DRV%" (MkDir "%WIM_DRV%")
    If Not Exist "%WIM_EFI%" (MkDir "%WIM_EFI%")
    If Not Exist "%WIM_X64%" (MkDir "%WIM_X64%")
    If Not Exist "%WIM_X86%" (MkDir "%WIM_X86%")
    If Not Exist "%WIM_BAK%" (MkDir "%WIM_BAK%")
    If Not Exist "%WIM_IMG%" (MkDir "%WIM_IMG%")
    If Not Exist "%WIM_MNT%" (MkDir "%WIM_MNT%")
    If Not Exist "%WIM_WRE%" (MkDir "%WIM_WRE%")
    If Not Exist "%WIM_EMP%" (MkDir "%WIM_EMP%")

Rem *** 原本から作業フォルダーにコピーする ************************************
    Echo *** 原本から作業フォルダーにコピーする ****************************************
    If Not Exist "%DRV_DVD%\sources\install.wim" If Not Exist "%DRV_DVD%\sources\install.swm" (
        Echo 統合する%CPU_TYP%版のDVDを"%DRV_DVD%"にセットして下さい。
        GoTo :DONE
    )

    If Exist "%DRV_DVD%\efi\boot\bootx64.efi" (
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

    Robocopy /J /MIR /A-:RHS /NDL /NFL "%DVD_SRC%" "%WIM_IMG%" %CPY_PRM%

Rem === wimバージョンの取得 ===================================================
    If Exist "%WIM_IMG%\Sources\Install.wim" (
        Set WIM_WIM=%WIM_IMG%\Sources\Install.wim
    ) Else (
        Set WIM_WIM=%WIM_IMG%\Sources\Install.swm
    )
    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"%WIM_WIM%" /Index:1 ^| FindStr /C:"バージョン :"`) Do Set WIM_VER=%%I
    Set DVD_DST=%DVD_DST:_VER_=_!WIM_VER!%

Rem *** ファイル・ダウンロード ************************************************
    Echo *** ファイル・ダウンロード ****************************************************
    For %%I In (%DIR_LST%) Do (
        Set DIR_TYP=%%I
        For %%J In (%WIM_LST%\Windows10!DIR_TYP!_Rollup_*.lst) Do (
            Set LIST=%%J
            Set FILE=
            Set RENAME=
            Set SIZE=
            For /F "delims== tokens=1* usebackq" %%K In (!LIST!) Do (
                Set KEY=%%K
                Set VAL=%%L
                If /I "!KEY:~0,1!!KEY:~-1,1!" EQU "[]" (
                    Set SECTION=!KEY:~1,-1!
                    Set FILE=
                    Set RENAME=
                    Set SIZE=
                )
                If /I "!SECTION!" NEQ "" (
                    If /I "!KEY!" EQU "FILE"   (Set FILE=!VAL!)
                    If /I "!KEY!" EQU "RENAME" (Set RENAME=!VAL!)
                    If /I "!KEY!" EQU "SIZE"   (Set SIZE=!VAL!)
                )
                If /I "!SECTION!" NEQ "" If /I "!FILE!" NEQ "" If /I "!SIZE!" NEQ "" (
                    If /I "!RENAME!" NEQ "" (
                        Set FNAME=!RENAME!
                    ) Else (
                        For /F "delims=! usebackq" %%M In ('!FILE!') Do (
                            Set FNAME=%%~nxM
                        )
                    )
                    If /I "!DIR_TYP!" NEQ "drv" (
                        If /I "!DIR_TYP!" EQU "x32" (
                            Set DNAME=%WIM_PKG%\x86
                        ) Else (
                            Set DNAME=%WIM_PKG%\!DIR_TYP!
                        )
                    ) Else (
                        If /I "!FNAME!" EQU "chipset-10.1.18228.8176-public-mup.zip"     (Set DIR_DRV=!DIR_TYP!\CHP
                        ) Else If /I "!FNAME!" EQU "ME_SW_1909.12.0.1236.zip"            (Set DIR_DRV=!DIR_TYP!\IME
                        ) Else If /I "!FNAME!" EQU "PROWin32.exe"                        (Set DIR_DRV=!DIR_TYP!\NIC
                        ) Else If /I "!FNAME!" EQU "PROWinx64.exe"                       (Set DIR_DRV=!DIR_TYP!\NIC
                        ) Else If /I "!FNAME!" EQU "SetupRST.exe"                        (Set DIR_DRV=!DIR_TYP!\RST
                        ) Else If /I "!FNAME!" EQU "SetupOptaneMemory.exe"               (Set DIR_DRV=!DIR_TYP!\RST
                        ) Else If /I "!FNAME!" EQU "f6flpy-x64.zip"                      (Set DIR_DRV=!DIR_TYP!\RST
                        ) Else If /I "!FNAME!" EQU "igfx_win10_100.7755.zip"             (Set DIR_DRV=!DIR_TYP!\VGA
                        ) Else If /I "!FNAME!" EQU "WiFi_21.60.2_Driver32_Win10.zip"     (Set DIR_DRV=!DIR_TYP!\NIC
                        ) Else If /I "!FNAME!" EQU "WiFi_21.60.2_Driver64_Win10.zip"     (Set DIR_DRV=!DIR_TYP!\NIC
                        ) Else If /I "!FNAME!" EQU "Install_Win10_10038_12202019.zip"    (Set DIR_DRV=!DIR_TYP!\NIC
                        ) Else If /I "!FNAME!" EQU "0009-Win7_Win8_Win81_Win10_R282.zip" (Set DIR_DRV=!DIR_TYP!\SND
                        ) Else                                                           (Set DIR_DRV=!DIR_TYP!
                        )
                        Set DNAME=%WIM_PKG%\!DIR_DRV!
                    )
                    If Not Exist "!DNAME!" MkDir "!DNAME!"
                    Set FNAME=!DNAME!\!FNAME!
                    If Exist "!FNAME!" If !SIZE! LSS 10 Del /F "!FNAME!"
                    If Not Exist "!FNAME!" (
                        Echo "!FNAME!"
                        Curl -L -# -R -o "!FNAME!" "!FILE!"
                    )
                    Set FILE=
                    Set RENAME=
                    Set SIZE=
                )
            )
        )
    )

Rem *** 統合パッケージの準備 **************************************************

Rem === ドライバー ============================================================

:UNATTEND
Rem === Unattend ==============================================================
    If Exist "%WIM_CFG%\autounattend-windows10-%CPU_TYP%.xml" (
        Echo *** autounattend.xml のコピー *************************************************
        Copy /Y "%WIM_CFG%\autounattend-windows10-%CPU_TYP%.xml" "%WIM_IMG%\autounattend.xml"
    )
Rem ---------------------------------------------------------------------------
    Echo *** options.cmd の作成 *********************************************************
    Set OPT_DIR=autounattend\options
    Set OPT_PKG=%OPT_DIR%\wupd
    Set OPT_CMD=%WIM_IMG%\%OPT_DIR%\options.cmd
    mkdir "%WIM_IMG%\%OPT_DIR%"
Rem --- options.cmd の作成 ----------------------------------------------------
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" Rem %DATE% %TIME% maked
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Echo ^%%DATE^%% ^%%TIME^%% Start
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\windows-kb890830-%CPU_TYP%-v5.79.exe" /Q
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\mpam-fe-%CPU_TYP%.exe" -q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\updateplatform-%CPU_TYP%.exe"
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C Wusa "%%configsetroot%%\autounattend\options\wupd\windows10.0-kb4528760-%CPU_TYP%.msu" /quiet /norestart
    Echo>>"%OPT_CMD%"     Cmd /C Wusa "%%configsetroot%%\autounattend\options\wupd\windows10.0-kb4532938-%CPU_TYP%-ndp48.msu" /quiet /norestart
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C msiexec /i "%%configsetroot%%\autounattend\options\wupd\MicrosoftEdgeEnterprise-%CPU_TYP%.msi" /norestart /passive
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" Rem Cmd /C RmDel /S /Q "%%configsetroot%%"
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C shutdown /r /t 3
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Echo ^%%DATE^%% ^%%TIME^%% End
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     pause
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
Rem ---------------------------------------------------------------------------
    Robocopy /J /A-:RHS /NDL /NFL "%WIM_WUD%" "%WIM_IMG%\%OPT_PKG%" ^
        "windows-kb890830-%CPU_TYP%-v5.79.exe"                      ^
        "mpam-fe-%CPU_TYP%.exe"                                     ^
        "updateplatform-%CPU_TYP%.exe"                              ^
        "windows10.0-kb4528760-%CPU_TYP%.msu"                       ^
        "windows10.0-kb4532938-%CPU_TYP%-ndp48.msu"                 ^
        "MicrosoftEdgeEnterprise-%CPU_TYP%.msi"
Rem ===========================================================================

:SPLIT
Rem === install.wimを分割する =================================================
    If Exist "%WIM_IMG%\sources\install.wim" (
        If Exist "%WIM_IMG%\sources\install.swm" (Del /F "%WIM_IMG%\sources\install*.swm")
        Dism /Split-Image /ImageFile:"%WIM_IMG%\sources\install.wim" /SWMFile:"%WIM_IMG%\sources\install.swm" /FileSize:2048 || GoTo DONE
        Move /Y "%WIM_IMG%\sources\install.wim" "%WIM_BAK%"
    )

:MAKE
Rem *** DVDイメージを作成する *************************************************
    Echo *** DVDイメージを作成する *****************************************************
    Set MAK_IMG=-m -o -u1 -h -bootdata:2#p0,e,b"%WIM_IMG%\boot\etfsboot.com"#pEF,e,b"%WIM_IMG%\efi\microsoft\boot\efisys.bin"
    Oscdimg %MAK_IMG% "%WIM_IMG%" "%DVD_DST%" || GoTo :DONE

Rem --- 作業フォルダーの削除 --------------------------------------------------
Rem Echo --- 作業フォルダーの削除 ------------------------------------------------------
    If Exist "%WIM_TMP%" (
        Set /P INP_ANS=作業フォルダーを削除しますか？ [Y/N] ^(Yes/No^)
        If /I "!INP_ANS!" EQU "Y" (
            RmDir /S /Q "%WIM_TMP%" || GoTo :DONE)
        )
    )

Rem *** 作業終了 **************************************************************
:DONE
    If Exist "%WIM_WRE%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_WRE%" /Discard)
    If Exist "%WIM_MNT%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Discard)
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
