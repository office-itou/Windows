Rem ***************************************************************************
    @Echo Off
    Cls

Rem *** 作業開始 **************************************************************
:START
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

Rem --- 環境変数設定 ----------------------------------------------------------
    Set NOW_DAY=%date:~0,4%%date:~5,2%%date:~8,2%

    If /I "%time:~0,1%" EQU " " (
        Set NOW_TIM=0%time:~1,1%%time:~3,2%%time:~6,2%
    ) Else (
        Set NOW_TIM=%time:~0,2%%time:~3,2%%time:~6,2%
    )

    For /F "usebackq delims=" %%I In (`Echo %0`) Do Set DIR_WRK=%%~dpI
    IF /I "%DIR_WRK:~-1%" EQU "\" (Set DIR_WRK=%DIR_WRK:~0,-1%)

:INPUT_PARAMETER
    Set DIR_WIM=C:\WimWK
    Set DIR_SPM=C:\winsppm

    Echo Enter のみの場合は既定値を設定します。

    Echo.
    Echo このアプリケーションのインストール先フォルダー名を入力して下さい。
    Echo 既定値では %DIR_WIM% です。
    Set /P DIR_WIM=＞
    IF /I "%DIR_WIM:~-1%" EQU "\" (Set DIR_WIM=%DIR_WIM:~0,-1%)

    Echo.
    Echo SP+メーカー^(winsppm.exe^)のインストール先フォルダー名を入力して下さい。
    Echo 既定値では %DIR_SPM% です。
    Set /P DIR_SPM=＞
    IF /I "%DIR_SPM:~-1%" EQU "\" (Set DIR_SPM=%DIR_SPM:~0,-1%)

    Echo.
    Echo Windows AIK DVDのマウント先ドライブ名を入力して下さい。
    Set /P DRV_AIK=＞
    Set DRV_AIK=%DRV_AIK:~0,2%
    IF /I "%DRV_AIK:~1,1%" NEQ ":" (Set DRV_AIK=%DRV_AIK%:)

    Echo.
    Echo -------------------------------------------------------------------------------
    Echo アプリケーション: %DIR_WIM%
    Echo SP+メーカー     : %DIR_SPM%
    Echo Windows AIK     : %DRV_AIK%
    Echo -------------------------------------------------------------------------------
    Echo 以上のパラメーターで作成します。
    Set /P INP_ANS=実行してよろしいでしょうか？ [Y/N/E] ^(Yes/No/Exit^)
    If /I "%INP_ANS%" EQU "E" (GoTo :DONE)
    If /I "%INP_ANS%" NEQ "Y" (GoTo :INPUT_PARAMETER)

Rem --- セットアップ作業 ------------------------------------------------------
    Set Path=%DIR_WRK%;%DIR_SPM%;%Path%
    Set DIR_BAK=%DIR_WIM%.%NOW_DAY%-%NOW_TIM%

    If Exist "%DIR_WIM%" (
        Echo.
        Echo %DIR_WIM% は存在します。
        Echo 1: 上書きする。
        Echo 2: 作り直す。
        Echo E: 中止する。
        Set /P INP_ANS=作業の指示をして下さい。
        If /I "!INP_ANS!" EQU "E" (GoTo :DONE)
        If /I "!INP_ANS!" EQU "1" (GoTo :MAKE_DIR)
        If /I "!INP_ANS!" EQU "2" (
           	Move /-Y "%DIR_WIM%" "%DIR_BAK%" || GoTo Done
            Echo 既存環境は以下のフォルダーに移動したので手動で削除して下さい。
            Echo → %DIR_BAK%
        )
    )

