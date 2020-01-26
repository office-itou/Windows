@echo off
:Start
    reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "PaintDesktopVersion" /t REG_DWORD /d "00000001" /f > NUL 2>&1

    goto End

:End
    pause.
