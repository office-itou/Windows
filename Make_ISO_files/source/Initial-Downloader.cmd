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

    For /F "tokens=2 usebackq delims=\" %%I In ('!WRK_DIR!') Do (Set WRK_TOP=%%~dI\%%~I)

:SETTING
Rem *** 作業環境設定 **********************************************************
    Set DEF_TOP=C:\WimWK

    If /I "!WRK_TOP!" EQU "!DEF_TOP!" (
        Set WIM_TOP=!DEF_TOP!
    ) Else (
:INP_FOLDER
        Set WIM_TOP=!DEF_TOP!
        Set /P WIM_TOP=作業環境のフォルダーを指定して下さい。（規定値[!WIM_TOP!]）
        If /I "!WIM_TOP!" EQU "" (Set WIM_TOP=C:\WimWK)

        Set INP_ANS=N
        Echo "!WIM_TOP!"
        Set /P INP_ANS=上記でよろしいですか？ [Y/N] ^(Yes/No^)（規定値[!INP_ANS!]）
        If /I "!INP_ANS!" NEQ "Y" (GoTo INP_FOLDER)
    )

    Set CUR_DIR=%CD%
Rem CD "!WIM_TOP!"

Rem --- 環境変数設定 ----------------------------------------------------------
    Set WIN_VER=7 8.1 10
    Set ARC_TYP=x86 x64
    Set LST_PKG=adk bin drv !ARC_TYP!
Rem Set WIM_TOP=C:\WimWK
    Set WIM_BIN=!WIM_TOP!\bin
    Set WIM_CFG=!WIM_TOP!\cfg
    Set WIM_ISO=!WIM_TOP!\iso
    Set WIM_LST=!WIM_TOP!\lst
    Set WIM_PKG=!WIM_TOP!\pkg
    Set WIM_USR=!WIM_TOP!\usr
    Set WIM_WRK=!WIM_TOP!\wrk

    Set CMD_DAT=!WIM_WRK!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!.dat
    Set CMD_WRK=!WIM_WRK!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!.wrk

    Set BAK_TOP=!WIM_WRK!\!NOW_DAY!!NOW_TIM!
    Set BAK_BIN=!BAK_TOP!\bin
    Set BAK_CFG=!BAK_TOP!\cfg
    Set BAK_ISO=!BAK_TOP!\iso
    Set BAK_LST=!BAK_TOP!\lst
    Set BAK_PKG=!BAK_TOP!\pkg
    Set BAK_USR=!BAK_TOP!\usr
    Set BAK_WRK=!BAK_TOP!\wrk

    Set MOV_WIM=!WIM_TOP!.!NOW_DAY!!NOW_TIM!
    Set MOV_ISO=!MOV_WIM!\iso

    Set GIT_TOP=https://raw.githubusercontent.com/office-itou/Windows/master/Make_ISO_files/source
    Set GIT_URL=%GIT_TOP%/Initial-Downloader.lst
    Set GIT_FIL=!WRK_DIR!\!WRK_NAM!.lst
    Set GIT_WIM=!WIM_LST!\!WRK_NAM!.lst

    Set UTL_ARC=amd64 arm arm64 x86

Rem --- 作業フォルダーの作成 --------------------------------------------------
    Echo *** 作業フォルダーの作成 ******************************************************
Rem --- 破損イメージの削除 ----------------------------------------------------
    For %%I In (!WIN_VER!) Do (
        For %%J In (!ARC_TYP!) Do (
            Set WIM_IMG=!WIM_WRK!\w%%~I\%%~J\img
            Set WIM_MNT=!WIM_WRK!\w%%~I\%%~J\mnt
            Set WIM_WRE=!WIM_WRK!\w%%~I\%%~J\wre
            If Exist "!WIM_WRE!\Windows" (Dism /UnMount-Wim /MountDir:"!WIM_WRE!" /Discard)
            If Exist "!WIM_MNT!\Windows" (Dism /UnMount-Wim /MountDir:"!WIM_MNT!" /Discard)
        )
    )

