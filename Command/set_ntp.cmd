@echo off
:Start
    if "%1" == "" (
        net stop w32time

        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "" /t REG_SZ /d "0" /f
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "0" /t REG_SZ /d "ntp.nict.jp" /f
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "UpdateInterval" /t REG_DWORD /d "0x00057e40" /f
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /t REG_SZ /d "NTP" /f
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /t REG_SZ /d "ntp.nict.jp,0x9" /f
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d "0x00005460" /f
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollTimeRemaining" /t REG_MULTI_SZ /d "" /f

        sc config w32time start= delayed-auto
        net start w32time
rem     w32tm /query /source
    ) else (
        net stop w32time
        W32tm /unregister
        W32tm /register
        reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "" /t REG_SZ /d "1" /f
        reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "0" /f
    )

    reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /s 
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "UpdateInterval"
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type"
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer"
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval"
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollTimeRemaining"

    goto End

:End
    pause.
