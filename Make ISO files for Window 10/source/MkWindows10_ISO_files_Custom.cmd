Rem ***************************************************************************
    @Echo Off
    Cls

Rem *** ��ƊJ�n **************************************************************
:START
    Echo *** ��ƊJ�n ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

    If /I "%USERNAME%" NEQ "Administrator" (
        If /I "%SESSIONNAME%" NEQ "" (
            Echo �Ǘ��ғ����Ŏ��s���ĉ������B
            GoTo :DONE
        )
    )

    If /I "%1" EQU ""  (
        GoTo :INPUT_CPU_TYPE
    )

    If /I "%1" EQU "COMMIT"  (
        Echo *** ��Ƃ�L���ɂ��ăA���}�E���g���� ******************************************
        Dism /UnMount-Wim /MountDir:"%2" /Commit && GoTo :DONE
    )

    If /I "%1" EQU "DISCARD" (
        Echo *** ��Ƃ𒆎~�ɂ��ăA���}�E���g���� ******************************************
        Dism /UnMount-Wim /MountDir:"%2" /Discard && GoTo :DONE
    )

:ERROR_MSG
    Echo *** WIM �t�@�C���̃}�E���g���������� ******************************************
    Echo   %0 {Commit ^| Discard} ^<�}�E���g�f�B���N�g��^>
    Echo     �ύX��ۑ�����ɂ� Commit  ���w��
    Echo     �ύX��j������ɂ� Discard ���w��

    GoTo :DONE

