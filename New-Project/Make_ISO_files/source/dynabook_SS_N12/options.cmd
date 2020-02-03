Rem ---------------------------------------------------------------------------
Rem 2020/02/03 13:32:00.78 maked
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
    Cmd /C PnpUtil -A "%configsetroot%\autounattend\options\drv\200000241_dbbd9421c7e464a2fd7a0f910946e140e52d7a88\*.inf"
    Cmd /C PnpUtil -A "%configsetroot%\autounattend\options\drv\20301636_d5e5018721292798b49e8cbc9d80ea2a51cf1577\*.inf"
    Cmd /C PnpUtil -A "%configsetroot%\autounattend\options\drv\20613990_06c69b11464d788830d23d3cc397c14337a40616\*.inf"
    Cmd /C PnpUtil -A "%configsetroot%\autounattend\options\drv\20941520_c8ce8c3504ee36697164eddda18aa8740f455849\*.inf"
    Cmd /C PnpUtil -A "%configsetroot%\autounattend\options\drv\20541202_69255649c39c0b2eeaa72014f7cfb1c4fd673ae1\*.inf"
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-x86-x64-enu.exe" /norestart /passive
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-x86-x64-allos-jpn.exe" /norestart /passive
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-kb4503575-x64.exe" /norestart /passive
    Cmd /C "%configsetroot%\autounattend\options\upd\ndp48-kb4515847-x64.exe" /norestart /passive
    Cmd /C "%configsetroot%\autounattend\options\upd\windows-kb890830-x64-v5.79.exe" /Q
    Cmd /C "%configsetroot%\autounattend\options\upd\mpas-fe-x64.exe" -q
    Cmd /C "%configsetroot%\autounattend\options\upd\MSEInstall-x64.exe" /s /runwgacheck /o
    Cmd /C "%configsetroot%\autounattend\options\upd\mpam-fe-x64.exe" -q
    Cmd /C "%configsetroot%\autounattend\options\upd\silverlight.exe" /q
    Cmd /C Wusa "%configsetroot%\autounattend\options\upd\windows6.1-kb2533552-x64.msu" /quiet /norestart
    Cmd /C Wusa "%configsetroot%\autounattend\options\upd\windows6.1-kb4534310-x64.msu" /quiet /norestart
    Cmd /C msiexec /i "%configsetroot%\autounattend\options\upd\MicrosoftEdgeEnterprise-x64.msi" /quiet /norestart
Rem ---------------------------------------------------------------------------
Rem Cmd /C RmDel /S /Q "%configsetroot%"
Rem ---------------------------------------------------------------------------
    Cmd /C shutdown /r /t 3
Rem ---------------------------------------------------------------------------
    Echo %DATE% %TIME% End
Rem ---------------------------------------------------------------------------
    pause
Rem ---------------------------------------------------------------------------
