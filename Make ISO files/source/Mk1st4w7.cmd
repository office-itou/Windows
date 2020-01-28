Rem ***************************************************************************
    @Echo Off
    Cls

Rem *** 作業開始 **************************************************************
:START
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

Rem --- 環境変数設定 ----------------------------------------------------------
    For /F "usebackq delims=" %%I In (`Echo %0`) Do Set DIR_WRK=%%~dpI

    Set NOW_DAY=%date:~0,4%%date:~5,2%%date:~8,2%

    If /I "%time:~0,1%" EQU " " (
        Set NOW_TIM=0%time:~1,1%%time:~3,2%%time:~6,2%
    ) Else (
        Set NOW_TIM=%time:~0,2%%time:~3,2%%time:~6,2%
    )

    Set WIN_VER=7
    Set WIM_TYP=w%WIN_VER%
    Set WIM_TOP=C:\WimWK
    Set WIM_CST=%WIM_TOP%\%WIM_TYP%.custom
    Set WIM_WRK=%WIM_TOP%\%WIM_TYP%
    Set WIM_BIN=%WIM_WRK%\bin
    Set WIM_CFG=%WIM_WRK%\cfg
    Set WIM_LST=%WIM_WRK%\lst
    Set WIM_PKG=%WIM_WRK%\pkg
    Set WIM_TMP=%WIM_WRK%\tmp
    Set WIM_DIR=bin cfg lst pkg tmp
    Set PKG_DIR=adk drv zip x64 x86
    Set PKG_LST=adk drv zip x32 x64
    Set URL_LST=https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/MicrosoftUpdateCatalog.url              ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/Mk1st4w%WIN_VER%.cmd                    ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/MkWindows%WIN_VER%_ISO_files_Custom.cmd ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/MkWindows%WIN_VER%_USB_Custom.cmd       ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/Windows%WIN_VER%adk_Rollup_202001.lst   ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/Windows%WIN_VER%drv_Rollup_202001.lst   ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/Windows%WIN_VER%x32_Rollup_202001.lst   ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/Windows%WIN_VER%x64_Rollup_202001.lst   ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/Windows%WIN_VER%zip_Rollup_202001.lst   ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/autounattend-windows%WIN_VER%-x64.xml   ^
                https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files/source/autounattend-windows%WIN_VER%-x86.xml

Rem *** 作業フォルダーの作成 **************************************************
    If /I "%DIR_WRK%" EQU "%WIM_BIN%\" (
        Echo 以下のディレクトリで作業中のため実行を中止します。
        Echo "%WIM_BIN%"
        GoTo DONE
    )
    If /I "%DIR_WRK%" EQU "%WIM_TMP%\" (
        Echo 以下のディレクトリで作業中のため実行を中止します。
        Echo "%WIM_TMP%"
        GoTo DONE
    )
    Echo *** 作業フォルダーの作成 ******************************************************
    If Exist "%WIM_WRK%" (
        Echo 既存ディレクトリを以下の名前に移動します。
        Echo "%WIM_WRK%"
        Echo      ↓↓
        Echo "%WIM_WRK%.%NOW_DAY%%NOW_TIM%"
        Move "%WIM_WRK%" "%WIM_WRK%.%NOW_DAY%%NOW_TIM%" || GoTo DONE
    )

    For %%I In (%WIM_DIR%) Do (
        If Not Exist "%WIM_WRK%\%%I" (MkDir "%WIM_WRK%\%%I")
    )

    For %%I In (%PKG_DIR%) Do (
        If Not Exist "%WIM_PKG%\%%I" (MkDir "%WIM_PKG%\%%I")
    )

    If Not Exist "%WIM_CST%" (MkDir "%WIM_CST%")

Rem *** ファイル・ダウンロード ************************************************
    Echo *** ファイル・ダウンロード ****************************************************
Rem --- GitHub ----------------------------------------------------------------
    Echo --- GitHub --------------------------------------------------------------------
    Pushd "%WIM_TMP%"
        For %%I In (%URL_LST%) Do (
            Echo %%~nxI
            Curl -L -# -R -O "%%I" || GoTo DONE
        )
        If Exist "%WIM_CST%\*.*" (
            Echo --- Custom file ---------------------------------------------------------------
            Copy /Y "%WIM_CST%\*.*" ".\" > Nul
        )
        Copy /Y "*.url" "%WIM_BIN%" > Nul
        Copy /Y "*.cmd" "%WIM_BIN%" > Nul
        Copy /Y "*.xml" "%WIM_CFG%" > Nul
        Copy /Y "*.lst" "%WIM_LST%" > Nul
    Popd
Rem --- モジュール・ファイル・ダウンロード ------------------------------------
    Echo --- モジュール・ファイル・ダウンロード ----------------------------------------
    For %%I In (%PKG_LST%) Do (
        Set PKG_TYP=%%I
        For %%J In (%WIM_LST%\Windows%WIN_VER%!PKG_TYP!_Rollup_*.lst) Do (
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
                    If /I "!PKG_TYP!" EQU "x32" (
                        Set DNAME=%WIM_PKG%\x86
                    ) Else (
                        Set DNAME=%WIM_PKG%\!PKG_TYP!
                    )
                    If /I "!RENAME!" NEQ "" (
                        Set FNAME=!DNAME!\!RENAME!
                    ) Else (
                        For /F "delims=! usebackq" %%M In ('!FILE!') Do (
                            Set FNAME=!DNAME!\%%~nxM
                        )
                    )
                    For /F "delims=! usebackq" %%M In ('!FNAME!') Do (
                        Set DNAME=%%~dpM
                        Set FSIZE=%%~zM
                        If "!FSIZE!" EQU "" Set FSIZE=-1
                    )
                    If Not Exist "!DNAME!" MkDir "!DNAME!"
                    If Exist "!FNAME!" If !FSIZE! NEQ !SIZE! Del /F "!FNAME!"
                    If Not Exist "!FNAME!" (
                        Echo "!FNAME!"
                        Curl -L -# -R -o "!FNAME!" "!FILE!" || GoTo DONE
                    )
                    Set FILE=
                    Set RENAME=
                    Set SIZE=
                )
            )
        )
    )

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
