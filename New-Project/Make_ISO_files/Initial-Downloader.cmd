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
:INP_FOLDER
    Set WIM_TOP=C:\WimWK
    Set /P WIM_TOP=作業環境のフォルダーを指定して下さい。（規定値[%WIM_TOP%]）
    If /I "%WIM_TOP%" EQU "" (Set WIM_TOP=C:\WimWK)

    Set INP_ANS=
    Echo "%WIM_TOP%"
    Set /P INP_ANS=上記でよろしいですか？ [Y/N] ^(Yes/No^)
    If /I "!INP_ANS!" NEQ "Y" (GoTo INP_FOLDER)

Rem --- 環境変数設定 ----------------------------------------------------------
    Set WIN_VER=7 10
Rem Set WIM_TOP=C:\WimWK
    Set WIM_BIN=%WIM_TOP%\bin
    Set WIM_CFG=%WIM_TOP%\cfg
    Set WIM_LST=%WIM_TOP%\lst
    Set WIM_PKG=%WIM_TOP%\pkg
    Set WIM_USR=%WIM_TOP%\usr
    Set WIM_WRK=%WIM_TOP%\wrk

    Set CMD_FIL=%WIM_WRK%\!WRK_NAM!_work.cmd
    Set CMD_DAT=%WIM_WRK%\!WRK_NAM!_work.dat
    Set CMD_WRK=%WIM_WRK%\!WRK_NAM!_work.wrk

    Set GIT_URL=https://raw.githubusercontent.com/office-itou/Windows/master/New-Project/Make_ISO_files/Initial-Downloader.lst
    Set GIT_FIL=!WRK_DIR!\!WRK_NAM!.lst
    Set GIT_WIM=!WIM_LST!\!WRK_NAM!.lst

Rem --- 既存フォルダーの移動 --------------------------------------------------
    If Exist "%WIM_TOP%" (
        Set INP_ANS=
        Set /P INP_ANS=既存フォルダーがありますが上書きしますか？ [Y/N] ^(Yes/No^)
        If /I "!INP_ANS!" EQU "Y" (
            Echo *** 既存フォルダーのバックアップ **********************************************
            Robocopy /J /MIR /A-:RHS /NDL "%WIM_BIN%" "%WIM_WRK%\%NOW_DAY%%NOW_TIM%\bin" > Nul
            Robocopy /J /MIR /A-:RHS /NDL "%WIM_CFG%" "%WIM_WRK%\%NOW_DAY%%NOW_TIM%\cfg" > Nul
            Robocopy /J /MIR /A-:RHS /NDL "%WIM_LST%" "%WIM_WRK%\%NOW_DAY%%NOW_TIM%\lst" > Nul
Rem         Robocopy /J /MIR /A-:RHS /NDL "%WIM_PKG%" "%WIM_WRK%\%NOW_DAY%%NOW_TIM%\pkg" > Nul
            Echo %WIM_WRK%\%NOW_DAY%%NOW_TIM% にバックアップしました。
        ) Else (
            If /I "!WRK_DIR!" EQU "%WIM_BIN%" (
                Echo 以下のフォルダーで作業中のため実行を中止します。
                Echo "%WIM_BIN%"
                GoTo DONE
            )
            Echo *** 既存フォルダーの移動 ******************************************************
            Echo 既存フォルダーを以下の名前に移動します。
            Echo "%WIM_TOP%"
            Echo      ↓↓
            Echo "%WIM_TOP%.%NOW_DAY%%NOW_TIM%"
            Move "%WIM_TOP%" "%WIM_TOP%.%NOW_DAY%%NOW_TIM%" || GoTo DONE
        )
    )

Rem --- 作業フォルダーの作成 --------------------------------------------------
    Echo *** 作業フォルダーの作成 ******************************************************
    If Not Exist "%WIM_BIN%" (MkDIr "%WIM_BIN%")
    If Not Exist "%WIM_CFG%" (MkDIr "%WIM_CFG%")
    If Not Exist "%WIM_LST%" (MkDIr "%WIM_LST%")
    If Not Exist "%WIM_PKG%" (MkDIr "%WIM_PKG%")
    If Not Exist "%WIM_USR%" (MkDIr "%WIM_USR%")
    If Not Exist "%WIM_WRK%" (MkDIr "%WIM_WRK%")

