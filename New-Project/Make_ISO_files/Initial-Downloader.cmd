Rem ***************************************************************************
    @Echo Off
    Cls

Rem *** 作業開始 **************************************************************
:START
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

    Set WIN_VER=7
    Set WIN_VER=10
    Set WIM_LST=C:\WimWK\w%WIN_VER%\lst
    Set WIM_PKG=C:\WimWK\w%WIN_VER%\pkg

    Set CMD_FIL=test_file.cmd
    Set CMD_DAT=test_file.dat
    Set CMD_WRK=test_file.wrk

    If Exist "%CMD_FIL%" (Del "%CMD_FIL%")
    If Exist "%CMD_DAT%" (Del "%CMD_DAT%")
    If Exist "%CMD_WRK%" (Del "%CMD_WRK%")
Rem ---------------------------------------------------------------------------
    For %%I In (%WIM_LST%\*.lst) Do (
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
                    Set LST_RENAME=%WIM_PKG%\!LST_PACKAGE!\!LST_RENAME!
                    Set LST_EXTENSION=!LST_EXTENSION:~1!
                    If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                    Echo>>"%CMD_WRK%" "!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
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
                Set LST_RENAME=%WIM_PKG%\!LST_PACKAGE!\!LST_RENAME!
                Set LST_EXTENSION=!LST_EXTENSION:~1!
                If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                Echo>>"%CMD_WRK%" "!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
            )
        )
    )
    Sort "%CMD_WRK%" > "%CMD_DAT%"
Rem ---------------------------------------------------------------------------
    Echo>>"%CMD_FIL%" Rem ***************************************************************************
    Echo>>"%CMD_FIL%"     @Echo Off
    Echo>>"%CMD_FIL%"     Cls
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
    Echo>>"%CMD_FIL%"     For /F "delims=, tokens=1-8 usebackq" %%%%I In ^(%CMD_DAT%^) Do ^(
    Echo>>"%CMD_FIL%"         Set LST_PACKAGE=%%%%~I
    Echo>>"%CMD_FIL%"         Set LST_TYPE=%%%%~J
    Echo>>"%CMD_FIL%"         Set LST_RUN_ORDER=%%%%~K
    Echo>>"%CMD_FIL%"         Set LST_SECTION=%%%%~L
    Echo>>"%CMD_FIL%"         Set LST_EXTENSION=%%%%~M
    Echo>>"%CMD_FIL%"         Set LST_CMD=%%%%~N
    Echo>>"%CMD_FIL%"         Set LST_RENAME=%%%%~O
    Echo>>"%CMD_FIL%"         Set LST_FILE=%%%%~P
    Echo>>"%CMD_FIL%"         For %%%%E In ^("^!LST_RENAME^!"^) Do ^(Set LST_FNAME=%%%%~nxE^)
    Echo>>"%CMD_FIL%"         For /F "delims=: tokens=2 usebackq" %%%%X In ^('^^!LST_FILE^^!'^) Do ^(
    Echo>>"%CMD_FIL%"             If /I "%%%%X" NEQ "" ^(
    Echo>>"%CMD_FIL%"                 If Not Exist "^!LST_RENAME^!" ^(
    Echo>>"%CMD_FIL%"                     Echo ^^!LST_FNAME^^!
    Echo>>"%CMD_FIL%"                     Curl -L -# -R -S --create-dirs -o "^!LST_RENAME^!" "^!LST_FILE^!" ^|^| GoTo DONE
    Echo>>"%CMD_FIL%"                 ^) Else ^(
    Echo>>"%CMD_FIL%"                     For /F "delims=: tokens=2 usebackq" %%%%Y In ^(`Curl -L -s -R -S -I "^!LST_FILE^!" ^^^^^| Find /I "Content-Length:"`^) Do ^(
    Echo>>"%CMD_FIL%"                         Set LST_LEN=%%%%Y
    Echo>>"%CMD_FIL%"                     ^)
    Echo>>"%CMD_FIL%"                     For /F "delims=/ usebackq" %%%%Z In ^('^^!LST_RENAME^^!'^) Do ^(Set LST_SIZE=%%%%~zZ^)
    Echo>>"%CMD_FIL%"                     If ^^!LST_LEN^^! NEQ ^^!LST_SIZE^^! ^(
    Echo>>"%CMD_FIL%"                         Echo ^^!LST_FNAME^^! : ^^!LST_SIZE^^! : ^^!LST_LEN^^!
    Echo>>"%CMD_FIL%"                         Curl -L -# -R -S --create-dirs -o "^!LST_RENAME^!" "^!LST_FILE^!" ^|^| GoTo DONE
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
    Echo>>"%CMD_FIL%"                                     If Not Exist "^%WIM_PKG%\x^!LST_PACKAGE^!\%%%%~nxF" ^(
    Echo>>"%CMD_FIL%"                                         Echo --- ファイル転送 --------------------------------------------------------------
    Echo>>"%CMD_FIL%"                                         If Not Exist "^%WIM_PKG%\x^!LST_PACKAGE^!" ^(MkDir "^%WIM_PKG%\x^!LST_PACKAGE^!")
    Echo>>"%CMD_FIL%"                                         Copy /Y "%%%%F" "%WIM_PKG%\x^!LST_PACKAGE^!"
    Echo>>"%CMD_FIL%"                                     ^)
    Echo>>"%CMD_FIL%"                                 ^)
    Echo>>"%CMD_FIL%"                             Popd
    Echo>>"%CMD_FIL%"                         ^)
    Echo>>"%CMD_FIL%"                         For /R %%%%F In ^(*.msu^) Do ^(
    Echo>>"%CMD_FIL%"                             For /F "delims=x tokens=2" %%%%G In ("%%%%~nF") Do ^(Set LST_PACKAGE=%%%%G^)
    Echo>>"%CMD_FIL%"                             If Not Exist "^%WIM_PKG%\x^!LST_PACKAGE^!\%%%%~nxF" ^(
    Echo>>"%CMD_FIL%"                                 Echo --- ファイル転送 --------------------------------------------------------------
    Echo>>"%CMD_FIL%"                                 If Not Exist "^%WIM_PKG%\x^!LST_PACKAGE^!" ^(MkDir "^%WIM_PKG%\x^!LST_PACKAGE^!")
    Echo>>"%CMD_FIL%"                                 Copy /Y "%%%%F" "%WIM_PKG%\x^!LST_PACKAGE^!"
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
