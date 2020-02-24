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

    For /F "tokens=2 usebackq delims=\" %%I In ('!WRK_DIR!') Do (Set WRK_TOP=%%~dI\%%~I)

    Set ARG_LST=%*
    Set FLG_OPT=0
    Set FLG_DEL=0
    Set FLG_DRV=0
    Set FLG_SPL=0
    Set FLG_MAK=0

    For %%I In (!ARG_LST!) Do (
        Set ARG_PRM=%%~I
               If /I "!ARG_PRM!" EQU ""            (GoTo SETTING
        ) Else If /I "!ARG_PRM!" EQU "Help"        (GoTo HELP
        ) Else If /I "!ARG_PRM!" EQU "Reuse-Image" (Set FLG_OPT=0&Set FLG_DEL=1
        ) Else If /I "!ARG_PRM!" EQU "Add-Driver"  (Set FLG_OPT=0&Set FLG_DRV=1
        ) Else If /I "!ARG_PRM!" EQU "Split-Image" (Set FLG_OPT=1&Set FLG_SPL=1
        ) Else If /I "!ARG_PRM!" EQU "Make-Image"  (Set FLG_OPT=1&Set FLG_MAK=1
        ) Else                                     (GoTo HELP
        )
    )

    GoTo SETTING

:HELP
    Echo !WRK_FIL! [Help^|Reuse-Image^|Add-Driver^|Split-Image^|Make-Image]
    GoTo DONE