Rem --- 作業ファイルの削除 ----------------------------------------------------
    If Exist "%CMD_FIL%" (Del /F "%CMD_FIL%")
    If Exist "%CMD_DAT%" (Del /F "%CMD_DAT%")
    If Exist "%CMD_WRK%" (Del /F "%CMD_WRK%")

Rem *** ファイルダウンロード **************************************************
Rem --- GitHub ----------------------------------------------------------------
    Echo --- GitHub --------------------------------------------------------------------
Rem --- GitHub ダウンロードファイル -------------------------------------------
    Set INP_ANS=
    If Exist "%GIT_FIL%" (
        Echo "%GIT_FIL%"
        Set /P INP_ANS=上記を使用しますか？ [Y/N] ^(Yes/No^)
    )
    If /I "!INP_ANS!" EQU "Y" (
        Copy /Y "!GIT_FIL!" "!GIT_WIM!" > Nul
    ) Else (
        Curl -L -# -R -S -f --create-dirs -o "!GIT_WIM!" "%GIT_URL%" || GoTo DONE
    )
    If Not Exist "!GIT_WIM!" (
        Echo 以下のファイルが無いため実行を中止します。
        Echo "%GIT_WIM%"
        GoTo DONE
    )
    For /F %%I In (%GIT_FIL%) Do (
        Set URL_LST=%%~I
        Set URL_FIL=%%~nxI
        Set URL_EXT=%%~xI
        Set URL_EXT=!URL_EXT:~1!
               If /I "!URL_EXT!" EQU "cmd" (Set WIM_DIR=%WIM_BIN%
        ) Else If /I "!URL_EXT!" EQU "url" (Set WIM_DIR=%WIM_BIN%
        ) Else If /I "!URL_EXT!" EQU "xml" (Set WIM_DIR=%WIM_CFG%
        ) Else If /I "!URL_EXT!" EQU "lst" (Set WIM_DIR=%WIM_LST%
        ) Else                             (Set WIM_DIR=%WIM_WRK%
        )
        If /I "!WRK_DIR!" EQU "%WIM_BIN%" If /I "!URL_FIL!" EQU "!WRK_FIL!" (
            Set URL_FIL=!URL_FIL!.%NOW_DAY%%NOW_TIM%
        )
Rem     If Not Exist "!WIM_DIR!\!URL_FIL!" (
            Echo "!URL_FIL!"
            Curl -L -# -R -S -f --create-dirs -o "!WIM_DIR!\!URL_FIL!" "%%I" || GoTo DONE
Rem     )
    )

Rem --- User Custom file ------------------------------------------------------
Rem If Exist "%WIM_USR%" (
Rem     Echo --- User Custom file ----------------------------------------------------------
Rem     If Exist "*.cmd" (Copy /Y "*.cmd" "%WIM_BIN%" > Nul)
Rem     If Exist "*.url" (Copy /Y "*.url" "%WIM_BIN%" > Nul)
Rem     If Exist "*.xml" (Copy /Y "*.xml" "%WIM_CFG%" > Nul)
Rem     If Exist "*.lst" (Copy /Y "*.lst" "%WIM_LST%" > Nul)
Rem )

