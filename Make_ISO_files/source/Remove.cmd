Rem ***************************************************************************
@Echo Off
    Cls

Rem *** 作業開始 **************************************************************
:START
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableExtensions
    SetLocal EnableDelayedExpansion

Rem --- 作業環境確認 ----------------------------------------------------------
    If /I "%USERNAME%" NEQ "Administrator" (
        If /I "%SESSIONNAME%" NEQ "" (
            Echo 管理者特権で実行して下さい。
            GoTo DONE
        )
    )

Rem --- 環境変数設定 ----------------------------------------------------------
    For /F "usebackq delims=" %%I In (`Echo %0`) Do (
        Set WRK_DIR=%%~dpI
        Set WRK_DIR=!WRK_DIR:~0,-1!
        Set WRK_FIL=%%~nxI
        Set WRK_NAM=%%~nI
    )

    Set NOW_DAY=%date:~0,4%%date:~5,2%%date:~8,2%

    If /I "%time:~0,1%" EQU " " (
        Set NOW_TIM=0%time:~1,1%%time:~3,2%%time:~6,2%
    ) Else (
        Set NOW_TIM=%time:~0,2%%time:~3,2%%time:~6,2%
    )

    For /F "tokens=1-2 usebackq delims=\" %%I In ('!WRK_DIR!') Do (Set WRK_TOP=%%~I\%%~J)

Rem *** Unmount and Remove ****************************************************
Rem Dism /Cleanup-Mountpoints
Rem Dism /Cleanup-WIM
    Set WIM_WRK=!WRK_TOP!\wrk
    For /D %%I In ("!WIM_WRK!\*") Do (
        Set WIM_NOW=%%~I
        If Exist "!WIM_NOW!" (
            If /I "!WIM_NOW:~0,77!" EQU "!WIM_NOW!" (Echo "!WIM_NOW!") Else (Echo "!WIM_NOW:~0,59!...!WIM_NOW:~-15!")
            For /D %%J In ("!WIM_NOW!\*") Do (
                Set WRK_NAM=MakeIsoFile
                Set WIN_VER=%%~nI
                Set WIN_VER=!WIN_VER:~1!!
                Set ARC_TYP=%%~nJ
                Set NOW_DAY=%%~xI
                Set NOW_DAY=!NOW_DAY:~1,8!
                Set NOW_TIM=%%~xI
                Set NOW_TIM=!NOW_TIM:~9!
                Set CMD_DAT=!WIM_WRK!\!WRK_NAM!.w!WIN_VER!.!ARC_TYP!.!NOW_DAY!!NOW_TIM!.dat
                Set CMD_WRK=!WIM_WRK!\!WRK_NAM!.w!WIN_VER!.!ARC_TYP!.!NOW_DAY!!NOW_TIM!.wrk
                Set CMD_WIM=!CMD_DAT!.wim
                Set CMD_WRE=!CMD_DAT!.wre
                If Exist "!CMD_DAT!" (Del /F "!CMD_DAT!")
                If Exist "!CMD_WRK!" (Del /F "!CMD_WRK!")
                If Exist "!CMD_WIM!" (Del /F "!CMD_WIM!")
                If Exist "!CMD_WRE!" (Del /F "!CMD_WRE!")
            )
            If Exist "!WIM_NOW!\!ARC_TYP!\bt1\Windows\\" (Dism /UnMount-Wim /MountDir:"!WIM_NOW!\!ARC_TYP!\bt1" /Discard)
            If Exist "!WIM_NOW!\!ARC_TYP!\bt2\Windows\\" (Dism /UnMount-Wim /MountDir:"!WIM_NOW!\!ARC_TYP!\bt2" /Discard)
            If Exist "!WIM_NOW!\!ARC_TYP!\wre\Windows\\" (Dism /UnMount-Wim /MountDir:"!WIM_NOW!\!ARC_TYP!\wre" /Discard)
            If Exist "!WIM_NOW!\!ARC_TYP!\mnt\Windows\\" (Dism /UnMount-Wim /MountDir:"!WIM_NOW!\!ARC_TYP!\mnt" /Discard)
Rem         TakeOwn /F "!WIM_NOW!\*.*" /A /R /D Y > NUL 2>&1
Rem         ICacls "!WIM_NOW!" /reset /T /Q
            RmDir /S /Q "!WIM_NOW!"
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
