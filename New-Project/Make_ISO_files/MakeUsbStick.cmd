Rem ***************************************************************************
@Echo Off
    Cls

Rem *** ��ƊJ�n **************************************************************
:START
    Echo *** ��ƊJ�n ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableExtensions
    SetLocal EnableDelayedExpansion

Rem --- ��Ɗ��m�F ----------------------------------------------------------
    If /I "%USERNAME%" NEQ "Administrator" (
        If /I "%SESSIONNAME%" NEQ "" (
            Echo �Ǘ��ғ����Ŏ��s���ĉ������B
            GoTo DONE
        )
    )

Rem --- ���ϐ��ݒ� ----------------------------------------------------------
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

Rem *** ��Ɗ��ݒ� **********************************************************
Rem --- DVD��USB�̃h���C�u���ݒ� ----------------------------------------------
:CHK_DVD_DRIVE
    Echo --- DVD�̃h���C�u���ݒ� -------------------------------------------------------
    Set DRV_DVD=
    Set /P DRV_DVD=DVD�̃h���C�u��[A-Z] ���̓C���[�W�t�H���_�[������͂��ĉ������B
    If /I "!DRV_DVD!" EQU "" (GoTo CHK_DVD_DRIVE)

    If /I "!DRV_DVD:~1,1!" EQU "" (
        Set DRV_DVD=!DRV_DVD!:\)
    )

    For %%I in (!DRV_DVD!\) Do (
        Set DVD_SRC=%%~dpI
        If /I "!DVD_SRC:~-1!" EQU "\" (
            Set DVD_SRC=!DVD_SRC:~0,-1!
        )
    )

:CHK_USB_DRIVE
    Echo --- USB�̃h���C�u���ݒ� -------------------------------------------------------
    Set DRV_USB=
    Set /P DRV_USB=USB�̃h���C�u��[A-Z]����͂��ĉ������B
    If /I "!DRV_USB!" EQU "" (GoTo CHK_USB_DRIVE)

    If /I "!DRV_USB:~1,1!" EQU "" (
        Set DRV_USB=!DRV_USB!:\)
    )

    For %%I in (!DRV_USB!\) Do (
        Set USB_DST=%%~dpI
        If /I "!USB_DST:~-1!" EQU "\" (
            Set USB_DST=!USB_DST:~0,-1!
        )
    )

:SET_USB_FORMAT
    Echo --- USB�̃t�H�[�}�b�g�ݒ� -----------------------------------------------------
    Echo 1: FAT32
    Echo 2: NTFS
    Echo 3: exFAT
    Set IDX_USB=1
    Set /P IDX_USB=USB�̃t�H�[�}�b�g[1-3]����͂��ĉ������B�i�K��l[!IDX_USB!]�j

           If /I "!IDX_USB!" EQU "1" (Set FMT_USB=FAT32
    ) Else If /I "!IDX_USB!" EQU "2" (Set FMT_USB=NTFS
    ) Else If /I "!IDX_USB!" EQU "3" (Set FMT_USB=exFAT
    ) Else                           (GoTo SET_USB_FORMAT
    )

:SET_DVD_DRIVE
    If Not Exist "!DRV_DVD!\sources\install.wim" If Not Exist "!DRV_DVD!\sources\install.swm" (
        Echo �]������DVD��"!DRV_DVD!"�ɃZ�b�g���ĉ������B
        Echo �������ł�����[Enter]���������ĉ������B
        Pause > Nul 2>&1
        GoTo SET_DVD_DRIVE
    )

Rem --- ���ϐ��ݒ� ----------------------------------------------------------
    Set CMD_WK1=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!.DiskPart1.txt
    Set CMD_WK2=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!.DiskPart2.txt
    Set CMD_IMG=!WRK_DIR!\!WRK_NAM!.!NOW_DAY!!NOW_TIM!

Rem --- ��ƃt�@�C���̍폜 ----------------------------------------------------
    If Exist "!CMD_WK1!" (Del /F "!CMD_WK1!" || GoTo DONE)
    If Exist "!CMD_WK2!" (Del /F "!CMD_WK2!" || GoTo DONE)

