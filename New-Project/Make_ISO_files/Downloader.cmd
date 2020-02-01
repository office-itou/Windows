Rem ***************************************************************************
@Echo Off
Rem Cls

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
            GoTo :DONE
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
Rem --- 環境変数設定 ----------------------------------------------------------
    Set WIN_VER=%~1
    Set LST_PKG=%~2
    Set WIM_TOP=%~3
    Set WIM_BIN=%WIM_TOP%\bin
    Set WIM_CFG=%WIM_TOP%\cfg
    Set WIM_ISO=%WIM_TOP%\iso
    Set WIM_LST=%WIM_TOP%\lst
    Set WIM_PKG=%WIM_TOP%\pkg
    Set WIM_USR=%WIM_TOP%\usr
    Set WIM_WRK=%WIM_TOP%\wrk
    Set CMD_DAT=%WIM_WRK%\!WRK_NAM!.dat
    Set CMD_WRK=%WIM_WRK%\!WRK_NAM!.wrk

    If /I "%WIN_VER%" EQU "" (
        Echo 引数1[WIN_VER]が設定されていません。
        GoTo DONE
    )

    If /I "%LST_PKG%" EQU "" (
        Echo 引数2[LST_PKG]が設定されていません。
        GoTo DONE
    )

    If /I "%WIM_TOP%" EQU "" (
        Echo 引数3[WIM_TOP]が設定されていません。
        GoTo DONE
    )

Rem --- 作業ファイルの削除 ----------------------------------------------------
    If Exist "%CMD_DAT%" (Del /F "%CMD_DAT%" || GoTo DONE)
    If Exist "%CMD_WRK%" (Del /F "%CMD_WRK%" || GoTo DONE)

Rem *** ファイルダウンロード **************************************************
Rem --- リストファイル変換 ----------------------------------------------------
    Echo --- リストファイル変換 --------------------------------------------------------
    Set LST_FIL=
    For %%I In (%WIN_VER%) Do (
        For %%J In (%LST_PKG%) Do (
            Set LST_WINVER=%%~I
            Set LST_PACKAGE=%%~J
            Set LST_LFNAME=%WIM_LST%\Windows!LST_WINVER!!LST_PACKAGE!*.lst
            Set LST_WINPACK=%WIM_PKG%\w!LST_WINVER!\!LST_PACKAGE!
            Set LST_SECTION=
            For %%K In (!LST_LFNAME!) Do (
                For /F "delims== tokens=1,2* usebackq" %%L In (%%~K) Do (
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
                            Echo>>"%CMD_WRK%" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
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
                    If /I "!LST_SECTION!" NEQ "" (
                        If /I "!LST_RENAME!" EQU "" (For %%E In ("!LST_FILE!")   Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE&Set LST_RENAME=%%~nxE)
                        ) Else                      (For %%E In ("!LST_RENAME!") Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE)
                        )
                        If /I "!LST_RUN_ORDER!" EQU "" (Set LST_RUN_ORDER=000)
                        Set LST_RENAME=!LST_WINPACK!\!LST_RENAME!
                        Set LST_EXTENSION=!LST_EXTENSION:~1!
                        If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                        Echo>>"%CMD_WRK%" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
                    )
                )
            )
        )
    )
Rem --- ファイルソート --------------------------------------------------------
    Sort "%CMD_WRK%" > "%CMD_DAT%"
Rem --- ファイル取得 ----------------------------------------------------------
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
        Set LST_WINPKG=%WIM_PKG%\!LST_WINDOWS!
        For %%E In ("!LST_RENAME!") Do (Set LST_FNAME=%%~nxE)
        For /F "delims=: tokens=2 usebackq" %%X In ('!LST_FILE!') Do (
            If /I "%%X" NEQ "" (
                If Not Exist "!LST_RENAME!" (
                    Echo "!LST_FNAME!"
                    Curl -L -# -R -S -f --create-dirs -o "!LST_RENAME!" "!LST_FILE!" || GoTo DONE
                ) Else (
                    For /F "delims=: tokens=2 usebackq" %%Y In (`Curl -L -s -R -S -I "!LST_FILE!" ^| Find /I "Content-Length:"`) Do (
                        Set LST_LEN=%%Y
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

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
Rem Echo [Enter]を押下して下さい。
Rem Pause > Nul 2>&1
Rem Echo On