Rem --- Windows�̃A�[�L�e�N�`���[�ݒ� -----------------------------------------
:INPUT_CPU_TYPE
    Echo --- Windows�̃A�[�L�e�N�`���[�ݒ� ---------------------------------------------
    Echo 1: 32bit��
    Echo 2: 64bit��
    Set /P IDX_CPU=Windows�̃A�[�L�e�N�`���[��1�`2�̐�������I��ŉ������B

    If /I "%IDX_CPU%" EQU "1" (Set CPU_TYP=x86&Set CPU_BIT=32)
    If /I "%IDX_CPU%" EQU "2" (Set CPU_TYP=x64&Set CPU_BIT=64)
    If /I "%CPU_TYP%" EQU ""  (GoTo :INPUT_CPU_TYPE)

Rem --- ���ϐ��ݒ� ----------------------------------------------------------
    For /F "usebackq delims=" %%I In (`Echo %0`) Do Set DIR_WRK=%%~dpI

    Set NOW_DAY=%date:~0,4%%date:~5,2%%date:~8,2%

    If /I "%time:~0,1%" EQU " " (
        Set NOW_TIM=0%time:~1,1%%time:~3,2%%time:~6,2%
    ) Else (
        Set NOW_TIM=%time:~0,2%%time:~3,2%%time:~6,2%
    )

    Set WIN_VER=10
    Set WIM_TYP=w%WIN_VER%
    Set WIM_TOP=C:\WimWK
    Set WIM_CST=%WIM_TOP%\%WIM_TYP%.custom
    Set WIM_WRK=%WIM_TOP%\%WIM_TYP%
    Set WIM_BIN=%WIM_WRK%\bin
    Set WIM_CFG=%WIM_WRK%\cfg
    Set WIM_LST=%WIM_WRK%\lst
    Set WIM_PKG=%WIM_WRK%\pkg
    Set WIM_TMP=%WIM_WRK%\tmp
    Set WIM_DIR=bin cfg lst pkg tmp
    Set PKG_DIR=adk drv zip  %CPU_TYP% 
    Set PKG_LST=adk drv zip x%CPU_BIT%

    Set WIM_WUD=%WIM_PKG%\%CPU_TYP%
    Set WIM_BAK=%WIM_WUD%\bak
    Set WIM_EFI=%WIM_WUD%\efi
    Set WIM_CPU=%WIM_WRK%\%CPU_TYP%
    Set WIM_IMG=%WIM_CPU%\img
    Set WIM_MNT=%WIM_CPU%\mnt
    Set WIM_WRE=%WIM_CPU%\wre
    Set WIM_DIR=%WIM_DIR% %CPU_TYP%\img %CPU_TYP%\mnt %CPU_TYP%\wre
    Set PKG_DIR=%PKG_DIR% %CPU_TYP%\bak %CPU_TYP%\efi

    Set WIM_DRV=%WIM_PKG%\drv
    Set DRV_CHP=%WIM_DRV%\CHP
    Set DRV_IME=%WIM_DRV%\IME
    Set DRV_NIC=%WIM_DRV%\NIC
    Set DRV_NVM=%WIM_DRV%\NVMe
    Set DRV_RST=%WIM_DRV%\RST
    Set DRV_USB=%WIM_DRV%\USB
    Set DRV_VGA=%WIM_DRV%\VGA

Rem *** ��ƃt�H���_�[�̍쐬 **************************************************
    Echo *** ��ƃt�H���_�[�̍쐬 ******************************************************
    If Exist "%WIM_WRE%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_WRE%" /Discard)
    If Exist "%WIM_MNT%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Discard)
    If Exist "%WIM_CPU%" (RmDir /S /Q "%WIM_CPU%" || GoTo :DONE)

    For %%I In (%WIM_DIR%) Do (
        If Not Exist "%WIM_WRK%\%%I" (MkDir "%WIM_WRK%\%%I")
    )

    For %%I In (%PKG_DIR%) Do (
        If Not Exist "%WIM_PKG%\%%I" (MkDir "%WIM_PKG%\%%I")
    )

Rem --- Oscdimg�̃p�X��ݒ肷�� -----------------------------------------------
    If "%KitsRoot%" EQU "" (
        If /I "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" (
            Set KitsRoot="%ProgramFiles(x86)%\Windows Kits\10\"
            Set KitsRoot=!KitsRoot:~1,-1!
        ) Else (
            Set KitsRoot=%ProgramFiles%\Windows Kits\10\
        )
    )
    Set KitsRoot=%KitsRoot:~0,-1%
    If Not Exist "%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%" (
        If Not Exist "%KitsRoot%\Assessment and Deployment Kit\Deployment Tools\%PROCESSOR_ARCHITECTURE%\Oscdimg" (
            Echo Windows ADK ���C���X�g�[�����ĉ������B
            GoTo :DONE
        )
        Robocopy /J /MIR /A-:RHS /NDL /NFL "%KitsRoot%\Assessment and Deployment Kit\Deployment Tools\%PROCESSOR_ARCHITECTURE%\Oscdimg" "%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%"
    )
    Set Path=%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%;%Path%
    Oscdimg > NUL 2>&1
    If "%ErrorLevel%" EQU "9009" (
        Echo Windows ADK ���C���X�g�[�����ĉ������B
        GoTo :DONE
    )

Rem --- DVD�̃h���C�u���ݒ� ---------------------------------------------------
    Echo --- DVD�̃h���C�u���ݒ� -------------------------------------------------------
    Set /P DRV_DVD=DVD�̃h���C�u������͂��ĉ������B [A-Z]
    If /I "%DRV_DVD:~1,1%" NEQ ":" (Set DRV_DVD=%DRV_DVD:~0,1%:)
    If Not Exist "%DRV_DVD%\sources\install.wim" If Not Exist "%DRV_DVD%\sources\install.swm" (
        Echo ��������%CPU_TYP%�ł�DVD��"%DRV_DVD%"�ɃZ�b�g���ĉ������B
        GoTo :DONE
    )
    If Exist "%DRV_DVD%\efi\boot\bootx64.efi" (
        If /I "%CPU_TYP%" EQU "x86" (
            Echo DVD��x64[64bit]�łł��B
            Echo ��������%CPU_TYP%�ł�DVD��"%DRV_DVD%"�ɃZ�b�g���ĉ������B
            GoTo :DONE
        )
    ) Else If Exist "%DRV_DVD%\efi\boot\bootia32.efi" (
        If /I "%CPU_TYP%" EQU "x64" (
            Echo DVD��x86[32bit]�łł��B
            Echo ��������%CPU_TYP%�ł�DVD��"%DRV_DVD%"�ɃZ�b�g���ĉ������B
            GoTo :DONE
        )
    ) Else (
        If Exist "%DRV_DVD%\efi\microsoft\boot\efisys.bin" (
            If /I "%CPU_TYP%" EQU "x86" (
                Echo DVD��x64[64bit]�łł��B
                Echo ��������%CPU_TYP%�ł�DVD��"%DRV_DVD%"�ɃZ�b�g���ĉ������B
                GoTo :DONE
            )
        ) Else (
            If /I "%CPU_TYP%" EQU "x64" (
                Echo DVD��x86[32bit]�łł��B
                Echo ��������%CPU_TYP%�ł�DVD��"%DRV_DVD%"�ɃZ�b�g���ĉ������B
                GoTo :DONE
            )
        )
    )

Rem --- ���ϐ��ݒ� ----------------------------------------------------------
    Set DVD_SRC=%DRV_DVD%\\
    Set DVD_DST=%WIM_TOP%\windows_%WIN_VER%_%CPU_TYP%_dvd_custom_VER_.iso

Rem --- Windows�̃G�f�B�V�����ݒ� ---------------------------------------------

Rem *** �t�@�C���E�_�E�����[�h ************************************************
    Echo *** �t�@�C���E�_�E�����[�h ****************************************************
Rem --- ���W���[���E�t�@�C���E�_�E�����[�h ------------------------------------
    Echo --- ���W���[���E�t�@�C���E�_�E�����[�h ----------------------------------------
    For %%I In (%PKG_LST%) Do (
        Set PKG_TYP=%%I
        For %%J In (%WIM_LST%\Windows%WIN_VER%!PKG_TYP!_Rollup_*.lst) Do (
            Set LIST=%%J
            Set FILE=
            Set RENAME=
            Set SIZE=
            For /F "delims== tokens=1* usebackq" %%K In (!LIST!) Do (
                Set KEY=%%K
                Set VAL=%%L
                If /I "!KEY:~0,1!!KEY:~-1,1!" EQU "[]" (
                    Set SECTION=!KEY:~1,-1!
                    Set FILE=
                    Set RENAME=
                    Set SIZE=
                )
                If /I "!SECTION!" NEQ "" (
                    If /I "!KEY!" EQU "FILE"   (Set FILE=!VAL!)
                    If /I "!KEY!" EQU "RENAME" (Set RENAME=!VAL!)
                    If /I "!KEY!" EQU "SIZE"   (Set SIZE=!VAL!)
                )
                If /I "!SECTION!" NEQ "" If /I "!FILE!" NEQ "" If /I "!SIZE!" NEQ "" (
                    If /I "!PKG_TYP!" EQU "x32" (
                        Set DNAME=%WIM_PKG%\x86
                    ) Else (
                        Set DNAME=%WIM_PKG%\!PKG_TYP!
                    )
                    If /I "!RENAME!" NEQ "" (
                        Set FNAME=!DNAME!\!RENAME!
                    ) Else (
                        For /F "delims=! usebackq" %%M In ('!FILE!') Do (
                            Set FNAME=!DNAME!\%%~nxM
                        )
                    )
                    For /F "delims=! usebackq" %%M In ('!FNAME!') Do (
                        Set DNAME=%%~dpM
                        Set FSIZE=%%~zM
                        If "!FSIZE!" EQU "" Set FSIZE=-1
                    )
                    If Not Exist "!DNAME!" MkDir "!DNAME!"
                    If Exist "!FNAME!" If !FSIZE! NEQ !SIZE! Del /F "!FNAME!"
                    If Not Exist "!FNAME!" (
                        Echo "!FNAME!"
                        Curl -L -# -R -o "!FNAME!" "!FILE!" || GoTo DONE
                    )
                    Set FILE=
                    Set RENAME=
                    Set SIZE=
                )
            )
        )
    )

Rem *** �����p�b�P�[�W�̏��� **************************************************
Rem --- ���{�����ƃt�H���_�[�ɃR�s�[���� ------------------------------------
    Echo --- ���{�����ƃt�H���_�[�ɃR�s�[���� ----------------------------------------
    Robocopy /J /MIR /A-:RHS /NDL /NFL "%DVD_SRC%" "%WIM_IMG%"

Rem --- wim�o�[�W�����̎擾 ---------------------------------------------------
    If Exist "%WIM_IMG%\Sources\Install.wim" (
        Set WIM_WIM=%WIM_IMG%\Sources\Install.wim
    ) Else (
        Set WIM_WIM=%WIM_IMG%\Sources\Install.swm
    )
    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"%WIM_WIM%" /Index:1 ^| FindStr /C:"�o�[�W���� :"`) Do Set WIM_VER=%%I
    Set DVD_DST=%DVD_DST:_VER_=_!WIM_VER!%

Rem === UEFI�u�[�g���� ========================================================

Rem === �h���C�o�[ ============================================================

:UNATTEND
Rem === Unattend ==============================================================
    If Exist "%WIM_CFG%\autounattend-windows%WIN_VER%-%CPU_TYP%.xml" (
        Echo *** autounattend.xml �̃R�s�[ *************************************************
        Copy /Y "%WIM_CFG%\autounattend-windows%WIN_VER%-%CPU_TYP%.xml" "%WIM_IMG%\autounattend.xml"
    )

Rem ---------------------------------------------------------------------------
    Echo *** options.cmd �̍쐬 *********************************************************
    Set OPT_DIR=autounattend\options
    Set OPT_PKG=%OPT_DIR%\wupd
    Set OPT_CMD=%WIM_IMG%\%OPT_DIR%\options.cmd
    mkdir "%WIM_IMG%\%OPT_DIR%"
Rem --- options.cmd �̍쐬 ----------------------------------------------------
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" Rem %DATE% %TIME% maked
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Echo ^%%DATE^%% ^%%TIME^%% Start
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C sc stop wuauserv
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\windows-kb890830-%CPU_TYP%-v5.79.exe" /Q
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\mpam-fe-%CPU_TYP%.exe" -q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\updateplatform-%CPU_TYP%.exe"
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C Wusa "%%configsetroot%%\autounattend\options\wupd\windows10.0-kb4528759-%CPU_TYP%.msu" /quiet /norestart
    Echo>>"%OPT_CMD%"     Cmd /C Wusa "%%configsetroot%%\autounattend\options\wupd\windows10.0-kb4532938-%CPU_TYP%-ndp48.msu" /quiet /norestart
    Echo>>"%OPT_CMD%"     Cmd /C Wusa "%%configsetroot%%\autounattend\options\wupd\windows10.0-kb4528760-%CPU_TYP%.msu" /quiet /norestart
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C msiexec /i "%%configsetroot%%\autounattend\options\wupd\MicrosoftEdgeEnterprise-%CPU_TYP%.msi" /norestart /passive
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%" Rem Cmd /C RmDel /S /Q "%%configsetroot%%"
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C shutdown /r /t 3
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Echo ^%%DATE^%% ^%%TIME^%% End
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     pause
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
Rem ---------------------------------------------------------------------------
    Robocopy /J /A-:RHS /NDL /NFL "%WIM_WUD%" "%WIM_IMG%\%OPT_PKG%" ^
        "windows-kb890830-%CPU_TYP%-v5.79.exe"                      ^
        "mpam-fe-%CPU_TYP%.exe"                                     ^
        "updateplatform-%CPU_TYP%.exe"                              ^
        "windows10.0-kb4528760-%CPU_TYP%.msu"                       ^
        "windows10.0-kb4532938-%CPU_TYP%-ndp48.msu"                 ^
        "MicrosoftEdgeEnterprise-%CPU_TYP%.msi"

:UPDATE
Rem === Windows Update �t�@�C���̓��� =========================================
Rem === �h���C�o�[ ============================================================

:SPLIT
Rem === install.wim�𕪊����� =================================================
    If Exist "%WIM_IMG%\sources\install.wim" (
        Echo === install.wim�𕪊����� =====================================================
        If Exist "%WIM_IMG%\sources\install.swm" (Del /F "%WIM_IMG%\sources\install*.swm")
        Dism /Split-Image /ImageFile:"%WIM_IMG%\sources\install.wim" /SWMFile:"%WIM_IMG%\sources\install.swm" /FileSize:2048 || GoTo DONE
        Move /Y "%WIM_IMG%\sources\install.wim" "%WIM_BAK%"
    )

:MAKE
Rem *** DVD�C���[�W���쐬���� *************************************************
    Echo *** DVD�C���[�W���쐬���� *****************************************************
    Set MAK_IMG=-m -o -u1 -h -bootdata:2#p0,e,b"%WIM_IMG%\boot\etfsboot.com"#pEF,e,b"%WIM_IMG%\efi\microsoft\boot\efisys.bin"
    Oscdimg %MAK_IMG% "%WIM_IMG%" "%DVD_DST%" || GoTo :DONE

Rem --- ��ƃt�H���_�[�̍폜 --------------------------------------------------
    If Exist "%WIM_CPU%" (
        Set /P INP_ANS=��ƃt�H���_�[���폜���܂����H [Y/N] ^(Yes/No^)
        If /I "!INP_ANS!" EQU "Y" (
            Echo --- ��ƃt�H���_�[�̍폜 ------------------------------------------------------
            RmDir /S /Q "%WIM_CPU%" || GoTo :DONE)
        )
    )

Rem *** ��ƏI�� **************************************************************
:DONE
    If Exist "%WIM_WRE%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_WRE%" /Discard)
    If Exist "%WIM_MNT%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Discard)
    EndLocal
    Echo *** ��ƏI�� ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]���������ĉ������B
    Pause > Nul 2>&1
    Echo On