:MAKE
Rem *** USB�������[���쐬���� *************************************************
    Echo> "!CMD_WK1!" Rem DiskPart1
    Echo>>"!CMD_WK1!" List Vol
    Echo>>"!CMD_WK1!" List Disk
    Echo>>"!CMD_WK1!" Exit

    DiskPart /S "!CMD_WK1!" || GoTo DONE

    Set /P IDX_DRV=USB�������[�̃f�B�X�N�E�C���f�b�N�X�ԍ�����͂��ĉ������B

    Echo> "!CMD_WK2!" Rem DiskPart2
    Echo>>"!CMD_WK2!" Select Disk !IDX_DRV!
    Echo>>"!CMD_WK2!" Clean
    Echo>>"!CMD_WK2!" Create Partition Primary
    Echo>>"!CMD_WK2!" Select Partition 1
    Echo>>"!CMD_WK2!" Format FS=!FMT_USB! Quick
    Echo>>"!CMD_WK2!" Active
    Echo>>"!CMD_WK2!" Assign Letter=!DRV_USB:~0,1!
    Echo>>"!CMD_WK2!" Exit

    Echo -------------------------------------------------------------------------------
    Type "!CMD_WK2!"
    Echo -------------------------------------------------------------------------------
    Echo �ȏ�̃p�����[�^�[��USB�������[���쐬���܂��B
    Set /P INP_ANS=���s���Ă�낵���ł��傤���H [Y/N/E] ^(Yes/No/Exit^)
    If /I "!INP_ANS!" EQU "E" (GoTo DONE)
    If /I "!INP_ANS!" NEQ "Y" (GoTo MAKE)

    DiskPart /S "!CMD_WK2!" || GoTo DONE

    Echo --- �t�@�C���]�� --------------------------------------------------------------
    If Exist "!DVD_SRC!\sources\install.swm" (
        Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!DVD_SRC!" "!USB_DST!" /XF install.wim /XD "System Volume Information" "$Recycle.Bin"
    ) Else (
        If /I "!FMT_USB!" NEQ "FAT32" (
            Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!DVD_SRC!" "!USB_DST!" /XD "System Volume Information" "$Recycle.Bin"
        ) Else (
            For %%I In ("!DVD_SRC!\sources\install.wim") Do (Set WIM_SIZ=%%~zI)
            If !WIM_SIZ! LSS 4294967296 (
                Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!DVD_SRC!" "!USB_DST!" /XD "System Volume Information" "$Recycle.Bin"
            ) Else (
                Echo --- �t�@�C������ --------------------------------------------------------------
                Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!DVD_SRC!" "!CMD_IMG!" install.wim
                Dism /Split-Image /ImageFile:"!CMD_IMG!\sources\install.wim" /SWMFile:"!CMD_IMG!\sources\install.swm" /FileSize:4095 || GoTo DONE
                Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!DVD_SRC!" "!USB_DST!" /XF install.wim /XD "System Volume Information" "$Recycle.Bin"
                Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!CMD_IMG!" "!USB_DST!" install*.swm /XD "System Volume Information" "$Recycle.Bin"
            )
        )
    )

Rem CD /D "!DRV_DVD!\boot"
    BootSect /NT60 !DRV_USB:~0,2! || GoTo DONE

Rem --- ��ƃt�@�C���̍폜 ----------------------------------------------------
    If Exist "!CMD_WK1!" (Del /F "!CMD_WK1!" || GoTo DONE)
    If Exist "!CMD_WK2!" (Del /F "!CMD_WK2!" || GoTo DONE)
    If Exist "!CMD_IMG!" (RmDir /S /Q "!CMD_IMG!" || GoTo DONE)

Rem *** ��ƏI�� **************************************************************
:DONE
    EndLocal
    Echo *** ��ƏI�� ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]���������ĉ������B
    Pause > Nul 2>&1
    Echo On