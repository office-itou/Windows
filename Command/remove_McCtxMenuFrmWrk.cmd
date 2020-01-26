@echo off
:Start

    if not exist "%USERPROFILE%\Desktop\reg1.reg" reg export "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\McCtxMenuFrmWrk"        "%USERPROFILE%\Desktop\reg1.reg"
    if not exist "%USERPROFILE%\Desktop\reg2.reg" reg export "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Folder\shellex\ContextMenuHandlers\McCtxMenuFrmWrk"   "%USERPROFILE%\Desktop\reg2.reg"
    if not exist "%USERPROFILE%\Desktop\reg3.reg" reg export  "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\lnkfile\shellex\ContextMenuHandlers\McCtxMenuFrmWrk" "%USERPROFILE%\Desktop\reg3.reg"

    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\McCtxMenuFrmWrk"       /f
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Folder\shellex\ContextMenuHandlers\McCtxMenuFrmWrk"  /f
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\lnkfile\shellex\ContextMenuHandlers\McCtxMenuFrmWrk" /f

    goto End

:End
    pause.
