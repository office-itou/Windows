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

Rem *** 作業環境設定 **********************************************************
:INP_FOLDER
    Set WIM_TOP=C:\WimWK
    Set /P WIM_TOP=作業環境のフォルダーを指定して下さい。（規定値[!WIM_TOP!]）
    If /I "!WIM_TOP!" EQU "" (Set WIM_TOP=C:\WimWK)

    Set INP_ANS=N
    Echo "!WIM_TOP!"
    Set /P INP_ANS=上記でよろしいですか？ [Y/N] ^(Yes/No^)（規定値[!INP_ANS!]）
    If /I "!INP_ANS!" NEQ "Y" (GoTo INP_FOLDER)

Rem --- 環境変数設定 ----------------------------------------------------------
    Set WIN_VER=7 10
    Set ARC_TYP=x86 x64
    Set LST_PKG=adk drv zip %ARC_TYP%
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

    Set BAK_WIM=!WIM_WRK!\!NOW_DAY!!NOW_TIM!
    Set BAK_BIN=!BAK_TOP!\bin
    Set BAK_CFG=!BAK_TOP!\cfg
    Set BAK_ISO=!BAK_TOP!\iso
    Set BAK_LST=!BAK_TOP!\lst
    Set BAK_PKG=!BAK_TOP!\pkg
    Set BAK_USR=!BAK_TOP!\usr
    Set BAK_WRK=!BAK_TOP!\wrk

    Set MOV_WIM=!WIM_TOP!.!NOW_DAY!!NOW_TIM!
    Set MOV_ISO=!MOV_WIM!\iso

    Set GIT_TOP=https://raw.githubusercontent.com/office-itou/Windows/master/New-Project/Make_ISO_files/source
    Set GIT_URL=%GIT_TOP%/Initial-Downloader.lst
    Set GIT_FIL=!WRK_DIR!\!WRK_NAM!.lst
    Set GIT_WIM=!WIM_LST!\!WRK_NAM!.lst

    Set UTL_ARC=amd64 arm arm64 x86

