Rem ***************************************************************************
    @Echo Off
    Cls

Rem ��ƊJ�n ******************************************************************
:START
    Echo *** ��ƊJ�n ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

Rem --- DVD��USB�̃h���C�u���ݒ� ----------------------------------------------
    Echo --- DVD�̃h���C�u���ݒ� -------------------------------------------------------
    Set /P DRV_DVD=DVD�̃h���C�u������͂��ĉ������B [A-Z]
    If /I "%DRV_DVD:~1,1%" NEQ ":" (Set DRV_DVD=%DRV_DVD:~0,1%:)

    Echo --- USB�̃h���C�u���ݒ� -------------------------------------------------------
    Set /P DRV_USB=USB�̃h���C�u������͂��ĉ������B [A-Z]
    If /I "%DRV_USB:~1,1%" NEQ ":" (Set DRV_USB=%DRV_USB:~0,1%:)

Rem ���ϐ��ݒ� --------------------------------------------------------------
    Set WIM_TOP=%CD%
    Set DVD_SRC=%DRV_DVD%\\
    Set USB_DST=%DRV_USB%\\

    If Not Exist "%DRV_DVD%\sources\install.wim" (
        Echo �R�s�[����DVD��"%DRV_DVD%"�ɃZ�b�g���ĉ������B
        GoTo DONE
    )

:MAKE
Rem *** USB�������[���쐬���� *************************************************
    Echo> "%WIM_TOP%\DiskPart1.txt" Rem DiskPart1
    Echo>>"%WIM_TOP%\DiskPart1.txt" List Vol
    Echo>>"%WIM_TOP%\DiskPart1.txt" List Disk
    Echo>>"%WIM_TOP%\DiskPart1.txt" Exit

    DiskPart /S "%WIM_TOP%\DiskPart1.txt"

    Set /P IDX_DRV=USB�������[�̃f�B�X�N�E�C���f�b�N�X�ԍ�����͂��ĉ������B

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
    Echo �ȏ�̃p�����[�^�[��USB�������[���쐬���܂��B
    Set /P INP_ANS=���s���Ă�낵���ł��傤���H [Y/N/E] ^(Yes/No/Exit^)
    If /I "%INP_ANS%" EQU "E" (GoTo DONE)
    If /I "%INP_ANS%" NEQ "Y" (GoTo MAKE)

    DiskPart /S "%WIM_TOP%\DiskPart2.txt"

    Robocopy /E /A-:R "%DVD_SRC%" "%USB_DST%"

    CD /D "%DRV_DVD%\boot"
    BootSect /NT60 %DRV_USB%

    If Exist "%WIM_TOP%\DiskPart1.txt" (Del "%WIM_TOP%\DiskPart1.txt")
    If Exist "%WIM_TOP%\DiskPart2.txt" (Del "%WIM_TOP%\DiskPart2.txt")

Rem *** ��ƏI�� **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** ��ƏI�� ******************************************************************
    Echo [Enter]���������Ă��������B
    Pause > Nul 2>&1
    Echo On
