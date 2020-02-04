Rem ---------------------------------------------------------------------------
Rem 2020/02/04  7:44:26.07 maked
Rem ---------------------------------------------------------------------------
    Echo %DATE% %TIME% Start
Rem ---------------------------------------------------------------------------
Rem Cmd /C sc stop wuauserv
Rem ---------------------------------------------------------------------------
    Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "AUOptions" /t REG_DWORD /d 1
    Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "IncludeRecommendedUpdates" /t REG_DWORD /d 1
    Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "ElevateNonAdmins" /t REG_DWORD /d 1
    Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "EnableFeaturedSoftware" /t REG_DWORD /d 1
Rem ---------------------------------------------------------------------------
    Cmd /C Wusa "%configsetroot%\autounattend\options\upd\windows6.1-kb2533552-x64.msu" /quiet /norestart
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-x86-x64-enu.exe" /norestart /passive
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-x86-x64-allos-jpn.exe" /norestart /passive
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-kb4503575-x64.exe" /norestart /passive
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-kb4515847-x64.exe" /norestart /passive
    Cmd /C "%configsetroot%\autounattend\options\upd\silverlight.exe" /q
    Cmd /C "%configsetroot%\autounattend\options\upd\windows-kb890830-x64-v5.79.exe" /Q
    Cmd /C "%configsetroot%\autounattend\options\upd\mpas-fe-x64.exe" -q
    Cmd /C "%configsetroot%\autounattend\options\upd\MSEInstall-x64.exe" /s /runwgacheck /o
    Cmd /C "%configsetroot%\autounattend\options\upd\mpam-fe-x64.exe" -q
    Cmd /C msiexec /i "%configsetroot%\autounattend\options\upd\MicrosoftEdgeEnterprise-x64.msi" /quiet /norestart
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\200000241_dbbd9421c7e464a2fd7a0f910946e140e52d7a88\*.inf"
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20299669_76d0d6efab2aad50ef9e4fca271c078cdea964ad\*.inf"
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20578785_5ecba0393438142c5f043e5a9360f3e9a87fb9ba\*.inf"
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20941520_c8ce8c3504ee36697164eddda18aa8740f455849\*.inf"
    Cmd /C PnpUtil -i -a "%configsetroot%\autounattend\options\drv\20411792_1372ed66ee58742cd0974ec85ddf67ef23dcae4d\*.inf"
Rem ---------------------------------------------------------------------------
Rem Cmd /C RmDel /S /Q "%configsetroot%"
Rem ---------------------------------------------------------------------------
    Cmd /C shutdown /r /t 3
Rem ---------------------------------------------------------------------------
    Echo %DATE% %TIME% End
Rem ---------------------------------------------------------------------------
    pause
Rem ---------------------------------------------------------------------------
