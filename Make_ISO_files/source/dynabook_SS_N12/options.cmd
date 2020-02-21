Rem ---------------------------------------------------------------------------
Rem 2020/02/21  0:07:45.28 maked
Rem ---------------------------------------------------------------------------
    Echo %DATE% %TIME% Start
Rem ---------------------------------------------------------------------------
    Set Path=%configsetroot%\autounattend\options\bin;%Path%
Rem --- NTP Setup -------------------------------------------------------------
Rem sc stop w32time
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "" /t REG_SZ /d "0" /f
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "0" /t REG_SZ /d "ntp.nict.jp" /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "UpdateInterval" /t REG_DWORD /d "0x00057e40" /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /t REG_SZ /d "NTP" /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /t REG_SZ /d "ntp.nict.jp,0x9" /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d "0x00005460" /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollTimeRemaining" /t REG_MULTI_SZ /d "" /f
    sc config w32time start= delayed-auto
Rem sc start w32time
Rem --- Package ---------------------------------------------------------------
    msiexec /i "%configsetroot%\autounattend\options\upd\MicrosoftEdgeEnterprise-x64.msi" /quiet /norestart
    "%configsetroot%\autounattend\options\upd\windows-kb890830-x64-v5.80.exe" /x
    Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -o "%configsetroot%\autounattend\options\upd\mpas-fe-x64.exe.tmp" "https://go.microsoft.com/fwlink/?LinkID=121721&clcid=0x409&arch=x64&eng=0.0.0.0&avdelta=0.0.0.0&asdelta=0.0.0.0&prod=925A3ACA-C353-458A-AC8D-A7E5EB378092" && Attrib -R "%configsetroot%\autounattend\options\upd\mpas-fe-x64.exe" && Move "%configsetroot%\autounattend\options\upd\mpas-fe-x64.exe.tmp" "%configsetroot%\autounattend\options\upd\mpas-fe-x64.exe"
    "%configsetroot%\autounattend\options\upd\mpas-fe-x64.exe" -q
    "%configsetroot%\autounattend\options\upd\MSEInstall-x64.exe" /s /runwgacheck /o
    Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -o "%configsetroot%\autounattend\options\upd\mpam-fe-x64.exe.tmp" "https://go.microsoft.com/fwlink/?LinkID=121721&arch=x64" && Attrib -R "%configsetroot%\autounattend\options\upd\mpam-fe-x64.exe" && Move "%configsetroot%\autounattend\options\upd\mpam-fe-x64.exe.tmp" "%configsetroot%\autounattend\options\upd\mpam-fe-x64.exe"
    "%configsetroot%\autounattend\options\upd\mpam-fe-x64.exe" -q
    "%configsetroot%\autounattend\options\upd\ndp48-x86-x64-enu.exe" /norestart /passive
    "%configsetroot%\autounattend\options\upd\ndp48-x86-x64-allos-jpn.exe" /norestart /passive
    "%configsetroot%\autounattend\options\upd\ndp48-kb4503575-x64.exe" /norestart /passive
    "%configsetroot%\autounattend\options\upd\ndp48-kb4515847-x64.exe" /norestart /passive
    "%configsetroot%\autounattend\options\upd\silverlight-x64.exe" /q
    PnpUtil -i -a "%configsetroot%\autounattend\options\drv\200000241_dbbd9421c7e464a2fd7a0f910946e140e52d7a88\*.inf"
    PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20299669_76d0d6efab2aad50ef9e4fca271c078cdea964ad\*.inf"
Rem PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20299668_973f2f7d4d6c6904b66bd7f32be04756f5a9c059\*.inf"
    PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20578785_5ecba0393438142c5f043e5a9360f3e9a87fb9ba\*.inf"
Rem PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20578786_74986e9b140db6cc7968f1845e372c5b5984ecaa\*.inf"
    PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20411792_1372ed66ee58742cd0974ec85ddf67ef23dcae4d\*.inf"
Rem PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20411791_1a1c67a7965c638485cfc25a363737ee46113db8\*.inf"
    PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20284342_6ef00f64329eb2380a7bc87a811f3da848cfba40\*.inf"
Rem PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20284341_7b1a5fd471387b2aaa58464c9c894583f4ed9d93\*.inf"
    PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20941520_c8ce8c3504ee36697164eddda18aa8740f455849\*.inf"
Rem --- Cleaning --------------------------------------------------------------
Rem Del /F /S /Q "%configsetroot%" > Nul
Rem For /D %%I In ("%configsetroot%\*") Do (RmDir /S /Q "%%~I" > Nul )
Rem --- Reboot-----------------------------------------------------------------
Rem shutdown /r /t 3
Rem ---------------------------------------------------------------------------
:DONE
    Echo %DATE% %TIME% End
Rem ---------------------------------------------------------------------------
Rem pause
Rem ---------------------------------------------------------------------------