:MAKE_DIR
    Echo --- フォルダーの作成中 --------------------------------------------------------

    If Not Exist "%DIR_WIM%\bin\Oscdimg\amd64"        (MkDir "%DIR_WIM%\bin\Oscdimg\amd64")
    If Not Exist "%DIR_WIM%\bin\Oscdimg\x86"          (MkDir "%DIR_WIM%\bin\Oscdimg\x86")
    If Not Exist "%DIR_WIM%\lst"                      (MkDir "%DIR_WIM%\lst")
    If Not Exist "%DIR_WIM%\w7\pkg\drv\asus\h170-pro" (MkDir "%DIR_WIM%\w7\pkg\drv\asus\h170-pro")
    If Not Exist "%DIR_WIM%\w7\pkg\drv\CHP"           (MkDir "%DIR_WIM%\w7\pkg\drv\CHP")
    If Not Exist "%DIR_WIM%\w7\pkg\drv\USB"           (MkDir "%DIR_WIM%\w7\pkg\drv\USB")
    If Not Exist "%DIR_WIM%\w7\pkg\drv\RST"           (MkDir "%DIR_WIM%\w7\pkg\drv\RST")
    If Not Exist "%DIR_WIM%\w7\pkg\drv\VGA"           (MkDir "%DIR_WIM%\w7\pkg\drv\VGA")
    If Not Exist "%DIR_WIM%\w7\pkg\drv\MEI"           (MkDir "%DIR_WIM%\w7\pkg\drv\MEI")
    If Not Exist "%DIR_WIM%\w7\pkg\drv\LAN"           (MkDir "%DIR_WIM%\w7\pkg\drv\LAN")
    If Not Exist "%DIR_WIM%\w7\pkg\drv\SND"           (MkDir "%DIR_WIM%\w7\pkg\drv\SND")
    If Not Exist "%DIR_WIM%\w7\pkg\efi"               (MkDir "%DIR_WIM%\w7\pkg\efi")
    If Not Exist "%DIR_WIM%\w7\pkg\upd"               (MkDir "%DIR_WIM%\w7\pkg\upd")
    If Not Exist "%DIR_WIM%\w7\pkg\x86"               (MkDir "%DIR_WIM%\w7\pkg\x86")
    If Not Exist "%DIR_WIM%\w7\pkg\x64"               (MkDir "%DIR_WIM%\w7\pkg\x64")
    If Not Exist "%DIR_WIM%\w10\src\x64\Sources"      (MkDir "%DIR_WIM%\w10\src\x64\Sources")
    If Not Exist "%DIR_WIM%\w10\src\x86\Sources"      (MkDir "%DIR_WIM%\w10\src\x86\Sources")

    Echo --- ツールの準備中 ------------------------------------------------------------
    If Not Exist "unzip.exe" (
        Echo> "ftp_get_unzip.txt" open ftp.info-zip.org
        Echo>>"ftp_get_unzip.txt" anonymous
        Echo>>"ftp_get_unzip.txt" anonymous@localhost
        Echo>>"ftp_get_unzip.txt" binary
        Echo>>"ftp_get_unzip.txt" get /pub/infozip/win32/unz600xn.exe
        Echo>>"ftp_get_unzip.txt" quit
        Ftp -i -s:"ftp_get_unzip.txt" || GoTo Done
        unz600xn.exe -d unz600xn
        Copy /B /Y unz600xn\unzip.exe . || GoTo Done
    )

    Copy /B "%DIR_SPM%\download.exe" "%DIR_WIM%\bin" || GoTo Done
    Copy /B "%DIR_WRK%\*.cmd"        "%DIR_WIM%\bin" || GoTo Done
    Copy /B "%DIR_WRK%\*.vbs"        "%DIR_WIM%\bin" || GoTo Done
    Copy /B "%DIR_WRK%\unzip.exe"    "%DIR_WIM%\bin" || GoTo Done
    Copy /B "%DIR_WRK%\*.lst"        "%DIR_WIM%\lst" || GoTo Done

    Echo --- Windows Updateの取得 ------------------------------------------------------
    CScript download.vbs /function:fncDownload /winsppm:"%DIR_WIM%\bin" /list:"%DIR_WIM%\lst\Windows7x32_Rollup_202001.lst" /update:"%DIR_WIM%\\w7\pkg\x86"     /timezone:utc
    CScript download.vbs /function:fncDownload /winsppm:"%DIR_WIM%\bin" /list:"%DIR_WIM%\lst\Windows7x64_Rollup_202001.lst" /update:"%DIR_WIM%\\w7\pkg\x64"     /timezone:utc
    CScript download.vbs /function:fncDownload /winsppm:"%DIR_WIM%\bin" /list:"%DIR_WIM%\lst\Windows7aik_Rollup_202001.lst" /update:"%DIR_WIM%\\w7\pkg\upd"     /timezone:utc
    CScript download.vbs /function:fncDownload /winsppm:"%DIR_WIM%\bin" /list:"%DIR_WIM%\lst\Windows7drv_Rollup_202001.lst" /update:"%DIR_WIM%\\w7\pkg\drv\USB" /timezone:utc

    Echo --- ファイルの解凍 ------------------------------------------------------------
