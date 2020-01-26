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
    Echo   MkWindows7_ISO_files_Custom.cmd {Commit ^| Discard} ^<�}�E���g�f�B���N�g��^>
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
    If /I "%CPU_TYP%" EQU "" (GoTo :INPUT_CPU_TYPE)

Rem --- ���ϐ��ݒ� ----------------------------------------------------------
    For /F "usebackq delims=" %%I In (`Echo %0`) Do Set DIR_WRK=%%~dpI

    CD "%DIR_WRK%\.."
    Set WIM_DIR=%CD%
    CD "%DIR_WRK%"

    Set WIM_TYP=w7
Rem Set WIM_DIR=C:\WimWK
    Set WIM_TOP=%WIM_DIR%\%WIM_TYP%
    Set WIM_BIN=%WIM_DIR%\bin
    Set WIM_CFG=%WIM_DIR%\cfg
    Set WIM_LST=%WIM_DIR%\lst
    Set WIM_PKG=%WIM_TOP%\pkg
    Set WIM_ADK=%WIM_PKG%\adk
    Set WIM_DRV=%WIM_PKG%\drv
    Set WIM_EFI=%WIM_PKG%\efi
    Set WIM_WUD=%WIM_PKG%\%CPU_TYP%
    Set WIM_X64=%WIM_PKG%\x64
    Set WIM_X86=%WIM_PKG%\x86
    Set WIM_TMP=%WIM_DIR%.$$$\%WIM_TYP%\%CPU_TYP%
    Set WIM_IMG=%WIM_TMP%\img
    Set WIM_MNT=%WIM_TMP%\mnt
    Set WIM_WRE=%WIM_TMP%\wre
    Set WIM_EMP=%WIM_TMP%\emp
    Set DIR_LST=adk drv zip x%CPU_BIT%

