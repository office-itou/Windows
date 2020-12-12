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

    Set ARG_LST=%*
    Set FLG_OPT=0
    Set FLG_DEL=0
    Set FLG_DRV=0
    Set FLG_SPL=0
    Set FLG_MAK=0
    Set FLG_BAT=0

    For %%I In (!ARG_LST!) Do (
        Set ARG_PRM=%%~I
               If /I "!ARG_PRM!" EQU ""            (GoTo SETTING
        ) Else If /I "!ARG_PRM!" EQU "Help"        (GoTo HELP
        ) Else If /I "!ARG_PRM!" EQU "Reuse-Image" (Set FLG_OPT=0&Set FLG_DEL=1
        ) Else If /I "!ARG_PRM!" EQU "Add-Driver"  (Set FLG_OPT=0&Set FLG_DRV=1
        ) Else If /I "!ARG_PRM!" EQU "Split-Image" (Set FLG_OPT=1&Set FLG_SPL=1
        ) Else If /I "!ARG_PRM!" EQU "Make-Image"  (Set FLG_OPT=1&Set FLG_MAK=1
        ) Else If /I "!ARG_PRM!" EQU "Make-Auto"   (Set FLG_OPT=0&Set FLG_BAT=1&GoTo SETTING
        ) Else                                     (GoTo HELP
        )
    )

    GoTo SETTING

:HELP
    Echo !WRK_FIL! [ Help ^| Reuse-Image ^| Add-Driver ^| Split-Image ^| Make-Image ^| Make-Auto ]
    GoTo DONE

:SETTING
Rem *** 作業環境設定 **********************************************************
    Set WIM_TOP=
    Set IDX_VER=
    Set IDX_CPU=
    Set DRV_DVD=
    Set IDX_WIN=
    Set IDX_LST=

    If !FLG_BAT! NEQ 0 (
        Set WIM_TOP=%~2
        Set IDX_VER=%~3
        Set IDX_CPU=%~4
        Set DRV_DVD=%~5
        Set IDX_WIN=%~6
        Set IDX_LST=%~7
    )

Rem --- memo ------------------------------------------------------------------
Rem Start /Wait MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 1 1 "F:" 4 0
Rem Start /Wait MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 1 2 "G:" 4 0
Rem Start /Wait MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 2 1 "H:" 1 0
Rem Start /Wait MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 2 2 "I:" 1 0
Rem Start /Wait MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 3 1 "J:" 3 0
Rem Start /Wait MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 3 2 "K:" 3 0
Rem --- memo ------------------------------------------------------------------

Rem --- 作業フォルダーの設定 --------------------------------------------------
    Set DEF_TOP=C:\WimWK

    If /I "!WIM_TOP!" EQU "" (
        If /I "!WRK_TOP!" EQU "%DEF_TOP%" (
            Set WIM_TOP=%DEF_TOP%
        ) Else (
:INP_FOLDER
            Set WIM_TOP=!WRK_TOP!
            Set /P WIM_TOP=作業環境のフォルダーを指定して下さい。（規定値[!WIM_TOP!]）
            If /I "!WIM_TOP!" EQU "" (Set WIM_TOP=!WRK_TOP!)

            Echo "!WIM_TOP!"
            Set INP_ANS=N
            Set /P INP_ANS=上記でよろしいですか？ [Y/N] ^(Yes/No^)（規定値[!INP_ANS!]）
            If /I "!INP_ANS!" NEQ "Y" (GoTo INP_FOLDER)
        )
    )

    Set CUR_DIR=%CD%
    CD "!WIM_TOP!"

Rem --- Windowsのバージョン設定 -----------------------------------------------
    If /I "!IDX_VER!" EQU "" (
:INPUT_WIN_TYPE
        Echo --- Windowsのバージョン設定 ---------------------------------------------------
        Echo 1: Windows 7
        Echo 2: Windows 8.1
        Echo 3: Windows 10
        Set IDX_VER=3
        Set /P IDX_VER=Windowsのバージョンを1～3の数字から選んで下さい。（規定値[!IDX_VER!]）
        Set IDX_VER=!IDX_VER:~0,1!
    )

           If /I "!IDX_VER!" EQU "1" (Set WIN_VER=7
    ) Else If /I "!IDX_VER!" EQU "2" (Set WIN_VER=8.1
    ) Else If /I "!IDX_VER!" EQU "3" (Set WIN_VER=10
    ) Else                           (GoTo INPUT_WIN_TYPE
    )

           If !WIN_VER! EQU  7  (Set WIN_PNM=Windows6.1
    ) Else If !WIN_VER! EQU 8.1 (Set WIN_PNM=windows8.1
    ) Else If !WIN_VER! EQU 10  (Set WIN_PNM=Windows10.0
    ) Else                      (GoTo INPUT_WIN_TYPE
    )

Rem --- Windowsのアーキテクチャー設定 -----------------------------------------
    If /I "!IDX_CPU!" EQU "" (
:INPUT_ARC_TYPE
        Echo --- Windowsのアーキテクチャー設定 ---------------------------------------------
        Echo 1: 32bit版
        Echo 2: 64bit版
        Set IDX_CPU=2
        Set /P IDX_CPU=Windowsのアーキテクチャーを1～2の数字から選んで下さい。（規定値[!IDX_CPU!]）
        Set IDX_CPU=!IDX_CPU:~0,1!
    )

           If /I "!IDX_CPU!" EQU "1" (Set ARC_TYP=x86&Set CPU_BIT=32
    ) Else If /I "!IDX_CPU!" EQU "2" (Set ARC_TYP=x64&Set CPU_BIT=64
    ) Else                           (GoTo INPUT_ARC_TYPE
    )

Rem --- DVDのドライブ名設定 ---------------------------------------------------
    If /I "!DRV_DVD!" EQU "" (
:CHK_DVD_DRIVE
        Echo --- DVDのドライブ名設定 -------------------------------------------------------
        Set DRV_DVD=
        Set /P DRV_DVD=DVDのドライブ名[A-Z] 又はイメージフォルダー名を入力して下さい。
        If /I "!DRV_DVD!" EQU "" (GoTo CHK_DVD_DRIVE)
    )

    If /I "!DRV_DVD:~1,1!" EQU "" (
        Set DRV_DVD=!DRV_DVD!:\)
    )

:SET_DVD_DRIVE
    If Not Exist "!DRV_DVD!\sources\install.wim" If Not Exist "!DRV_DVD!\sources\install.swm" (
        Echo 統合する!ARC_TYP!版のDVDを"!DRV_DVD!"にセットして下さい。
        Echo 準備ができたら[Enter]を押下して下さい。
        Pause > Nul 2>&1
        GoTo SET_DVD_DRIVE
    )

Rem --- wimバージョンの取得 ---------------------------------------------------
    If Exist "!DRV_DVD!\Sources\Install.wim" (Set WIM_WIM=!DRV_DVD!\Sources\Install.wim
    ) Else                                   (Set WIM_WIM=!DRV_DVD!\Sources\Install.swm
    )
    For /F "Usebackq Tokens=3 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"!WIM_WIM!" /Index:1 ^| FindStr /C:"名前:"`)           Do (Set WIM_NME=%%~I)
    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"!WIM_WIM!" /Index:1 ^| FindStr /C:"アーキテクチャ:"`) Do (Set WIM_ARC=%%~I)
    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"!WIM_WIM!" /Index:1 ^| FindStr /C:"バージョン :"`)    Do (Set WIM_VER=%%~I)
    If !WIM_NME! NEQ !WIN_VER! (
        Echo DVDがWindows !WIM_NME! !WIM_ARC!版です。
        Echo 統合するWindows !WIN_VER! !ARC_TYP!版のDVDを"!DRV_DVD!"にセットして下さい。
        Echo 準備ができたら[Enter]を押下して下さい。
        Pause > Nul 2>&1
        GoTo SET_DVD_DRIVE
    )
    If /I "!WIM_ARC!" NEQ "!ARC_TYP!" (
        Echo DVDがWindows !WIM_NME! !WIM_ARC!版です。
        Echo 統合するWindows !WIN_VER! !ARC_TYP!版のDVDを"!DRV_DVD!"にセットして下さい。
        Echo 準備ができたら[Enter]を押下して下さい。
        Pause > Nul 2>&1
        GoTo SET_DVD_DRIVE
    )

    If /I "!DRV_DVD:~3!" NEQ "" (
        Set DVD_VOL=
    ) Else (
        For /F "Usebackq Tokens=5 Delims= " %%I In (`Vol "!DRV_DVD:~0,2!" ^| FindStr  /C:"ボリューム ラベル"`) Do (Set DVD_VOL=%%~I)
    )