Rem --- 破損イメージの削除 ----------------------------------------------------
    For %%I In (%WIN_VER%) Do (
        For %%J In (%ARC_TYP%) Do (
            Set WIM_IMG=!WIM_WRK!\w%%I\%%J\img
            Set WIM_MNT=!WIM_WRK!\w%%I\%%J\mnt
            Set WIM_WRE=!WIM_WRK!\w%%I\%%J\wre
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
            Echo !BAK_WIM! にバックアップしました。
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

Rem --- 作業フォルダーの作成 --------------------------------------------------
    Echo *** 作業フォルダーの作成 ******************************************************
Rem --- 破損イメージの削除 ----------------------------------------------------
    For %%I In (%WIN_VER%) Do (
        For %%J In (%ARC_TYP%) Do (
            Set WIM_IMG=!WIM_WRK!\w%%I\%%J\img
            Set WIM_MNT=!WIM_WRK!\w%%I\%%J\mnt
            Set WIM_WRE=!WIM_WRK!\w%%I\%%J\wre
            If Exist "!WIM_WRE!\Windows" (Dism /UnMount-Wim /MountDir:"!WIM_WRE!" /Discard)
            If Exist "!WIM_MNT!\Windows" (Dism /UnMount-Wim /MountDir:"!WIM_MNT!" /Discard)
        )
    )

    If Not Exist "!WIM_BIN!" (MkDIr "!WIM_BIN!" || GoTo DONE)
    If Not Exist "!WIM_CFG!" (MkDIr "!WIM_CFG!" || GoTo DONE)
    If Not Exist "!WIM_LST!" (MkDIr "!WIM_LST!" || GoTo DONE)
    If Not Exist "!WIM_PKG!" (MkDIr "!WIM_PKG!" || GoTo DONE)
    If Not Exist "!WIM_USR!" (MkDIr "!WIM_USR!" || GoTo DONE)
    If Not Exist "!WIM_WRK!" (MkDIr "!WIM_WRK!" || GoTo DONE)

    For %%I In (%WIN_VER%) Do (
        For %%J In (%ARC_TYP%) Do (
            Set WIM_DRV=!WIM_PKG!\w%%I\drv
            Set WIM_WUD=!WIM_PKG!\w%%I\%%J
            Set WIM_BAK=!WIM_WRK!\w%%I\%%J\bak
            Set WIM_EFI=!WIM_WRK!\w%%I\%%J\efi
            Set WIM_IMG=!WIM_WRK!\w%%I\%%J\img
            Set WIM_MNT=!WIM_WRK!\w%%I\%%J\mnt
            Set WIM_WRE=!WIM_WRK!\w%%I\%%J\wre
            If Not Exist "!WIM_WUD!" (MkDir "!WIM_WUD!" || GoTo DONE)
            If Not Exist "!WIM_BAK!" (MkDir "!WIM_BAK!" || GoTo DONE)
            If Not Exist "!WIM_EFI!" (MkDir "!WIM_EFI!" || GoTo DONE)
            If Not Exist "!WIM_IMG!" (MkDir "!WIM_IMG!" || GoTo DONE)
            If Not Exist "!WIM_MNT!" (MkDir "!WIM_MNT!" || GoTo DONE)
            If Not Exist "!WIM_WRE!" (MkDir "!WIM_WRE!" || GoTo DONE)
        )
    )

Rem --- 作業ファイルの削除 ----------------------------------------------------
    If Exist "!CMD_DAT!" (Del /F "!CMD_DAT!" || GoTo DONE)
    If Exist "!CMD_WRK!" (Del /F "!CMD_WRK!" || GoTo DONE)

Rem --- Oscdimg取得 -----------------------------------------------------------
    Echo --- Oscdimg取得 ---------------------------------------------------------------
    For /R "%ProgramFiles(x86)%" %%I In (Oscdimg.exe*) Do (Set UTL_WRK=%%~dpI)
    If /I "!UTL_WRK!" EQU "" (
        Echo Windows ADK をインストールして下さい。
        GoTo DONE
    )
    For %%I In (%UTL_ARC%) DO (
        Set UTL_SRC=!UTL_WRK!\..\..\%%~I\Oscdimg
        Set UTL_DST=!WIM_BIN!\Oscdimg\%%~I
        Robocopy /J /MIR /A-:RHS /NDL "!UTL_SRC!" "!UTL_DST!" > Nul
    )

Rem --- Oscdimgのパスを設定する -----------------------------------------------
    Set Path=!WIM_BIN!\Oscdimg\%PROCESSOR_ARCHITECTURE%;%Path%
    Oscdimg > NUL 2>&1
    If "%ErrorLevel%" EQU "9009" (
        Echo Windows ADK をインストールして下さい。
        GoTo DONE
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
        Curl -L -# -R -S -f --create-dirs -o "!GIT_WIM!" "%GIT_URL%" || GoTo DONE
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
            Curl -L -# -R -S -f --create-dirs -o "!WIM_DIR!\!URL_FIL!" "%%I" || GoTo DONE
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

Rem *** リストファイル変換 ****************************************************
    Echo --- リストファイル変換 --------------------------------------------------------
    Set LST_FIL=
    For %%I In (%WIN_VER%) Do (
        Set LST_WINVER=%%~I
        For %%J In (!LST_PKG!) Do (
            Set LST_PACKAGE=%%~J
            Set LST_LFSNAME=!WIM_LST!\Windows!LST_WINVER!!LST_PACKAGE!*.lst
            Set LST_WINPACK=!WIM_PKG!\w!LST_WINVER!\!LST_PACKAGE!
            Set LST_SECTION=
            For %%K In (!LST_LFSNAME!) Do (
                Set LST_LFNAME=%%~K
                For /F "delims== tokens=1* usebackq" %%L In (!LST_LFNAME!) Do (
                    Set LST_KEY=%%~L
                    Set LST_VAL=%%~M
                    If /I "!LST_KEY:~0,1!!LST_KEY:~-1,1!" EQU "[]" (
                        If /I "!LST_SECTION!" EQU "INFO" (Set LST_SECTION=)
                        If /I "!LST_SECTION!" EQU "LIST" (Set LST_SECTION=)
                        If /I "!LST_SECTION!" NEQ "" (
                            If /I "!LST_RENAME!" EQU "" (For %%E In ("!LST_FILE!")   Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE&Set LST_RENAME=%%~nxE)
                            ) Else                      (For %%E In ("!LST_RENAME!") Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE)
                            )
                            If /I "!LST_RUN_ORDER!" EQU "" (Set LST_RUN_ORDER=000)
                            Set LST_RENAME=!LST_WINPACK!\!LST_RENAME!
                            Set LST_EXTENSION=!LST_EXTENSION:~1!
                            If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                            Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
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
                    )
                    If /I "!LST_SECTION!" NEQ "" (
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
                    )
                )
                If /I "!LST_SECTION!" NEQ "" (
                    If /I "!LST_RENAME!" EQU "" (For %%E In ("!LST_FILE!")   Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE&Set LST_RENAME=%%~nxE)
                    ) Else                      (For %%E In ("!LST_RENAME!") Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE)
                    )
                    If /I "!LST_RUN_ORDER!" EQU "" (Set LST_RUN_ORDER=000)
                    Set LST_RENAME=!LST_WINPACK!\!LST_RENAME!
                    Set LST_EXTENSION=!LST_EXTENSION:~1!
                    If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                    Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
                )
            )
        )
    )

