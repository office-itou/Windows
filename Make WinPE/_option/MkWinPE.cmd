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

Rem --- �c�[���̏��� ----------------------------------------------------------
    Echo --- �c�[���̏��� --------------------------------------------------------------
    If Not Exist "%WPE_BIN%" (MkDir "%WPE_BIN%")
    If Not Exist "%WPE_TMP%" (MkDir "%WPE_TMP%")
    Pushd "%WPE_TMP%"
Rem ��� unzip�̓W�J �����������������������������������������������������������
        If Not Exist "%WPE_BIN%\unzip.exe" (
            Echo ��� unzip�̓W�J ���������������������������������������������������������������
            Echo> "ftp_get_unzip.txt" open ftp.info-zip.org
            Echo>>"ftp_get_unzip.txt" anonymous
            Echo>>"ftp_get_unzip.txt" anonymous@localhost
            Echo>>"ftp_get_unzip.txt" binary
            Echo>>"ftp_get_unzip.txt" get /pub/infozip/win32/unz600xn.exe
            Echo>>"ftp_get_unzip.txt" quit
            Ftp -i -s:"ftp_get_unzip.txt" || GoTo Done
            unz600xn.exe -d unz600xn
            Copy /B /Y unz600xn\unzip.exe "%WPE_BIN%" || GoTo Done
        )
    Popd

Rem --- ATI2020�̓W�J ---------------------------------------------------------
    Echo --- ATI2020�̓W�J -------------------------------------------------------------
    Set ATI_TOP=%ProgramFiles(x86)%\Acronis\TrueImageHome
    If "%ProgramFiles(x86)%" EQU "" (Set ATI_TOP=%ProgramFiles%\Acronis\TrueImageHome)
    If Not Exist "%WPE_ATI%\WinPE" (
Rem     Xcopy /Y "%ATI_TOP%\WinPE\WinPE.zip" "%WPE_ATI%\"      || GoTo Done
        UnZip -q -o "%WPE_ATI%\WinPE.zip" -d "%WPE_ATI%\WinPE" || GoTo Done
    )

Rem --- WinPE��ƃt�H���_�[�̍쐬 ---------------------------------------------
    Echo --- WinPE��ƃt�H���_�[�̍쐬 -------------------------------------------------
    If Exist "%WPE_TOP%" (
        TakeOwn /F "%WPE_TOP%\*.*" /A /R /D Y > NUL 2>&1 || GoTo :DONE
        ICacls "%WPE_TOP%" /reset /T /Q                  || GoTo :DONE
        RmDir /S /Q "%WPE_TOP%"                          || GoTo :DONE
    )
    %ComSpec% /C CopyPE %WPE_TYP% "%WPE_TOP%"                                                           || GoTo :DONE

Rem --- �w��h���C�u�ɃC���[�W��W�J ------------------------------------------
    Echo --- �w��h���C�u�ɃC���[�W��W�J ----------------------------------------------
    If Not Exist "%WPE_MNT%" (MkDir "%WPE_MNT%")
    Dism /Apply-Image /ImageFile:"%WPE_WIM%" /Index:1 /ApplyDir:"%WPE_MNT%"                             || GoTo :DONE

Rem --- WMI�FWindows Management Instrumentation (WinPE-WMI) -------------------
    Echo --- WMI�FWindows Management Instrumentation (WinPE-WMI) -----------------------
    Dism /Image:"%WPE_MNT%" /Add-package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-WMI.cab"               || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Add-package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-JP\WinPE-WMI_ja-jp.cab"   || GoTo :DONE

Rem --- ���{�ꉻ�p�p�b�P�[�W�̒ǉ� --------------------------------------------
    Echo --- ���{�ꉻ�p�p�b�P�[�W�̒ǉ� ------------------------------------------------
    Dism /Image:"%WPE_MNT%" /Add-package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-FontSupport-JA-JP.cab" || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Add-package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\lp.cab"                || GoTo :DONE

Rem --- Windows PE�̓��{�ꉻ --------------------------------------------------
    Echo --- Windows PE�̓��{�ꉻ ------------------------------------------------------
    Dism /Image:"%WPE_MNT%" /Set-AllIntl:ja-jp                  || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Set-InputLocale:0411:00000411      || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Set-LayeredDriver:6                || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Set-TimeZone:"Tokyo Standard Time" || GoTo :DONE

Rem --- SMBv1�̗L���� ---------------------------------------------------------
    Echo --- SMBv1�̗L���� ---------------------------------------------------------
    Dism /Image:"%WPE_MNT%" /Enable-Feature /FeatureName:SMB1Protocol        || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Enable-Feature /FeatureName:SMB1Protocol-Client || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Enable-Feature /FeatureName:SMB1Protocol-Server || GoTo :DONE

Rem --- �h���C�o�[�̒ǉ� ------------------------------------------------------
    Echo --- �h���C�o�[�̒ǉ� ----------------------------------------------------------
    If /I "%CPU_TYP%" EQU "x86" (Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\AMD\PCNET\WinXP_SignedDriver"        || GoTo :DONE)
    Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\VMware.%CPU_BIT%\vmxnet3\Win8"                                    || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\LSI\LSIMPT_SCSI_WinVista_1-28-03\lsimpt_scsi_vista_%CPU_TYP%_rel" || GoTo :DONE
    If /I "%CPU_TYP%" EQU "x86" (
        Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\Realtek\Ethernet\WIN10\WinPE\32" || GoTo :DONE
    ) Else (
        Dism /Image:"%WPE_MNT%" /Add-Driver /ForceUnsigned /Driver:"%WPE_ATI%\_drivers\Realtek\Ethernet\WIN10\WinPE\64" || GoTo :DONE
    )

Rem --- �J�X�^�}�C�Y���� ------------------------------------------------------
    Echo --- �J�X�^�}�C�Y���� ----------------------------------------------------------
    Xcopy /Y    "%WPE_ATI%\_for ATIH\*.*" "%WPE_MNT%\windows\system32\" || GoTo :Done

Rem ---------------------------------------------------------------------------
    If /I "%CPU_TYP%" EQU "x86" (
        Set WPE_PAK=%WPE_ATI%\WinPE\Files32
    ) Else (
        Set WPE_PAK=%WPE_ATI%\WinPE\Files64
    )
Rem ---------------------------------------------------------------------------
    Xcopy /Y    "%CommonProgramFiles(x86)%\Acronis\TrueImageMedia\gen_bootmenu.bin"     "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%CommonProgramFiles(x86)%\Acronis\TrueImageHome\kernel.dat"            "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%CommonProgramFiles(x86)%\Acronis\TrueImageHome\kernel64.dat"          "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%CommonProgramFiles(x86)%\Acronis\TrueImageHome\ramdisk_merged.dat"    "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%CommonProgramFiles(x86)%\Acronis\TrueImageHome\ramdisk_merged.sgn"    "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%CommonProgramFiles(x86)%\Acronis\TrueImageHome\ramdisk_merged64.dat"  "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%CommonProgramFiles(x86)%\Acronis\TrueImageHome\ramdisk_merged64.sgn"  "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
Rem --- common ----------------------------------------------------------------
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\7z.dll"                                          "%WPE_MNT%\Program Files\Acronis\TrueImageHome\a43\"                                                || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\A43.exe"                                         "%WPE_MNT%\Program Files\Acronis\TrueImageHome\a43\"                                                || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\A43.ini"                                         "%WPE_MNT%\Program Files\Acronis\TrueImageHome\a43\"                                                || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\TextEditorPE.exe"                                "%WPE_MNT%\Program Files\Acronis\TrueImageHome\a43\"                                                || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\auto_reactivate.bin"                             "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\auto_reactivate64.bin"                           "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\bootmenu.bin"                                    "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\bootmenu_logo.png"                               "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\bootwiz.bin"                                     "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\bootwiz32.efi"                                   "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\bootwiz64.efi"                                   "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\cpp.so"                                          "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\fox.so"                                          "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\graphapi.so"                                     "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\icu38.so"                                        "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\icudt38.so"                                      "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\libc.so"                                         "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\libgcc_s.so"                                     "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\mouse.com"                                       "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\osfiles.so"                                      "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\resource.so"                                     "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\threads.so"                                      "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_ATI%\WinPE\Files\ti_boot.so"                                      "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
Rem --- 32/64 bit -------------------------------------------------------------
    Xcopy /Y    "%WPE_PAK%\boot_assist.dll"                                             "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\expat.dll"                                                   "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\fox.dll"                                                     "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\icu38.dll"                                                   "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\icudt38.dll"                                                 "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\kb_link.dll"                                                 "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\libcrypto10.dll"                                             "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\libssl10.dll"                                                "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\logging.dll"                                                 "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\mspack.dll"                                                  "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\oem_doc_source.dll"                                          "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\resource.dll"                                                "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\rpc_client.dll"                                              "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\thread_pool.dll"                                             "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\tib_api.dll"                                                 "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\tib_mounter.dll"                                             "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\TrueImage.exe"                                               "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\trueimage_starter.exe"                                       "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\ulxmlrpcpp.dll"                                              "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\Drivers\Microsoft.VC120.CRT\msvcp120.dll"                    "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\Drivers\Microsoft.VC120.CRT\msvcr120.dll"                    "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\Drivers\Microsoft.VC120.CRT\vccorlib120.dll"                 "%WPE_MNT%\Program Files\Acronis\TrueImageHome\"                                                    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\Drivers\fltsrv.sys"                                          "%WPE_MNT%\Windows\System32\drivers\"                                                               || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\Drivers\snapman.sys"                                         "%WPE_MNT%\Windows\System32\drivers\"                                                               || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\Drivers\snapapi.dll"                                         "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
Rem Xcopy /Y    "%WPE_PAK%\IScsi\iscsi.inf"                                             "%WPE_MNT%\Windows\INF\"                                                                            || GoTo :Done
Rem Xcopy /Y    "%WPE_PAK%\IScsi\iscsi.inf"                                             "%WPE_MNT%\Windows\System32\DriverStore\FileRepository\iscsi.inf_amd64_b69452cda37f37cb\"           || GoTo :Done
Rem Xcopy /Y    "%WPE_PAK%\IScsi\iscsilog.dll"                                          "%WPE_MNT%\Windows\System32\DriverStore\FileRepository\iscsi.inf_amd64_b69452cda37f37cb\"           || GoTo :Done
Rem Xcopy /Y    "%WPE_PAK%\IScsi\msiscsi.sys"                                           "%WPE_MNT%\Windows\System32\DriverStore\FileRepository\iscsi.inf_amd64_b69452cda37f37cb\"           || GoTo :Done
Rem Xcopy /Y    "%WPE_PAK%\IScsi\iscsi.inf"                                             "%WPE_MNT%\Windows\WinSxS\amd64_iscsi.inf_31bf3856ad364e35_10.0.16299.15_none_5faff1a664cb2558\"    || GoTo :Done
Rem Xcopy /Y    "%WPE_PAK%\IScsi\iscsilog.dll"                                          "%WPE_MNT%\Windows\WinSxS\amd64_iscsi.inf_31bf3856ad364e35_10.0.16299.15_none_5faff1a664cb2558\"    || GoTo :Done
Rem Xcopy /Y    "%WPE_PAK%\IScsi\msiscsi.sys"                                           "%WPE_MNT%\Windows\WinSxS\amd64_iscsi.inf_31bf3856ad364e35_10.0.16299.15_none_5faff1a664cb2558\"    || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsicli.exe"                                          "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsicpl.cpl"                                          "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsidip.dll"                                          "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsidsc.dll"                                          "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
Rem Xcopy /Y    "%WPE_PAK%\IScsi\iscsilog.dll"                                          "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsipp.dll"                                           "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsiexe.exe"                                          "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsium.dll"                                           "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsiwmi.dll"                                          "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsixip.dll"                                          "%WPE_MNT%\Windows\System32\"                                                                       || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsiprt.sys"                                          "%WPE_MNT%\Windows\System32\drivers\"                                                               || GoTo :Done
Rem Xcopy /Y    "%WPE_PAK%\IScsi\msiscsi.sys"                                           "%WPE_MNT%\Windows\System32\drivers\"                                                               || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsi.cat"                                             "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsi.inf"                                             "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsidsc.mof"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsievt.mof"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsihba.mof"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsiprf.mof"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsiprt.sys"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\iscsirem.mof"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\mpdev.inf"                                             "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\mpdev.sys"                                             "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\mpio.cat"                                              "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\mpio.inf"                                              "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\mpio.sys"                                              "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\mpspfltr.sys"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\msiscdsm.inf"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\msiscdsm.sys"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\msiscsi.sys"                                           "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\readme.txt"                                            "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\relnotes.txt"                                          "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done
    Xcopy /Y    "%WPE_PAK%\IScsi\uguide.doc"                                            "%WPE_MNT%\Windows\iscsi\"                                                                          || GoTo :Done

    Reg Load HKLM\WPE_SOFTWARE "%WPE_MNT%\windows\system32\config\SOFTWARE" || GoTo :DONE
    Reg Load HKLM\WPE_SYSTEM   "%WPE_MNT%\windows\system32\config\SYSTEM"   || GoTo :DONE

    Reg Import "%WPE_ATI%\ATI_Software.reg" || GoTo :DONE
    Reg Import "%WPE_ATI%\ATI_System.reg"   || GoTo :DONE

    Reg UnLoad HKLM\WPE_SYSTEM   || GoTo :DONE
    Reg UnLoad HKLM\WPE_SOFTWARE || GoTo :DONE

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