:SETTING
Rem *** ��Ɗ��ݒ� **********************************************************
    Set DEF_TOP=C:\WimWK

    If /I "!WRK_TOP!" EQU "!DEF_TOP!" (
        Set WIM_TOP=!DEF_TOP!
    ) Else (
:INP_FOLDER
        Set WIM_TOP=!DEF_TOP!
        Set /P WIM_TOP=��Ɗ��̃t�H���_�[���w�肵�ĉ������B�i�K��l[!WIM_TOP!]�j
        If /I "!WIM_TOP!" EQU "" (Set WIM_TOP=C:\WimWK)

        Echo "!WIM_TOP!"
        Set INP_ANS=N
        Set /P INP_ANS=��L�ł�낵���ł����H [Y/N] ^(Yes/No^)�i�K��l[!INP_ANS!]�j
        If /I "!INP_ANS!" NEQ "Y" (GoTo INP_FOLDER)
    )

Rem --- Windows�̃o�[�W�����ݒ� -----------------------------------------------
:INPUT_WIN_TYPE
    Echo --- Windows�̃o�[�W�����ݒ� ---------------------------------------------------
    Echo 1: Windows 7
    Echo 2: Windows 8.1
    Echo 3: Windows 10
    Set IDX_WIN=3
    Set /P IDX_WIN=Windows�̃o�[�W������1�`3�̐�������I��ŉ������B�i�K��l[!IDX_WIN!]�j

           If /I "!IDX_WIN!" EQU "1" (Set WIN_VER=7
    ) Else If /I "!IDX_WIN!" EQU "2" (Set WIN_VER=8.1
    ) Else If /I "!IDX_WIN!" EQU "3" (Set WIN_VER=10
    ) Else                           (GoTo INPUT_WIN_TYPE
    )

           If !WIN_VER! EQU  7  (Set WIN_PNM=Windows6.1
    ) Else If !WIN_VER! EQU 8.1 (Set WIN_PNM=windows8.1
    ) Else If !WIN_VER! EQU 10  (Set WIN_PNM=Windows10.0
    ) Else                      (GoTo INPUT_WIN_TYPE
    )

Rem --- Windows�̃A�[�L�e�N�`���[�ݒ� -----------------------------------------
:INPUT_ARC_TYPE
    Echo --- Windows�̃A�[�L�e�N�`���[�ݒ� ---------------------------------------------
    Echo 1: 32bit��
    Echo 2: 64bit��
    Set IDX_CPU=2
    Set /P IDX_CPU=Windows�̃A�[�L�e�N�`���[��1�`2�̐�������I��ŉ������B�i�K��l[!IDX_CPU!]�j

           If /I "!IDX_CPU!" EQU "1" (Set ARC_TYP=x86&Set CPU_BIT=32
    ) Else If /I "!IDX_CPU!" EQU "2" (Set ARC_TYP=x64&Set CPU_BIT=64
    ) Else                           (GoTo INPUT_ARC_TYPE
    )

Rem --- DVD�̃h���C�u���ݒ� ---------------------------------------------------
:CHK_DVD_DRIVE
    Echo --- DVD�̃h���C�u���ݒ� -------------------------------------------------------
    Set DRV_DVD=
    Set /P DRV_DVD=DVD�̃h���C�u��[A-Z] ���̓C���[�W�t�H���_�[������͂��ĉ������B
    If /I "!DRV_DVD!" EQU "" (GoTo CHK_DVD_DRIVE)

    If /I "!DRV_DVD:~1,1!" EQU "" (
        Set DRV_DVD=!DRV_DVD!:\)
    )

:SET_DVD_DRIVE
    If Not Exist "!DRV_DVD!\sources\install.wim" If Not Exist "!DRV_DVD!\sources\install.swm" (
        Echo ��������!ARC_TYP!�ł�DVD��"!DRV_DVD!"�ɃZ�b�g���ĉ������B
        Echo �������ł�����[Enter]���������ĉ������B
        Pause > Nul 2>&1
        GoTo SET_DVD_DRIVE
    )

Rem --- wim�o�[�W�����̎擾 ---------------------------------------------------
    If Exist "!DRV_DVD!\Sources\Install.wim" (Set WIM_WIM=!DRV_DVD!\Sources\Install.wim
    ) Else                                   (Set WIM_WIM=!DRV_DVD!\Sources\Install.swm
    )
    For /F "Usebackq Tokens=3 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"!WIM_WIM!" /Index:1 ^| FindStr /C:"���O:"`)           Do (Set WIM_NME=%%~I)
    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"!WIM_WIM!" /Index:1 ^| FindStr /C:"�A�[�L�e�N�`��:"`) Do (Set WIM_ARC=%%~I)
    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"!WIM_WIM!" /Index:1 ^| FindStr /C:"�o�[�W���� :"`)    Do (Set WIM_VER=%%~I)
    If !WIM_NME! NEQ !WIN_VER! (
        Echo DVD��Windows !WIM_NME! !WIM_ARC!�łł��B
        Echo ��������Windows !WIN_VER! !ARC_TYP!�ł�DVD��"!DRV_DVD!"�ɃZ�b�g���ĉ������B
        Echo �������ł�����[Enter]���������ĉ������B
        Pause > Nul 2>&1
        GoTo SET_DVD_DRIVE
    )
    If /I "!WIM_ARC!" NEQ "!ARC_TYP!" (
        Echo DVD��Windows !WIM_NME! !WIM_ARC!�łł��B
        Echo ��������Windows !WIN_VER! !ARC_TYP!�ł�DVD��"!DRV_DVD!"�ɃZ�b�g���ĉ������B
        Echo �������ł�����[Enter]���������ĉ������B
        Pause > Nul 2>&1
        GoTo SET_DVD_DRIVE
    )

    If /I "!DRV_DVD:~3!" NEQ "" (
        Set DVD_VOL=
    ) Else (
        For /F "Usebackq Tokens=5 Delims= " %%I In (`Vol "!DRV_DVD:~0,2!" ^| FindStr  /C:"�{�����[�� ���x��"`) Do (Set DVD_VOL=%%~I)
    )

Rem --- Windows�̃G�f�B�V�����ݒ� ---------------------------------------------
    If !FLG_OPT! EQU 0 (
        If !WIN_VER! EQU 7 (
            Echo --- Windows�̃G�f�B�V�����ݒ� -------------------------------------------------
            Echo 1: Windows 7 Starter ^(32bit�ł̂�^)
            Echo 2: Windows 7 HomeBasic
            Echo 3: Windows 7 HomePremium
            Echo 4: Windows 7 Professional
            Echo 5: Windows 7 Ultimate
            Set IDX_WIN=4
            Set /P IDX_WIN=Windows�̃G�f�B�V������1�`5�̐�������I��ŉ������B�i�K��l[!IDX_WIN!]�j

                   If /I "!IDX_WIN!" EQU "1" (Set WIN_TYP=Windows 7 Starter
            ) Else If /I "!IDX_WIN!" EQU "2" (Set WIN_TYP=Windows 7 HomeBasic
            ) Else If /I "!IDX_WIN!" EQU "3" (Set WIN_TYP=Windows 7 HomePremium
            ) Else If /I "!IDX_WIN!" EQU "4" (Set WIN_TYP=Windows 7 Professional
            ) Else If /I "!IDX_WIN!" EQU "5" (Set WIN_TYP=Windows 7 Ultimate
            )
        ) Else If !WIN_VER! EQU 8.1 (
            Echo --- Windows�̃G�f�B�V�����ݒ� -------------------------------------------------
            Echo 1: Windows 8.1 Pro
            Echo 2: Windows 8.1
            Set IDX_WIN=1
            Set /P IDX_WIN=Windows�̃G�f�B�V������1�`2�̐�������I��ŉ������B�i�K��l[!IDX_WIN!]�j

                   If /I "!IDX_WIN!" EQU "1" (Set WIN_TYP=Windows 8.1 Pro
            ) Else If /I "!IDX_WIN!" EQU "2" (Set WIN_TYP=Windows 8.1
            )
        ) Else If !WIN_VER! EQU 10 (
            Echo --- Windows�̃G�f�B�V�����ݒ� -------------------------------------------------
            Echo 1: Windows 10 Home
            Echo 2: Windows 10 Education
            Echo 3: Windows 10 Pro
            Echo 4: Windows 10 Pro Education
            Echo 5: Windows 10 Pro for Workstations
            Set IDX_WIN=3
            Set /P IDX_WIN=Windows�̃G�f�B�V������1�`5�̐�������I��ŉ������B�i�K��l[!IDX_WIN!]�j

                   If /I "!IDX_WIN!" EQU "1" (Set WIN_TYP=Windows 10 Home
            ) Else If /I "!IDX_WIN!" EQU "2" (Set WIN_TYP=Windows 10 Education
            ) Else If /I "!IDX_WIN!" EQU "3" (Set WIN_TYP=Windows 10 Pro
            ) Else If /I "!IDX_WIN!" EQU "4" (Set WIN_TYP=Windows 10 Pro Education
            ) Else If /I "!IDX_WIN!" EQU "5" (Set WIN_TYP=Windows 10 Pro for Workstations
            )
        )
    )

Rem --- ���ϐ��ݒ� ----------------------------------------------------------
Rem Set WIN_VER=%~1
    Set LST_PKG=adk bin drv !ARC_TYP!
Rem Set WIM_TOP=%~3
    Set WIM_BIN=!WIM_TOP!\bin
    Set WIM_CFG=!WIM_TOP!\cfg
    Set WIM_ISO=!WIM_TOP!\iso
    Set WIM_LST=!WIM_TOP!\lst
    Set WIM_PKG=!WIM_TOP!\pkg
    Set WIM_USR=!WIM_TOP!\usr
    Set WIM_WRK=!WIM_TOP!\wrk
    Set CMD_DAT=!WIM_WRK!\!WRK_NAM!.w!WIN_VER!.!ARC_TYP!.!NOW_DAY!!NOW_TIM!.dat
    Set CMD_WRK=!WIM_WRK!\!WRK_NAM!.w!WIN_VER!.!ARC_TYP!.!NOW_DAY!!NOW_TIM!.wrk

    Set DVD_SRC=!DRV_DVD!\
    Set DVD_SRC=!DVD_SRC:\\=\!
    Set DVD_DST=!WIM_TOP!\windows_!WIN_VER!_!ARC_TYP!_dvd_custom_VER_.iso
    Set DVD_DST=%DVD_DST:_VER_=_!WIM_VER!%

    Set LST_OPT=
    Set LST_LST=
    Set LST_CNT=0
    Pushd "!WIM_LST!" || GoTo DONE
        For /R %%I In ("Windows!WIN_VER!*.lst") Do (
            For /F "tokens=1,2 usebackq delims=_" %%J in ('%%~nxI') Do (
                Set DVD_PKG=%%~J
                Set DVD_PKG=!DVD_PKG:~-3!
                Set DVD_OPT=%%~nK
                For %%P In (!LST_PKG!) Do (
                    If /I "%%~P" EQU "!DVD_PKG!" (
                        If /I "!DVD_OPT!" NEQ "Rollup" (
                            If /I "!LST_LST!" EQU "" (Set LST_LST=!DVD_OPT!
                            ) Else                   (Set LST_LST=!LST_LST! !DVD_OPT!
                            )
                            Set /A LST_CNT+=1
                        )
                    )
                )
            )
        )
    Popd

    If /I "!LST_LST!" NEQ "" (
:INPUT_ADD_LIST_FILE
        Set WRK_CNT=0
        Echo --- ���X�g�t�@�C���̒ǉ� ------------------------------------------------------
        Echo 0: �ǉ����Ȃ�
        For %%I In (!LST_LST!) Do (
            Set /A WRK_CNT+=1
            Echo !WRK_CNT!: %%~I
        )
        Set IDX_LST=0
        Set /P IDX_LST=�ǉ����X�g�t�@�C����0�`!WRK_CNT!�̐�������I��ŉ������B�i�K��l[!IDX_LST!]�j
        If !IDX_LST! LSS 0         (GoTo INPUT_ADD_LIST_FILE)
        If !IDX_LST! GTR !WRK_CNT! (GoTo INPUT_ADD_LIST_FILE)
        If !IDX_LST! GTR 0 (
            For /F "tokens=1 usebackq" %%I In (`Cmd /C ^"For /F ^"tokens^=!IDX_LST! usebackq^" %%J In ^('!LST_LST!'^) Do ^(Echo %%~J^)^"`) Do (Set LST_OPT=%%~I)
            Set DVD_DST=%DVD_DST:_custom_=_!LST_OPT!_%
        )
    )

    Set UTL_ARC=amd64 arm arm64 x86

Rem --- ��ƃt�H���_�[�̍쐬 --------------------------------------------------
    Echo *** ��ƃt�H���_�[�̍쐬 ******************************************************
Rem --- �j���C���[�W�̍폜 ----------------------------------------------------
    For %%I In (!WIN_VER!) Do (
        For %%J In (!ARC_TYP!) Do (
            Set WIM_IMG=!WIM_WRK!\w%%~I\%%~J\img
            Set WIM_MNT=!WIM_WRK!\w%%~I\%%~J\mnt
            Set WIM_WRE=!WIM_WRK!\w%%~I\%%~J\wre
            If Exist "!WIM_WRE!\Windows" (Dism /UnMount-Wim /MountDir:"!WIM_WRE!" /Discard)
            If Exist "!WIM_MNT!\Windows" (Dism /UnMount-Wim /MountDir:"!WIM_MNT!" /Discard)
        )
    )

    If Not Exist "!WIM_BIN!" (MkDIr "!WIM_BIN!" || GoTo DONE)
    If Not Exist "!WIM_CFG!" (MkDIr "!WIM_CFG!" || GoTo DONE)
    If Not Exist "!WIM_LST!" (MkDIr "!WIM_LST!" || GoTo DONE)
    If Not Exist "!WIM_PKG!" (MkDIr "!WIM_PKG!" || GoTo DONE)
    If Not Exist "!WIM_USR!" (MkDIr "!WIM_USR!" || GoTo DONE)
    If Not Exist "!WIM_WRK!" (MkDIr "!WIM_WRK!" || GoTo DONE)

    For %%I In (!WIN_VER!) Do (
        For %%J In (!ARC_TYP!) Do (
            Set WIM_PKB=!WIM_PKG!\w%%~I\bin
            Set WIM_DRV=!WIM_PKG!\w%%~I\drv
            Set WIM_WUD=!WIM_PKG!\w%%~I\%%~J
            Set WIM_CAB=!WIM_PKG!\w%%~I\%%~J\cab
            Set WIM_BAK=!WIM_WRK!\w%%~I\%%~J\bak
            Set WIM_EFI=!WIM_WRK!\w%%~I\%%~J\efi
            Set WIM_IMG=!WIM_WRK!\w%%~I\%%~J\img
            Set WIM_MNT=!WIM_WRK!\w%%~I\%%~J\mnt
            Set WIM_WRE=!WIM_WRK!\w%%~I\%%~J\wre

            If /I "!DRV_DVD!" EQU "!WIM_IMG!" (
                Echo �C���[�W�t�H���_�[�̓������ƍ�Ɨp�������ł��B
                Echo �������F"!DRV_DVD!"
                Echo ��Ɨp�F"!WIM_IMG!"
                Echo �ʂ̃t�H���_�[���w�肵�ĉ������B
                GoTo CHK_DVD_DRIVE
            )

            If !FLG_DEL! EQU 0 (
                If     Exist "!WIM_IMG!" (RmDir /S /Q "!WIM_IMG!" || GoTo DONE)
            )

            If     Exist "!WIM_MNT!" (RmDir /S /Q "!WIM_MNT!" || GoTo DONE)
            If     Exist "!WIM_WRE!" (RmDir /S /Q "!WIM_WRE!" || GoTo DONE)

            If Not Exist "!WIM_WUD!" (MkDir       "!WIM_WUD!" || GoTo DONE)
            If Not Exist "!WIM_CAB!" (MkDir       "!WIM_CAB!" || GoTo DONE)
            If Not Exist "!WIM_BAK!" (MkDir       "!WIM_BAK!" || GoTo DONE)
            If Not Exist "!WIM_EFI!" (MkDir       "!WIM_EFI!" || GoTo DONE)
            If Not Exist "!WIM_IMG!" (MkDir       "!WIM_IMG!" || GoTo DONE)
            If Not Exist "!WIM_MNT!" (MkDir       "!WIM_MNT!" || GoTo DONE)
            If Not Exist "!WIM_WRE!" (MkDir       "!WIM_WRE!" || GoTo DONE)
        )
    )

Rem --- ��ƃt�@�C���̍폜 ----------------------------------------------------
    If Exist "!CMD_DAT!" (Del /F "!CMD_DAT!" || GoTo DONE)
    If Exist "!CMD_WRK!" (Del /F "!CMD_WRK!" || GoTo DONE)

    Copy /Y Nul "!CMD_WRK!" > Nul || GoTo DONE

Rem --- Oscdimg�擾 -----------------------------------------------------------
    If Not Exist "!WIM_BIN!\Oscdimg\%PROCESSOR_ARCHITECTURE%" (
        Echo --- Oscdimg�擾 ---------------------------------------------------------------
        Pushd "%ProgramFiles(x86)%" || GoTo DONE
            For /R %%I In (Oscdimg.exe*) Do (Set UTL_WRK=%%~dpI)
        Popd
        If /I "!UTL_WRK!" EQU "" (
            Echo Windows ADK ���C���X�g�[�����ĉ������B
            GoTo DONE
        )
        For %%I In (!UTL_ARC!) DO (
            Set UTL_SRC=!UTL_WRK!\..\..\%%~I\Oscdimg
            Set UTL_DST=!WIM_BIN!\Oscdimg\%%~I
            Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!UTL_SRC!" "!UTL_DST!" > Nul
        )
    )

Rem --- Oscdimg�̃p�X��ݒ肷�� -----------------------------------------------
    Set Path=!WIM_BIN!\Oscdimg\%PROCESSOR_ARCHITECTURE%;%Path%
    Oscdimg > NUL 2>&1
    If "%ErrorLevel%" EQU "9009" (
        Echo Oscdimg ������܂���B
        Echo Windows ADK ���C���X�g�[�����ĉ������B
        GoTo DONE
    )

    If !FLG_DRV! EQU 0 (
        If !FLG_SPL! EQU 1 (
            GoTo MAKE_ISO_IMAGE
        )
    )

:DOWNLOAD
Rem *** ���X�g�t�@�C���ϊ� ****************************************************
    Echo --- ���X�g�t�@�C���ϊ� --------------------------------------------------------
    Set LST_FIL=
    For %%I In (!WIN_VER!) Do (
        Set LST_WINVER=%%~I
        For %%J In (!LST_PKG!) Do (
            Set LST_PACKAGE=%%~J
            Set LST_LFSNAME=!WIM_LST!\Windows!LST_WINVER!!LST_PACKAGE!*.lst
            Set LST_WINPACK=!WIM_PKG!\w!LST_WINVER!\!LST_PACKAGE!
            Set LST_SECTION=
            For %%K In ("!LST_LFSNAME!") Do (
                Set LST_LFNAME=
                For /F "tokens=2 usebackq delims=_" %%E in ('%%~nxK') Do (
                           If /I "%%~E"  EQU "Rollup"    (If !FLG_DRV! EQU 0 (Set LST_LFNAME=%%~K)
                    ) Else If /I "%%~nE" EQU "!LST_OPT!" (Set LST_LFNAME=%%~K
                    )
                )
                If /I "!LST_LFNAME!" NEQ "" (
                    For /F "tokens=1* usebackq delims==" %%L In ("!LST_LFNAME!") Do (
                        Set LST_KEY=%%~L
                        Set LST_VAL=%%~M
                        If /I "!LST_KEY:~0,1!!LST_KEY:~-1,1!" EQU "[]" (
                            If /I "!LST_SECTION!" EQU "INFO" (Set LST_SECTION=)
                            If /I "!LST_SECTION!" EQU "LIST" (Set LST_SECTION=)
                            If /I "!LST_SECTION!" NEQ "" (
                                If /I "!LST_RENAME!" EQU "" (For %%E In ("!LST_FILE!")   Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE&Set LST_RENAME=%%~nxE)
                                ) Else                      (For %%E In ("!LST_RENAME!") Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE)
                                )
                                If /I "!LST_RUN_ORDER!" EQU "" (Set LST_RUN_ORDER=000)
                                Set LST_RENAME=!LST_WINPACK!\!LST_RENAME!
                                Set LST_EXTENSION=!LST_EXTENSION:~1!
                                If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                                Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE_NUM!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
                            )
                            Set LST_SECTION=!LST_KEY:~1,-1!
                            Set LST_TITLE=
                            Set LST_INFO=
                            Set LST_FILE=
                            Set LST_RENAME=
                            Set LST_SIZE=
                            Set LST_TYPE=
                            Set LST_CATEGORY=
                            Set LST_TIE_UP=
                            Set LST_XOR_KEY=
                            Set LST_SYNCHRO_KEY=
                            Set LST_RELEASE=
                            Set LST_RUN_ORDER=
                            Set LST_CMD=
                            Set LST_DECODE=
                            Set LST_DECODE_TYPE=
                            Set LST_DECODE_GET=
                            Set LST_IEXPRESS=
                            Set LST_IEXPRESS_LIST=
                            Set LST_IEXPRESS_CMD=
                            Set LST_PREVIOUS_SP=
                            Set LST_COMMENT=
                            Set LST_TYPE_NUM=
                        )
                        If /I "!LST_SECTION!" NEQ "" (
                                   If /I "!LST_KEY!" EQU "TITLE"         (Set LST_TITLE=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "INFO"          (Set LST_INFO=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "FILE"          (Set LST_FILE=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "RENAME"        (Set LST_RENAME=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "SIZE"          (Set LST_SIZE=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "TYPE"          (Set LST_TYPE=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "CATEGORY"      (Set LST_CATEGORY=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "TIE_UP"        (Set LST_TIE_UP=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "XOR_KEY"       (Set LST_XOR_KEY=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "SYNCHRO_KEY"   (Set LST_SYNCHRO_KEY=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "RELEASE"       (Set LST_RELEASE=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "RUN_ORDER"     (Set LST_RUN_ORDER=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "CMD"           (Set LST_CMD=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "DECODE"        (Set LST_DECODE=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "DECODE_TYPE"   (Set LST_DECODE_TYPE=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "DECODE_GET"    (Set LST_DECODE_GET=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "IEXPRESS"      (Set LST_IEXPRESS=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "IEXPRESS_LIST" (Set LST_IEXPRESS_LIST=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "IEXPRESS_CMD"  (Set LST_IEXPRESS_CMD=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "PREVIOUS_SP"   (Set LST_PREVIOUS_SP=!LST_VAL!
                            ) Else If /I "!LST_KEY!" EQU "COMMENT"       (Set LST_COMMENT=!LST_VAL!
                            )
                            If /I "!LST_KEY!" EQU "TYPE" (
                                       If /I "!LST_TYPE!" EQU "Service Pack"         (Set LST_TYPE_NUM=01
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(SVCPACK.INF)"  (Set LST_TYPE_NUM=02
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIXES.CMD)" (Set LST_TYPE_NUM=03
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX1.CMD)"  (Set LST_TYPE_NUM=04
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX2.CMD)"  (Set LST_TYPE_NUM=05
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX3.CMD)"  (Set LST_TYPE_NUM=06
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX4.CMD)"  (Set LST_TYPE_NUM=07
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX5.CMD)"  (Set LST_TYPE_NUM=08
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX6.CMD)"  (Set LST_TYPE_NUM=09
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX7.CMD)"  (Set LST_TYPE_NUM=10
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX8.CMD)"  (Set LST_TYPE_NUM=11
                                ) Else If /I "!LST_TYPE!" EQU "HOTFIX(HOTFIX9.CMD)"  (Set LST_TYPE_NUM=12
                                ) Else                                               (Set LST_TYPE_NUM=
                                )
                            )
                        )
                    )
                    If /I "!LST_SECTION!" NEQ "" (
                        If /I "!LST_RENAME!" EQU "" (For %%E In ("!LST_FILE!")   Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE&Set LST_RENAME=%%~nxE)
                        ) Else                      (For %%E In ("!LST_RENAME!") Do (Set LST_EXTENSION=%%~xE&Set LST_FNAME=%%~nxE)
                        )
                        If /I "!LST_RUN_ORDER!" EQU "" (Set LST_RUN_ORDER=000)
                        Set LST_RENAME=!LST_WINPACK!\!LST_RENAME!
                        Set LST_EXTENSION=!LST_EXTENSION:~1!
                        If /I "!LST_EXTENSION!" EQU "msu" If /I "!LST_CMD!" NEQ "" (Set LST_EXTENSION=wus)
                        Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE_NUM!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
                        Set LST_SECTION=
                        Set LST_TITLE=
                        Set LST_INFO=
                        Set LST_FILE=
                        Set LST_RENAME=
                        Set LST_SIZE=
                        Set LST_TYPE=
                        Set LST_CATEGORY=
                        Set LST_TIE_UP=
                        Set LST_XOR_KEY=
                        Set LST_SYNCHRO_KEY=
                        Set LST_RELEASE=
                        Set LST_RUN_ORDER=
                        Set LST_CMD=
                        Set LST_DECODE=
                        Set LST_DECODE_TYPE=
                        Set LST_DECODE_GET=
                        Set LST_IEXPRESS=
                        Set LST_IEXPRESS_LIST=
                        Set LST_IEXPRESS_CMD=
                        Set LST_PREVIOUS_SP=
                        Set LST_COMMENT=
                        Set LST_TYPE_NUM=
                    )
                )
            )
        )
    )

Rem --- �t�@�C���\�[�g --------------------------------------------------------
    Sort "!CMD_WRK!" > "!CMD_DAT!"

Rem *** �t�@�C���擾 **********************************************************
    Echo --- �t�@�C���擾 --------------------------------------------------------------
    For /F "tokens=1-10 usebackq delims=," %%I In ("!CMD_DAT!") Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE_NUM=%%~K
        Set LST_TYPE=%%~L
        Set LST_RUN_ORDER=%%~M
        Set LST_SECTION=%%~N
        Set LST_EXTENSION=%%~O
        Set LST_CMD=%%~P
        Set LST_RENAME=%%~Q
        Set LST_FILE=%%~R
        Set LST_WINPKG=!WIM_PKG!\!LST_WINDOWS!
        For %%E In ("!LST_RENAME!") Do (Set LST_FNAME=%%~nxE)
        For /F "tokens=1 usebackq delims=:" %%X In ('!LST_FILE!') Do (
                   If /I "%%~X" EQU "http"  (Set FLG_URL=1
            ) Else If /I "%%~X" EQU "https" (Set FLG_URL=1
            ) Else                          (Set FLG_URL=0
            )
            If !FLG_URL! EQU 1 (
                If Not Exist "!LST_RENAME!" (
                    Echo "!LST_FNAME!"
                    Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -o "!LST_RENAME!" "!LST_FILE!" || GoTo DONE
                ) Else (
                    Curl -L -s --connect-timeout 60 --dump-header "!CMD_WRK!" "!LST_FILE!"
                    Set LST_LEN=0
                    For /F "tokens=1,2* usebackq delims=:" %%Y In ("!CMD_WRK!") Do (
                        If /I "%%~Y" EQU "Content-Length" (Set LST_LEN=%%~Z)
                    )
                    For /F "usebackq delims=/" %%Z In ('!LST_RENAME!') Do (Set LST_SIZE=%%~zZ)
                    If !LST_LEN! NEQ !LST_SIZE! (
                        Echo "!LST_FNAME!" : !LST_SIZE! : !LST_LEN!
                        Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -o "!LST_RENAME!" "!LST_FILE!" || GoTo DONE
                    )
                )
            )
            If Not Exist "!LST_RENAME!" (
                Echo File not exist: "!LST_RENAME!"
            ) Else (
                If /I "!LST_EXTENSION!" EQU "zip" (
                    For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                    If Not Exist "!LST_DIR!" (
                        Echo --- �t�@�C���W�J --------------------------------------------------------------
                        MkDir "!LST_DIR!"
                        Tar -xzf "!LST_RENAME!" -C "!LST_DIR!"
                    )
                    Pushd "!LST_DIR!" || GoTo DONE
                        For /R %%E In ("*.zip") Do (
                            Set LST_ZIPFILE=%%~E
                            Set LST_ZIPDIR=%%~dpnE
                            If Not Exist "!LST_ZIPDIR!" (
                                Echo --- �t�@�C���W�J --------------------------------------------------------------
                                MkDir "!LST_ZIPDIR!"
                                Tar -xzf "!LST_ZIPFILE!" -C "!LST_ZIPDIR!"
                            )
                            Pushd "!LST_ZIPDIR!" || GoTo DONE
                                For /R %%F In ("*.msu") Do (
                                    For /F "tokens=2 delims=x" %%G In ("%%~nF") Do (Set LST_PACKAGE=%%~G)
                                    If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!\%%~nxF" (
                                        Echo --- �t�@�C���]�� --------------------------------------------------------------
                                        If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!" (MkDir "!LST_WINPKG!\x!LST_PACKAGE!")
                                        Copy /Y "%%~F" "!LST_WINPKG!\x!LST_PACKAGE!" > Nul || GoTo DONE
                                    )
                                )
                            Popd
                        )
                        For /R %%F In ("*.msu") Do (
                            For /F "tokens=2 delims=x" %%G In ("%%~nF") Do (Set LST_PACKAGE=%%~G)
                            If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!\%%~nxF" (
                                Echo --- �t�@�C���]�� --------------------------------------------------------------
                                If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!" (MkDir "!LST_WINPKG!\x!LST_PACKAGE!")
                                Copy /Y "%%~F" "!LST_WINPKG!\x!LST_PACKAGE!" > Nul || GoTo DONE
                            )
                        )
                    Popd
                ) Else If /I "!LST_EXTENSION!" EQU "msi" (
                   If /I "!LST_CMD!" EQU "" (
                        For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                        If Not Exist "!LST_DIR!" (
                            Echo --- �t�@�C���W�J --------------------------------------------------------------
                            MkDir "!LST_DIR!"
                            MsiExec /a "!LST_RENAME!" targetdir="!LST_DIR!" /qn > Nul || GoTo DONE
                        )
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "cab" (
                    For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                    If Not Exist "!LST_DIR!" (
                        Echo --- �t�@�C���W�J --------------------------------------------------------------
                        MkDir "!LST_DIR!"
                        Expand "!LST_RENAME!" -F:* "!LST_DIR!" > Nul || GoTo DONE
                    )
                ) Else If /I "!LST_SECTION!" EQU "IE11" (
                    For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                    If Not Exist "!LST_DIR!" (
                        Echo --- �t�@�C���W�J --------------------------------------------------------------
                        MkDir "!LST_DIR!"
                        "!LST_RENAME!" /x:"!LST_DIR!"
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "msu" (
                    If /I "!LST_SECTION!" EQU "KB2533552" (
                        Echo --- �t�@�C���W�J --------------------------------------------------------------
                        For %%E In ("!LST_RENAME!") Do (
                            Set LST_FPATH=%%~dpnE
                            Set LST_FNAME=%%~nE
                            Set LST_FCAB=!LST_FPATH!\!LST_FNAME!
                        )
                        If Exist "!LST_FPATH!" (RmDir /S /Q "!LST_FPATH!")
                        MkDir "!LST_FCAB!"
                        Expand -F:* "!LST_RENAME!" "!LST_FPATH!" > Nul || GoTo DONE
                        Expand -F:* "!LST_FCAB!.cab" "!LST_FCAB!" > Nul || GoTo DONE
                        For /F "usebackq delims=" %%E In ("!LST_FCAB!\update.mum") Do (
                            Set LST_LINE=%%~E
                            For /F "usebackq delims=" %%F In (`Echo "!LST_LINE!" ^| Find "allowedOffline"`) Do (
                                Set LST_LINE="		<mum:packageExtended xmlns:mum="urn:schemas-microsoft-com:asm.v3" exclusive="true" allowedOffline="true"/>"
                            )
                            Echo>>"!LST_FPATH!\update.wrk" !LST_LINE!
                        )
                        Move "!LST_FPATH!\update.wrk" "!LST_FCAB!\update.mum" > Nul || GoTo DONE
                    )
                )
            )
        )
    )

:UPDATE
Rem *** ����ISO�t�@�C���쐬 ***************************************************
Rem === ���{�����ƃt�H���_�[�ɃR�s�[���� ====================================
    Echo --- ���{�����ƃt�H���_�[�ɃR�s�[���� ----------------------------------------
    Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS /NFL "!DVD_SRC!\" "!WIM_IMG!" > Nul

    If !FLG_DRV! EQU 1 (If /I "!LST_OPT!" EQU "" (GoTo MAKE_ISO_IMAGE))
    If !FLG_OPT! EQU 1 (If !FLG_MAK! EQU 1       (GoTo MAKE_ISO_IMAGE))

:ADD_BOOT_OPTIONS
Rem === UEFI�u�[�g���� ========================================================
    If !WIN_VER! LEQ 7 (
        If /I "!ARC_TYP!" EQU "x64" (
            If Not Exist "!WIM_EFI!\bootx64.efi" (
                Echo --- bootx64.efi �̒��o --------------------------------------------------------
                Dism /Mount-Wim /WimFile:"!WIM_IMG!\sources\boot.wim" /index:1 /MountDir:"!WIM_MNT!" /ReadOnly || GoTo DONE
                Copy /Y "!WIM_MNT!\Windows\Boot\EFI\bootmgfw.efi" "!WIM_EFI!\bootx64.efi" > Nul || GoTo DONE
                Dism /Unmount-Wim /MountDir:"!WIM_MNT!" /Discard || GoTo DONE
            )
            Echo --- bootx64.efi �̃R�s�[ ------------------------------------------------------
            Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!WIM_EFI!" "!WIM_IMG!\efi\boot" "bootx64.efi" > Nul
        )
    )

:ADD_UNATTEND
Rem === Unattend ==============================================================
    If Exist "!WIM_CFG!\autounattend-windows!WIN_VER!-!ARC_TYP!.xml" (
        Echo --- autounattend.xml �̃R�s�[ -------------------------------------------------
        Copy /Y "!WIM_CFG!\autounattend-windows!WIN_VER!-!ARC_TYP!.xml" "!WIM_IMG!\autounattend.xml" > Nul || GoTo DONE
    )

:ADD_OPTIONS
Rem === options.cmd �̍쐬 ====================================================
    Echo --- options.cmd �̍쐬 ---------------------------------------------------------
    Set OPT_DIR=autounattend\options
    Set OPT_PKG=!OPT_DIR!\upd
    Set OPT_DRV=!OPT_DIR!\drv
    Set OPT_BIN=!OPT_DIR!\bin
    Set OPT_CMD=!WIM_IMG!\!OPT_DIR!\options.cmd
    Set OPT_BAK=!OPT_CMD!.!NOW_DAY!!NOW_TIM!
    Set OPT_TMP=!OPT_CMD!.tmp
    Set OPT_LST=
    Set OPT_MSU=0
    If Not Exist "!WIM_IMG!\!OPT_DIR!" (MkDir "!WIM_IMG!\!OPT_DIR!")
    If !FLG_DRV! EQU 1 (If Exist "!OPT_CMD!" (Move /Y "!OPT_CMD!" "!OPT_BAK!" > Nul))
    If Exist "!OPT_CMD!" (Del /F "!OPT_CMD!")
    If Exist "!OPT_TMP!" (Del /F "!OPT_TMP!")
Rem --- options.cmd �̍쐬 ----------------------------------------------------
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem %DATE% %TIME% maked
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"     Echo ^%%DATE^%% ^%%TIME^%% Start
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"     Set Path=%%configsetroot%%\!OPT_BIN!;%%Path%%
    Echo>>"!OPT_CMD!" Rem --- NTP Setup -------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem sc stop w32time
    Echo>>"!OPT_CMD!"     reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "" /t REG_SZ /d "0" /f
    Echo>>"!OPT_CMD!"     reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers" /v "0" /t REG_SZ /d "ntp.nict.jp" /f
    Echo>>"!OPT_CMD!"     reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v "UpdateInterval" /t REG_DWORD /d "0x00057e40" /f
    Echo>>"!OPT_CMD!"     reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "Type" /t REG_SZ /d "NTP" /f
    Echo>>"!OPT_CMD!"     reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" /v "NtpServer" /t REG_SZ /d "ntp.nict.jp,0x9" /f
    Echo>>"!OPT_CMD!"     reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollInterval" /t REG_DWORD /d "0x00005460" /f
    Echo>>"!OPT_CMD!"     reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v "SpecialPollTimeRemaining" /t REG_MULTI_SZ /d "" /f
    Echo>>"!OPT_CMD!"     sc config w32time start= delayed-auto
    Echo>>"!OPT_CMD!" Rem sc start w32time
Rem ---------------------------------------------------------------------------
    If !FLG_DRV! EQU 0 (
        Echo>>"!OPT_CMD!" Rem --- Package ---------------------------------------------------------------
    ) Else (
        Set CMD_SKP=0
        For /F "usebackq delims=" %%I In ("!OPT_BAK!") Do (
            Set LINE=%%~I
            For /F "tokens=1,2 usebackq delims=- " %%J In ('!LINE!') Do (
                If /I "%%~J" EQU "Rem" (
                    If /I "%%~K" EQU "Package"  (Set CMD_SKP=1)
                    If /I "%%~K" EQU "Cleaning" (Set CMD_SKP=0)
                )
            )
            If !CMD_SKP! EQU 1 (
                If "!LINE!" EQU "" (
                    Echo.>>"!OPT_CMD!"
                ) Else (
                    Echo>>"!OPT_CMD!" !LINE!
                )
            )
        )
    )
Rem ---------------------------------------------------------------------------
    For /F "tokens=1-10 usebackq delims=," %%I In ("!CMD_DAT!") Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE_NUM=%%~K
        Set LST_TYPE=%%~L
        Set LST_RUN_ORDER=%%~M
        Set LST_SECTION=%%~N
        Set LST_EXTENSION=%%~O
        Set LST_CMD=%%~P
        Set LST_RENAME=%%~Q
        Set LST_FILE=%%~R
        For %%E In ("!LST_RENAME!") Do (
            Set LST_FNAME=%%~nxE
            Set LST_FDSRC=%%~dpE
            Set LST_FDSRC=!LST_FDSRC:~0,-1!
            Set LST_FNSRC=%%~dpnE
            Set LST_FNDST=%%~nE
        )
        If /I "!LST_WINDOWS!" EQU "w!WIN_VER!" (
            If /I "!LST_CMD!" EQU "" (If /I "!LST_EXTENSION!" EQU "msu" (Set OPT_MSU=1)
            ) Else                   (
                Set LST_REM=   
                Set LST_SECTION_LST=!LST_SECTION:_= !
                For %%A In (!LST_SECTION_LST!) Do (
                    if /I "%%A" NEQ "!ARC_TYP!" (
                               If /I "%%~A" EQU "x64" (Set LST_REM=Rem
                        ) Else If /I "%%~A" EQU "x86" (Set LST_REM=Rem
                        )
                    )
                )
                If /I "!LST_EXTENSION!" EQU "exe" (
                    If /I "!LST_PACKAGE!" EQU "drv" (
                        For %%E In ("!LST_FDSRC!") Do (Set LST_FNDST=%%~nE)
                        Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!LST_FDSRC!" "!WIM_IMG!\!OPT_DRV!\!LST_SECTION!" > Nul
                        Echo>>"!OPT_CMD!" !LST_REM! "%%configsetroot%%\!OPT_DRV!\!LST_SECTION!\!LST_FNAME!" !LST_CMD!
                    ) Else (
                        If /I "!LST_FNAME!" EQU "mpam-fe-!ARC_TYP!.exe" (Echo>>"!OPT_CMD!"     Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -o "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!.tmp" "!LST_FILE!" ^&^& Attrib -R "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" ^&^& Move "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!.tmp" "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!")
                        If /I "!LST_FNAME!" EQU "mpas-fe-!ARC_TYP!.exe" (Echo>>"!OPT_CMD!"     Curl -L -# -R -S -f --create-dirs --connect-timeout 60 -o "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!.tmp" "!LST_FILE!" ^&^& Attrib -R "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" ^&^& Move "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!.tmp" "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!")
                        Echo>>"!OPT_CMD!" !LST_REM! "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" !LST_CMD!
                        Set OPT_LST=!OPT_LST! "!LST_FNAME!"
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "wus" (
                    Echo>>"!OPT_CMD!" !LST_REM! Wusa "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" !LST_CMD!
                    Set OPT_LST=!OPT_LST! "!LST_FNAME!"
                ) Else If /I "!LST_EXTENSION!" EQU "msi" (
                    Echo>>"!OPT_CMD!" !LST_REM! msiexec /i "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" !LST_CMD!
                    Set OPT_LST=!OPT_LST! "!LST_FNAME!"
                ) Else If /I "!LST_EXTENSION!" EQU "cab" (
                    Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!LST_FNSRC!" "!WIM_IMG!\!OPT_DRV!\!LST_FNDST!" > Nul
                    If !WIN_VER! LEQ 7 (Echo>>"!OPT_TMP!" !LST_REM! PnpUtil -i -a "%%configsetroot%%\!OPT_DRV!\!LST_FNDST!\*.inf"
                    ) Else             (Echo>>"!OPT_TMP!" !LST_REM! PnpUtil /Add-Driver "%%configsetroot%%\!OPT_DRV!\!LST_FNDST!\*.inf" /SubDirs /Install
                    )
                )
            )
        )
    )
    If Exist "!OPT_TMP!" (
        Type "!OPT_TMP!" >> "!OPT_CMD!"
        Del /F "!OPT_TMP!"
    )
Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem --- Cleaning --------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem Del /F /S /Q "%%configsetroot%%" ^> Nul
    Echo>>"!OPT_CMD!" Rem For /D %%%%I In ("%%configsetroot%%\*") Do (RmDir /S /Q "%%%%~I" ^> Nul )
    Echo>>"!OPT_CMD!" Rem --- Reboot-----------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem shutdown /r /t 3
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" :DONE
    Echo>>"!OPT_CMD!"     Echo ^%%DATE^%% ^%%TIME^%% End
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem pause
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
Rem ---------------------------------------------------------------------------
    If Exist "!OPT_BAK!" (Del /F "!OPT_BAK!")

    For /D %%I In ("!WIM_PKB!\curl-*-win!CPU_BIT!-mingw") Do (
        Pushd "%%~I" || GoTo DONE
            For /R %%E In ("curl.exe*") Do (
                Set CUR_DIR=%%~dpE
                If /I "!CUR_DIR:~-1!" EQU "\" (Set CUR_DIR=!CUR_DIR:~0,-1!)
                Robocopy /J /MIR /A-:RHS /NDL /NFL /NC /NJH /NJS "!CUR_DIR!" "!WIM_IMG!\!OPT_BIN!" > Nul
            )
        Popd
    )

    If /I "!OPT_LST!" NEQ "" (
        Robocopy /J /A-:RHS /NDL /NFL /NC /NJH /NJS "!WIM_WUD!" "!WIM_IMG!\!OPT_PKG!" !OPT_LST! > Nul
    )

    If !FLG_DRV! EQU 1 (If !OPT_MSU! EQU 0 (GoTo MAKE_ISO_IMAGE))

Rem ---------------------------------------------------------------------------
:ADD_PACKAGE
Rem === Windows Update �t�@�C�� �� �h���C�o�[ �̓��� ==========================
    Set ADD_PAC=/Image:^"!WIM_MNT!^" /Add-Package /IgnoreCheck
    Set ADD_DRV=/Image:^"!WIM_MNT!^" /Add-Driver /ForceUnsigned /Recurse
    Set WRE_PAC=/Image:^"!WIM_WRE!^" /Add-Package /IgnoreCheck
    Set WRE_DRV=/Image:^"!WIM_WRE!^" /Add-Driver /ForceUnsigned /Recurse

    If !WIN_VER! EQU 7 (
        Echo --- �h���C�o�[�̓��� -----------------------------------------------------------
        If Not Exist "!WIM_DRV!\USB"  (Set DRV_USB=) Else (Pushd "!WIM_DRV!\USB" &For /R %%I In ("Win7\!ARC_TYP!\iusb3hub.inf*")  Do (Set DRV_USB=%%~dpI&Set DRV_USB=!DRV_USB:~0,-1!)&Popd)
        If Not Exist "!WIM_DRV!\RST"  (Set DRV_RST=) Else (Pushd "!WIM_DRV!\RST" &For /R %%I In ("f6flpy-!ARC_TYP!\iaAHCIC.inf*") Do (Set DRV_RST=%%~dpI&Set DRV_RST=!DRV_RST:~0,-1!)&Popd)
        If Not Exist "!WIM_DRV!\NVMe" (Set DRV_NVM=) Else (Pushd "!WIM_DRV!\NVMe"&For /R %%I In ("Client-!ARC_TYP!\IaNVMe.inf*")  Do (Set DRV_NVM=%%~dpI&Set DRV_NVM=!DRV_NVM:~0,-1!)&Popd)

               If /I "!DRV_USB!" NEQ "" (Set ADD_FLG=1
        ) Else If /I "!DRV_RST!" NEQ "" (Set ADD_FLG=1
        ) Else If /I "!DRV_NVM!" NEQ "" (Set ADD_FLG=1
        ) Else                          (Set ADD_FLG=0
        )

Rem --- boot.wim���X�V���� ----------------------------------------------------
        If !ADD_FLG! EQU 1 (
            Echo --- boot.wim���X�V���� [1] ----------------------------------------------------
            Dism /Mount-WIM /WimFile:"!WIM_IMG!\sources\boot.wim" /Index:1 /MountDir:"!WIM_MNT!"    || GoTo :DONE
            If /I "!DRV_NVM!" NEQ "" (
Rem             Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-KB2990941-v3-!ARC_TYP!.msu"       || GoTo :DONE
Rem             Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-kb3087873-v2-!ARC_TYP!.msu"       || GoTo :DONE
Rem             Dism !ADD_DRV! /Driver:"!DRV_NVM!"                                                  || GoTo :DONE
            )
            If /I "!DRV_USB!" NEQ "" (
                Dism !ADD_DRV! /Driver:"!DRV_USB!"                                                  || GoTo :DONE
            )
            If /I "!DRV_RST!" NEQ "" (
                Dism !ADD_DRV! /Driver:"!DRV_RST!"                                                  || GoTo :DONE
            )
            Dism /UnMount-Wim /MountDir:"!WIM_MNT!" /Commit                                         || GoTo :DONE

            Echo --- boot.wim���X�V���� [2] ----------------------------------------------------
            Dism /Mount-WIM /WimFile:"!WIM_IMG!\sources\boot.wim" /Index:2 /MountDir:"!WIM_MNT!"    || GoTo :DONE
            If /I "!DRV_NVM!" NEQ "" (
Rem             Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-KB2990941-v3-!ARC_TYP!.msu"       || GoTo :DONE
Rem             Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-kb3087873-v2-!ARC_TYP!.msu"       || GoTo :DONE
Rem             Dism !ADD_DRV! /Driver:"!DRV_NVM!"                                                  || GoTo :DONE
            )
            If /I "!DRV_USB!" NEQ "" (
                Dism !ADD_DRV! /Driver:"!DRV_USB!"                                                  || GoTo :DONE
            )
            If /I "!DRV_RST!" NEQ "" (
                Dism !ADD_DRV! /Driver:"!DRV_RST!"                                                  || GoTo :DONE
            )
            Dism /UnMount-Wim /MountDir:"!WIM_MNT!" /Commit                                         || GoTo :DONE
        )

Rem --- install.wim���X�V���� -------------------------------------------------
        Dism /Mount-WIM /WimFile:"!WIM_IMG!\sources\install.wim" /Name:"!WIN_TYP!" /MountDir:"!WIM_MNT!" || GoTo :DONE
        If !ADD_FLG! EQU 1 (
            Echo --- winRE.wim���X�V���� -------------------------------------------------------
            Dism /Mount-WIM /WimFile:"!WIM_MNT!\Windows\System32\Recovery\winRE.wim" /Index:1 /MountDir:"!WIM_WRE!"    || GoTo :DONE
            If /I "!DRV_NVM!" NEQ "" (
Rem             Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-KB2990941-v3-!ARC_TYP!.msu"       || GoTo :DONE
Rem             Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-kb3087873-v2-!ARC_TYP!.msu"       || GoTo :DONE
Rem             Dism !ADD_DRV! /Driver:"!DRV_NVM!"                                                  || GoTo :DONE
            )
            If /I "!DRV_USB!" NEQ "" (
                Dism !ADD_DRV! /Driver:"!DRV_USB!"                                                  || GoTo :DONE
            )
            If /I "!DRV_RST!" NEQ "" (
                Dism !ADD_DRV! /Driver:"!DRV_RST!"                                                  || GoTo :DONE
            )
            Dism /UnMount-Wim /MountDir:"!WIM_WRE!" /Commit                                         || GoTo :DONE
            Echo --- install.wim���X�V���� -----------------------------------------------------
            If /I "!DRV_NVM!" NEQ "" (
Rem             Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-KB2990941-v3-!ARC_TYP!.msu"       || GoTo :DONE
Rem             Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-kb3087873-v2-!ARC_TYP!.msu"       || GoTo :DONE
Rem             Dism !ADD_DRV! /Driver:"!DRV_NVM!"                                                  || GoTo :DONE
            )
            If /I "!DRV_USB!" NEQ "" (
                Dism !ADD_DRV! /Driver:"!DRV_USB!"                                                  || GoTo :DONE
            )
            If /I "!DRV_RST!" NEQ "" (
                Dism !ADD_DRV! /Driver:"!DRV_RST!"                                                  || GoTo :DONE
            )
        )
    ) Else (
Rem --- install.wim���X�V���� -------------------------------------------------
        Dism /Mount-WIM /WimFile:"!WIM_IMG!\sources\install.wim" /Name:"!WIN_TYP!" /MountDir:"!WIM_MNT!" || GoTo :DONE
    )
Rem --- Windows Update �t�@�C���̓��� -----------------------------------------
    Echo --- Windows Update �t�@�C���̓��� ---------------------------------------------
    For /F "tokens=1-10 usebackq delims=," %%I In ("!CMD_DAT!") Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE_NUM=%%~K
        Set LST_TYPE=%%~L
        Set LST_RUN_ORDER=%%~M
        Set LST_SECTION=%%~N
        Set LST_EXTENSION=%%~O
        Set LST_CMD=%%~P
        Set LST_RENAME=%%~Q
        Set LST_FILE=%%~R
        If /I "!LST_WINDOWS!" EQU "w!WIN_VER!" (
            If /I "!LST_PACKAGE!" EQU "!ARC_TYP!" (
                If /I "!LST_EXTENSION!" EQU "msu" (
                    If /I "!LST_SECTION!" EQU "KB2533552" (
                        For %%E In ("!LST_RENAME!") Do (Set LST_FCAB=%%~dpnE\%%~nE)
                        Dism !ADD_PAC! /PackagePath:"!LST_FCAB!"                                || GoTo :DONE
                    ) Else (
                        Dism !ADD_PAC! /PackagePath:"!LST_RENAME!"                              || GoTo :DONE
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "exe" (
                    If /I "!LST_SECTION!" EQU "IE11" (
                        If /I "!LST_CMD!" EQU "" (
                            Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\IE-Win7.CAB"           || GoTo :DONE
                            Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\ielangpack-ja-JP.CAB"  || GoTo :DONE
                            Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\IE-Spelling-en.MSU"    || GoTo :DONE
                            Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\IE-Hyphenation-en.MSU" || GoTo :DONE
                        )
                    )
                )
            )
        )
    )
    Dism /UnMount-Wim /MountDir:"!WIM_MNT!" /Commit                                         || GoTo :DONE

:MAKE_ISO_IMAGE
Rem === DVD�C���[�W���쐬���� =================================================
    Echo --- DVD�C���[�W���쐬���� -----------------------------------------------------
    If !FLG_SPL! EQU 1 (
        For %%I In ("!WIM_IMG!\sources\install.wim") Do (Set WIM_SIZ=%%~zI)
        If !WIM_SIZ! GEQ 4294967296 (
            Echo --- �t�@�C������ --------------------------------------------------------------
            Dism /Split-Image /ImageFile:"!WIM_IMG!\sources\install.wim" /SWMFile:"!WIM_IMG!\sources\install.swm" /FileSize:4095 || GoTo DONE
            Move /Y "!WIM_IMG!\sources\install.wim" "!WIM_BAK!" > Nul || GoTo DONE
        )
    )
    If Exist "!WIM_IMG!\efi\boot" (
        Set MAK_IMG=-m -o -u1 -h -l!DVD_VOL! -bootdata:2#p0,e,b"!WIM_IMG!\boot\etfsboot.com"#pEF,e,b"!WIM_IMG!\efi\microsoft\boot\efisys.bin"
    ) Else (
        Set MAK_IMG=-m -o -u1 -h -l!DVD_VOL! -bootdata:1#p0,e,b"!WIM_IMG!\boot\etfsboot.com"
    )
    Oscdimg !MAK_IMG! "!WIM_IMG!" "!DVD_DST!" || GoTo :DONE

Rem --- ��ƃt�@�C���̍폜 ----------------------------------------------------
    If Exist "!CMD_DAT!" (Del /F "!CMD_DAT!" || GoTo DONE)
    If Exist "!CMD_WRK!" (Del /F "!CMD_WRK!" || GoTo DONE)

    Echo --- ��ƃt�@�C���̍폜 --------------------------------------------------------
    Echo "!WIM_IMG!"
    Set INP_ANS=Y
    Set /P INP_ANS= ��L�t�H���_�[�̃t�@�C�����폜���܂����H [Y/N] ^(Yes/No^)�i�K��l[!INP_ANS!]�j
    If /I "!INP_ANS!" EQU "Y" (
        Del /F /S /Q "!WIM_IMG!" > Nul || GoTo DONE
        For /D %%I In (!WIM_IMG!\*) Do (RmDir /S /Q "%%~I" > Nul || GoTo DONE)
    )

Rem *** ��ƏI�� **************************************************************
:DONE
    EndLocal
    Echo *** ��ƏI�� ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]���������ĉ������B
    Pause > Nul 2>&1
    Echo On
