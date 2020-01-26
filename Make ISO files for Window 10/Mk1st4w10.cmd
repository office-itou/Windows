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

    If /I "%windir%" EQU "%SystemDrive%\WINNT" (
        Set NOW_DAY=%date:~2,4%%date:~7,2%%date:~10,2%
    ) Else (
        Set NOW_DAY=%date:~0,4%%date:~5,2%%date:~8,2%
    )

    If /I "%time:~0,1%" EQU " " (
        Set NOW_TIM=0%time:~1,1%%time:~3,2%%time:~6,2%
    ) Else (
        Set NOW_TIM=%time:~0,2%%time:~3,2%%time:~6,2%
    )

    CD "%DIR_WRK%\.."
    Set WIM_DIR=%CD%
    CD "%DIR_WRK%"

    Set WIM_TYP=w10
    Set WIM_DIR=C:\WimWK
    Set WIM_TOP=%WIM_DIR%\%WIM_TYP%
    Set WIM_BIN=%WIM_DIR%\bin
    Set WIM_CFG=%WIM_DIR%\cfg
    Set WIM_LST=%WIM_DIR%\lst
    Set WIM_PKG=%WIM_TOP%\pkg
    Set WIM_ADK=%WIM_PKG%\adk
    Set WIM_DRV=%WIM_PKG%\drv
    Set WIM_EFI=%WIM_PKG%\efi
    Set WIM_X64=%WIM_PKG%\x64
    Set WIM_X86=%WIM_PKG%\x86
    Set WIM_BAK=%WIM_PKG%\bak\%CPU_TYP%
    Set DIR_LST=adk drv zip x32 x64

Rem *** 作業フォルダーの作成 **************************************************
    Echo *** 作業フォルダーの作成 ******************************************************
    If Exist "%WIM_TOP%" (
        Echo 既存ディレクトリを以下の名前に移動します。
        Echo "%WIM_TOP%"
        Echo      ↓↓
        Echo "%WIM_TOP%.%NOW_DAY%%NOW_TIM%"
        Move "%WIM_TOP%" "%WIM_TOP%.%NOW_DAY%%NOW_TIM%" || GoTo Done
    )
    If Not Exist "%WIM_BIN%" (MkDir "%WIM_BIN%")
    If Not Exist "%WIM_CFG%" (MkDir "%WIM_CFG%")
    If Not Exist "%WIM_LST%" (MkDir "%WIM_LST%")
    If Not Exist "%WIM_ADK%" (MkDir "%WIM_ADK%")
    If Not Exist "%WIM_DRV%" (MkDir "%WIM_DRV%")
    If Not Exist "%WIM_EFI%" (MkDir "%WIM_EFI%")
    If Not Exist "%WIM_X64%" (MkDir "%WIM_X64%")
    If Not Exist "%WIM_X86%" (MkDir "%WIM_X86%")
    If Not Exist "%WIM_BAK%" (MkDir "%WIM_BAK%")

Rem *** ファイル・コピー ******************************************************
    Echo *** ファイル・コピー **********************************************************
Rem --- GitHub ----------------------------------------------------------------
    Echo --- GitHub --------------------------------------------------------------------
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/MicrosoftUpdateCatalog.url"
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/MkWindows10_ISO_files_Custom.cmd"
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/MkWindows10_USB_Custom.cmd"
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/Windows10adk_Rollup_202001.lst"
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/Windows10drv_Rollup_202001.lst"
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/Windows10x32_Rollup_202001.lst"
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/Windows10x64_Rollup_202001.lst"
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/Windows10zip_Rollup_202001.lst"
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/autounattend-windows10-x64.xml"
    Curl -L -# -R -O "https://raw.githubusercontent.com/office-itou/Windows/master/Make%%20ISO%%20files%%20for%%20Window%%2010/autounattend-windows10-x86.xml"
Rem --- LF -> CRLF 変換 -------------------------------------------------------
Rem more < "MkWindows10_ISO_files_Custom.cmd" > "Mk1st.tmp" && Move /Y "Mk1st.tmp" "MkWindows10_ISO_files_Custom.cmd"
Rem more < "MkWindows10_USB_Custom.cmd"       > "Mk1st.tmp" && Move /Y "Mk1st.tmp" "MkWindows10_USB_Custom.cmd"
Rem more < "Windows10adk_Rollup_202001.lst"   > "Mk1st.tmp" && Move /Y "Mk1st.tmp" "Windows10adk_Rollup_202001.lst"
Rem more < "Windows10drv_Rollup_202001.lst"   > "Mk1st.tmp" && Move /Y "Mk1st.tmp" "Windows10drv_Rollup_202001.lst"
Rem more < "Windows10x32_Rollup_202001.lst"   > "Mk1st.tmp" && Move /Y "Mk1st.tmp" "Windows10x32_Rollup_202001.lst"
Rem more < "Windows10x64_Rollup_202001.lst"   > "Mk1st.tmp" && Move /Y "Mk1st.tmp" "Windows10x64_Rollup_202001.lst"
Rem more < "autounattend-windows10-x64.xml"   > "Mk1st.tmp" && Move /Y "Mk1st.tmp" "autounattend-windows10-x64.xml"
Rem more < "autounattend-windows10-x86.xml"   > "Mk1st.tmp" && Move /Y "Mk1st.tmp" "autounattend-windows10-x86.xml"

    Pushd "%DIR_WRK%"
        Copy /Y "*.xml" "%WIM_CFG%"
        Copy /Y "*.url" "%WIM_BIN%"
        Copy /Y "*.cmd" "%WIM_BIN%"
        Copy /Y "*.lst" "%WIM_LST%"
    Popd

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

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