Rem --- ファイルソート --------------------------------------------------------
    Sort "!CMD_WRK!" > "!CMD_DAT!"

Rem *** ファイル取得 **********************************************************
    Echo --- ファイル取得 --------------------------------------------------------------
    For /F "delims=, tokens=1-9 usebackq" %%I In (!CMD_DAT!) Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE=%%~K
        Set LST_RUN_ORDER=%%~L
        Set LST_SECTION=%%~M
        Set LST_EXTENSION=%%~N
        Set LST_CMD=%%~O
        Set LST_RENAME=%%~P
        Set LST_FILE=%%~Q
        Set LST_WINPKG=!WIM_PKG!\!LST_WINDOWS!
        For %%E In ("!LST_RENAME!") Do (Set LST_FNAME=%%~nxE)
        For /F "delims=: tokens=2 usebackq" %%X In ('!LST_FILE!') Do (
            If /I "%%X" NEQ "" (
                If Not Exist "!LST_RENAME!" (
                    Echo "!LST_FNAME!"
                    Curl -L -# -R -S -f --create-dirs -o "!LST_RENAME!" "!LST_FILE!" || GoTo DONE
                ) Else (
                    Curl -L -s --dump-header "!CMD_WRK!" "!LST_FILE!"
                    Set LST_LEN=0
                    For /F "delims=: tokens=1,2* usebackq" %%Y In ("!CMD_WRK!") Do (
                        If /I "%%~Y" EQU "Content-Length" (
                            Set LST_LEN=%%~Z
                        )
                    )
                    For /F "delims=/ usebackq" %%Z In ('!LST_RENAME!') Do (Set LST_SIZE=%%~zZ)
                    If !LST_LEN! NEQ !LST_SIZE! (
                        Echo "!LST_FNAME!" : !LST_SIZE! : !LST_LEN!
                        Curl -L -# -R -S -f --create-dirs -o "!LST_RENAME!" "!LST_FILE!" || GoTo DONE
                    )
                )
                If /I "!LST_EXTENSION!" EQU "zip" (
                    For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                    If Not Exist "!LST_DIR!" (
                        Echo --- ファイル展開 --------------------------------------------------------------
                        MkDir "!LST_DIR!"
                        Tar -xzf "!LST_RENAME!" -C "!LST_DIR!"
                    )
                    Pushd "!LST_DIR!"
                        For /R %%E In (*.zip) Do (
                            Set LST_ZIPFILE=%%E
                            Set LST_ZIPDIR=%%~dpnE
                            If Not Exist "!LST_ZIPDIR!" (
                                Echo --- ファイル展開 --------------------------------------------------------------
                                MkDir "!LST_ZIPDIR!"
                                Tar -xzf "!LST_ZIPFILE!" -C "!LST_ZIPDIR!"
                            )
                            Pushd "!LST_ZIPDIR!"
                                For /R %%F In (*.msu) Do (
                                    For /F "delims=x tokens=2" %%G In ("%%~nF") Do (Set LST_PACKAGE=%%G)
                                    If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!\%%~nxF" (
                                        Echo --- ファイル転送 --------------------------------------------------------------
                                        If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!" (MkDir "!LST_WINPKG!\x!LST_PACKAGE!")
                                        Copy /Y "%%F" "!LST_WINPKG!\x!LST_PACKAGE!" > Nul
                                    )
                                )
                            Popd
                        )
                        For /R %%F In (*.msu) Do (
                            For /F "delims=x tokens=2" %%G In ("%%~nF") Do (Set LST_PACKAGE=%%G)
                            If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!\%%~nxF" (
                                Echo --- ファイル転送 --------------------------------------------------------------
                                If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!" (MkDir "!LST_WINPKG!\x!LST_PACKAGE!")
                                Copy /Y "%%F" "!LST_WINPKG!\x!LST_PACKAGE!" > Nul
                            )
                        )
                    Popd
                ) Else If /I "!LST_SECTION!" EQU "IE11" (
                    For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                    If Not Exist "!LST_DIR!" (
                        Echo --- ファイル展開 --------------------------------------------------------------
                        MkDir "!LST_DIR!"
                        "!LST_RENAME!" /x:"!LST_DIR!"
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
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