Rem --- 既存フォルダーの移動 --------------------------------------------------
    If Exist "!WIM_TOP!" (
        Set INP_ANS=N
        Set /P INP_ANS=既存フォルダーがありますが上書きしますか？ [Y/N] ^(Yes/No^)（規定値[!INP_ANS!]）
        If /I "!INP_ANS!" EQU "Y" (
            Echo *** 既存フォルダーのバックアップ **********************************************
            Robocopy /J /MIR /A-:RHS /NDL "!WIM_BIN!" "!BAK_BIN!" > Nul
            Robocopy /J /MIR /A-:RHS /NDL "!WIM_CFG!" "!BAK_CFG!" > Nul
            Robocopy /J /MIR /A-:RHS /NDL "!WIM_LST!" "!BAK_LST!" > Nul
Rem         Robocopy /J /MIR /A-:RHS /NDL "!WIM_PKG!" "!BAK_PKG!" > Nul
            Echo !BAK_TOP! にバックアップしました。
        ) Else (
            If /I "!WRK_DIR!" EQU "!WIM_BIN!" (
                Echo 以下のフォルダーで作業中のため実行を中止します。
                Echo "!WIM_BIN!"
                GoTo DONE
            )
            Echo *** 既存フォルダーの移動 ******************************************************
            Echo 既存フォルダーを以下の名前に移動します。
            Echo "!WIM_TOP!"
            Echo      ↓↓
            Echo "!MOV_WIM!"
            Move "!WIM_TOP!" "!MOV_WIM!" || GoTo DONE
            If Not Exist "!WIM_TOP!" (MkDir "!WIM_TOP!" || GoTo DONE)
            If Exist "!MOV_ISO!" (Move "!MOV_ISO!" "!WIM_ISO!" || GoTo DONE)
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
            Set WIM_DRV=!WIM_PKG!\w%%~I\drv
            Set WIM_WUD=!WIM_PKG!\w%%~I\%%~J
            Set WIM_CAB=!WIM_PKG!\w%%~I\%%~J\cab
            Set WIM_BAK=!WIM_WRK!\w%%~I\%%~J\bak
            Set WIM_EFI=!WIM_WRK!\w%%~I\%%~J\efi
            Set WIM_IMG=!WIM_WRK!\w%%~I\%%~J\img
            Set WIM_MNT=!WIM_WRK!\w%%~I\%%~J\mnt
            Set WIM_WRE=!WIM_WRK!\w%%~I\%%~J\wre

            If !FLG_DEL! EQU 0 (
                If     Exist "!WIM_IMG!" (RmDir /S /Q "!WIM_IMG!" || GoTo DONE)
            )

            If     Exist "!WIM_MNT!" (RmDir /S /Q "!WIM_MNT!" || GoTo DONE)
            If     Exist "!WIM_WRE!" (RmDir /S /Q "!WIM_WRE!" || GoTo DONE)

            If Not Exist "!WIM_WUD!" (MkDir       "!WIM_WUD!" || GoTo DONE)
            If Not Exist "!WIM_CAB!" (MkDir       "!WIM_CAB!" || GoTo DONE)
            If Not Exist "!WIM_BAK!" (MkDir       "!WIM_BAK!" || GoTo DONE)
            If Not Exist "!WIM_EFI!" (MkDir       "!WIM_EFI!" || GoTo DONE)
            If Not Exist "!WIM_IMG!" (MkDir       "!WIM_IMG!" || GoTo DONE)
            If Not Exist "!WIM_MNT!" (MkDir       "!WIM_MNT!" || GoTo DONE)
            If Not Exist "!WIM_WRE!" (MkDir       "!WIM_WRE!" || GoTo DONE)
        )
    )

Rem --- 作業ファイルの削除 ----------------------------------------------------
    If Exist "!CMD_DAT!" (Del /F "!CMD_DAT!" || GoTo DONE)
    If Exist "!CMD_WRK!" (Del /F "!CMD_WRK!" || GoTo DONE)

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
            Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!UTL_SRC!" "!UTL_DST!"
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
        If !FLG_IMG! EQU 1 (
            GoTo MAKE_ISO_IMAGE
        )
    )

Rem *** ファイルダウンロード **************************************************
Rem --- GitHub ----------------------------------------------------------------
    Echo --- GitHub --------------------------------------------------------------------
