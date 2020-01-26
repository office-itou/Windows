@echo off
:Start

    reg delete "HKEY_CURRENT_USER\Software\Justsystem\JswMail\User0\AddrFrame" /f /v "FrameRect"   > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Justsystem\JswMail\User0\AddrFrame" /f /v "FrameZoomed" > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Justsystem\JswMail\User0\MainFrame" /f /v "FrameRect"   > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Justsystem\JswMail\User0\MainFrame" /f /v "FrameZoomed" > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Justsystem\JswMail\User0\SendFrame" /f /v "FrameRect"   > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Justsystem\JswMail\User0\SendFrame" /f /v "FrameZoomed" > NUL 2>&1

    goto End

:End
    pause.
