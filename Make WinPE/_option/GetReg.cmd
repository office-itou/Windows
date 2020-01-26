    SetLocal EnableDelayedExpansion

    Set CPU_TYP=x86
    Set CPU_TYP=x64
    Set WPE_DIR=C:\WinPE.ATI2020
    Set WPE_ATI=C:\WinPE.ATI2020\ati
    Set WPE_TOP=C:\WinPE.ATI2020\x64
    Set WPE_MNT=C:\WinPE.ATI2020\x64\mount

Rem --- Make Directry ---------------------------------------------------------
    If Not Exist "C:\WinPE.ATI2020\ati"       (MkDir "C:\WinPE.ATI2020\ati")
    If Not Exist "C:\WinPE.ATI2020\x64\mount" (MkDir "C:\WinPE.ATI2020\x64\mount")

Rem --- Mount Image -----------------------------------------------------------
    Dism /Apply-Image /ImageFile:"%USERPROFILE%\Desktop\AcronisBootablePEMedia %CPU_TYP%.wim" /Index:1 /ApplyDir:"C:\WinPE.ATI2020\x64\mount"

Rem --- Unmount Image ---------------------------------------------------------
    

Rem --- Save Registry ---------------------------------------------------------
    Reg Load HKLM\WPE_SOFTWARE "C:\WinPE.ATI2020\x64\mount\windows\system32\config\SOFTWARE"
    Reg Load HKLM\WPE_SYSTEM   "C:\WinPE.ATI2020\x64\mount\windows\system32\config\SYSTEM"

    Reg Export HKLM\WPE_SOFTWARE "C:\WinPE.ATI2020\ati\ATI_Software.reg" /y
    Reg Export HKLM\WPE_SYSTEM   "C:\WinPE.ATI2020\ati\ATI_System.reg"   /y

    Reg UnLoad HKLM\WPE_SYSTEM
    Reg UnLoad HKLM\WPE_SOFTWARE

Rem --- Load Registry ---------------------------------------------------------
Rem Reg Load HKLM\WPE_SOFTWARE "C:\WinPE.ATI2020\x64\mount\windows\system32\config\SOFTWARE"
Rem Reg Load HKLM\WPE_SYSTEM   "C:\WinPE.ATI2020\x64\mount\windows\system32\config\SYSTEM"

Rem Reg Import "C:\WinPE.ATI2020\ati\ATI_Software.reg"
Rem Reg Import "C:\WinPE.ATI2020\ati\ATI_System.reg"

Rem Reg UnLoad HKLM\WPE_SYSTEM
Rem Reg UnLoad HKLM\WPE_SOFTWARE

Rem ---------------------------------------------------------------------------
    TakeOwn /F "C:\WinPE.ATI2020\*.*" /A /R /D Y > NUL 2>&1
    ICacls "C:\WinPE.ATI2020" /reset /T /Q

    EndLocal