Rem --- リストファイル --------------------------------------------------------
    Echo --- リストファイル ------------------------------------------------------------
    For %%V In (%WIN_VER%) Do (
        Set WIM_WIN=%WIM_PKG%\w%%V
        For %%I In (%WIM_LST%\Windows%%V*.lst) Do (
            For /F "delims=1234567890-_. tokens=2" %%J In ("%%~nI") Do (Set LST_PACKAGE=%%J)
            If /I "!LST_PACKAGE!" EQU "x" (
                For /F "delims=x-_. tokens=2" %%J In ("%%~nI") Do (
                    If /I "%%J" EQU "32" (
                        Set LST_PACKAGE=x86
                    ) Else (
                        Set LST_PACKAGE=x%%J
                    )
                )
            )
            Set LST_LFNAME=%%~nI
            Set LST_SECTION=
            For /F "delims== tokens=1* usebackq" %%J In (%%I) Do (
                Set LST_KEY=%%J
                Set LST_VAL=%%K
                If /I "!LST_KEY:~0,1!!LST_KEY:~-1,1!" EQU "[]" (
                    If /I "!LST_SECTION!" EQU "INFO" (Set LST_SECTION=)
                    If /I "!LST_SECTION!" EQU "LIST" (Set LST_SECTION=)
                    If /I "!LST_SECTION!" NEQ "" (
                        If /I "!LST_RENAME!" EQU "" (For %%E In ("!LST_FILE!")   Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE&Set LST_RENAME=%%~nxE)
                        ) Else                      (For %%E In ("!LST_RENAME!") Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE)
                        )
                        If /I "!LST_RUN_ORDER!" EQU "" (Set LST_RUN_ORDER=000)
                        Set LST_RENAME=!WIM_WIN!\!LST_PACKAGE!\!LST_RENAME!
                        Set LST_EXTENSION=!LST_EXTENSION:~1!
                        If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                        Echo>>"%CMD_WRK%" "w%%V","!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
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
                    Set LST_RENAME=!WIM_WIN!\!LST_PACKAGE!\!LST_RENAME!
                    Set LST_EXTENSION=!LST_EXTENSION:~1!
                    If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                    Echo>>"%CMD_WRK%" "w%%V","!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
                )
            )
        )
    )
    Sort "%CMD_WRK%" > "%CMD_DAT%"
