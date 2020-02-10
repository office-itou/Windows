Rem ---------------------------------------------------------------------------
Rem 2020/02/10 15:10:28.50 maked
Rem ---------------------------------------------------------------------------
    Echo %DATE% %TIME% Start
Rem --- NTP Setup -------------------------------------------------------------
Rem Cmd /C sc stop w32time
    Cmd /C reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "" /t REG_SZ /d "0" /f                                       || Pause
    Cmd /C reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "0" /t REG_SZ /d "ntp.nict.jp" /f                            || Pause
    Cmd /C reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "UpdateInterval" /t REG_DWORD /d "0x00057e40" /f                       || Pause
    Cmd /C reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /t REG_SZ /d "NTP" /f                                       || Pause
    Cmd /C reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /t REG_SZ /d "ntp.nict.jp,0x9" /f                      || Pause
    Cmd /C reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d "0x00005460" /f || Pause
    Cmd /C reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollTimeRemaining" /t REG_MULTI_SZ /d "" /f   || Pause
    Cmd /C sc config w32time start= delayed-auto                                                                                                                   || Pause
Rem Cmd /C sc start w32time
Rem --- Paint Desktop Version Setup -------------------------------------------
    Cmd /C reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "PaintDesktopVersion" /t REG_DWORD /d "00000001" /f || Pause
Rem ---------------------------------------------------------------------------
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\200000241_dbbd9421c7e464a2fd7a0f910946e140e52d7a88\*.inf" || Pause
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20299669_76d0d6efab2aad50ef9e4fca271c078cdea964ad\*.inf" || Pause
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20578785_5ecba0393438142c5f043e5a9360f3e9a87fb9ba\*.inf" || Pause
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20941520_c8ce8c3504ee36697164eddda18aa8740f455849\*.inf" || Pause
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20411792_1372ed66ee58742cd0974ec85ddf67ef23dcae4d\*.inf" || Pause
    Cmd /C msiexec /i "%configsetroot%\autounattend\options\upd\MicrosoftEdgeEnterprise-x64.msi" /quiet /norestart || Pause
    Cmd /C "%configsetroot%\autounattend\options\upd\silverlight.exe" /q || Pause
    Cmd /C "%configsetroot%\autounattend\options\upd\windows-kb890830-x64-v5.79.exe" /Q || Pause
    Cmd /C "%configsetroot%\autounattend\options\upd\mpas-fe-x64.exe" -q || Pause
    Cmd /C "%configsetroot%\autounattend\options\upd\MSEInstall-x64.exe" /s /runwgacheck /o || Pause
    Cmd /C "%configsetroot%\autounattend\options\upd\mpam-fe-x64.exe" -q || Pause
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-x86-x64-enu.exe" /norestart /passive || Pause
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-x86-x64-allos-jpn.exe" /norestart /passive || Pause
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-kb4503575-x64.exe" /norestart /passive || Pause
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-kb4515847-x64.exe" /norestart /passive || Pause
Rem ---------------------------------------------------------------------------
Rem Cmd /C Del /F /S /Q "%configsetroot%" > Nul || Pause
Rem Cmd /C For /D %%I In (%configsetroot%\*) Do (RmDir /S /Q %%I > Nul || Pause)
Rem ---------------------------------------------------------------------------
    Cmd /C shutdown /r /t 3 || Pause
Rem ---------------------------------------------------------------------------
:DONE
    Echo %DATE% %TIME% End
Rem ---------------------------------------------------------------------------
    pause
Rem ---------------------------------------------------------------------------