Rem --- Windowsのエディション設定 ---------------------------------------------
    If !FLG_OPT! EQU 0 (
        If !WIN_VER! EQU 7 (
            If /I "!IDX_WIN!" EQU "" (
                Echo --- Windowsのエディション設定 -------------------------------------------------
                Echo 1: Windows 7 Starter ^(32bit版のみ^)
                Echo 2: Windows 7 HomeBasic
                Echo 3: Windows 7 HomePremium
                Echo 4: Windows 7 Professional
                Echo 5: Windows 7 Ultimate
                Set IDX_WIN=4
                Set /P IDX_WIN=Windowsのエディションを1～5の数字から選んで下さい。（規定値[!IDX_WIN!]）
                Set IDX_WIN=!IDX_WIN:~0,1!
            )

                   If /I "!IDX_WIN!" EQU "1" (Set WIN_TYP=Windows 7 Starter
            ) Else If /I "!IDX_WIN!" EQU "2" (Set WIN_TYP=Windows 7 HomeBasic
            ) Else If /I "!IDX_WIN!" EQU "3" (Set WIN_TYP=Windows 7 HomePremium
            ) Else If /I "!IDX_WIN!" EQU "4" (Set WIN_TYP=Windows 7 Professional
            ) Else If /I "!IDX_WIN!" EQU "5" (Set WIN_TYP=Windows 7 Ultimate
            )
        ) Else If !WIN_VER! EQU 8.1 (
            If /I "!IDX_WIN!" EQU "" (
                Echo --- Windowsのエディション設定 -------------------------------------------------
                Echo 1: Windows 8.1 Pro
                Echo 2: Windows 8.1
                Set IDX_WIN=1
                Set /P IDX_WIN=Windowsのエディションを1～2の数字から選んで下さい。（規定値[!IDX_WIN!]）
                Set IDX_WIN=!IDX_WIN:~0,1!
            )

                   If /I "!IDX_WIN!" EQU "1" (Set WIN_TYP=Windows 8.1 Pro
            ) Else If /I "!IDX_WIN!" EQU "2" (Set WIN_TYP=Windows 8.1
            )
        ) Else If !WIN_VER! EQU 10 (
            If /I "!IDX_WIN!" EQU "" (
                Echo --- Windowsのエディション設定 -------------------------------------------------
                Echo 1: Windows 10 Home
                Echo 2: Windows 10 Education
                Echo 3: Windows 10 Pro
                Echo 4: Windows 10 Pro Education
                Echo 5: Windows 10 Pro for Workstations
                Set IDX_WIN=3
                Set /P IDX_WIN=Windowsのエディションを1～5の数字から選んで下さい。（規定値[!IDX_WIN!]）
                Set IDX_WIN=!IDX_WIN:~0,1!
            )

                   If /I "!IDX_WIN!" EQU "1" (Set WIN_TYP=Windows 10 Home
            ) Else If /I "!IDX_WIN!" EQU "2" (Set WIN_TYP=Windows 10 Education
            ) Else If /I "!IDX_WIN!" EQU "3" (Set WIN_TYP=Windows 10 Pro
            ) Else If /I "!IDX_WIN!" EQU "4" (Set WIN_TYP=Windows 10 Pro Education
            ) Else If /I "!IDX_WIN!" EQU "5" (Set WIN_TYP=Windows 10 Pro for Workstations
            )
        )
    )

Rem --- 環境変数設定 ----------------------------------------------------------
Rem Set WIN_VER=%~1
    Set LST_PKG=adk bin drv !ARC_TYP!
Rem Set WIM_TOP=%~3
    Set WIM_BIN=!WIM_TOP!\bin
    Set WIM_CFG=!WIM_TOP!\cfg
    Set WIM_ISO=!WIM_TOP!\iso
    Set WIM_LST=!WIM_TOP!\lst
    Set WIM_PKG=!WIM_TOP!\pkg
    Set WIM_USR=!WIM_TOP!\usr
    Set WIM_WRK=!WIM_TOP!\wrk
    Set CMD_DAT=!WIM_WRK!\!WRK_NAM!.w!WIN_VER!.!ARC_TYP!.!NOW_DAY!!NOW_TIM!.dat
    Set CMD_WRK=!WIM_WRK!\!WRK_NAM!.w!WIN_VER!.!ARC_TYP!.!NOW_DAY!!NOW_TIM!.wrk
    Set CMD_DUP=!WIM_WRK!\!WRK_NAM!.w!WIN_VER!.!ARC_TYP!.!NOW_DAY!!NOW_TIM!.dup

    Set DVD_SRC=!DRV_DVD!\
    Set DVD_SRC=!DVD_SRC:\\=\!
    Set DVD_DST=!WIM_TOP!\windows_!WIN_VER!_!ARC_TYP!_dvd_custom_VER_.iso
    Set DVD_DST=%DVD_DST:_VER_=_!WIM_VER!%

    Set LST_OPT=
    Set LST_LST=
    Set LST_CNT=0
    Pushd "!WIM_LST!" || GoTo DONE
        For /R %%I In ("Windows!WIN_VER!*.lst") Do (
            For /F "tokens=1,2 usebackq delims=_" %%J in ('%%~nxI') Do (
                Set DVD_PKG=%%~J
                Set DVD_PKG=!DVD_PKG:~-3!
                Set DVD_OPT=%%~nK
                For %%P In (!LST_PKG!) Do (
                    If /I "%%~P" EQU "!DVD_PKG!" (
                        If /I "!DVD_OPT!" NEQ "Rollup" (
                            If /I "!LST_LST!" EQU "" (Set LST_LST=!DVD_OPT!
                            ) Else                   (Set LST_LST=!LST_LST! !DVD_OPT!
                            )
                            Set /A LST_CNT+=1
                        )
                    )
                )
            )
        )
    Popd

    If /I "!LST_LST!" NEQ "" (
        If /I "!IDX_LST!" EQU "" (
:INPUT_ADD_LIST_FILE
            Set WRK_CNT=0
            Echo --- リストファイルの追加 ------------------------------------------------------
            Echo 0: 追加しない
            For %%I In (!LST_LST!) Do (
                Set /A WRK_CNT+=1
                Echo !WRK_CNT!: %%~I
            )
            Set IDX_LST=0
            Set /P IDX_LST=追加リストファイルを0～!WRK_CNT!の数字から選んで下さい。（規定値[!IDX_LST!]）
            Set IDX_LST=!IDX_LST:~0,1!
            If !IDX_LST! LSS 0         (GoTo INPUT_ADD_LIST_FILE)
            If !IDX_LST! GTR !WRK_CNT! (GoTo INPUT_ADD_LIST_FILE)
        )
        If !IDX_LST! GTR 0 (
            For /F "tokens=1 usebackq" %%I In (`Cmd /C ^"For /F ^"tokens^=!IDX_LST! usebackq^" %%J In ^('!LST_LST!'^) Do ^(Echo %%~J^)^"`) Do (Set LST_OPT=%%~I)
            Set DVD_DST=%DVD_DST:_custom_=_!LST_OPT!_%
        )
    )

    Set UTL_ARC=amd64 arm arm64 x86

Rem --- 作業フォルダーの作成 --------------------------------------------------
    Echo *** 作業フォルダーの作成 ******************************************************