Rem == ファイルの解凍 =========================================================
    For /R "%DIR_WIM%\w7\pkg" %%I In ("*.zip") Do If Not Exist "%%~dpnI" (UnZip -q -o "%%I" -d "%%~dpnI")

    Echo --- Windows AIKの展開 ---------------------------------------------------------
:INPUT_SET_WAIK
    Echo.
    Echo Windows AIK DVDを %DRV_AIK% にセットして下さい。
    Set /P INP_ANS=実行してよろしいでしょうか？ [Y/N/E] ^(Yes/No/Exit^)
    If /I "%INP_ANS%" EQU "E" (GoTo :DONE)
    If /I "%INP_ANS%" NEQ "Y" (GoTo :INPUT_SET_WAIK)

    MSIexec /a "%DRV_AIK%\wAIKAMD64.msi" TargetDir="%DIR_WRK%\wAIKAMD64" /qn || GoTo Done

    Copy /B "%DIR_WRK%\wAIKAMD64\Tools\amd64\oscdimg.exe" "%DIR_WIM%\bin\Oscdimg\amd64" || GoTo Done
    Copy /B "%DIR_WRK%\wAIKAMD64\Tools\x86\oscdimg.exe"   "%DIR_WIM%\bin\Oscdimg\x86"   || GoTo Done

    Copy /B "%DIR_WRK%\wAIKAMD64\Tools\PETools\amd64\boot\efisys.bin"          "%DIR_WIM%\bin\Oscdimg\amd64" || GoTo Done
    Copy /B "%DIR_WRK%\wAIKAMD64\Tools\PETools\amd64\boot\efisys_noprompt.bin" "%DIR_WIM%\bin\Oscdimg\amd64" || GoTo Done
    Copy /B "%DIR_WRK%\wAIKAMD64\Tools\PETools\amd64\boot\etfsboot.com"        "%DIR_WIM%\bin\Oscdimg\amd64" || GoTo Done

Rem Copy /B "%DIR_WRK%\wAIKAMD64\Tools\PETools\x86\boot\efisys.bin"            "%DIR_WIM%\bin\Oscdimg\x86" || GoTo Done
Rem Copy /B "%DIR_WRK%\wAIKAMD64\Tools\PETools\x86\boot\efisys_noprompt.bin"   "%DIR_WIM%\bin\Oscdimg\x86" || GoTo Done
    Copy /B "%DIR_WRK%\wAIKAMD64\Tools\PETools\x86\boot\etfsboot.com"          "%DIR_WIM%\bin\Oscdimg\x86" || GoTo Done

    Copy /B "%DIR_WRK%\wAIKAMD64\Tools\PETools\amd64\efi\boot\bootx64.efi" "%DIR_WIM%\w7\pkg\efi" || GoTo Done

    RmDir /S /Q "%DIR_WRK%\wAIKAMD64"

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** 作業終了 ******************************************************************
    Echo [Enter]を押下してください。
    Pause > Nul 2>&1
    Echo On

Rem *** Memo ******************************************************************
Rem CScript download.vbs /function:fncDownload /winsppm:"C:\WimWK\bin" /list:"C:\WimWK\lst\Windows7_Rollup_201711.lst" /update:"C:\WimWK\w7\pkg" /timezone:utc
Rem For /R "C:\WimWK\w7\pkg" %I In ("*.zip") Do If Not Exist "%~dpnI" (UnZip -q -o "%I" -d "%~dpnI")
Rem *** Memo ******************************************************************
