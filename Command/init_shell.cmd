@echo off
:Start
    if "%ProgramData%" EQU "" (
        echo "`WinXP”»’è"
        goto WinXP
    ) else (
        if "%PROCESSOR_ARCHITECTURE%" EQU "x86" (
            echo "WinVista(x86)`”»’è"
            goto WinVista_x86
        ) else (
            echo "WinVista(x64)`”»’è"
            goto WinVista_x64
        )
    )

    echo "ƒGƒ‰[”»’è"

    goto End

rem ` XP ---------------------------------------------------------------------
:WinXP
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Bags" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\BagMRU" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\ShellNoRoam" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\ShellNoRoam\BagMRU" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\ShellNoRoam\Bags" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Window_Placement" /f > NUL 2>&1

    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell" /v "BagMRU Size" /d "5000" /f > NUL 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\ShellNoRoam" /v "BagMRU Size" /d "5000" /f > NUL 2>&1

    goto End

rem Vista(x64) ` -------------------------------------------------------------
:WinVista_x64
    reg delete "HKEY_CURRENT_USER\Software\Classes\Wow6432Node\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Classes\Wow6432Node\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f > NUL 2>&1
rem reg delete "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Window_Placement" /f > NUL 2>&1

    reg add "HKEY_CURRENT_USER\Software\Classes\Wow6432Node\Local Settings\Software\Microsoft\Windows\Shell\Bags" /v "BagMRU Size" /d "5000" /f > NUL 2>&1
    reg add "HKEY_CURRENT_USER\Software\Classes\Wow6432Node\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /v "BagMRU Size" /d "5000" /f > NUL 2>&1

rem goto End

rem Vista(x86) ` -------------------------------------------------------------
:WinVista_x86
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Bags" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\BagMRU" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\ShellNoRoam\Bags" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\ShellNoRoam\BagMRU" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f > NUL 2>&1
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Window_Placement" /f > NUL 2>&1

    reg add "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /v "BagMRU Size" /d "5000" /f > NUL 2>&1
    reg add "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /v "BagMRU Size" /d "5000" /f > NUL 2>&1

    goto End

:End
    pause.