Rem --- 破損イメージの削除 ----------------------------------------------------
    For %%I In (!WIN_VER!) Do (
        For %%J In (!ARC_TYP!) Do (
            Set WIM_NOW=!WIM_WRK!\w%%~I.!NOW_DAY!!NOW_TIM!
            Set WIM_IMG=!WIM_NOW!\%%~J\img
            Set WIM_MNT=!WIM_NOW!\%%~J\mnt
            Set WIM_WRE=!WIM_NOW!\%%~J\wre
            Set WIM_BT1=!WIM_NOW!\%%~J\bt1
            Set WIM_BT2=!WIM_NOW!\%%~J\bt2
            If Exist "!WIM_BT1!\Windows" (
                Echo --- 破損イメージの削除 --------------------------------------------------------
                Dism /Quiet /UnMount-Wim /MountDir:"!WIM_BT1!" /Discard
            )
            If Exist "!WIM_BT2!\Windows" (
                Echo --- 破損イメージの削除 --------------------------------------------------------
                Dism /Quiet /UnMount-Wim /MountDir:"!WIM_BT2!" /Discard
            )
            If Exist "!WIM_WRE!\Windows" (
                Echo --- 破損イメージの削除 --------------------------------------------------------
                Dism /Quiet /UnMount-Wim /MountDir:"!WIM_WRE!" /Discard
            )
            If Exist "!WIM_MNT!\Windows" (
                Echo --- 破損イメージの削除 --------------------------------------------------------
                Dism /Quiet /UnMount-Wim /MountDir:"!WIM_MNT!" /Discard
            )
        )
    )

    If Not Exist "!WIM_BIN!" (MkDIr "!WIM_BIN!" || GoTo DONE)
    If Not Exist "!WIM_CFG!" (MkDIr "!WIM_CFG!" || GoTo DONE)
    If Not Exist "!WIM_LST!" (MkDIr "!WIM_LST!" || GoTo DONE)
    If Not Exist "!WIM_PKG!" (MkDIr "!WIM_PKG!" || GoTo DONE)
    If Not Exist "!WIM_USR!" (MkDIr "!WIM_USR!" || GoTo DONE)
    If Not Exist "!WIM_WRK!" (MkDIr "!WIM_WRK!" || GoTo DONE)

    For %%I In (!WIN_VER!) Do (
        For %%J In (!ARC_TYP!) Do (
            Set WIM_PKB=!WIM_PKG!\w%%~I\bin
            Set WIM_DRV=!WIM_PKG!\w%%~I\drv
            Set WIM_WUD=!WIM_PKG!\w%%~I\%%~J
            Set WIM_CAB=!WIM_PKG!\w%%~I\%%~J\cab
            Set WIM_NOW=!WIM_WRK!\w%%~I.!NOW_DAY!!NOW_TIM!
            Set WIM_BAK=!WIM_NOW!\%%~J\bak
            Set WIM_EFI=!WIM_NOW!\%%~J\efi
            Set WIM_IMG=!WIM_NOW!\%%~J\img
            Set WIM_MNT=!WIM_NOW!\%%~J\mnt
            Set WIM_WRE=!WIM_NOW!\%%~J\wre
            Set WIM_BT1=!WIM_NOW!\%%~J\bt1
            Set WIM_BT2=!WIM_NOW!\%%~J\bt2
            Set WIM_WIM=!WIM_NOW!\%%~J\wim

            If /I "!DRV_DVD!" EQU "!WIM_IMG!" (
                Echo イメージフォルダーの統合元と作業用が同じです。
                Echo 統合元："!DRV_DVD!"
                Echo 作業用："!WIM_IMG!"
                Echo 別のフォルダーを指定して下さい。
                GoTo CHK_DVD_DRIVE
            )

            If !FLG_DEL! EQU 0 (
                If     Exist "!WIM_IMG!" (RmDir /S /Q "!WIM_IMG!" || GoTo DONE)
            )

            If     Exist "!WIM_MNT!" (RmDir /S /Q "!WIM_MNT!" || GoTo DONE)
            If     Exist "!WIM_WRE!" (RmDir /S /Q "!WIM_WRE!" || GoTo DONE)
            If     Exist "!WIM_BT1!" (RmDir /S /Q "!WIM_BT1!" || GoTo DONE)
            If     Exist "!WIM_BT2!" (RmDir /S /Q "!WIM_BT2!" || GoTo DONE)

            If Not Exist "!WIM_WUD!" (MkDir       "!WIM_WUD!" || GoTo DONE)
            If Not Exist "!WIM_CAB!" (MkDir       "!WIM_CAB!" || GoTo DONE)
            If Not Exist "!WIM_BAK!" (MkDir       "!WIM_BAK!" || GoTo DONE)
            If Not Exist "!WIM_EFI!" (MkDir       "!WIM_EFI!" || GoTo DONE)
            If Not Exist "!WIM_IMG!" (MkDir       "!WIM_IMG!" || GoTo DONE)
            If Not Exist "!WIM_MNT!" (MkDir       "!WIM_MNT!" || GoTo DONE)
            If Not Exist "!WIM_WRE!" (MkDir       "!WIM_WRE!" || GoTo DONE)
            If Not Exist "!WIM_BT1!" (MkDir       "!WIM_BT1!" || GoTo DONE)
            If Not Exist "!WIM_BT2!" (MkDir       "!WIM_BT2!" || GoTo DONE)
            If Not Exist "!WIM_WIM!" (MkDir       "!WIM_WIM!" || GoTo DONE)
        )
    )

Rem --- 作業ファイルの削除 ----------------------------------------------------
    If Exist "!CMD_DAT!" (Del /F "!CMD_DAT!" || GoTo DONE)
    If Exist "!CMD_WRK!" (Del /F "!CMD_WRK!" || GoTo DONE)
    If Exist "!CMD_DUP!" (Del /F "!CMD_DUP!" || GoTo DONE)

    Copy /Y Nul "!CMD_WRK!" > Nul || GoTo DONE

Rem --- Oscdimg取得 -----------------------------------------------------------
    If Not Exist "!WIM_BIN!\Oscdimg\%PROCESSOR_ARCHITECTURE%" (
        Echo --- Oscdimg取得 ---------------------------------------------------------------
        Pushd "%ProgramFiles(x86)%" || GoTo DONE
            For /R %%I In (Oscdimg.exe*) Do (Set UTL_WRK=%%~dpI)
        Popd
        If /I "!UTL_WRK!" EQU "" (
            Echo Windows ADK をインストールして下さい。
            GoTo DONE
        )
        For %%I In (!UTL_ARC!) DO (
            Set UTL_SRC=!UTL_WRK!\..\..\%%~I\Oscdimg
            Set UTL_DST=!WIM_BIN!\Oscdimg\%%~I
            Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!UTL_SRC!" "!UTL_DST!" > Nul
        )
    )

Rem --- Oscdimgのパスを設定する -----------------------------------------------
    Set Path=!WIM_BIN!;!WIM_BIN!\Oscdimg\%PROCESSOR_ARCHITECTURE%;%Path%
    Oscdimg > NUL 2>&1
    If "%ErrorLevel%" EQU "9009" (
        Echo Oscdimg がありません。
        Echo Windows ADK をインストールして下さい。
        GoTo DONE
    )

    If !FLG_DRV! EQU 0 (
        If !FLG_SPL! EQU 1 (
            GoTo MAKE_ISO_IMAGE
        )
    )

