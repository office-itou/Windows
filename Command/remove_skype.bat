@echo off
:Start

    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /f /v "Skype" > NUL 2>&1

    goto End

:End
    pause.
