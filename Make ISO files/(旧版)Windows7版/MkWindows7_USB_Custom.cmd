Rem ***************************************************************************
    @Echo Off
    Cls

Rem 作業開始 ******************************************************************
:START
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

Rem --- DVDとUSBのドライブ名設定 ----------------------------------------------
    Echo --- DVDのドライブ名設定 -------------------------------------------------------
    Set /P DRV_DVD=DVDのドライブ名を入力して下さい。 [A-Z]
    If /I "%DRV_DVD:~1,1%" NEQ ":" (Set DRV_DVD=%DRV_DVD:~0,1%:)

    Echo --- USBのドライブ名設定 -------------------------------------------------------
    Set /P DRV_USB=USBのドライブ名を入力して下さい。 [A-Z]
    If /I "%DRV_USB:~1,1%" NEQ ":" (Set DRV_USB=%DRV_USB:~0,1%:)

Rem 環境変数設定 --------------------------------------------------------------
    Set WIM_TOP=%CD%
    Set DVD_SRC=%DRV_DVD%\\
    Set USB_DST=%DRV_USB%\\

    If Not Exist "%DRV_DVD%\sources\install.wim" (
        Echo コピー元のDVDを"%DRV_DVD%"にセットして下さい。
        GoTo DONE
    )

:MAKE
Rem *** USBメモリーを作成する *************************************************
    Echo> "%WIM_TOP%\DiskPart1.txt" Rem DiskPart1
    Echo>>"%WIM_TOP%\DiskPart1.txt" List Vol
    Echo>>"%WIM_TOP%\DiskPart1.txt" List Disk
    Echo>>"%WIM_TOP%\DiskPart1.txt" Exit

    DiskPart /S "%WIM_TOP%\DiskPart1.txt"

    Set /P IDX_DRV=USBメモリーのディスク・インデックス番号を入力して下さい。

    Echo> "%WIM_TOP%\DiskPart2.txt" Rem DiskPart2
    Echo>>"%WIM_TOP%\DiskPart2.txt" Select Disk %IDX_DRV%
    Echo>>"%WIM_TOP%\DiskPart2.txt" Clean
    Echo>>"%WIM_TOP%\DiskPart2.txt" Create Partition Primary
    Echo>>"%WIM_TOP%\DiskPart2.txt" Select Partition 1
    Echo>>"%WIM_TOP%\DiskPart2.txt" Format FS=FAT32 Quick
    Echo>>"%WIM_TOP%\DiskPart2.txt" Active
    Echo>>"%WIM_TOP%\DiskPart2.txt" Assign Letter=%DRV_USB%
    Echo>>"%WIM_TOP%\DiskPart2.txt" Exit

    Echo -------------------------------------------------------------------------------
    Type "%WIM_TOP%\DiskPart2.txt"
    Echo -------------------------------------------------------------------------------
    Echo 以上のパラメーターでUSBメモリーを作成します。
    Set /P INP_ANS=実行してよろしいでしょうか？ [Y/N/E] ^(Yes/No/Exit^)
    If /I "%INP_ANS%" EQU "E" (GoTo DONE)
    If /I "%INP_ANS%" NEQ "Y" (GoTo MAKE)

    DiskPart /S "%WIM_TOP%\DiskPart2.txt"

    Robocopy /E /A-:R "%DVD_SRC%" "%USB_DST%"

    CD /D "%DRV_DVD%\boot"
    BootSect /NT60 %DRV_USB%

    If Exist "%WIM_TOP%\DiskPart1.txt" (Del "%WIM_TOP%\DiskPart1.txt")
    If Exist "%WIM_TOP%\DiskPart2.txt" (Del "%WIM_TOP%\DiskPart2.txt")

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** 作業終了 ******************************************************************
    Echo [Enter]を押下してください。
    Pause > Nul 2>&1
    Echo On