:DOWNLOAD
Rem *** リストファイル変換 ****************************************************
    Echo --- リストファイル変換 --------------------------------------------------------
    Set LST_FIL=
    For %%I In (!WIN_VER!) Do (
        Set LST_WINVER=%%~I
        For %%J In (!LST_PKG!) Do (
            Set LST_PACKAGE=%%~J
            Set LST_LFSNAME=!WIM_LST!\Windows!LST_WINVER!!LST_PACKAGE!*.lst
            Set LST_WINPACK=!WIM_PKG!\w!LST_WINVER!\!LST_PACKAGE!
            Set LST_SECTION=
            For %%K In ("!LST_LFSNAME!") Do (
                Set LST_LFNAME=
                For /F "tokens=1-3 usebackq delims=_" %%E in ('%%~nK') Do (
                           If /I "%%~F"  EQU "Rollup"    (If !FLG_DRV! EQU 0 (Set LST_LFNAME=%%~K)
                    ) Else If /I "%%~nF" EQU "!LST_OPT!" (Set LST_LFNAME=%%~K
                    )
                    Set LST_PACK=%%~E
                    Set LST_TYPE=%%~F
                    Set LST_DATE=%%~G
                )
                Pushd "!WIM_LST!" || GoTo DONE
                    For /R %%L In ("!LST_PACK!_!LST_TYPE!*.lst") Do (
                        For /F "tokens=1-3 usebackq delims=_" %%E in ('%%~nL') Do (
                            If !LST_DATE! LSS %%~G (Set LST_LFNAME=)
                        )
                    )
                Popd
                If /I "!LST_LFNAME!" NEQ "" (
                    If /I "!LST_LFNAME:~0,77!" EQU "!LST_LFNAME!" (Echo "!LST_LFNAME!") Else (Echo "!LST_LFNAME:~0,59!...!LST_LFNAME:~-15!")
                    Set LST_LIST=
                    Set LST_SECTION=
                    Set LST_TITLE=
                    Set LST_INFO=
                    Set LST_FILE=
                    Set LST_RENAME=
                    Set LST_SIZE=
                    Set LST_TYPE=
                    Set LST_CATEGORY=
                    Set LST_TIE_UP=
                    Set LST_XOR_KEY=
                    Set LST_SYNCHRO_KEY=
                    Set LST_RELEASE=
                    Set LST_RUN_ORDER=
                    Set LST_CMD=
                    Set LST_DECODE=
                    Set LST_DECODE_TYPE=
                    Set LST_DECODE_GET=
                    Set LST_IEXPRESS=
                    Set LST_IEXPRESS_LIST=
                    Set LST_IEXPRESS_CMD=
                    Set LST_PREVIOUS_SP=
                    Set LST_COMMENT=
                    Set LST_TYPE_NUM=
                    For /F "tokens=1* usebackq delims==" %%L In ("!LST_LFNAME!") Do (
                        Set LST_KEY=%%~L
                        Set LST_VAL=%%~M
                        If /I "!LST_KEY:~0,1!!LST_KEY:~-1,1!" EQU "[]" (
                                   If /I "!LST_SECTION!" EQU "INFO" (Rem
                            ) Else If /I "!LST_SECTION!" EQU "LIST" (Rem
                            ) Else If /I "!LST_SECTION!" NEQ ""     (
                                Set FLG_SKIP=0
                                If /I "!LST_XOR_KEY!" NEQ "" (
                                    For %%A In (!LST_XOR_KEY!) Do (
                                        For %%X In (!LST_LIST!) Do (
                                            If /I "%%~A" EQU "%%~X" (Set FLG_SKIP=1)
                                        )
                                    )
                                )
                                If !FLG_SKIP! EQU 0 (
                                    If /I "!LST_RENAME!" EQU "" (For %%E In ("!LST_FILE!")   Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE&Set LST_RENAME=%%~nxE)
                                    ) Else                      (For %%E In ("!LST_RENAME!") Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE)
                                    )
                                    If /I "!LST_RUN_ORDER!" EQU "" (Set LST_RUN_ORDER=000)
                                    Set LST_RENAME=!LST_WINPACK!\!LST_RENAME!
                                    Set LST_EXTENSION=!LST_EXTENSION:~1!
                                    If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                                    Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE_NUM!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!","!LST_COMMENT!"
                                )
                            )
                            Set LST_SECTION=!LST_KEY:~1,-1!
                            Set LST_TITLE=
                            Set LST_INFO=
                            Set LST_FILE=
                            Set LST_RENAME=
                            Set LST_SIZE=
                            Set LST_TYPE=
                            Set LST_CATEGORY=
                            Set LST_TIE_UP=
                            Set LST_XOR_KEY=
                            Set LST_SYNCHRO_KEY=
                            Set LST_RELEASE=
                            Set LST_RUN_ORDER=
                            Set LST_CMD=
                            Set LST_DECODE=
                            Set LST_DECODE_TYPE=
                            Set LST_DECODE_GET=
                            Set LST_IEXPRESS=
                            Set LST_IEXPRESS_LIST=
                            Set LST_IEXPRESS_CMD=
                            Set LST_PREVIOUS_SP=
                            Set LST_COMMENT=
                            Set LST_TYPE_NUM=
                        ) Else (
                                   If /I "!LST_SECTION!" EQU "INFO" (Rem
                            ) Else If /I "!LST_SECTION!" EQU "LIST" (
                                If /I "!LST_KEY!" NEQ "COUNT" (
                                    If /I "!LST_LIST!" EQU "" (Set LST_LIST=!LST_VAL!
                                    ) Else                    (Set LST_LIST=!LST_LIST! !LST_VAL!
                                    )
                                )
                            ) Else If /I "!LST_SECTION!" NEQ "" (
                                       If /I "!LST_KEY!" EQU "TITLE"         (Set LST_TITLE=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "INFO"          (Set LST_INFO=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "FILE"          (Set LST_FILE=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "RENAME"        (Set LST_RENAME=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "SIZE"          (Set LST_SIZE=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "TYPE"          (Set LST_TYPE=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "CATEGORY"      (Set LST_CATEGORY=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "TIE_UP"        (Set LST_TIE_UP=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "XOR_KEY"       (Set LST_XOR_KEY=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "SYNCHRO_KEY"   (Set LST_SYNCHRO_KEY=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "RELEASE"       (Set LST_RELEASE=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "RUN_ORDER"     (Set LST_RUN_ORDER=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "CMD"           (Set LST_CMD=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "DECODE"        (Set LST_DECODE=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "DECODE_TYPE"   (Set LST_DECODE_TYPE=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "DECODE_GET"    (Set LST_DECODE_GET=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "IEXPRESS"      (Set LST_IEXPRESS=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "IEXPRESS_LIST" (Set LST_IEXPRESS_LIST=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "IEXPRESS_CMD"  (Set LST_IEXPRESS_CMD=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "PREVIOUS_SP"   (Set LST_PREVIOUS_SP=!LST_VAL!
                                ) Else If /I "!LST_KEY!" EQU "COMMENT"       (Set LST_COMMENT=!LST_VAL!
                                )
                                If /I "!LST_KEY!" EQU "TYPE" (
                                           If /I "!LST_TYPE!" EQU "Service Pack"         (Set LST_TYPE_NUM=01
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(SVCPACK.INF)"  (Set LST_TYPE_NUM=02
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIXES.CMD)" (Set LST_TYPE_NUM=03
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX1.CMD)"  (Set LST_TYPE_NUM=04
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX2.CMD)"  (Set LST_TYPE_NUM=05
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX3.CMD)"  (Set LST_TYPE_NUM=06
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX4.CMD)"  (Set LST_TYPE_NUM=07
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX5.CMD)"  (Set LST_TYPE_NUM=08
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX6.CMD)"  (Set LST_TYPE_NUM=09
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX7.CMD)"  (Set LST_TYPE_NUM=10
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX8.CMD)"  (Set LST_TYPE_NUM=11
                                    ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX9.CMD)"  (Set LST_TYPE_NUM=12
                                    ) Else                                               (Set LST_TYPE_NUM=
                                    )
                                )
                            )
                        )
                    )
                           If /I "!LST_SECTION!" EQU "INFO" (Rem
                    ) Else If /I "!LST_SECTION!" EQU "LIST" (Rem
                    ) Else If /I "!LST_SECTION!" NEQ ""     (
                        Set FLG_SKIP=0
                        If /I "!LST_XOR_KEY!" NEQ "" (
                            For %%A In (!LST_XOR_KEY!) Do (
                                For %%X In (!LST_LIST!) Do (
                                    If /I "%%~A" EQU "%%~X" (Set FLG_SKIP=1)
                                )
                            )
                        )
                        If !FLG_SKIP! EQU 0 (
                            If /I "!LST_RENAME!" EQU "" (For %%E In ("!LST_FILE!")   Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE&Set LST_RENAME=%%~nxE)
                            ) Else                      (For %%E In ("!LST_RENAME!") Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE)
                            )
                            If /I "!LST_RUN_ORDER!" EQU "" (Set LST_RUN_ORDER=000)
                            Set LST_RENAME=!LST_WINPACK!\!LST_RENAME!
                            Set LST_EXTENSION=!LST_EXTENSION:~1!
                            If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                            Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE_NUM!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!","!LST_COMMENT!"
                        )
                    )
                )
            )
        )
    )

Rem --- ファイルソート --------------------------------------------------------
    Sort "!CMD_WRK!" > "!CMD_DAT!"

Rem --- Dynamic Update --------------------------------------------------------
    For /F "tokens=1-11 usebackq delims=," %%I In ("!CMD_DAT!") Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE_NUM=%%~K
        Set LST_TYPE=%%~L
        Set LST_RUN_ORDER=%%~M
        Set LST_SECTION=%%~N
        Set LST_EXTENSION=%%~O
        Set LST_CMD=%%~P
        Set LST_RENAME=%%~Q
        Set LST_FILE=%%~R
        Set LST_COMMENT=%%~S
        If /I "!LST_WINDOWS!" EQU "w!WIN_VER!" (
            If /I "!LST_PACKAGE!" EQU "!ARC_TYP!" (
                If /I "!LST_COMMENT!" EQU "Dynamic Update" (
Rem                 Echo>>"!CMD_DUP!" "!LST_WINDOWS!","!LST_PACKAGE!","!LST_TYPE_NUM!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!","!LST_COMMENT!"
                )
            )
        )
    )

Rem *** ファイル取得 **********************************************************
    Echo --- ファイル取得 --------------------------------------------------------------
    For /F "tokens=1-11 usebackq delims=," %%I In ("!CMD_DAT!") Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE_NUM=%%~K
        Set LST_TYPE=%%~L
        Set LST_RUN_ORDER=%%~M
        Set LST_SECTION=%%~N
        Set LST_EXTENSION=%%~O
        Set LST_CMD=%%~P
        Set LST_RENAME=%%~Q
        Set LST_FILE=%%~R
        Set LST_COMMENT=%%~S
        Set LST_WINPKG=!WIM_PKG!\!LST_WINDOWS!
        For %%E In ("!LST_RENAME!") Do (Set LST_FNAME=%%~nxE)
        For /F "tokens=1 usebackq delims=:" %%X In ('!LST_FILE!') Do (
                   If /I "%%~X" EQU "http"  (Set FLG_URL=1
            ) Else If /I "%%~X" EQU "https" (Set FLG_URL=1
            ) Else                          (Set FLG_URL=0
            )
            If !FLG_URL! EQU 1 (
                If Not Exist "!LST_RENAME!" (
                    If /I "!LST_FNAME:~0,77!" EQU "!LST_FNAME!" (Echo "!LST_FNAME!") Else (Echo "!LST_FNAME:~0,59!...!LST_FNAME:~-15!")
                       Curl -L -# -R -S -f --create-dirs --connect-timeout 60    -o "!LST_RENAME!" "!LST_FILE!" ^
                    || Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -k -o "!LST_RENAME!" "!LST_FILE!" ^
                    || GoTo DONE
                ) Else (
                    If /I "!LST_FNAME:~0,77!" EQU "!LST_FNAME!" (Echo "!LST_FNAME!") Else (Echo "!LST_FNAME:~0,59!...!LST_FNAME:~-15!")
                       Curl -L -s -S -f --connect-timeout 60    --dump-header "!CMD_WRK!" "!LST_FILE!" ^
                    || Curl -L -s -S -f --connect-timeout 60 -k --dump-header "!CMD_WRK!" "!LST_FILE!"
                    If !ErrorLevel! NEQ 22 (
                        Set LST_LEN=0
                        For /F "tokens=1,2* usebackq delims=:" %%Y In ("!CMD_WRK!") Do (
                            If /I "%%~Y" EQU "Content-Length" (Set LST_LEN=%%~Z)
                        )
                        For /F "usebackq delims=/" %%Z In ('!LST_RENAME!') Do (Set LST_SIZE=%%~zZ)
                        If !LST_LEN! NEQ !LST_SIZE! (
Rem                         If /I "!LST_FNAME:~0,77!" EQU "!LST_FNAME!" (Echo "!LST_FNAME!") Else (Echo "!LST_FNAME:~0,59!...!LST_FNAME:~-15!")
                               Curl -L -# -R -S -f --create-dirs --connect-timeout 60    -o "!LST_RENAME!" "!LST_FILE!" ^
                            || Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -k -o "!LST_RENAME!" "!LST_FILE!" ^
                            || GoTo DONE
                        )
                    )
                )
            )
:SET_INSTALL_FILE_CHECK
            If Not Exist "!LST_RENAME!" (
                Echo 統合する!LST_RENAME!をセットして下さい。
                Echo 準備ができたら[Enter]を押下して下さい。
                Pause > Nul 2>&1
                GoTo SET_INSTALL_FILE_CHECK
            )
            If Not Exist "!LST_RENAME!" (
                Echo File not exist: "!LST_RENAME!"
                GoTo SET_INSTALL_FILE_CHECK
            ) Else (
                If /I "!LST_EXTENSION!" EQU "zip" (
                    For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                    If Not Exist "!LST_DIR!" (
                        Echo --- ファイル展開 --------------------------------------------------------------
                        MkDir "!LST_DIR!"
                        Tar -xzf "!LST_RENAME!" -C "!LST_DIR!" || GoTo DONE
                    )
                    Pushd "!LST_DIR!" || GoTo DONE
                        For /R %%E In ("*.zip") Do (
                            Set LST_ZIPFILE=%%~E
                            Set LST_ZIPDIR=%%~dpnE
                            If Not Exist "!LST_ZIPDIR!" (
                                Echo --- ファイル展開 --------------------------------------------------------------
                                MkDir "!LST_ZIPDIR!"
                                Tar -xzf "!LST_ZIPFILE!" -C "!LST_ZIPDIR!" || GoTo DONE
                            )
                            Pushd "!LST_ZIPDIR!" || GoTo DONE
                                For /R %%F In ("*.msu") Do (
                                    For /F "tokens=2 delims=x" %%G In ("%%~nF") Do (Set LST_PACKAGE=%%~G)
                                    If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!\%%~nxF" (
                                        Echo --- ファイル転送 --------------------------------------------------------------
                                        If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!" (MkDir "!LST_WINPKG!\x!LST_PACKAGE!")
                                        Copy /Y "%%~F" "!LST_WINPKG!\x!LST_PACKAGE!" > Nul || GoTo DONE
                                    )
                                )
                            Popd
                        )
                        For /R %%F In ("*.msu") Do (
                            For /F "tokens=2 delims=x" %%G In ("%%~nF") Do (Set LST_PACKAGE=%%~G)
                            If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!\%%~nxF" (
                                Echo --- ファイル転送 --------------------------------------------------------------
                                If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!" (MkDir "!LST_WINPKG!\x!LST_PACKAGE!")
                                Copy /Y "%%~F" "!LST_WINPKG!\x!LST_PACKAGE!" > Nul || GoTo DONE
                            )
                        )
                    Popd
                ) Else If /I "!LST_EXTENSION!" EQU "msi" (
                   If /I "!LST_CMD!" EQU "" (
                        For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                        If Not Exist "!LST_DIR!" (
                            Echo --- ファイル展開 --------------------------------------------------------------
                            MkDir "!LST_DIR!"
                            MsiExec /a "!LST_RENAME!" targetdir="!LST_DIR!" /qn > Nul || GoTo DONE
                        )
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "cab" (
                           If /I "!LST_PACKAGE!" EQU "x64" (Rem
                    ) Else If /I "!LST_PACKAGE!" EQU "x86" (Rem
                    ) Else (
                        For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                        If Not Exist "!LST_DIR!" (
                            Echo --- ファイル展開 --------------------------------------------------------------
                            MkDir "!LST_DIR!"
                            Expand "!LST_RENAME!" -F:* "!LST_DIR!" > Nul || GoTo DONE
                        )
                    )
                ) Else If /I "!LST_SECTION!" EQU "IE11" (
                    For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                    If Not Exist "!LST_DIR!" (
                        Echo --- ファイル展開 --------------------------------------------------------------
                        MkDir "!LST_DIR!"
                        "!LST_RENAME!" /x:"!LST_DIR!"
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "msu" (
                    If /I "!LST_SECTION!" EQU "KB2533552" (
                        Echo --- ファイル展開 --------------------------------------------------------------
                        For %%E In ("!LST_RENAME!") Do (
                            Set LST_FPATH=%%~dpnE
                            Set LST_FNAME=%%~nE
                            For /F "usebackq delims=_" %%F In (`Echo "!LST_FNAME!"`) Do (
                                Set LST_FCAB=!LST_FPATH!\%%~F
                            )
                        )
                        If Exist "!LST_FPATH!" (RmDir /S /Q "!LST_FPATH!")
                        MkDir "!LST_FCAB!"
                        Expand -F:* "!LST_RENAME!" "!LST_FPATH!" > Nul || GoTo DONE
                        Expand -F:* "!LST_FCAB!.cab" "!LST_FCAB!" > Nul || GoTo DONE
                        For /F "usebackq delims=" %%E In ("!LST_FCAB!\update.mum") Do (
                            Set LST_LINE=%%~E
                            For /F "usebackq delims=" %%F In (`Echo "!LST_LINE!" ^| Find "allowedOffline"`) Do (
                                Set LST_LINE="		<mum:packageExtended xmlns:mum="urn:schemas-microsoft-com:asm.v3" exclusive="true" allowedOffline="true"/>"
                            )
                            Echo>>"!LST_FPATH!\update.wrk" !LST_LINE!
                        )
                        Move "!LST_FPATH!\update.wrk" "!LST_FCAB!\update.mum" > Nul || GoTo DONE
                    )
                )
            )
        )
    )

:UPDATE
Rem *** 統合ISOファイル作成 ***************************************************
Rem === 原本から作業フォルダーにコピーする ====================================
    Echo --- 原本から作業フォルダーにコピーする ----------------------------------------
    Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS /NFL "!DVD_SRC!\" "!WIM_IMG!" > Nul

    If !FLG_DRV! EQU 1 (If /I "!LST_OPT!" EQU "" (GoTo MAKE_ISO_IMAGE))
    If !FLG_OPT! EQU 1 (If !FLG_MAK! EQU 1       (GoTo MAKE_ISO_IMAGE))

:ADD_BOOT_OPTIONS
Rem === UEFIブート準備 ========================================================
    If !WIN_VER! LEQ 7 (
        If /I "!ARC_TYP!" EQU "x64" (
            If Not Exist "!WIM_EFI!\bootx64.efi" (
                Echo --- bootx64.efi の抽出 --------------------------------------------------------
                Dism /Quiet /Mount-Wim /WimFile:"!WIM_IMG!\sources\boot.wim" /index:1 /MountDir:"!WIM_BT1!" /ReadOnly || GoTo DONE
                Copy /Y "!WIM_BT1!\Windows\Boot\EFI\bootmgfw.efi" "!WIM_EFI!\bootx64.efi" > Nul || GoTo DONE
                Dism /Quiet /Unmount-Wim /MountDir:"!WIM_BT1!" /Discard || GoTo DONE
            )
            Echo --- bootx64.efi のコピー ------------------------------------------------------
            Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!WIM_EFI!" "!WIM_IMG!\efi\boot" "bootx64.efi" > Nul
        )
    )

:ADD_UNATTEND
Rem === Unattend ==============================================================
    If Exist "!WIM_CFG!\autounattend-windows!WIN_VER!-!ARC_TYP!.xml" (
        Echo --- autounattend.xml のコピー -------------------------------------------------
        Copy /Y "!WIM_CFG!\autounattend-windows!WIN_VER!-!ARC_TYP!.xml" "!WIM_IMG!\autounattend.xml" > Nul || GoTo DONE
    )

:ADD_OPTIONS
Rem === options.cmd の作成 ====================================================
    Echo --- options.cmd の作成 --------------------------------------------------------
    Set OPT_DIR=autounattend\options
    Set OPT_PKG=!OPT_DIR!\upd
    Set OPT_DRV=!OPT_DIR!\drv
    Set OPT_BIN=!OPT_DIR!\bin
    Set OPT_CMD=!WIM_IMG!\!OPT_DIR!\options.cmd
    Set OPT_BAK=!OPT_CMD!.!NOW_DAY!!NOW_TIM!
    Set OPT_TMP=!OPT_CMD!.tmp
    Set OPT_LST=
    Set OPT_MSU=0
    Set OPT_SUB=1
    If Not Exist "!WIM_IMG!\!OPT_DIR!" (MkDir "!WIM_IMG!\!OPT_DIR!")
    If !FLG_DRV! EQU 1 (If Exist "!OPT_CMD!" (Move /Y "!OPT_CMD!" "!OPT_BAK!" > Nul))
    If Exist "!OPT_CMD!" (Del /F "!OPT_CMD!")
    If Exist "!OPT_TMP!" (Del /F "!OPT_TMP!")
Rem --- options.cmd の作成 ----------------------------------------------------
    Echo>>"!OPT_CMD!" @Echo Off
    Echo>>"!OPT_CMD!"     Cls
    Echo>>"!OPT_CMD!"     SetLocal EnableExtensions
    Echo>>"!OPT_CMD!"     SetLocal EnableDelayedExpansion
    Echo>>"!OPT_CMD!"     Echo *** 作業開始 ******************************************************************
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem %DATE% %TIME% maked
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"     Echo ^%%DATE^%% ^%%TIME^%% Start
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"     Set Path=%%configsetroot%%\!OPT_BIN!;%%Path%%
    If !OPT_SUB! NEQ 0 (
        Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
        Echo>>"!OPT_CMD!"     If "%%1" EQU "" ^(
    )
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"         Echo === Step 1 start ==============================================================
    Echo>>"!OPT_CMD!" Rem --- NTP Setup -------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem     SC Stop W32Time ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!"         Reg Add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "" /t REG_SZ /d "0" /f ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!"         Reg Add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "0" /t REG_SZ /d "ntp.nict.jp" /f ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!"         Reg Add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "UpdateInterval" /t REG_DWORD /d "0x00057e40" /f ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!"         Reg Add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /t REG_SZ /d "NTP" /f ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!"         Reg Add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /t REG_SZ /d "ntp.nict.jp,0x9" /f ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!"         Reg Add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d "0x00005460" /f ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!"         Reg Add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollTimeRemaining" /t REG_MULTI_SZ /d "" /f ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!"         SC Config W32Time Start= Delayed-Auto ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!" Rem     SC Start W32Time ^> Nul 2^>^&1
Rem ---------------------------------------------------------------------------
    If !FLG_DRV! EQU 0 (
        Echo>>"!OPT_CMD!" Rem --- Package ---------------------------------------------------------------
    ) Else (
        Set CMD_SKP=0
        For /F "usebackq delims=" %%I In ("!OPT_BAK!") Do (
            Set LINE=%%~I
            For /F "tokens=1,2 usebackq delims=- " %%J In ('!LINE!') Do (
                If /I "%%~J" EQU "Rem" (
                    If /I "%%~K" EQU "Package"  (Set CMD_SKP=1)
                    If /I "%%~K" EQU "Cleaning" (Set CMD_SKP=0)
                )
            )
            If !CMD_SKP! EQU 1 (
                If "!LINE!" EQU "" (
                    Echo.>>"!OPT_CMD!"
                ) Else (
                    Echo>>"!OPT_CMD!"     !LINE!
                )
            )
        )
    )
Rem ---------------------------------------------------------------------------
    For /F "tokens=1-11 usebackq delims=," %%I In ("!CMD_DAT!") Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE_NUM=%%~K
        Set LST_TYPE=%%~L
        Set LST_RUN_ORDER=%%~M
        Set LST_SECTION=%%~N
        Set LST_EXTENSION=%%~O
        Set LST_CMD=%%~P
        Set LST_RENAME=%%~Q
        Set LST_FILE=%%~R
        Set LST_COMMENT=%%~S
        For %%E In ("!LST_RENAME!") Do (
            Set LST_FNAME=%%~nxE
            Set LST_FDSRC=%%~dpE
            Set LST_FDSRC=!LST_FDSRC:~0,-1!
            Set LST_FNSRC=%%~dpnE
            Set LST_FNDST=%%~nE
        )
        If /I "!LST_WINDOWS!" EQU "w!WIN_VER!" (
            If /I "!LST_CMD!" EQU "" (If /I "!LST_EXTENSION!" EQU "msu" (Set OPT_MSU=1)
            ) Else                   (
                Set LST_REM=   
                Set LST_SECTION_LST=!LST_SECTION:_= !
                For %%A In (!LST_SECTION_LST!) Do (
                    If /I "%%A" NEQ "!ARC_TYP!" (
                               If /I "%%~A" EQU "x64" (Set LST_REM=Rem
                        ) Else If /I "%%~A" EQU "x86" (Set LST_REM=Rem
                        )
                    )
                )
                If /I "!LST_EXTENSION!" EQU "exe" (
                    If /I "!LST_PACKAGE!" EQU "drv" (
                        For %%E In ("!LST_FDSRC!") Do (Set LST_FNDST=%%~nE)
                        Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!LST_FDSRC!" "!WIM_IMG!\!OPT_DRV!\!LST_SECTION!" > Nul
                        If /I "!LST_FNAME:~0,77!" EQU "!LST_FNAME!" (
                            Echo>>"!OPT_TMP!"         Echo "!LST_FNAME!"
                        ) Else (
                            Echo>>"!OPT_TMP!"         Echo "!LST_FNAME:~0,59!...!LST_FNAME:~-15!"
                        )
                        Echo>>"!OPT_TMP!"     !LST_REM! "%%configsetroot%%\!OPT_DRV!\!LST_SECTION!\!LST_FNAME!" !LST_CMD!
                    ) Else (
                        If /I "!LST_FNAME:~0,77!" EQU "!LST_FNAME!" (
                            Echo>>"!OPT_CMD!"         Echo "!LST_FNAME!"
                        ) Else (
                            Echo>>"!OPT_CMD!"         Echo "!LST_FNAME:~0,59!...!LST_FNAME:~-15!"
                        )
                        If /I "!LST_FNAME!" EQU "mpam-fe-!ARC_TYP!.exe" (Echo>>"!OPT_CMD!"         Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -o "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!.tmp" "!LST_FILE!" ^&^& Attrib -R "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" ^&^& Move "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!.tmp" "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!")
                        If /I "!LST_FNAME!" EQU "mpas-fe-!ARC_TYP!.exe" (Echo>>"!OPT_CMD!"         Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -o "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!.tmp" "!LST_FILE!" ^&^& Attrib -R "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" ^&^& Move "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!.tmp" "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!")
                        Echo>>"!OPT_CMD!" !LST_REM!     "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" !LST_CMD!
                        Set OPT_LST=!OPT_LST! "!LST_FNAME!"
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "wus" (
                    If /I "!LST_FNAME:~0,77!" EQU "!LST_FNAME!" (
                        Echo>>"!OPT_CMD!"         Echo "!LST_FNAME!"
                    ) Else (
                        Echo>>"!OPT_CMD!"         Echo "!LST_FNAME:~0,59!...!LST_FNAME:~-15!"
                    )
                    Echo>>"!OPT_CMD!" !LST_REM!     Wusa "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" !LST_CMD!
                    Set OPT_LST=!OPT_LST! "!LST_FNAME!"
                ) Else If /I "!LST_EXTENSION!" EQU "msi" (
                    If /I "!LST_FNAME:~0,77!" EQU "!LST_FNAME!" (
                        Echo>>"!OPT_CMD!"         Echo "!LST_FNAME!"
                    ) Else (
                        Echo>>"!OPT_CMD!"         Echo "!LST_FNAME:~0,59!...!LST_FNAME:~-15!"
                    )
                    Echo>>"!OPT_CMD!" !LST_REM!     msiexec /i "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" !LST_CMD!
                    Set OPT_LST=!OPT_LST! "!LST_FNAME!"
                ) Else If /I "!LST_EXTENSION!" EQU "cab" (
                           If /I "!LST_PACKAGE!" EQU "x64" (Rem
                    ) Else If /I "!LST_PACKAGE!" EQU "x86" (Rem
                    ) Else (
                        Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!LST_FNSRC!" "!WIM_IMG!\!OPT_DRV!\!LST_FNDST!" > Nul
                        If /I "!LST_FNAME:~0,77!" EQU "!LST_FNAME!" (
                            Echo>>"!OPT_TMP!"         Echo "!LST_FNAME!"
                        ) Else (
                            Echo>>"!OPT_TMP!"         Echo "!LST_FNAME:~0,59!...!LST_FNAME:~-15!"
                        )
                        If !WIN_VER! LEQ 7 (Echo>>"!OPT_TMP!" !LST_REM!     PnpUtil -i -a "%%configsetroot%%\!OPT_DRV!\!LST_FNDST!\*.inf"
                        ) Else             (Echo>>"!OPT_TMP!" !LST_REM!     PnpUtil /Add-Driver "%%configsetroot%%\!OPT_DRV!\!LST_FNDST!\*.inf" /SubDirs /Install
                        )
                    )
                )
            )
        )
    )
    If Exist "!OPT_TMP!" (
        Type "!OPT_TMP!" >> "!OPT_CMD!"
        Del /F "!OPT_TMP!"
    )
Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"         Echo === Step 1 end ================================================================
    If !OPT_SUB! NEQ 0 (
        Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
        Echo>>"!OPT_CMD!"     ^) Else ^(
    )
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"         Echo === Step 2 start ==============================================================
    Echo>>"!OPT_CMD!" Rem --- Trigger an update -----------------------------------------------------
    Echo>>"!OPT_CMD!"         If Exist "%%ProgramFiles%%\Microsoft Security Client" (
    Echo>>"!OPT_CMD!"             Echo --- Security Essentials -------------------------------------------------------
    Echo>>"!OPT_CMD!"             Set DIR_SECU=%%ProgramFiles%%\Microsoft Security Client
    Echo>>"!OPT_CMD!"         ) Else (
    Echo>>"!OPT_CMD!"             Echo --- Windows Defender ----------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem         SC Stop  WinDefend ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!" Rem         SC Start WinDefend ^> Nul 2^>^&1
    Echo>>"!OPT_CMD!"             Set DIR_SECU=%%ProgramFiles%%\Windows Defender
    Echo>>"!OPT_CMD!"         )
    Echo>>"!OPT_CMD!"         Pushd "^!DIR_SECU^!"
    Echo>>"!OPT_CMD!" Rem         MpCmdRun.exe -RemoveDefinitions -All
    Echo>>"!OPT_CMD!"             MpCmdRun.exe -SignatureUpdate
    Echo>>"!OPT_CMD!"         Popd
    Echo>>"!OPT_CMD!"         Echo === Step 2 end ================================================================
    If !OPT_SUB! NEQ 0 (
        Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
        Echo>>"!OPT_CMD!"     ^)
    )
    Echo>>"!OPT_CMD!" Rem --- Cleaning --------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem Del /F /S /Q "%%configsetroot%%" ^> Nul
    Echo>>"!OPT_CMD!" Rem For /D %%%%I In ("%%configsetroot%%\*") Do (RmDir /S /Q "%%%%~I" ^> Nul )
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" :DONE
    Echo>>"!OPT_CMD!"     EndLocal
    Echo>>"!OPT_CMD!"     Echo *** 作業終了 ******************************************************************
    Echo>>"!OPT_CMD!"     Echo ^%%DATE^%% ^%%TIME^%% End
    Echo>>"!OPT_CMD!" Rem Echo [Enter]を押下して下さい。
    Echo>>"!OPT_CMD!" Rem Pause > Nul 2>&1
    Echo>>"!OPT_CMD!" Rem Echo On
    Echo>>"!OPT_CMD!" Rem --- Reboot-----------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem Shutdown /r /t 3
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"     TimeOut /T 10 /NoBreak
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
Rem ---------------------------------------------------------------------------
    If Exist "!OPT_BAK!" (Del /F "!OPT_BAK!")

    For /D %%I In ("!WIM_PKB!\curl-*-win!CPU_BIT!-mingw") Do (
        Pushd "%%~I" || GoTo DONE
            For /R %%E In ("curl.exe*") Do (
                Set CUR_DIR=%%~dpE
                If /I "!CUR_DIR:~-1!" EQU "\" (Set CUR_DIR=!CUR_DIR:~0,-1!)
                Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!CUR_DIR!" "!WIM_IMG!\!OPT_BIN!" > Nul
            )
        Popd
    )

    If /I "!OPT_LST!" NEQ "" (
        Robocopy /J /A-:RHS /NDL /NFL /NC /NJH /NJS "!WIM_WUD!" "!WIM_IMG!\!OPT_PKG!" !OPT_LST! > Nul
    )

    If !FLG_DRV! EQU 1 (If !OPT_MSU! EQU 0 (GoTo MAKE_ISO_IMAGE))

Rem ---------------------------------------------------------------------------
:WIM_PACKAGE
Rem === Windows Update ファイル と ドライバー の統合 ==========================
    Set WIM_ADD=0
    Set WIM_PAC=/Image:^"!WIM_MNT!^" /Add-Package /IgnoreCheck
    Set WIM_DRV=/Image:^"!WIM_MNT!^" /Add-Driver /ForceUnsigned /Recurse
    Set BT1_PAC=/Image:^"!WIM_BT1!^" /Add-Package /IgnoreCheck
    Set BT1_DRV=/Image:^"!WIM_BT1!^" /Add-Driver /ForceUnsigned /Recurse
    Set BT2_PAC=/Image:^"!WIM_BT2!^" /Add-Package /IgnoreCheck
    Set BT2_DRV=/Image:^"!WIM_BT2!^" /Add-Driver /ForceUnsigned /Recurse
    Set WRE_PAC=/Image:^"!WIM_WRE!^" /Add-Package /IgnoreCheck
    Set WRE_DRV=/Image:^"!WIM_WRE!^" /Add-Driver /ForceUnsigned /Recurse

Rem --- lstファイルを分解する -------------------------------------------------
    Echo --- lstファイルを分解する -----------------------------------------------------
    Set CMD_WIM=!CMD_DAT!.wim
    Set CMD_WRE=!CMD_DAT!.wre
    If Exist "!CMD_WIM!" (Del /F "!CMD_WIM!")
    If Exist "!CMD_WRE!" (Del /F "!CMD_WRE!")
    For /F "tokens=1-11 usebackq delims=," %%I In ("!CMD_DAT!") Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE_NUM=%%~K
        Set LST_TYPE=%%~L
        Set LST_RUN_ORDER=%%~M
        Set LST_SECTION=%%~N
        Set LST_EXTENSION=%%~O
        Set LST_CMD=%%~P
        Set LST_RENAME=%%~Q
        Set LST_FILE=%%~R
        Set LST_COMMENT=%%~S
        For %%E In ("!LST_RENAME!") Do (
            Set LST_FNAME=%%~nxE
            Set LST_FDSRC=%%~dpE
            Set LST_FDSRC=!LST_FDSRC:~0,-1!
            Set LST_FNSRC=%%~dpnE
            Set LST_FNBAS=%%~nE
        )
        If /I "!LST_WINDOWS!" EQU "w!WIN_VER!" (
            If /I "!LST_PACKAGE!" EQU "adk" (Rem
            ) Else If /I "!LST_PACKAGE!" EQU "bin" (Rem
            ) Else If /I "!LST_PACKAGE!" EQU "drv" (
                For /F "tokens=2 usebackq delims=_" %%A in ('!LST_SECTION!') Do (
                    If /I "%%A" EQU "!ARC_TYP!" (
                        If /I "!LST_EXTENSION!" EQU "inf" (
                            If /I "!LST_FNAME!" EQU "iusb3hub.inf" (
                                Echo>>"!CMD_WRE!" !LST_RENAME!
                            )
                            If /I "!LST_FNAME!" EQU "iaAHCIC.inf"  (
                                Echo>>"!CMD_WRE!" !LST_RENAME!
                            )
                            If /I "!LST_FNAME!" EQU "IaNVMe.inf"   (
                                Echo>>"!CMD_WRE!" !WIM_WUD!\Windows6.1-KB2990941-v3-!ARC_TYP!.msu
                                Echo>>"!CMD_WRE!" !WIM_WUD!\Windows6.1-kb3087873-v2-!ARC_TYP!.msu
                                Echo>>"!CMD_WRE!" !LST_RENAME!
                            )
                        )
                    )
                )
            ) Else If /I "!LST_PACKAGE!" EQU "!ARC_TYP!" (
                If /I "!LST_EXTENSION!" EQU "msu" (
                    If /I "!LST_SECTION!" EQU "KB2533552" (
                        Set LST_FNLST=!LST_FNBAS:_= !
                        For /F "tokens=1 usebackq delims= " %%A In (`Echo !LST_FNLST!`) Do (Echo>>"!CMD_WIM!" !LST_FNSRC!\%%A)
                    ) Else (
                        Echo>>"!CMD_WIM!" !LST_RENAME!
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "exe" (
                    If /I "!LST_SECTION!" EQU "IE11" (
                        If /I "!LST_CMD!" EQU "" (
                            Echo>>"!CMD_WIM!" !WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\IE-Win7.CAB
                            Echo>>"!CMD_WIM!" !WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\ielangpack-ja-JP.CAB
                            Echo>>"!CMD_WIM!" !WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\IE-Spelling-en.MSU
                            Echo>>"!CMD_WIM!" !WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\IE-Hyphenation-en.MSU
                        )
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "cab" (
                    Echo>>"!CMD_WIM!" !LST_RENAME!
                )
            )
        )
    )

Rem --- イメージの取り出し ----------------------------------------------------
    Echo --- イメージの取り出し --------------------------------------------------------
    If Exist "!WIM_WIM!\install.wim" (Del "!WIM_WIM!\install.wim")
    Dism /Quiet /Export-Image /SourceImageFile:"!WIM_IMG!\sources\install.wim" /SourceName:"!WIN_TYP!" /DestinationImageFile:"!WIM_WIM!\install.wim" || GoTo :DONE
    Dism /Quiet /Mount-WIM /WimFile:"!WIM_WIM!\install.wim" /Name:"!WIN_TYP!" /MountDir:"!WIM_MNT!" || GoTo :DONE

Rem --- ドライバーの統合 ------------------------------------------------------
    If Exist "!CMD_WRE!" (
        Echo --- ドライバーの統合 ----------------------------------------------------------
        Set WIM_ADD=1

        Echo --- boot.wimを更新する [1] ----------------------------------------------------
        Dism /Quiet /Mount-WIM /WimFile:"!WIM_IMG!\sources\boot.wim" /Index:1 /MountDir:"!WIM_BT1!" || GoTo :DONE
        For /F "usebackq delims=" %%I In ("!CMD_WRE!") Do (
            Set FNAME=%%~I
            Set FDIRE=%%~dpI
            Set FDIRE=!FDIRE:~0,-1!
            Set FEXTE=%%~xI
            If /I "!FNAME:~0,77!" EQU "!FNAME!" (Echo "!FNAME!") Else (Echo "!FNAME:~0,59!...!FNAME:~-15!")
            If /I "!FEXTE!" EQU ".inf" (
                Dism /Quiet !BT1_DRV! /Driver:"!FDIRE!" || GoTo :DONE
            ) Else (
                Dism /Quiet !BT1_PAC! /PackagePath:"!FNAME!" || GoTo :DONE
            )
        )
        Echo --- boot.wimを保存する [1] ----------------------------------------------------
        Dism /Quiet /UnMount-Wim /MountDir:"!WIM_BT1!" /Commit || GoTo :DONE

        Echo --- boot.wimを更新する [2] ----------------------------------------------------
        Dism /Quiet /Mount-WIM /WimFile:"!WIM_IMG!\sources\boot.wim" /Index:2 /MountDir:"!WIM_BT2!" || GoTo :DONE
        For /F "usebackq delims=" %%I In ("!CMD_WRE!") Do (
            Set FNAME=%%~I
            Set FDIRE=%%~dpI
            Set FDIRE=!FDIRE:~0,-1!
            Set FEXTE=%%~xI
            If /I "!FNAME:~0,77!" EQU "!FNAME!" (Echo "!FNAME!") Else (Echo "!FNAME:~0,59!...!FNAME:~-15!")
            If /I "!FEXTE!" EQU ".inf" (
                Dism /Quiet !BT2_DRV! /Driver:"!FDIRE!" || GoTo :DONE
            ) Else (
                Dism /Quiet !BT2_PAC! /PackagePath:"!FNAME!" || GoTo :DONE
            )
        )
        Echo --- boot.wimを保存する [2] ----------------------------------------------------
        Dism /Quiet /UnMount-Wim /MountDir:"!WIM_BT2!" /Commit || GoTo :DONE

        Echo --- winRE.wimを更新する -------------------------------------------------------
Rem     Dism /Quiet /Mount-WIM /WimFile:"!WIM_WIM!\install.wim" /Name:"!WIN_TYP!" /MountDir:"!WIM_MNT!" || GoTo :DONE
        Dism /Quiet /Mount-WIM /WimFile:"!WIM_MNT!\Windows\System32\Recovery\winRE.wim" /Index:1 /MountDir:"!WIM_WRE!" || GoTo :DONE
        For /F "usebackq delims=" %%I In ("!CMD_WRE!") Do (
            Set FNAME=%%~I
            Set FDIRE=%%~dpI
            Set FDIRE=!FDIRE:~0,-1!
            Set FEXTE=%%~xI
            If /I "!FNAME:~0,77!" EQU "!FNAME!" (Echo "!FNAME!") Else (Echo "!FNAME:~0,59!...!FNAME:~-15!")
            If /I "!FEXTE!" EQU ".inf" (
                Dism /Quiet !WRE_DRV! /Driver:"!FDIRE!" || GoTo :DONE
                Dism /Quiet !WIM_DRV! /Driver:"!FDIRE!" || GoTo :DONE
            ) Else (
                Dism /Quiet !WRE_PAC! /PackagePath:"!FNAME!" || GoTo :DONE
                Dism /Quiet !WIM_PAC! /PackagePath:"!FNAME!" || GoTo :DONE
            )
        )
        Echo --- winRE.wimを保存する -------------------------------------------------------
        Dism /Quiet /UnMount-Wim /MountDir:"!WIM_WRE!" /Commit || GoTo :DONE
        Dism /Quiet /Commit-Image /MountDir:"!WIM_MNT!" || GoTo :DONE
Rem     Dism /Quiet /UnMount-Wim /MountDir:"!WIM_MNT!" /Commit || GoTo :DONE
    )

Rem --- install.wimを更新する -------------------------------------------------
    If Exist "!CMD_WIM!" (
        Echo --- install.wimを更新する -----------------------------------------------------
        Set WIM_ADD=1
Rem     Dism /Quiet /Mount-WIM /WimFile:"!WIM_WIM!\install.wim" /Name:"!WIN_TYP!" /MountDir:"!WIM_MNT!" || GoTo :DONE
        For /F "usebackq delims=" %%I In ("!CMD_WIM!") Do (
            Set FNAME=%%~I
            Set FDIRE=%%~dpI
            Set FDIRE=!FDIRE:~0,-1!
            Set FEXTE=%%~xI
            If /I "!FNAME:~0,77!" EQU "!FNAME!" (Echo "!FNAME!") Else (Echo "!FNAME:~0,59!...!FNAME:~-15!")
            If /I "!FEXTE!" EQU ".inf" (
                Dism /Quiet !WIM_DRV! /Driver:"!FDIRE!" || GoTo :DONE
            ) Else (
                Dism /Quiet !WIM_PAC! /PackagePath:"!FNAME!" || GoTo :DONE
            )
        )
        Echo --- install.wimを保存する -----------------------------------------------------
        Dism /Quiet /Commit-Image /MountDir:"!WIM_MNT!" || GoTo :DONE
Rem     Dism /Quiet /UnMount-Wim /MountDir:"!WIM_MNT!" /Commit || GoTo :DONE
    )

Rem --- イメージの結合 --------------------------------------------------------
Rem Dism /Quiet /Mount-WIM /WimFile:"!WIM_WIM!\install.wim" /Name:"!WIN_TYP!" /MountDir:"!WIM_MNT!" || GoTo :DONE
    If !WIM_ADD! NEQ 0 (
        Echo --- イメージの結合 ------------------------------------------------------------
        If /I "!LST_OPT!" EQU "" (
            Dism /Quiet /Append-Image /ImageFile:"!WIM_IMG!\sources\install.wim" /CaptureDir:"!WIM_MNT!" /Name:"!WIN_TYP! custom" /Description:"!WIN_TYP! custom" || GoTo :DONE
        ) Else (
            Dism /Quiet /Append-Image /ImageFile:"!WIM_IMG!\sources\install.wim" /CaptureDir:"!WIM_MNT!" /Name:"!WIN_TYP! !LST_OPT!" /Description:"!WIN_TYP! !LST_OPT!" || GoTo :DONE
        )
    )
    Dism /Quiet /Unmount-Image /MountDir:"!WIM_MNT!" /Discard || GoTo :DONE

:MAKE_ISO_IMAGE
Rem === DVDイメージを作成する =================================================
    Echo --- DVDイメージを作成する -----------------------------------------------------
    If !FLG_SPL! EQU 1 (
        For %%I In ("!WIM_IMG!\sources\install.wim") Do (Set WIM_SIZ=%%~zI)
        If !WIM_SIZ! GEQ 4294967296 (
            Echo --- ファイル分割 --------------------------------------------------------------
            Dism /Quiet /Split-Image /ImageFile:"!WIM_IMG!\sources\install.wim" /SWMFile:"!WIM_IMG!\sources\install.swm" /FileSize:4095 || GoTo DONE
            Move /Y "!WIM_IMG!\sources\install.wim" "!WIM_BAK!" > Nul || GoTo DONE
        )
    )
    If Exist "!WIM_IMG!\efi\boot" (
        Set MAK_IMG=-m -o -u1 -h -l!DVD_VOL! -bootdata:2#p0,e,b"!WIM_IMG!\boot\etfsboot.com"#pEF,e,b"!WIM_IMG!\efi\microsoft\boot\efisys.bin"
    ) Else (
        Set MAK_IMG=-m -o -u1 -h -l!DVD_VOL! -bootdata:1#p0,e,b"!WIM_IMG!\boot\etfsboot.com"
    )
    Oscdimg !MAK_IMG! "!WIM_IMG!" "!DVD_DST!" || GoTo :DONE

Rem --- 作業ファイルの削除 ----------------------------------------------------
    If Exist "!CMD_DAT!" (Del /F "!CMD_DAT!" || GoTo DONE)
    If Exist "!CMD_WRK!" (Del /F "!CMD_WRK!" || GoTo DONE)
    If Exist "!CMD_DUP!" (Del /F "!CMD_DUP!" || GoTo DONE)
    If Exist "!CMD_WIM!" (Del /F "!CMD_WIM!" || GoTo DONE)
    If Exist "!CMD_WRE!" (Del /F "!CMD_WRE!" || GoTo DONE)

    Echo --- 作業ファイルの削除 --------------------------------------------------------
    Echo "!WIM_IMG!"
    Set INP_ANS=Y
    If !FLG_BAT! EQU 0 (Set /P INP_ANS= 上記フォルダーのファイルを削除しますか？ [Y/N] ^(Yes/No^)（規定値[!INP_ANS!]）)
    If /I "!INP_ANS!" EQU "Y" (
        For /D %%I In (!WIM_NOW!\*) Do (RmDir /S /Q "%%~I" > Nul)
        RmDir /S /Q "!WIM_NOW!" > Nul
    )

    GoTo EXIT

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