Rem ***************************************************************************
    Echo>>"%CMD_FIL%" Rem ***************************************************************************
    Echo>>"%CMD_FIL%"     @Echo Off
    Echo>>"%CMD_FIL%" Rem Cls
    Echo.>>"%CMD_FIL%"
    Echo>>"%CMD_FIL%" Rem *** 作業開始 **************************************************************
    Echo>>"%CMD_FIL%" :START
    Echo>>"%CMD_FIL%"     Echo *** 作業開始 ******************************************************************
    Echo>>"%CMD_FIL%"     Echo ^%%DATE^%% ^%%TIME^%%
    Echo.>>"%CMD_FIL%"
    Echo>>"%CMD_FIL%"     SetLocal EnableExtensions
    Echo>>"%CMD_FIL%"     SetLocal EnableDelayedExpansion
    Echo.>>"%CMD_FIL%"
    Echo>>"%CMD_FIL%" Rem *** ファイル取得 **********************************************************
    Echo>>"%CMD_FIL%"     Echo *** ファイル取得 **************************************************************
    Echo>>"%CMD_FIL%"     For /F "delims=, tokens=1-9 usebackq" %%%%I In ^(%CMD_DAT%^) Do ^(
    Echo>>"%CMD_FIL%"         Set LST_WINDOWS=%%%%~I
    Echo>>"%CMD_FIL%"         Set LST_PACKAGE=%%%%~J
    Echo>>"%CMD_FIL%"         Set LST_TYPE=%%%%~K
    Echo>>"%CMD_FIL%"         Set LST_RUN_ORDER=%%%%~L
    Echo>>"%CMD_FIL%"         Set LST_SECTION=%%%%~M
    Echo>>"%CMD_FIL%"         Set LST_EXTENSION=%%%%~N
    Echo>>"%CMD_FIL%"         Set LST_CMD=%%%%~O
    Echo>>"%CMD_FIL%"         Set LST_RENAME=%%%%~P
    Echo>>"%CMD_FIL%"         Set LST_FILE=%%%%~Q
    Echo>>"%CMD_FIL%"         Set WIM_WIN=%WIM_PKG%\^^!LST_WINDOWS^^!
    Echo>>"%CMD_FIL%"         For %%%%E In ^("^!LST_RENAME^!"^) Do ^(Set LST_FNAME=%%%%~nxE^)
    Echo>>"%CMD_FIL%"         For /F "delims=: tokens=2 usebackq" %%%%X In ^('^^!LST_FILE^^!'^) Do ^(
    Echo>>"%CMD_FIL%"             If /I "%%%%X" NEQ "" ^(
    Echo>>"%CMD_FIL%"                 If Not Exist "^!LST_RENAME^!" ^(
    Echo>>"%CMD_FIL%"                     Echo "^!LST_FNAME^!"
    Echo>>"%CMD_FIL%"                     Curl -L -# -R -S -f --create-dirs -o "^!LST_RENAME^!" "^!LST_FILE^!" ^|^| GoTo DONE
    Echo>>"%CMD_FIL%"                 ^) Else ^(
    Echo>>"%CMD_FIL%"                     For /F "delims=: tokens=2 usebackq" %%%%Y In ^(`Curl -L -s -R -S -I "^!LST_FILE^!" ^^^^^| Find /I "Content-Length:"`^) Do ^(
    Echo>>"%CMD_FIL%"                         Set LST_LEN=%%%%Y
    Echo>>"%CMD_FIL%"                     ^)
    Echo>>"%CMD_FIL%"                     For /F "delims=/ usebackq" %%%%Z In ^('^^!LST_RENAME^^!'^) Do ^(Set LST_SIZE=%%%%~zZ^)
    Echo>>"%CMD_FIL%"                     If ^^!LST_LEN^^! NEQ ^^!LST_SIZE^^! ^(
    Echo>>"%CMD_FIL%"                         Echo "^!LST_FNAME^!" : ^^!LST_SIZE^^! : ^^!LST_LEN^^!
    Echo>>"%CMD_FIL%"                         Curl -L -# -R -S -f --create-dirs -o "^!LST_RENAME^!" "^!LST_FILE^!" ^|^| GoTo DONE
    Echo>>"%CMD_FIL%"                     ^)
    Echo>>"%CMD_FIL%"                 ^)
    Echo>>"%CMD_FIL%"                 If /I "^!LST_EXTENSION^!" EQU "zip" ^(
    Echo>>"%CMD_FIL%"                     For %%%%E In ^("^!LST_RENAME^!"^) Do ^(Set LST_DIR=%%%%~dpnE^)
    Echo>>"%CMD_FIL%"                     If Not Exist "^!LST_DIR^!" ^(
    Echo>>"%CMD_FIL%"                         Echo --- ファイル展開 --------------------------------------------------------------
    Echo>>"%CMD_FIL%"                         MkDir "^!LST_DIR^!"
    Echo>>"%CMD_FIL%"                         Tar -xzf "^!LST_RENAME^!" -C "^!LST_DIR^!"
    Echo>>"%CMD_FIL%"                     ^)
    Echo>>"%CMD_FIL%"                     Pushd "^!LST_DIR^!"
    Echo>>"%CMD_FIL%"                         For /R %%%%E In ^(*.zip^) Do ^(
    Echo>>"%CMD_FIL%"                             Set LST_ZIPFILE=%%%%E
    Echo>>"%CMD_FIL%"                             Set LST_ZIPDIR=%%%%~dpnE
    Echo>>"%CMD_FIL%"                             If Not Exist "^!LST_ZIPDIR^!" ^(
    Echo>>"%CMD_FIL%"                                 Echo --- ファイル展開 --------------------------------------------------------------
    Echo>>"%CMD_FIL%"                                 MkDir "^!LST_ZIPDIR^!"
    Echo>>"%CMD_FIL%"                                 Tar -xzf "^!LST_ZIPFILE^!" -C "^!LST_ZIPDIR^!"
    Echo>>"%CMD_FIL%"                             ^)
    Echo>>"%CMD_FIL%"                             Pushd "^!LST_ZIPDIR^!"
    Echo>>"%CMD_FIL%"                                 For /R %%%%F In ^(*.msu^) Do ^(
    Echo>>"%CMD_FIL%"                                     For /F "delims=x tokens=2" %%%%G In ("%%%%~nF") Do ^(Set LST_PACKAGE=%%%%G^)
    Echo>>"%CMD_FIL%"                                     If Not Exist "^!WIM_WIN^!\x^!LST_PACKAGE^!\%%%%~nxF" ^(
    Echo>>"%CMD_FIL%"                                         Echo --- ファイル転送 --------------------------------------------------------------
    Echo>>"%CMD_FIL%"                                         If Not Exist "^!WIM_WIN^!\x^!LST_PACKAGE^!" ^(MkDir "^!WIM_WIN^!\x^!LST_PACKAGE^!")
    Echo>>"%CMD_FIL%"                                         Copy /Y "%%%%F" "^!WIM_WIN^!\x^!LST_PACKAGE^!" ^> Nul
    Echo>>"%CMD_FIL%"                                     ^)
    Echo>>"%CMD_FIL%"                                 ^)
    Echo>>"%CMD_FIL%"                             Popd
    Echo>>"%CMD_FIL%"                         ^)
    Echo>>"%CMD_FIL%"                         For /R %%%%F In ^(*.msu^) Do ^(
    Echo>>"%CMD_FIL%"                             For /F "delims=x tokens=2" %%%%G In ("%%%%~nF") Do ^(Set LST_PACKAGE=%%%%G^)
    Echo>>"%CMD_FIL%"                             If Not Exist "^!WIM_WIN^!\x^!LST_PACKAGE^!\%%%%~nxF" ^(
    Echo>>"%CMD_FIL%"                                 Echo --- ファイル転送 --------------------------------------------------------------
    Echo>>"%CMD_FIL%"                                 If Not Exist "^!WIM_WIN^!\x^!LST_PACKAGE^!" ^(MkDir "^!WIM_WIN^!\x^!LST_PACKAGE^!")
    Echo>>"%CMD_FIL%"                                 Copy /Y "%%%%F" "^!WIM_WIN^!\x^!LST_PACKAGE^!" ^> Nul
    Echo>>"%CMD_FIL%"                             ^)
    Echo>>"%CMD_FIL%"                         ^)
    Echo>>"%CMD_FIL%"                     Popd
    Echo>>"%CMD_FIL%"                 ^) Else If /I "^!LST_SECTION^!" EQU "IE11" ^(
    Echo>>"%CMD_FIL%"                     For %%%%E In ^("^!LST_RENAME^!"^) Do ^(Set LST_DIR=%%%%~dpnE^)
    Echo>>"%CMD_FIL%"                     If Not Exist "^!LST_DIR^!" ^(
    Echo>>"%CMD_FIL%"                         Echo --- ファイル展開 --------------------------------------------------------------
    Echo>>"%CMD_FIL%"                         MkDir "^!LST_DIR^!"
    Echo>>"%CMD_FIL%"                         "^!LST_RENAME^!" /x:"^!LST_DIR^!"
    Echo>>"%CMD_FIL%"                     ^)
    Echo>>"%CMD_FIL%"                 ^)
    Echo>>"%CMD_FIL%"             ^)
    Echo>>"%CMD_FIL%"         ^)
    Echo>>"%CMD_FIL%"     ^)
    Echo.>>"%CMD_FIL%"
    Echo>>"%CMD_FIL%" Rem *** 作業終了 **************************************************************
    Echo>>"%CMD_FIL%" :DONE
    Echo>>"%CMD_FIL%"     EndLocal
    Echo>>"%CMD_FIL%"     Echo *** 作業終了 ******************************************************************
    Echo>>"%CMD_FIL%"     Echo ^%%DATE^%% ^%%TIME^%%
    Echo>>"%CMD_FIL%" Rem Echo [Enter]を押下して下さい。
    Echo>>"%CMD_FIL%" Rem Pause ^> Nul 2^>^&1
    Echo>>"%CMD_FIL%" Rem Echo On
Rem ---------------------------------------------------------------------------
    Call "%CMD_FIL%"

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
