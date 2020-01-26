Rem ****************************************************************************
    @Echo Off
    Cls

Rem ��ƊJ�n *******************************************************************
:START
    Echo *** ��ƊJ�n *******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

    If /I "%WinPERoot%" EQU "" (
        Echo �Ǘ��ғ���:�W�J����уC���[�W���O �c�[�����Ŏ��s���ĉ������B
        GoTo :DONE
    )

    If /I "%USERNAME%" NEQ "Administrator" (
        If /I "%SESSIONNAME%" NEQ "" (
            Echo �Ǘ��ғ����Ŏ��s���ĉ������B
            GoTo :DONE
        )
    )

    If /I "%1" EQU "COMMIT"  (
        Echo *** ��Ƃ�L���ɂ��ăA���}�E���g���� *******************************************
        Dism /UnMount-Wim /MountDir:"%2" /Commit
        GoTo :DONE
    )

    If /I "%1" EQU "DISCARD" (
        Echo *** ��Ƃ𒆎~�ɂ��ăA���}�E���g���� *******************************************
        Dism /UnMount-Wim /MountDir:"%2" /Discard
        GoTo :DONE
    )

Rem --- Windows�̃A�[�L�e�N�`���[�ݒ� ------------------------------------------
:INPUT_CPU_TYPE
    Echo --- Windows�̃A�[�L�e�N�`���[�ݒ� ----------------------------------------------
    Echo 0: ��Ƃ𒆎~����
    Echo 1: 32bit��
    Echo 2: 64bit��
    Set /P IDX_CPU=Windows�̃A�[�L�e�N�`���[��1�`2�̐�������I��ŉ������B

    If /I "%IDX_CPU%" EQU "0" (GoTo :DONE)
    If /I "%IDX_CPU%" EQU "1" (Set CPU_TYP=x86&Set CPU_BIT=x32&Set WPE_TYP=x86)
    If /I "%IDX_CPU%" EQU "2" (Set CPU_TYP=x64&Set CPU_BIT=x64&Set WPE_TYP=amd64)
    If /I "%CPU_TYP%" EQU "" (GoTo :INPUT_CPU_TYPE)

Rem ���ϐ��ݒ� ---------------------------------------------------------------
    Set WPE_DIR=C:\WinPE
    Set WPE_TOP=%WPE_DIR%\%CPU_TYP%
    Set WPE_ATI=%WPE_DIR%\ati
    Set WPE_BIN=%WPE_DIR%\bin
    Set WPE_TMP=%WPE_DIR%\tmp
    Set WPE_EMP=%WPE_TOP%\empty
    Set WPE_EFI=%WPE_TOP%\fwfiles
    Set WPE_IMG=%WPE_TOP%\media
    Set WPE_MNT=%WPE_TOP%\mount
    Set WPE_WIM=%WPE_IMG%\sources\boot.wim
    Set WPE_ISO=%WPE_DIR%\WinPE_ATI2020%CPU_TYP%.iso
    Set WPE_NME=Microsoft Windows PE (%CPU_TYP%)
    Set WPE_KIT=%WinPERoot%\%WPE_TYP%
    Set Path=%WPE_BIN%;%Path%

Rem --- WinPE��ƃt�H���_�[�̍쐬 ---------------------------------------------
    Echo --- WinPE��ƃt�H���_�[�̍쐬 -------------------------------------------------
    If Exist "%WPE_TOP%" (
        TakeOwn /F "%WPE_TOP%\*.*" /A /R /D Y > NUL 2>&1 || GoTo :DONE
        ICacls "%WPE_TOP%" /reset /T /Q                  || GoTo :DONE
        RmDir /S /Q "%WPE_TOP%"                          || GoTo :DONE
    )
    %ComSpec% /C CopyPE %WPE_TYP% "%WPE_TOP%"                                           || GoTo :DONE
    Copy /B /Y "%USERPROFILE%\Desktop\AcronisBootablePEMedia %CPU_TYP%.wim" "%WPE_WIM%" || GoTo :DONE

Rem --- �w��h���C�u�ɃC���[�W��W�J ------------------------------------------
    Echo --- �w��h���C�u�ɃC���[�W��W�J ----------------------------------------------
    If Not Exist "%WPE_MNT%" (MkDir "%WPE_MNT%")
    Dism /Apply-Image /ImageFile:"%WPE_WIM%" /Index:1 /ApplyDir:"%WPE_MNT%"  || GoTo :DONE

Rem --- �t�H���g�FTrueType �R���N�V���� (TTC) �t�@�C���Ƃ��ăp�b�P�[�W�����ꂽ 2 �̓��{��t�H���g �t�@�~�� ----------
    Echo --- ���{�ꌾ��p�b�N�Ɠ��{��t�H���g ------------------------------------------
    Dism /Image:"%WPE_MNT%" /Add-package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-FontSupport-JA-JP.cab"           || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Add-package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\lp.cab"                          || GoTo :DONE

Rem --- �X�N���v�g�FWindows Management Instrumentation (WMI) �v���o�C�_�[�̃T�u�Z�b�g ---------------------------------
    Echo --- WMI�FWindows Management Instrumentation (WinPE-WMI) -----------------------
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-WMI.cab"                         || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-WMI_ja-jp.cab"             || GoTo :DONE

Rem --- �X�N���v�g�F�o�b�` �t�@�C�������Ȃǂ̃V�X�e���Ǘ��^�X�N������������̂ɍœK�ȑ�����X�N���v�g�� -------------
Rem Echo --- WSH�FWindows Scripting Host (WinPE-Scripting) -----------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-Scripting.cab"                   || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-Scripting_ja-jp.cab"       || GoTo :DONE

Rem --- HTML�FHTML �A�v���P�[�V���� (HTA) �̃T�|�[�g��� ------------------------------------------------------------
Rem Echo --- HTML �A�v���P�[�V�����T�|�[�g (WinPE-HTA) ---------------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-HTA.cab"                         || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-HTA_ja-jp.cab"             || GoTo :DONE

Rem --- �t�@�C���Ǘ��FWindows PE File Management API (FMAPI) �ւ̃A�N�Z�X��� ---------------------------------------
Rem Echo --- �폜���ꂽ�t�@�C�������o���A�񕜂��鑀����T�|�[�g����API (WinPE-FMAPI) ---
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-FMAPI.cab"                       || GoTo :DONE

Rem --- Microsoft .NET�F�N���C�A���g �A�v���P�[�V���������ɍ��ꂽ�A.NET Framework 4.5 �̃T�u�Z�b�g ------------------
Rem Echo --- �@�\����ł�.net Framework 4.5 (WinPE-NetFX) ------------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-NetFx.cab"                       || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-NetFx_ja-jp.cab"           || GoTo :DONE

Rem --- �l�b�g���[�N�FRemote Network Driver Interface Specification (�����[�g NDIS) �̃T�|�[�g ------------------------
Rem Echo --- 802.1X���܂ޗL���l�b�g���[�N�̃T�|�[�g (WinPE-RNDIS) ----------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-RNDIS.cab"                       || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-RNDIS_ja-jp.cab"           || GoTo :DONE

Rem --- �l�b�g���[�N�F�L���l�b�g���[�N�ł� IEEE 802.X �F�؃v���g�R���̃T�|�[�g ----------------------------------------
Rem Echo --- 802.1X���܂ޗL���l�b�g���[�N�̃T�|�[�g (WinPE-Dot3Svc) --------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-Dot3Svc.cab"                     || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-Dot3Svc_ja-jp.cab"         || GoTo :DONE

Rem --- �l�b�g���[�N�F�C���[�W �L���v�`�� �c�[���ƁA�J�X�^���� Windows �W�J�T�[�r�X �N���C�A���g ----------------------
Rem Echo --- �C���[�W�L���v�`���c�[���ƓW�J�T�[�r�X�N���C�A���g (WinPE-WDS-Tools) ------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-WDS-Tools.cab"                   || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-WDS-Tools_ja-jp.cab"       || GoTo :DONE

Rem --- Windows PowerShell�FWMI ���g���ăn�[�h�E�F�A���Ɖ��v���Z�X���ȑf������ Windows PowerShell �x�[�X�̐f�f ----
Rem Echo --- �@�\����ł�Windows PowerShell (WinPE-PowerShell) -------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-PowerShell.cab"                  || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-PowerShell_ja-jp.cab"      || GoTo :DONE

Rem --- Windows PowerShell�FWindows �C���[�W�̊Ǘ����s���R�}���h���b�g���܂� DISM PowerShell ���W���[�� ---------------
Rem Echo --- DISM �R�}���h���[�e�B���e�B (WinPE-DismCmdlets) ---------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-DismCmdlets.cab"                 || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-DismCmdlets_ja-jp.cab"     || GoTo :DONE

Rem --- Windows PowerShell�F�Z�L���A �u�[�g�p�� UEFI ���ϐ����Ǘ����邽�߂� PowerShell �R�}���h���b�g ---------------
Rem Echo --- �Z�L���A�u�[�g���ł̊��ϐ��Ǘ��pPowerShell�R�}���h���[�e�B���e�B (WinPE-SecureBootCmdlets) ---
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-SecureBootCmdlets.cab"           || GoTo :DONE

Rem --- Windows PowerShell�F�L����̊Ǘ��̂��߂� PowerShell �R�}���h���b�g --------------------------------------------
Rem Echo --- iSCSI�Ȃǂ̋L����Ǘ��p PowerShell�R�}���h���[�e�B���e�B (WinPE-StorageWMI) ---
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-StorageWMI.cab"                  || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-StorageWMI_ja-jp.cab"      || GoTo :DONE

Rem --- �X�^�[�g�A�b�v�FBitLocker �ƃg���X�e�b�h �v���b�g�t�H�[�� ���W���[�� (TPM) �̃v���r�W���j���O�ƊǗ� -----------
Rem Echo --- BitLocker��TPM�̃T�|�[�g (WinPE-SecureStartup) ----------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-SecureStartup.cab"               || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-SecureStartup_ja-jp.cab"   || GoTo :DONE

Rem --- �L����F�L�����u�̒ǉ��@�\��ATrusted Computing Group �� IEEE 1667 �̎d�l��g�ݍ��킹������ -------------------
Rem Echo --- �Í����h���C�u�Ȃǂ̃T�|�[�g (WinPE-EnhancedStorage) ----------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-EnhancedStorage.cab"             || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-EnhancedStorage_ja-jp.cab" || GoTo :DONE

Rem --- SMBv1�̗L���� ---------------------------------------------------------
    Echo --- SMBv1�̗L���� -------------------------------------------------------------
    Dism /Image:"%WPE_MNT%" /Enable-Feature /All /FeatureName:SMB1Protocol                                        || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Enable-Feature /All /FeatureName:SMB1Protocol-Client                                 || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Enable-Feature /All /FeatureName:SMB1Protocol-Server                                 || GoTo :DONE

Rem --- Windows PE�̓��{�ꉻ --------------------------------------------------
    Echo --- Windows PE�̓��{�ꉻ ------------------------------------------------------
    Dism /Image:"%WPE_MNT%" /Set-AllIntl:ja-jp                                                                    || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Set-InputLocale:0411:00000411                                                        || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Set-LayeredDriver:6                                                                  || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Set-TimeZone:"Tokyo Standard Time"                                                   || GoTo :DONE

Rem --- �h���C�o�[�̒ǉ� ------------------------------------------------------
Rem Echo --- �h���C�o�[�̒ǉ� ----------------------------------------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\audio\Vista\vmaudio.inf"                         || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\efifw\Win8\efifw.inf"                            || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\hgfs\Vista\vmhgfs.inf"                           || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\hgfs\Win8\vmhgfs.inf"                            || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\memctl\Vista\vmmemctl.inf"                       || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\memctl\Win8\vmmemctl.inf"                        || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\mouse\Vista\vmmouse.inf"                         || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\mouse\Vista\vmusbmouse.inf"                      || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\mouse\Win8\vmmouse.inf"                          || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\mouse\Win8\vmusbmouse.inf"                       || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\pvscsi\Vista\pvscsi.inf"                         || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\pvscsi\Win8\pvscsi.inf"                          || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\rawdsk\Vista\vmrawdsk.inf"                       || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\rawdsk\Win8\vmrawdsk.inf"                        || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vFileFilter\Vista\vsepflt.inf"                   || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vFileFilter\Win8\vsepflt.inf"                    || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\video_wddm\Vista\vm3d.inf"                       || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\Virtual Printer\TPOG3\OEMPRINT.INF"              || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\Virtual Printer\TPOGPS\OEMPRINT.inf"             || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vmci\device\Vista\vmci.inf"                      || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vmci\device\Win8\vmci.inf"                       || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vmci\sockets\Vista\vsock.inf"                    || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vmci\sockets\Win8\vsock.inf"                     || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vmxnet\Win2K8\vmxnet.inf"                        || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vmxnet3\Vista\vmxnet3.inf"                       || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vmxnet3\Win8\vmxnet3.inf"                        || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vNetFilter\Vista\vnetflt.inf"                    || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vNetFilter\Win10\vnetWFP.inf"                    || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vNetFilter\Win7\vnetWFP.inf"                     || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vNetFilter\Win8\vnetWFP.inf"                     || GoTo :DONE

    Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\LSI\LSIMPT_SCSI_WinVista_1-28-03\lsimpt_scsi_vista_%CPU_TYP%_rel" || GoTo :DONE
    If /I "%CPU_TYP%" EQU "x86" (Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\AMD\PCNET\WinXP_SignedDriver"        || GoTo :DONE)
    If /I "%CPU_TYP%" EQU "x86" (Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\Realtek\Ethernet\WIN10\WinPE\32"     || GoTo :DONE
    ) Else                      (Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\Realtek\Ethernet\WIN10\WinPE\64"     || GoTo :DONE)

Rem --- �J�X�^�}�C�Y���� ------------------------------------------------------
    Echo --- �J�X�^�}�C�Y���� ----------------------------------------------------------
    Xcopy /Y    "%WPE_ATI%\_for ATIH\*.*" "%WPE_MNT%\windows\system32\" || GoTo :Done

Rem --- ��t�H���_�[�̍쐬 ----------------------------------------------------
    Echo --- ��t�H���_�[�̍쐬 --------------------------------------------------------
    If Exist "%WPE_EMP%" (RmDir /S /Q "%WPE_EMP%")
    MkDir "%WPE_EMP%"

Rem --- boot.wim�̍쐬 --------------------------------------------------------
    Echo --- boot.wim�̍쐬 ------------------------------------------------------------
    If Exist "%WPE_WIM%" (Del /F /Q "%WPE_WIM%")
    Dism /Capture-Image /ImageFile:"%WPE_WIM%" /CaptureDir:"%WPE_EMP%" /Name:"EmptyIndex" /Compress:Max || GoTo :DONE
    Dism /Capture-Image /ImageFile:"%WPE_WIM%" /CaptureDir:"%WPE_MNT%" /Name:"%WPE_NME%" /Description:"%WPE_NME%" /Compress:Max /Bootable || GoTo :DONE
    Dism /Get-WimInfo /WimFile:"%WPE_WIM%" /Index:1 || GoTo :DONE

Rem --- DVD�C���[�W�̍쐬 -----------------------------------------------------
    Echo --- DVD�C���[�W�̍쐬 ---------------------------------------------------------
    Oscdimg -m -o -u2 -udfver102 -bootdata:2#p0,e,b"%WPE_EFI%\etfsboot.com"#pEF,e,b"%WPE_EFI%\efisys.bin" "%WPE_IMG%" "%WPE_ISO%" || GoTo :DONE

Rem --- WinPE��ƃt�H���_�[�̍폜 ---------------------------------------------
    Echo --- WinPE��ƃt�H���_�[�̍폜 -------------------------------------------------
    If Exist "%WPE_TOP%" (
        TakeOwn /F "%WPE_TOP%\*.*" /A /R /D Y > NUL 2>&1 || GoTo :DONE
        ICacls "%WPE_TOP%" /reset /T /Q                  || GoTo :DONE
        RmDir /S /Q "%WPE_TOP%"                          || GoTo :DONE
    )

Rem *** ��ƏI�� **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** ��ƏI�� ******************************************************************
    Echo [Enter]���������Ă��������B
    Pause > Nul 2>&1
    Echo On