Rem --- GitHub ダウンロードファイル -------------------------------------------
    Set INP_ANS=
    If Exist "!GIT_FIL!" (
        Echo "!GIT_FIL!"
        Set /P INP_ANS=上記を使用しますか？ [Y/N] ^(Yes/No^)
    )
    If /I "!INP_ANS!" EQU "Y" (
        Copy /Y "!GIT_FIL!" "!GIT_WIM!" > Nul
    ) Else (
        Curl -L -# -R -S -f --create-dirs --connect-timeout 60 --max-time 7200 --retry 5 -o "!GIT_WIM!" "%GIT_URL%" || GoTo DONE
    )
    If Not Exist "!GIT_WIM!" (
        Echo 以下のファイルが無いため実行を中止します。
        Echo "!GIT_WIM!"
        GoTo DONE
    )
    For /F %%I In (!GIT_WIM!) Do (
        Set URL_LST=%%~I
        Set URL_FIL=%%~nxI
        Set URL_EXT=%%~xI
        Set URL_EXT=!URL_EXT:~1!
               If /I "!URL_EXT!" EQU "cmd" (Set WIM_DIR=!WIM_BIN!
        ) Else If /I "!URL_EXT!" EQU "url" (Set WIM_DIR=!WIM_BIN!
        ) Else If /I "!URL_EXT!" EQU "xml" (Set WIM_DIR=!WIM_CFG!
        ) Else If /I "!URL_EXT!" EQU "lst" (Set WIM_DIR=!WIM_LST!
        ) Else                             (Set WIM_DIR=!WIM_WRK!
        )
        If /I "!WRK_DIR!" EQU "!WIM_BIN!" If /I "!URL_FIL!" EQU "!WRK_FIL!" (
            Set URL_FIL=!URL_FIL!.!NOW_DAY!!NOW_TIM!
        )
Rem     If Not Exist "!WIM_DIR!\!URL_FIL!" (
            Echo "!URL_FIL!"
            Curl -L -# -R -S -f --create-dirs --connect-timeout 60 --max-time 7200 --retry 5 -o "!WIM_DIR!\!URL_FIL!" "%%~I" || GoTo DONE
Rem     )
    )

Rem --- User Custom file ------------------------------------------------------
Rem If Exist "!WIM_USR!" (
Rem     Echo --- User Custom file ----------------------------------------------------------
Rem     If Exist "*.cmd" (Copy /Y "*.cmd" "!WIM_BIN!" > Nul)
Rem     If Exist "*.url" (Copy /Y "*.url" "!WIM_BIN!" > Nul)
Rem     If Exist "*.xml" (Copy /Y "*.xml" "!WIM_CFG!" > Nul)
Rem     If Exist "*.lst" (Copy /Y "*.lst" "!WIM_LST!" > Nul)
Rem )

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
                                    Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE_NUM!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
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
                            Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE_NUM!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
                        )
                    )
                )
            )
        )
    )

Rem --- ファイルソート --------------------------------------------------------
    Sort "!CMD_WRK!" > "!CMD_DAT!"

Rem *** ファイル取得 **********************************************************
    Echo --- ファイル取得 --------------------------------------------------------------
    For /F "tokens=1-10 usebackq delims=," %%I In ("!CMD_DAT!") Do (
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
                       Curl -L -s -S -f --connect-timeout 60    --dump-header "!CMD_WRK!" "!LST_FILE!" ^
                    || Curl -L -s -S -f --connect-timeout 60 -k --dump-header "!CMD_WRK!" "!LST_FILE!"
                    Set LST_LEN=0
                    For /F "tokens=1,2* usebackq delims=:" %%Y In ("!CMD_WRK!") Do (
                        If /I "%%~Y" EQU "Content-Length" (Set LST_LEN=%%~Z)
                    )
                    For /F "usebackq delims=/" %%Z In ('!LST_RENAME!') Do (Set LST_SIZE=%%~zZ)
                    If !LST_LEN! NEQ !LST_SIZE! (
                        If /I "!LST_FNAME:~0,77!" EQU "!LST_FNAME!" (Echo "!LST_FNAME!") Else (Echo "!LST_FNAME:~0,59!...!LST_FNAME:~-15!")
                           Curl -L -# -R -S -f --create-dirs --connect-timeout 60    -o "!LST_RENAME!" "!LST_FILE!" ^
                        || Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -k -o "!LST_RENAME!" "!LST_FILE!" ^
                        || GoTo DONE
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
                    For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                    If Not Exist "!LST_DIR!" (
                        Echo --- ファイル展開 --------------------------------------------------------------
                        MkDir "!LST_DIR!"
                        Expand "!LST_RENAME!" -F:* "!LST_DIR!" > Nul || GoTo DONE
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
                            Set LST_FCAB=!LST_FPATH!\!LST_FNAME!
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

Rem --- 作業ファイルの削除 ----------------------------------------------------
    If Exist "!CMD_DAT!" (Del /F "!CMD_DAT!" || GoTo DONE)
    If Exist "!CMD_WRK!" (Del /F "!CMD_WRK!" || GoTo DONE)

Rem *** 作業終了 **************************************************************
:DONE
Rem CD "!CUR_DIR!"
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