Rem --- Oscdimg�̃p�X��ݒ肷�� -----------------------------------------------
    If Not Exist "%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%" (
        If Not Exist "%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\%PROCESSOR_ARCHITECTURE%\Oscdimg" (
            Echo Windows ADK ���C���X�g�[�����ĉ������B
            GoTo :DONE
        )
        Robocopy /J /MIR /A-:RHS /NDL /NFL "%ProgramFiles(x86)%\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\%PROCESSOR_ARCHITECTURE%\Oscdimg" "%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%"
    )
    Set Path=%WIM_BIN%\Oscdimg\%PROCESSOR_ARCHITECTURE%;%Path%
    Oscdimg > NUL 2>&1
    If "%ErrorLevel%" EQU "9009" (
        Echo Windows ADK ���C���X�g�[�����ĉ������B
        GoTo :DONE
    )

Rem --- Windows�̃G�f�B�V�����ݒ� ---------------------------------------------
    Echo --- Windows�̃G�f�B�V�����ݒ� -------------------------------------------------
    Echo 1: Windows 7 Starter (32bit�ł̂�)
    Echo 2: Windows 7 HomeBasic
    Echo 3: Windows 7 HomePremium
    Echo 4: Windows 7 Professional
    Echo 5: Windows 7 Ultimate
    Set /P IDX_WIN=Windows�̃G�f�B�V������1�`5�̐�������I��ŉ������B

    If /I "%IDX_WIN%" EQU "1" (Set WIN_TYP=Windows 7 Starter)
    If /I "%IDX_WIN%" EQU "2" (Set WIN_TYP=Windows 7 HomeBasic)
    If /I "%IDX_WIN%" EQU "3" (Set WIN_TYP=Windows 7 HomePremium)
    If /I "%IDX_WIN%" EQU "4" (Set WIN_TYP=Windows 7 Professional)
    If /I "%IDX_WIN%" EQU "5" (Set WIN_TYP=Windows 7 Ultimate)

Rem --- DVD�̃h���C�u���ݒ� ---------------------------------------------------
    Echo --- DVD�̃h���C�u���ݒ� -------------------------------------------------------
    Set /P DRV_DVD=DVD�̃h���C�u������͂��ĉ������B [A-Z]
    If /I "%DRV_DVD:~1,1%" NEQ ":" (Set DRV_DVD=%DRV_DVD:~0,1%:)
Rem --- ���ϐ��ݒ� ----------------------------------------------------------
    Set DVD_SRC=%DRV_DVD%\\
    Set DVD_DST=%WIM_TOP%\windows_7_with_sp1_%CPU_TYP%_dvd_custom_VER_.iso

Rem *** ��ƃt�H���_�[�̍쐬 **************************************************
    Echo *** ��ƃt�H���_�[�̍쐬 ******************************************************
    If Exist "%WIM_WRE%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_WRE%" /Discard)
    If Exist "%WIM_MNT%\Windows" (Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Discard)
    If Exist "%WIM_TMP%" (RmDir /S /Q "%WIM_TMP%" || GoTo :DONE)

    If Not Exist "%WIM_BIN%" (MkDir "%WIM_BIN%")
    If Not Exist "%WIM_CFG%" (MkDir "%WIM_CFG%")
    If Not Exist "%WIM_LST%" (MkDir "%WIM_LST%")
    If Not Exist "%WIM_ADK%" (MkDir "%WIM_ADK%")
    If Not Exist "%WIM_DRV%" (MkDir "%WIM_DRV%")
    If Not Exist "%WIM_EFI%" (MkDir "%WIM_EFI%")
    If Not Exist "%WIM_X64%" (MkDir "%WIM_X64%")
    If Not Exist "%WIM_X86%" (MkDir "%WIM_X86%")
    If Not Exist "%WIM_IMG%" (MkDir "%WIM_IMG%")
    If Not Exist "%WIM_MNT%" (MkDir "%WIM_MNT%")
    If Not Exist "%WIM_WRE%" (MkDir "%WIM_WRE%")
    If Not Exist "%WIM_EMP%" (MkDir "%WIM_EMP%")

Rem *** �t�@�C���E�_�E�����[�h ************************************************
    Echo *** �t�@�C���E�_�E�����[�h ****************************************************
    For %%I In (%DIR_LST%) Do (
        Set DIR_TYP=%%I
        For %%J In (%WIM_LST%\Windows7!DIR_TYP!_Rollup_*.lst) Do (
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
                    If /I "!RENAME!" NEQ "" (
                        Set FNAME=!RENAME!
                    ) Else (
                        For /F "delims=! usebackq" %%M In ('!FILE!') Do (
                            Set FNAME=%%~nxM
                        )
                    )
                    If /I "!DIR_TYP!" NEQ "drv" (
                        If /I "!DIR_TYP!" EQU "x32" (
                            Set DNAME=%WIM_PKG%\x86
                        ) Else (
                            Set DNAME=%WIM_PKG%\!DIR_TYP!
                        )
                    ) Else (
                        If /I "!FNAME!" EQU "ASUS_EZInstaller_V10306.zip" (Set DIR_DRV=!DIR_TYP!\NVMe
                        ) Else If /I "!FNAME!" EQU "Client-x64.zip"       (Set DIR_DRV=!DIR_TYP!\NVMe
                        ) Else If /I "!FNAME!" EQU "Client-x86.zip"       (Set DIR_DRV=!DIR_TYP!\NVMe
                        ) Else If /I "!FNAME!" EQU "f6flpy-x64.zip"       (Set DIR_DRV=!DIR_TYP!\RST
                        ) Else If /I "!FNAME!" EQU "f6flpy-x86.zip"       (Set DIR_DRV=!DIR_TYP!\RST
                        ) Else                                            (Set DIR_DRV=!DIR_TYP!\USB
                        )
                        Set DNAME=%WIM_PKG%\!DIR_DRV!
                    )
                    If Not Exist "!DNAME!" MkDir "!DNAME!"
                    Set FNAME=!DNAME!\!FNAME!
                    If Exist "!FNAME!" If !SIZE! LSS 10 Del /F "!FNAME!"
                    If Not Exist "!FNAME!" (
                        Echo "!FNAME!"
                        Curl -L -# -R -o "!FNAME!" "!FILE!"
                    )
                    Set FILE=
                    Set RENAME=
                    Set SIZE=
                )
            )
        )
    )

Rem *** �����p�b�P�[�W�̏��� **************************************************
    If Not Exist "%WIM_WUD%\windows6.1-kb3125574-v4-%CPU_TYP%.msu" (
        Echo ��������p�b�P�[�W��"%WIM_WUD%"�ɃR�s�[���ĉ������B
        GoTo :DONE
    )

Rem === �h���C�o�[ ============================================================
    Echo === USB�h���C�o�[ =============================================================
    For /R "%WIM_DRV%\USB" %%I In (*.zip) Do (
        Set ZIP_USB=%%I
        Set DIR_USB=%%~dpnI
        If Not Exist "!DIR_USB!" (
            MkDir "!DIR_USB!"
            Tar -xvzf "!ZIP_USB!" -C "!DIR_USB!"
        )
    )
    For /R "%WIM_DRV%\USB" %%I In (Win7\%CPU_TYP%\iusb3hub.inf*) Do (
        Set DRV_USB=%%~dpI
        Set DRV_USB=!DRV_USB:~0,-1!
    )

    Echo === RST�h���C�o�[ =============================================================
    For /R "%WIM_DRV%\RST" %%I In (*.zip) Do (
        Set ZIP_RST=%%I
        Set DIR_RST=%%~dpnI
        If Not Exist "!DIR_RST!" (
            MkDir "!DIR_RST!"
            Tar -xvzf "!ZIP_RST!" -C "!DIR_RST!"
        )
    )
    For /R "%WIM_DRV%\RST" %%I In (f6flpy-%CPU_TYP%\iaAHCIC.inf*) Do (
        Set DRV_RST=%%~dpI
        Set DRV_RST=!DRV_RST:~0,-1!
    )

    Echo === NVMe�h���C�o�[ ============================================================
    For /R "%WIM_DRV%\NVMe" %%I In (*.zip) Do (
        Set ZIP_NVM=%%I
        Set DIR_NVM=%%~dpnI
        If Not Exist "!DIR_NVM!" (
            MkDir "!DIR_NVM!"
            Tar -xvzf "!ZIP_NVM!" -C "!DIR_NVM!"
        )
    )
    For /R "%WIM_DRV%\NVMe" %%I In (Client-%CPU_TYP%\IaNVMe.inf*) Do (
        Set DRV_NVM=%%~dpI
        Set DRV_NVM=!DRV_NVM:~0,-1!
    )
    If Not Exist "%WIM_WUD%\Windows6.1-KB2990941-v3-%CPU_TYP%.msu" (
        For /R "%WIM_DRV%\NVMe" %%I In (NVMe\%CPU_TYP%\Windows6.1-KB2990941-v3-%CPU_TYP%.msu*) Do (
            Copy /Y "%%~dpI*.msu" "%WIM_WUD%"
        )
    )

Rem === Internet Explorer 11 ==================================================
    If Not Exist "%WIM_WUD%\ie11\IE-Win7.CAB" (
        Echo === Internet Explorer 11 ======================================================
        "%WIM_WUD%\IE11-Windows6.1-%CPU_TYP%-ja-jp.exe" /x:"%WIM_WUD%\ie11"
    )

Rem === Windows Management Framework 5.1 ======================================
    If /I "%CPU_TYP%" EQU "x64" (
        If Not Exist "%WIM_WUD%\Win7AndW2K8R2-KB3191566-x64" (
            Echo === Windows Management Framework 5.1 ==========================================
            MkDir "%WIM_WUD%\Win7AndW2K8R2-KB3191566-x64"
            Tar -xvzf "%WIM_WUD%\Win7AndW2K8R2-KB3191566-x64.zip" -C "%WIM_WUD%\Win7AndW2K8R2-KB3191566-x64"
            Copy /Y "%WIM_WUD%\Win7AndW2K8R2-KB3191566-x64\*.msu" "%WIM_WUD%"
        )
    ) Else (
        If Not Exist "%WIM_WUD%\Win7-KB3191566-x86" (
            Echo === Windows Management Framework 5.1 ==========================================
            MkDir "%WIM_WUD%\Win7-KB3191566-x86"
            Tar -xvzf "%WIM_WUD%\Win7-KB3191566-x86.zip" -C "%WIM_WUD%\Win7-KB3191566-x86"
            Copy /Y "%WIM_WUD%\Win7-KB3191566-x86\*.msu" "%WIM_WUD%"
        )
    )

Rem *** ���{�����ƃt�H���_�[�ɃR�s�[���� ************************************
    Echo *** ���{�����ƃt�H���_�[�ɃR�s�[���� ****************************************
    If Not Exist "%DRV_DVD%\sources\install.wim" (
        Echo ��������%CPU_TYP%�ł�DVD��"%DRV_DVD%"�ɃZ�b�g���ĉ������B
        GoTo :DONE
    )

    If Exist "%DRV_DVD%\efi\microsoft\boot\efisys.bin" (
        If /I "%CPU_TYP%" NEQ "x64" (
            Echo DVD��x64[64bit]�łł��B
            Echo ��������%CPU_TYP%�ł�DVD��"%DRV_DVD%"�ɃZ�b�g���ĉ������B
            GoTo :DONE
        )
    ) Else (
        If /I "%CPU_TYP%" NEQ "x86" (
            Echo DVD��x86[32bit]�łł��B
            Echo ��������%CPU_TYP%�ł�DVD��"%DRV_DVD%"�ɃZ�b�g���ĉ������B
            GoTo :DONE
        )
    )

    Robocopy /J /MIR /A-:RHS /NDL /NFL "%DVD_SRC%" "%WIM_IMG%" %CPY_PRM%

Rem === UEFI�u�[�g���� ========================================================
    If /I "%CPU_TYP%" EQU "x64" (
        If Not Exist "%WIM_EFI%\bootx64.efi" (
            Dism /Mount-Wim /WimFile:"%WIM_IMG%\sources\boot.wim" /index:1 /MountDir:"%WIM_MNT%"
            Copy /Y "%WIM_MNT%\Windows\Boot\EFI\bootmgfw.efi" "%WIM_EFI%\bootx64.efi"
            Dism /Unmount-Wim /MountDir:"%WIM_MNT%" /Commit
        )
        Robocopy /J /A-:RHS /NDL /NFL "%WIM_EFI%" "%WIM_IMG%\efi\boot" "bootx64.efi"
    )

Rem === wim�o�[�W�����̎擾 ===================================================
    For /F "Usebackq Tokens=2 Delims=: " %%I In (`Dism /Get-WimInfo /WimFile:"%WIM_IMG%\Sources\Install.wim" /Name:"%WIN_TYP%" ^| FindStr /C:"�o�[�W���� :"`) Do Set WIM_VER=%%I
    Set DVD_DST=%DVD_DST:_VER_=_!WIM_VER!%

:UNATTEND
Rem === Unattend ==============================================================
    If Exist "%WIM_CFG%\autounattend-windows7-%CPU_TYP%.xml" (
        Echo *** autounattend.xml �̃R�s�[ *************************************************
        Copy /Y "%WIM_CFG%\autounattend-windows7-%CPU_TYP%.xml" "%WIM_IMG%\autounattend.xml"
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
    Echo>>"%OPT_CMD%"     Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "AUOptions" /t REG_DWORD /d 2
    Echo>>"%OPT_CMD%"     Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "IncludeRecommendedUpdates" /t REG_DWORD /d 1
    Echo>>"%OPT_CMD%"     Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "ElevateNonAdmins" /t REG_DWORD /d 1
    Echo>>"%OPT_CMD%"     Cmd /C reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /f /v "EnableFeaturedSoftware" /t REG_DWORD /d 1
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\ndp48-x86-x64-enu.exe"       /norestart /passive
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\ndp48-x86-x64-allos-jpn.exe" /norestart /passive
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\ndp48-kb4503575-%CPU_TYP%.exe"     /norestart /passive
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\ndp48-kb4515847-%CPU_TYP%.exe"     /norestart /passive
    If /I "%CPU_TYP%" EQU "x64" (
        Echo>>"%OPT_CMD%" Rem Cmd /C Wusa "%%configsetroot%%\autounattend\options\wupd\Win7AndW2K8R2-KB3191566-x64.msu" /quiet /norestart
    ) Else (
        Echo>>"%OPT_CMD%" Rem Cmd /C Wusa "%%configsetroot%%\autounattend\options\wupd\Win7-KB3191566-x86.msu" /quiet /norestart
    )
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\windows-kb890830-%CPU_TYP%-v5.79.exe" /Q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\mpas-fe-%CPU_TYP%.exe" -q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\MSEInstall-%CPU_TYP%.exe" /s /runwgacheck /o
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\mpam-fe-%CPU_TYP%.exe" -q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C "%%configsetroot%%\autounattend\options\wupd\silverlight.exe" /q
    Echo>>"%OPT_CMD%" Rem ---------------------------------------------------------------------------
    Echo>>"%OPT_CMD%"     Cmd /C Wusa "%%configsetroot%%\autounattend\options\wupd\windows6.1-kb2533552-%CPU_TYP%.msu" /quiet /norestart
    Echo>>"%OPT_CMD%"     Cmd /C Wusa "%%configsetroot%%\autounattend\options\wupd\windows6.1-kb4534310-%CPU_TYP%.msu" /quiet /norestart
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
        "windows6.1-kb2533552-%CPU_TYP%.msu"                        ^
        "windows6.1-kb4534310-%CPU_TYP%.msu"                        ^
        "IE11-Windows6.1-%CPU_TYP%-ja-jp.exe"                       ^
        "MSEInstall.exe"                                            ^
        "ndp48-kb4503575-%CPU_TYP%.exe"                             ^
        "ndp48-kb4515847-%CPU_TYP%.exe"                             ^
        "ndp48-x86-x64-allos-jpn.exe"                               ^
        "ndp48-x86-x64-enu.exe"                                     ^
        "windows-kb890830-%CPU_TYP%-v5.79.exe"                      ^
        "mpas-fe-%CPU_TYP%.exe"                                     ^
        "MSEInstall-%CPU_TYP%.exe"                                  ^
        "mpam-fe-%CPU_TYP%.exe"                                     ^
        "silverlight.exe"                                           ^
        "MicrosoftEdgeEnterprise-%CPU_TYP%.msi"
    If /I "%CPU_TYP%" EQU "x64" (
        Robocopy /J /A-:RHS /NDL /NFL "%WIM_WUD%" "%WIM_IMG%\%OPT_PKG%" ^
            "Win7AndW2K8R2-KB3191566-x64.msu"
    ) Else (
        Robocopy /J /A-:RHS /NDL /NFL "%WIM_WUD%" "%WIM_IMG%\%OPT_PKG%" ^
            "Win7-KB3191566-x86.msu"
    )
Rem ===========================================================================

:UPDATE
Rem === Windows Update �t�@�C���̓��� =========================================
    Set ADD_PAC=/Image:^"%WIM_MNT%^" /Add-Package /IgnoreCheck
    Set ADD_DRV=/Image:^"%WIM_MNT%^" /Add-Driver /ForceUnsigned /Recurse
    Set WRE_PAC=/Image:^"%WIM_WRE%^" /Add-Package /IgnoreCheck
    Set WRE_DRV=/Image:^"%WIM_WRE%^" /Add-Driver /ForceUnsigned /Recurse
Rem === �e��h���C�o�[ ========================================================
Rem *** boot.wim���X�V���� ****************************************************
    Echo *** boot.wim���X�V���� [1] ****************************************************
    Dism /Mount-WIM /WimFile:"%WIM_IMG%\sources\boot.wim" /Index:1 /MountDir:"%WIM_MNT%"    || GoTo :DONE
Rem Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-KB2990941-v3-%CPU_TYP%.msu"           || GoTo :DONE
Rem Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-kb3087873-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_DRV% /Driver:"%DRV_USB%"                                                      || GoTo :DONE
    Dism %ADD_DRV% /Driver:"%DRV_RST%"                                                      || GoTo :DONE
Rem Dism %ADD_DRV% /Driver:"%DRV_NVM%"                                                      || GoTo :DONE
    Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Commit                                         || GoTo :DONE

    Echo *** boot.wim���X�V���� [2] ****************************************************
    Dism /Mount-WIM /WimFile:"%WIM_IMG%\sources\boot.wim" /Index:2 /MountDir:"%WIM_MNT%"    || GoTo :DONE
Rem Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-KB2990941-v3-%CPU_TYP%.msu"           || GoTo :DONE
Rem Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-kb3087873-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_DRV% /Driver:"%DRV_USB%"                                                      || GoTo :DONE
    Dism %ADD_DRV% /Driver:"%DRV_RST%"                                                      || GoTo :DONE
Rem Dism %ADD_DRV% /Driver:"%DRV_NVM%"                                                      || GoTo :DONE
    Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Commit                                         || GoTo :DONE

Rem *** install.wim���X�V���� *************************************************
    Echo *** install.wim���X�V���� *****************************************************
    Dism /Mount-WIM /WimFile:"%WIM_IMG%\sources\install.wim" /Name:"%WIN_TYP%" /MountDir:"%WIM_MNT%" || GoTo :DONE
Rem === �e��h���C�o�[ [winRE.wim] ============================================
    Echo === winRE.wim���X�V���� =======================================================
    Dism /Mount-WIM /WimFile:"%WIM_MNT%\Windows\System32\Recovery\winRE.wim" /Index:1 /MountDir:"%WIM_WRE%"    || GoTo :DONE
Rem Dism %WRE_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-KB2990941-v3-%CPU_TYP%.msu"           || GoTo :DONE
Rem Dism %WRE_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-kb3087873-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %WRE_DRV% /Driver:"%DRV_USB%"                                                      || GoTo :DONE
    Dism %WRE_DRV% /Driver:"%DRV_RST%"                                                      || GoTo :DONE
Rem Dism %WRE_DRV% /Driver:"%DRV_NVM%"                                                      || GoTo :DONE
    Dism /UnMount-Wim /MountDir:"%WIM_WRE%" /Commit                                         || GoTo :DONE
Rem === �e��h���C�o�[ ========================================================
Rem Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-KB2990941-v3-%CPU_TYP%.msu"           || GoTo :DONE
Rem Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-kb3087873-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_DRV% /Driver:"%DRV_USB%"                                                      || GoTo :DONE
    Dism %ADD_DRV% /Driver:"%DRV_RST%"                                                      || GoTo :DONE
Rem Dism %ADD_DRV% /Driver:"%DRV_NVM%"                                                      || GoTo :DONE
Rem === Windows Update �t�@�C���̓��� =========================================
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb947821-v34-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2454826-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-KB2534366-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\Windows6.1-KB2679255-v2-%CPU_TYP%.msu"           || GoTo :DONE
Rem Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2533552-%CPU_TYP%.msu"              || GoTo :DONE
Rem === Internet Explorer 11 ==================================================
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2670838-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2834140-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2729094-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\ie11\IE-Win7.CAB"                                || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\ie11\ielangpack-ja-JP.CAB"                       || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\ie11\IE-Spelling-en.MSU"                         || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\ie11\IE-Hyphenation-en.MSU"                      || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\ie11-windows6.1-kb3185319-%CPU_TYP%.msu"         || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\ie11-windows6.1-kb4534251-%CPU_TYP%.msu"         || GoTo :DONE
Rem === Convenience rollup update =============================================
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb4474419-v3-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb4490628-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb4536952-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3020369-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3125574-v4-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3172605-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3179573-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb4534310-%CPU_TYP%.msu"              || GoTo :DONE
Rem === Security and Update ===================================================
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3021917-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3068708-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3080149-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3138612-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3150513-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3184143-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2984972-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2574819-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2592687-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3020387-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2830477-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3020388-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3075226-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2923545-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2900986-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2667402-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2698365-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2862330-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3004375-v3-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3046269-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3059317-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3156016-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3159398-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3161949-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3031432-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3042058-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3155178-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2545698-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2547666-%CPU_TYP%.msu"              || GoTo :DONE
    If /I "%CPU_TYP%" EQU "x64" (
        Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2603229-%CPU_TYP%.msu"          || GoTo :DONE
    )
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2732059-v5-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2750841-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2761217-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2773072-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2919469-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2970228-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3006137-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3102429-v2-%CPU_TYP%.msu"           || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3161102-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb4019990-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2818604-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb3170735-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2685811-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2685813-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb4040980-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb4507004-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2894844-%CPU_TYP%.msu"              || GoTo :DONE
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb2898851-%CPU_TYP%.msu"              || GoTo :DONE
Rem ---------------------------------------------------------------------------
    Dism %ADD_PAC% /PackagePath:"%WIM_WUD%\windows6.1-kb4532945-%CPU_TYP%.msu"              || GoTo :DONE
Rem === install.wim���X�V���ăA���}�E���g���� =================================
    Dism /UnMount-Wim /MountDir:"%WIM_MNT%" /Commit                                         || GoTo :DONE

:MAKE
Rem *** DVD�C���[�W���쐬���� *************************************************
    Echo *** DVD�C���[�W���쐬���� *****************************************************
    If /I "%CPU_TYP%" EQU "x64" (
        Set MAK_IMG=-m -o -u1 -h -bootdata:2#p0,e,b"%WIM_IMG%\boot\etfsboot.com"#pEF,e,b"%WIM_IMG%\efi\microsoft\boot\efisys.bin"
    ) Else (
        Set MAK_IMG=-m -o -u1 -h -bootdata:1#p0,e,b"%WIM_IMG%\boot\etfsboot.com"
    )
    Oscdimg %MAK_IMG% "%WIM_IMG%" "%DVD_DST%" || GoTo :DONE

Rem --- ��ƃt�H���_�[�̍폜 --------------------------------------------------
Rem Echo --- ��ƃt�H���_�[�̍폜 ------------------------------------------------------
    If Exist "%WIM_TMP%" (
        Set /P INP_ANS=��ƃt�H���_�[���폜���܂����H [Y/N] ^(Yes/No^)
        If /I "!INP_ANS!" EQU "Y" (
            RmDir /S /Q "%WIM_TMP%" || GoTo :DONE)
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
