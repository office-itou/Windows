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
    Set ARC_TYP=86 64
    Set LST_PKG=adk drv zip %ARC_TYP%
Rem Set WIM_TOP=C:\WimWK
    Set WIM_BIN=%WIM_TOP%\bin
    Set WIM_CFG=%WIM_TOP%\cfg
    Set WIM_ISO=%WIM_TOP%\iso
    Set WIM_LST=%WIM_TOP%\lst
    Set WIM_PKG=%WIM_TOP%\pkg
    Set WIM_USR=%WIM_TOP%\usr
    Set WIM_WRK=%WIM_TOP%\wrk

    Set BAK_WIM=%WIM_WRK%\%NOW_DAY%%NOW_TIM%
    Set BAK_BIN=%BAK_TOP%\bin
    Set BAK_CFG=%BAK_TOP%\cfg
    Set BAK_ISO=%BAK_TOP%\iso
    Set BAK_LST=%BAK_TOP%\lst
    Set BAK_PKG=%BAK_TOP%\pkg
    Set BAK_USR=%BAK_TOP%\usr
    Set BAK_WRK=%BAK_TOP%\wrk

    Set MOV_WIM=%WIM_TOP%.%NOW_DAY%%NOW_TIM%
    Set MOV_ISO=%MOV_WIM%\iso

    Set CMD_FIL=%WIM_BIN%\Downloader.cmd
    Set CMD_DAT=%WIM_WRK%\Downloader.dat
    Set CMD_WRK=%WIM_WRK%\Downloader.wrk

    Set GIT_TOP=https://raw.githubusercontent.com/office-itou/Windows/master/New-Project/Make_ISO_files
    Set GIT_URL=%GIT_TOP%/Initial-Downloader.lst
    Set GIT_FIL=!WRK_DIR!\!WRK_NAM!.lst
    Set GIT_WIM=!WIM_LST!\!WRK_NAM!.lst

    Set UTL_ARC=amd64 arm arm64 x86

Rem --- 破損イメージの削除 ----------------------------------------------------
    For %%I In (%WIN_VER%) Do (
        For %%J In (%ARC_TYP%) Do (
            Set WIM_IMG=%WIM_WRK%\w%%I\x%%J\img
            Set WIM_MNT=%WIM_WRK%\w%%I\x%%J\mnt
            Set WIM_WRE=%WIM_WRK%\w%%I\x%%J\wre
            If Exist "%WIM_WRE%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_WRE%" /Discard)
            If Exist "%WIM_MNT%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Discard)
        )
    )

Rem --- 既存フォルダーの移動 --------------------------------------------------
    If Exist "%WIM_TOP%" (
        Set INP_ANS=
        Set /P INP_ANS=既存フォルダーがありますが上書きしますか？ [Y/N] ^(Yes/No^)
        If /I "!INP_ANS!" EQU "Y" (
            Echo *** 既存フォルダーのバックアップ **********************************************
            Robocopy /J /MIR /A-:RHS /NDL "%WIM_BIN%" "%BAK_BIN%" > Nul
            Robocopy /J /MIR /A-:RHS /NDL "%WIM_CFG%" "%BAK_CFG%" > Nul
            Robocopy /J /MIR /A-:RHS /NDL "%WIM_LST%" "%BAK_LST%" > Nul
Rem         Robocopy /J /MIR /A-:RHS /NDL "%WIM_PKG%" "%BAK_PKG%" > Nul
            Echo %BAK_WIM% にバックアップしました。
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
            Echo "%MOV_WIM%"
            Move "%WIM_TOP%" "%MOV_WIM%" || GoTo DONE
            If Not Exist "%WIM_TOP%" (MkDir "%WIM_TOP%" || GoTo DONE)
            If Exist "%MOV_ISO%" (Move "%MOV_ISO%" "%WIM_ISO%" || GoTo DONE)
        )
    )

Rem --- 作業フォルダーの作成 --------------------------------------------------
    Echo *** 作業フォルダーの作成 ******************************************************
    If Not Exist "%WIM_BIN%" (MkDIr "%WIM_BIN%" || GoTo DONE)
    If Not Exist "%WIM_CFG%" (MkDIr "%WIM_CFG%" || GoTo DONE)
    If Not Exist "%WIM_LST%" (MkDIr "%WIM_LST%" || GoTo DONE)
    If Not Exist "%WIM_PKG%" (MkDIr "%WIM_PKG%" || GoTo DONE)
    If Not Exist "%WIM_USR%" (MkDIr "%WIM_USR%" || GoTo DONE)
    If Not Exist "%WIM_WRK%" (MkDIr "%WIM_WRK%" || GoTo DONE)

    For %%I In (%WIN_VER%) Do (
        For %%J In (%ARC_TYP%) Do (
            Set WIM_IMG=%WIM_WRK%\w%%I\x%%J\img
            Set WIM_MNT=%WIM_WRK%\w%%I\x%%J\mnt
            Set WIM_WRE=%WIM_WRK%\w%%I\x%%J\wre
            If Not Exist "!WIM_IMG!" (MkDir "!WIM_IMG!" || GoTo DONE)
            If Not Exist "!WIM_MNT!" (MkDir "!WIM_MNT!" || GoTo DONE)
            If Not Exist "!WIM_WRE!" (MkDir "!WIM_WRE!" || GoTo DONE)
        )
    )

Rem --- 作業ファイルの削除 ----------------------------------------------------
    If Exist "%CMD_FIL%" (Del /F "%CMD_FIL%" || GoTo DONE)
    If Exist "%CMD_DAT%" (Del /F "%CMD_DAT%" || GoTo DONE)
    If Exist "%CMD_WRK%" (Del /F "%CMD_WRK%" || GoTo DONE)

Rem --- Oscdimg取得 -----------------------------------------------------------
    Echo --- Oscdimg取得 ---------------------------------------------------------------
    For /R "%ProgramFiles(x86)%" %%I In (Oscdimg.exe*) Do (Set UTL_WRK=%%~dpI)
    If /I "!UTL_WRK!" EQU "" (
        Echo Windows ADK をインストールして下さい。
        GoTo :DONE
    )
    For %%I In (%UTL_ARC%) DO (
        Set UTL_SRC=!UTL_WRK!\..\..\%%~I\Oscdimg
        Set UTL_DST=!WIM_BIN!\Oscdimg\%%~I
        Robocopy /J /MIR /A-:RHS /NDL "!UTL_SRC!" "!UTL_DST!" > Nul
    )

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
    For /F %%I In (%GIT_WIM%) Do (
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

Rem --- ファイル取得 ----------------------------------------------------------
    Call "%CMD_FIL%" "%WIN_VER%" "%LST_PKG%" "%WIM_LST%" "%WIM_PKG%"

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
