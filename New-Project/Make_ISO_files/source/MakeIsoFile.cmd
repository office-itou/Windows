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

    For /F "delims=\ tokens=2 usebackq" %%I In ('!WRK_DIR!') Do (Set WRK_TOP=%%~dI\%%~I)

Rem *** ��Ɗ��ݒ� **********************************************************
    Set DEF_TOP=C:\WimWK

    If /I "!WRK_TOP!" EQU "!DEF_TOP!" (
        Set WIM_TOP=!DEF_TOP!
    ) Else (
:INP_FOLDER
        Set WIM_TOP=!DEF_TOP!
        Set /P WIM_TOP=��Ɗ��̃t�H���_�[���w�肵�ĉ������B�i�K��l[!WIM_TOP!]�j
        If /I "!WIM_TOP!" EQU "" (Set WIM_TOP=C:\WimWK)

        Set INP_ANS=N
        Echo "!WIM_TOP!"
        Set /P INP_ANS=��L�ł�낵���ł����H [Y/N] ^(Yes/No^)�i�K��l[!INP_ANS!]�j
        If /I "!INP_ANS!" NEQ "Y" (GoTo INP_FOLDER)
    )

Rem --- Windows�̃o�[�W�����ݒ� -----------------------------------------------
:INPUT_WIN_TYPE
    Echo --- Windows�̃o�[�W�����ݒ� ---------------------------------------------------
    Echo 1: Windows 7
    Echo 2: Windows 10
    Set IDX_WIN=2
    Set /P IDX_WIN=Windows�̃o�[�W������1�`2�̐�������I��ŉ������B�i�K��l[!IDX_WIN!]�j

           If /I "!IDX_WIN!" EQU "1" (Set WIN_VER=7
    ) Else If /I "!IDX_WIN!" EQU "2" (Set WIN_VER=10
    ) Else                           (GoTo INPUT_WIN_TYPE
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

    For %%I in (!DRV_DVD!\) Do (
        Set DVD_SRC=%%~dpI
        If /I "!DVD_SRC:~-1!" EQU "\" (
            Set DVD_SRC=!DVD_SRC:~0,-1!
        )
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
    For /F "Usebackq Tokens=3 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"!WIM_WIM!" /Index:1 ^| FindStr /C:"���O:"`)           Do (Set WIM_NME=%%I)
    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"!WIM_WIM!" /Index:1 ^| FindStr /C:"�A�[�L�e�N�`��:"`) Do (Set WIM_ARC=%%I)
    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"!WIM_WIM!" /Index:1 ^| FindStr /C:"�o�[�W���� :"`)    Do (Set WIM_VER=%%I)
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

Rem --- Windows�̃G�f�B�V�����ݒ� ---------------------------------------------
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
    ) Else If !WIN_VER! EQU 10 (
Rem     Echo --- Windows�̃G�f�B�V�����ݒ� -------------------------------------------------
Rem     Echo 1: Windows 10 Home
Rem     Echo 2: Windows 10 Education
Rem     Echo 3: Windows 10 Pro
Rem     Echo 4: Windows 10 Pro Education
Rem     Echo 5: Windows 10 Pro for Workstations
        Set IDX_WIN=3
Rem     Set /P IDX_WIN=Windows�̃G�f�B�V������1�`5�̐�������I��ŉ������B�i�K��l[!IDX_WIN!]�j

               If /I "!IDX_WIN!" EQU "1" (Set WIN_TYP=Windows 10 Home
        ) Else If /I "!IDX_WIN!" EQU "2" (Set WIN_TYP=Windows 10 Education
        ) Else If /I "!IDX_WIN!" EQU "3" (Set WIN_TYP=Windows 10 Pro
        ) Else If /I "!IDX_WIN!" EQU "4" (Set WIN_TYP=Windows 10 Pro Education
        ) Else If /I "!IDX_WIN!" EQU "5" (Set WIN_TYP=Windows 10 Pro for Workstations
        )
    )

Rem --- ���ϐ��ݒ� ----------------------------------------------------------
Rem Set WIN_VER=%~1
    Set LST_PKG=adk drv zip !ARC_TYP!
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

    Set DVD_SRC=!DRV_DVD!
    Set DVD_DST=!WIM_TOP!\windows_!WIN_VER!_!ARC_TYP!_dvd_custom_VER_.iso
    Set DVD_DST=%DVD_DST:_VER_=_!WIM_VER!%

Rem --- ��ƃt�H���_�[�̍쐬 --------------------------------------------------
    Echo *** ��ƃt�H���_�[�̍쐬 ******************************************************
Rem --- �j���C���[�W�̍폜 ----------------------------------------------------
    For %%I In (!WIN_VER!) Do (
        For %%J In (!ARC_TYP!) Do (
            Set WIM_IMG=!WIM_WRK!\w%%I\%%J\img
            Set WIM_MNT=!WIM_WRK!\w%%I\%%J\mnt
            Set WIM_WRE=!WIM_WRK!\w%%I\%%J\wre
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
            Set WIM_DRV=!WIM_PKG!\w%%I\drv
            Set WIM_WUD=!WIM_PKG!\w%%I\%%J
            Set WIM_BAK=!WIM_WRK!\w%%I\%%J\bak
            Set WIM_EFI=!WIM_WRK!\w%%I\%%J\efi
            Set WIM_IMG=!WIM_WRK!\w%%I\%%J\img
            Set WIM_MNT=!WIM_WRK!\w%%I\%%J\mnt
            Set WIM_WRE=!WIM_WRK!\w%%I\%%J\wre

            If     Exist "!WIM_IMG!" (RmDir /S /Q "!WIM_IMG!" || GoTo DONE)
            If     Exist "!WIM_MNT!" (RmDir /S /Q "!WIM_MNT!" || GoTo DONE)
            If     Exist "!WIM_WRE!" (RmDir /S /Q "!WIM_WRE!" || GoTo DONE)

            If Not Exist "!WIM_WUD!" (MkDir       "!WIM_WUD!" || GoTo DONE)
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

Rem --- Oscdimg�擾 -----------------------------------------------------------
    If Not Exist "!WIM_BIN!\Oscdimg\%PROCESSOR_ARCHITECTURE%" (
        Echo --- Oscdimg�擾 ---------------------------------------------------------------
        Pushd "%ProgramFiles(x86)%"
            For /R %%I In (Oscdimg.exe*) Do (Set UTL_WRK=%%~dpI)
        Popd
        If /I "!UTL_WRK!" EQU "" (
            Echo Windows ADK ���C���X�g�[�����ĉ������B
            GoTo DONE
        )
        For %%I In (!UTL_ARC!) DO (
            Set UTL_SRC=!UTL_WRK!\..\..\%%~I\Oscdimg
            Set UTL_DST=!WIM_BIN!\Oscdimg\%%~I
            Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!UTL_SRC!" "!UTL_DST!"
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
            For %%K In (!LST_LFSNAME!) Do (
                Set LST_LFNAME=%%~K
                For /F "delims== tokens=1* usebackq" %%L In (!LST_LFNAME!) Do (
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
                            Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
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
                    Echo>>"!CMD_WRK!" "w!LST_WINVER!","!LST_PACKAGE!","!LST_TYPE!","!LST_RUN_ORDER!","!LST_SECTION!","!LST_EXTENSION!","!LST_CMD!","!LST_RENAME!","!LST_FILE!"
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
                )
            )
        )
    )

Rem --- �t�@�C���\�[�g --------------------------------------------------------
    Sort "!CMD_WRK!" > "!CMD_DAT!"

Rem *** �t�@�C���擾 **********************************************************
    Echo --- �t�@�C���擾 --------------------------------------------------------------
    For /F "delims=, tokens=1-9 usebackq" %%I In (!CMD_DAT!) Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE=%%~K
        Set LST_RUN_ORDER=%%~L
        Set LST_SECTION=%%~M
        Set LST_EXTENSION=%%~N
        Set LST_CMD=%%~O
        Set LST_RENAME=%%~P
        Set LST_FILE=%%~Q
        Set LST_WINPKG=!WIM_PKG!\!LST_WINDOWS!
        For %%E In ("!LST_RENAME!") Do (Set LST_FNAME=%%~nxE)
        For /F "delims=: tokens=2 usebackq" %%X In ('!LST_FILE!') Do (
            If /I "%%X" NEQ "" (
                If Not Exist "!LST_RENAME!" (
                    Echo "!LST_FNAME!"
                    Curl -L -# -R -S -f --create-dirs -o "!LST_RENAME!" "!LST_FILE!" || GoTo DONE
                ) Else (
                    Curl -L -s --dump-header "!CMD_WRK!" "!LST_FILE!"
                    Set LST_LEN=0
                    For /F "delims=: tokens=1,2* usebackq" %%Y In ("!CMD_WRK!") Do (
                        If /I "%%~Y" EQU "Content-Length" (
                            Set LST_LEN=%%~Z
                        )
                    )
                    For /F "delims=/ usebackq" %%Z In ('!LST_RENAME!') Do (Set LST_SIZE=%%~zZ)
                    If !LST_LEN! NEQ !LST_SIZE! (
                        Echo "!LST_FNAME!" : !LST_SIZE! : !LST_LEN!
                        Curl -L -# -R -S -f --create-dirs -o "!LST_RENAME!" "!LST_FILE!" || GoTo DONE
                    )
                )
                If /I "!LST_EXTENSION!" EQU "zip" (
                    For %%E In ("!LST_RENAME!") Do (Set LST_DIR=%%~dpnE)
                    If Not Exist "!LST_DIR!" (
                        Echo --- �t�@�C���W�J --------------------------------------------------------------
                        MkDir "!LST_DIR!"
                        Tar -xzf "!LST_RENAME!" -C "!LST_DIR!"
                    )
                    Pushd "!LST_DIR!"
                        For /R %%E In (*.zip) Do (
                            Set LST_ZIPFILE=%%E
                            Set LST_ZIPDIR=%%~dpnE
                            If Not Exist "!LST_ZIPDIR!" (
                                Echo --- �t�@�C���W�J --------------------------------------------------------------
                                MkDir "!LST_ZIPDIR!"
                                Tar -xzf "!LST_ZIPFILE!" -C "!LST_ZIPDIR!"
                            )
                            Pushd "!LST_ZIPDIR!"
                                For /R %%F In (*.msu) Do (
                                    For /F "delims=x tokens=2" %%G In ("%%~nF") Do (Set LST_PACKAGE=%%G)
                                    If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!\%%~nxF" (
                                        Echo --- �t�@�C���]�� --------------------------------------------------------------
                                        If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!" (MkDir "!LST_WINPKG!\x!LST_PACKAGE!")
                                        Copy /Y "%%F" "!LST_WINPKG!\x!LST_PACKAGE!" > Nul
                                    )
                                )
                            Popd
                        )
                        For /R %%F In (*.msu) Do (
                            For /F "delims=x tokens=2" %%G In ("%%~nF") Do (Set LST_PACKAGE=%%G)
                            If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!\%%~nxF" (
                                Echo --- �t�@�C���]�� --------------------------------------------------------------
                                If Not Exist "!LST_WINPKG!\x!LST_PACKAGE!" (MkDir "!LST_WINPKG!\x!LST_PACKAGE!")
                                Copy /Y "%%F" "!LST_WINPKG!\x!LST_PACKAGE!" > Nul
                            )
                        )
                    Popd
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
                )
            )
        )
    )

:UPDATE
Rem *** ����ISO�t�@�C���쐬 ***************************************************
Rem === ���{�����ƃt�H���_�[�ɃR�s�[���� ====================================
    Echo --- ���{�����ƃt�H���_�[�ɃR�s�[���� ----------------------------------------
    Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS /NFL "!DVD_SRC!\" "!WIM_IMG!"

:ADD_BOOT_OPTIONS
Rem === UEFI�u�[�g���� ========================================================
    If !WIN_VER! EQU 7 If /I "!ARC_TYP!" EQU "x64" (
        If Not Exist "!WIM_EFI!\bootx64.efi" (
            Echo --- bootx64.efi �̒��o --------------------------------------------------------
            Dism /Mount-Wim /WimFile:"!WIM_IMG!\sources\boot.wim" /index:1 /MountDir:"!WIM_MNT!" /ReadOnly || GoTo DONE
            Copy /Y "!WIM_MNT!\Windows\Boot\EFI\bootmgfw.efi" "!WIM_EFI!\bootx64.efi" > Nul || GoTo DONE
            Dism /Unmount-Wim /MountDir:"!WIM_MNT!" /Discard || GoTo DONE
        )
        Echo --- bootx64.efi �̃R�s�[ ------------------------------------------------------
        Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!WIM_EFI!" "!WIM_IMG!\efi\boot" "bootx64.efi"
    )

:ADD_UNATTEND
Rem === Unattend ==============================================================
    If Exist "!WIM_CFG!\autounattend-windows!WIN_VER!-!ARC_TYP!.xml" (
        Echo --- autounattend.xml �̃R�s�[ -------------------------------------------------
        Copy /Y "!WIM_CFG!\autounattend-windows!WIN_VER!-!ARC_TYP!.xml" "!WIM_IMG!\autounattend.xml" > Nul
    )

:ADD_OPTIONS
Rem === options.cmd �̍쐬 ====================================================
    Echo --- options.cmd �̍쐬 ---------------------------------------------------------
    Set OPT_DIR=autounattend\options
    Set OPT_PKG=!OPT_DIR!\upd
    Set OPT_DRV=!OPT_DIR!\drv
    Set OPT_CMD=!WIM_IMG!\!OPT_DIR!\options.cmd
    Set OPT_LST=
    If Not Exist "!WIM_IMG!\!OPT_DIR!" (MkDir "!WIM_IMG!\!OPT_DIR!")
    If Exist "!OPT_CMD!" (Del /F "!OPT_CMD!")
Rem --- options.cmd �̍쐬 ----------------------------------------------------
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem %DATE% %TIME% maked
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"     Echo ^%%DATE^%% ^%%TIME^%% Start
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem Cmd /C sc stop wuauserv
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    If !WIN_VER! EQU 7 (
        Echo>>"!OPT_CMD!"     Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "AUOptions" /t REG_DWORD /d 1
        Echo>>"!OPT_CMD!"     Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "IncludeRecommendedUpdates" /t REG_DWORD /d 1
        Echo>>"!OPT_CMD!"     Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "ElevateNonAdmins" /t REG_DWORD /d 1
        Echo>>"!OPT_CMD!"     Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "EnableFeaturedSoftware" /t REG_DWORD /d 1
        Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    )
Rem ---------------------------------------------------------------------------
    For /F "delims=, tokens=1-9 usebackq" %%I In (!CMD_DAT!) Do (
        Set LST_WINDOWS=%%~I
        Set LST_PACKAGE=%%~J
        Set LST_TYPE=%%~K
        Set LST_RUN_ORDER=%%~L
        Set LST_SECTION=%%~M
        Set LST_EXTENSION=%%~N
        Set LST_CMD=%%~O
        Set LST_RENAME=%%~P
        Set LST_FILE=%%~Q
        For %%E In ("!LST_RENAME!") Do (
            Set LST_FNAME=%%~nxE
            Set LST_FDIR=%%~dpnE
        )
        If /I "!LST_WINDOWS!" EQU "w!WIN_VER!" (
            If /I "!LST_PACKAGE!" EQU "!ARC_TYP!" (
                If /I "!LST_EXTENSION!" EQU "exe" (
                    If /I "!LST_SECTION!" NEQ "IE11" (
                        Echo>>"!OPT_CMD!"     Cmd /C "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" !LST_CMD!
                        Set OPT_LST=!OPT_LST! "!LST_FNAME!"
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "wus" (
                    If /I "!LST_CMD!" NEQ "" (
                        Echo>>"!OPT_CMD!"     Cmd /C Wusa "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" !LST_CMD!
                        Set OPT_LST=!OPT_LST! "!LST_FNAME!"
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "msi" (
                    Echo>>"!OPT_CMD!"     Cmd /C msiexec /i "%%configsetroot%%\!OPT_PKG!\!LST_FNAME!" !LST_CMD!
                    Set OPT_LST=!OPT_LST! "!LST_FNAME!"
                )
            ) Else If /I "!LST_PACKAGE!" EQU "drv" (
                If /I "!LST_EXTENSION!" EQU "cab" (
                    If /I "!LST_CMD!" NEQ "" (
                        For %%E In ("!LST_RENAME!") Do (
                            Set OPT_WRK=%%~nE
                            If !WIN_VER! EQU 7 (
                                Echo>>"!OPT_CMD!"     Cmd /C PnpUtil -A "%%configsetroot%%\!OPT_DRV!\!OPT_WRK!\*.inf"
                            ) Else             (
                                Echo>>"!OPT_CMD!"     Cmd /C PnpUtil /Add-Driver "%%configsetroot%%\!OPT_DRV!\!OPT_WRK!\*.inf" /SubDirs /Install
                            )
                            Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!LST_FDIR!" "!WIM_IMG!\!OPT_DRV!\!OPT_WRK!"
                        )
                    )
                ) Else If /I "!LST_EXTENSION!" EQU "zip" (
                    If /I "!LST_CMD!" NEQ "" (
                        For %%E In ("!LST_RENAME!") Do (
                            Set OPT_WRK=%%~nE
                            Robocopy /J /MIR /A-:RHS /NDL /NC /NJH /NJS "!LST_FDIR!" "!WIM_IMG!\!OPT_DRV!\!OPT_WRK!"
                        )
                    )
                )
            )
        )
    )
Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!" Rem Cmd /C RmDel /S /Q "%%configsetroot%%"
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"     Cmd /C shutdown /r /t 3
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"     Echo ^%%DATE^%% ^%%TIME^%% End
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
    Echo>>"!OPT_CMD!"     pause
    Echo>>"!OPT_CMD!" Rem ---------------------------------------------------------------------------
Rem ---------------------------------------------------------------------------
    If /I "!OPT_LST!" NEQ "" (
        Robocopy /J /A-:RHS /NDL /NC /NJH /NJS "!WIM_WUD!" "!WIM_IMG!\!OPT_PKG!" !OPT_LST!
    )

Rem GoTo MAKE_ISO_IMAGE

:ADD_PACKAGE
Rem === Windows Update �t�@�C�� �� �h���C�o�[ �̓��� ==========================
    Set ADD_PAC=/Image:^"!WIM_MNT!^" /Add-Package /IgnoreCheck
    Set ADD_DRV=/Image:^"!WIM_MNT!^" /Add-Driver /ForceUnsigned /Recurse
    Set WRE_PAC=/Image:^"!WIM_WRE!^" /Add-Package /IgnoreCheck
    Set WRE_DRV=/Image:^"!WIM_WRE!^" /Add-Driver /ForceUnsigned /Recurse

    If !WIN_VER! EQU 7 (
        Echo --- �h���C�o�[�̓��� -----------------------------------------------------------
        Pushd "!WIM_DRV!\USB" &For /R %%I In (Win7\!ARC_TYP!\iusb3hub.inf*)  Do (Set DRV_USB=%%~dpI&Set DRV_USB=!DRV_USB:~0,-1!)&Popd
        Pushd "!WIM_DRV!\RST" &For /R %%I In (f6flpy-!ARC_TYP!\iaAHCIC.inf*) Do (Set DRV_RST=%%~dpI&Set DRV_RST=!DRV_RST:~0,-1!)&Popd
        Pushd "!WIM_DRV!\NVMe"&For /R %%I In (Client-!ARC_TYP!\IaNVMe.inf*)  Do (Set DRV_NVM=%%~dpI&Set DRV_NVM=!DRV_NVM:~0,-1!)&Popd

Rem --- boot.wim���X�V���� ----------------------------------------------------
        Echo --- boot.wim���X�V���� [1] ----------------------------------------------------
        Dism /Mount-WIM /WimFile:"!WIM_IMG!\sources\boot.wim" /Index:1 /MountDir:"!WIM_MNT!"    || GoTo :DONE
Rem     Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-KB2990941-v3-!ARC_TYP!.msu"           || GoTo :DONE
Rem     Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-kb3087873-v2-!ARC_TYP!.msu"           || GoTo :DONE
        Dism !ADD_DRV! /Driver:"!DRV_USB!"                                                      || GoTo :DONE
        Dism !ADD_DRV! /Driver:"!DRV_RST!"                                                      || GoTo :DONE
Rem     Dism !ADD_DRV! /Driver:"!DRV_NVM!"                                                      || GoTo :DONE
        Dism /UnMount-Wim /MountDir:"!WIM_MNT!" /Commit                                         || GoTo :DONE

        Echo --- boot.wim���X�V���� [2] ----------------------------------------------------
        Dism /Mount-WIM /WimFile:"!WIM_IMG!\sources\boot.wim" /Index:2 /MountDir:"!WIM_MNT!"    || GoTo :DONE
Rem     Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-KB2990941-v3-!ARC_TYP!.msu"           || GoTo :DONE
Rem     Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-kb3087873-v2-!ARC_TYP!.msu"           || GoTo :DONE
        Dism !ADD_DRV! /Driver:"!DRV_USB!"                                                      || GoTo :DONE
        Dism !ADD_DRV! /Driver:"!DRV_RST!"                                                      || GoTo :DONE
Rem     Dism !ADD_DRV! /Driver:"!DRV_NVM!"                                                      || GoTo :DONE
        Dism /UnMount-Wim /MountDir:"!WIM_MNT!" /Commit                                         || GoTo :DONE

Rem --- install.wim���X�V���� -------------------------------------------------
        Dism /Mount-WIM /WimFile:"!WIM_IMG!\sources\install.wim" /Name:"!WIN_TYP!" /MountDir:"!WIM_MNT!" || GoTo :DONE
        Echo --- winRE.wim���X�V���� -------------------------------------------------------
        Dism /Mount-WIM /WimFile:"!WIM_MNT!\Windows\System32\Recovery\winRE.wim" /Index:1 /MountDir:"!WIM_WRE!"    || GoTo :DONE
Rem     Dism !WRE_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-KB2990941-v3-!ARC_TYP!.msu"           || GoTo :DONE
Rem     Dism !WRE_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-kb3087873-v2-!ARC_TYP!.msu"           || GoTo :DONE
        Dism !WRE_DRV! /Driver:"!DRV_USB!"                                                      || GoTo :DONE
        Dism !WRE_DRV! /Driver:"!DRV_RST!"                                                      || GoTo :DONE
Rem     Dism !WRE_DRV! /Driver:"!DRV_NVM!"                                                      || GoTo :DONE
        Dism /UnMount-Wim /MountDir:"!WIM_WRE!" /Commit                                         || GoTo :DONE
        Echo --- install.wim���X�V���� -----------------------------------------------------
Rem     Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-KB2990941-v3-!ARC_TYP!.msu"           || GoTo :DONE
Rem     Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\Windows6.1-kb3087873-v2-!ARC_TYP!.msu"           || GoTo :DONE
        Dism !ADD_DRV! /Driver:"!DRV_USB!"                                                      || GoTo :DONE
        Dism !ADD_DRV! /Driver:"!DRV_RST!"                                                      || GoTo :DONE
Rem     Dism !ADD_DRV! /Driver:"!DRV_NVM!"                                                      || GoTo :DONE
Rem --- Windows Update �t�@�C���̓��� -----------------------------------------
        For /F "delims=, tokens=1-9 usebackq" %%I In (!CMD_DAT!) Do (
            Set LST_WINDOWS=%%~I
            Set LST_PACKAGE=%%~J
            Set LST_TYPE=%%~K
            Set LST_RUN_ORDER=%%~L
            Set LST_SECTION=%%~M
            Set LST_EXTENSION=%%~N
            Set LST_CMD=%%~O
            Set LST_RENAME=%%~P
            Set LST_FILE=%%~Q
            For %%E In ("!LST_RENAME!") Do (Set LST_FNAME=%%~nxE)
            If /I "!LST_WINDOWS!" EQU "w!WIN_VER!" (
                If /I "!LST_PACKAGE!" EQU "!ARC_TYP!" (
                    If /I "!LST_EXTENSION!" EQU "msu" (
                        Dism !ADD_PAC! /PackagePath:"!LST_RENAME!"                              || GoTo :DONE
                    ) Else If /I "!LST_EXTENSION!" EQU "exe" (
                        If /I "!LST_SECTION!" EQU "IE11" (
                            Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\IE-Win7.CAB"           || GoTo :DONE
                            Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\ielangpack-ja-JP.CAB"  || GoTo :DONE
                            Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\IE-Spelling-en.MSU"    || GoTo :DONE
                            Dism !ADD_PAC! /PackagePath:"!WIM_WUD!\IE11-Windows6.1-!ARC_TYP!-ja-jp\IE-Hyphenation-en.MSU" || GoTo :DONE
                        )
                    )
                )
            )
        )
        Dism /UnMount-Wim /MountDir:"!WIM_MNT!" /Commit                                         || GoTo :DONE
    )

:MAKE_ISO_IMAGE
Rem === DVD�C���[�W���쐬���� =================================================
    Echo --- DVD�C���[�W���쐬���� -----------------------------------------------------
    For %%I In ("!WIM_IMG!\sources\install.wim") Do (Set WIM_SIZ=%%~zI)
Rem If !WIM_SIZ! GEQ 4294967296 (
Rem     Echo --- �t�@�C������ --------------------------------------------------------------
Rem     Dism /Split-Image /ImageFile:"!WIM_IMG!\sources\install.wim" /SWMFile:"!WIM_IMG!\sources\install.swm" /FileSize:4095 || GoTo DONE
Rem     Move /Y "!WIM_IMG!\sources\install.wim" "!WIM_BAK!" > Nul
Rem )
    If Exist "!WIM_IMG!\efi\boot" (
        Set MAK_IMG=-m -o -u1 -h -bootdata:2#p0,e,b"!WIM_IMG!\boot\etfsboot.com"#pEF,e,b"!WIM_IMG!\efi\microsoft\boot\efisys.bin"
    ) Else (
        Set MAK_IMG=-m -o -u1 -h -bootdata:1#p0,e,b"!WIM_IMG!\boot\etfsboot.com"
    )
    Oscdimg !MAK_IMG! "!WIM_IMG!" "!DVD_DST!" || GoTo :DONE

Rem --- ��ƃt�@�C���̍폜 ----------------------------------------------------
    If Exist "!CMD_DAT!" (Del /F "!CMD_DAT!" || GoTo DONE)
    If Exist "!CMD_WRK!" (Del /F "!CMD_WRK!" || GoTo DONE)

Rem *** ��ƏI�� **************************************************************
:DONE
    EndLocal
    Echo *** ��ƏI�� ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]���������ĉ������B
    Pause > Nul 2>&1
    Echo On
