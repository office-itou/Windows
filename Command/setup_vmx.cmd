Rem ****************************************************************************
    @Echo Off
    Cls

Rem ��ƊJ�n *******************************************************************
:START
    Echo *** ��ƊJ�n *******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

    Set /P DRV_VMX=�ϊ�����VMX�t�@�C���̃t�H���_�[������͂��ĉ������B

    For /R "%DRV_VMX%" %%F In ("*.vmx") Do (
        If /I "%%~xF" EQU ".vmx" (
            If Not Exist "%%F.orig" (
                Set PRM_OS=
                Set PRM_NAME=
                Set PRM_NIC=
                Set PRM_USB=
                Set PRM_SVGA=
                Echo "%%F" ��ϊ����܂��B
                Ren "%%F" "%%~nxF.orig"
                For /F "Usebackq Tokens=1* Delims==" %%I In ("%%F.orig") Do (
                    If /I "%%I" EQU "guestOS " (
                        Set PRM_OS=%%J
                        If /I "!PRM_OS:~2,7!" EQU "windows" (
                            Echo>>"%%F" %%I=%%J
                        ) Else (
                            Echo>>"%%F" %%I=%%J
                            Echo>>"%%F" svga.minVRAMSize = 8388608                                  # SVGA�̍Œ�VRAM�ݒ�l^(���𑜓x�ɂȂ�Ȃ����ɐݒ�^)
                            Echo>>"%%F" svga.minVRAM8MB = TRUE
Rem                         Echo>>"%%F" monitor.phys_bits_used = "43"
Rem                         Echo>>"%%F" vmotion.checkpointFBSize = "8388608"
Rem                         Echo>>"%%F" vmotion.checkpointSVGAPrimarySize = "33554432"
                        )
                    ) Else If /I "%%I" EQU "tools.syncTime " (
                        Echo>>"%%F" tools.syncTime = "TRUE"                                     # ���������̗L����
                    ) Else If /I "%%I" EQU "mem.hotadd " (
                        Echo>>"%%F" mem.hotadd = "FALSE"                                        # ������ hot-add �@�\�̖�����
                    ) Else If /I "%%I" EQU "ethernet0.virtualDev " (
                        Set PRM_NIC=%%J
                        If /I "!PRM_NIC:~2,-1!" EQU "e1000" (
                            If /I "!PRM_OS:~2,7!" EQU "windows" (
                                Echo>>"%%F" %%I=%%J
                            ) Else (
                                Echo>>"%%F" ethernet0.virtualDev = "vmxnet3"                            # �G�~�����[�g�E�h���C�o�[
                            )
                        ) Else (
                            Echo>>"%%F" %%I=%%J
                        )
                    ) Else If /I "%%I" EQU "displayName " (
                        Set PRM_NAME=%%J
                        Echo>>"%%F" %%I=%%J
                               If /I "!PRM_NAME:~2,-1!" EQU "VM-PC01"       (Set SET_UUID=xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx
                        ) Else If /I "!PRM_NAME:~2,-1!" EQU "VM-PC02"       (Set SET_UUID=xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx
                        ) Else If /I "!PRM_NAME:~2,-1!" EQU "VM-PC03"       (Set SET_UUID=xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx
                        ) Else If /I "!PRM_NAME:~2,-1!" EQU "VM-PC04"       (Set SET_UUID=xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx
                        ) Else If /I "!PRM_NAME:~2,-1!" EQU "VM-PC05"       (Set SET_UUID=xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx
                        ) Else                                              (Set SET_UUID=
                        )
                    ) Else If /I "%%I" EQU "usb_xhci.present " (
                        Set PRM_USB=%%J
                    ) Else If /I "%%I" EQU "mks.enable3d " (
                        Set PRM_SVGA=%%J
                    ) Else If /I "%%I" EQU "serial0.present " (
                        Echo>>"%%F" # %%I=%%J
                    ) Else (
                        Echo>>"%%F" %%I=%%J
                    )
                )
                Echo>>"%%F" bios.bootDelay = "5000"                                     # BIOS�̃L�[�󂯕t��^(�\������^)�𒷂�����^(ms�P�ʂŎw��^)
                Echo>>"%%F" logging = "false"                                           # ���O�L�^���I�t�ɂ���
                Echo>>"%%F" mainMem.useNamedFile = "FALSE"                              # �Q�X�g�̃������̓t�@�C���ł͂Ȃ������������g��
                Echo>>"%%F" MemAllowAutoScaleDown = "FALSE"                             # ���z�}�V���̃������T�C�Y���������߂��Ȃ��悤�ɂ���
                Echo>>"%%F" MemTrimRate = "0"                                           # ���g�p�̕�����������������Ȃ��悤�ɂ���
                Echo>>"%%F" pciSound.enableVolumeControl = "FALSE"                      # �z�X�g�ƃQ�X�g�ŉ��ʂ�A�������Ȃ�
                Echo>>"%%F" prefvmx.useRecommendedLockedMemSize = "TRUE"                # �������g�p�ʂ��ω��������̃������T�C�Y���Œ艻
                Echo>>"%%F" sched.mem.pshare.enable = "FALSE"                           # �y�[�W���L�@�\�̖�����
                Echo>>"%%F" usb.generic.keepStreamsEnabled = "FALSE"                    # USB 3.0 �}�X �X�g���[�W �f�o�C�X�̋����ݒ�^(UAS �f�o�C�X�̕s����^)
                Echo>>"%%F" devices.hotplug = "FALSE"                                   # HotAdd/HotPlug �@�\�̖�����
                Echo>>"%%F" sound.bufferTime = "400"                                    # �T�E���h�J�[�h�̃o�b�N�O���E���h�m�C�Y�΍�
                Echo>>"%%F" firmware = "efi"
                Echo>>"%%F" managedvm.autoAddVTPM = "software"
                If /I "!PRM_USB!" EQU "" (
                    Echo>>"%%F" usb_xhci.present = "TRUE"
                )
                If /I "!PRM_SVGA!" EQU "" (
                    Echo>>"%%F" svga.graphicsMemoryKB = "786432"
                    Echo>>"%%F" svga.guestBackedPrimaryAware = "TRUE"
                    Echo>>"%%F" mks.enable3d = "TRUE"
                )
                Echo>>"%%F" mks.keyboardFilter = "allow"
                Echo>>"%%F" isolation.tools.hgfs.disable = "FALSE"
                Echo>>"%%F" sharedFolder0.present = "TRUE"
                Echo>>"%%F" sharedFolder0.enabled = "TRUE"
                Echo>>"%%F" sharedFolder0.readAccess = "TRUE"
                Echo>>"%%F" sharedFolder0.writeAccess = "TRUE"
                Echo>>"%%F" sharedFolder0.hostPath = "D:\share"
                Echo>>"%%F" sharedFolder0.guestName = "share"
                Echo>>"%%F" sharedFolder0.expiration = "never"
                Echo>>"%%F" sharedFolder1.present = "TRUE"
                Echo>>"%%F" sharedFolder1.enabled = "TRUE"
                Echo>>"%%F" sharedFolder1.readAccess = "TRUE"
                Echo>>"%%F" sharedFolder1.writeAccess = "TRUE"
                Echo>>"%%F" sharedFolder1.hostPath = "D:\vmware"
                Echo>>"%%F" sharedFolder1.guestName = "vmware"
                Echo>>"%%F" sharedFolder1.expiration = "never"
                Echo>>"%%F" sharedFolder2.present = "TRUE"
                Echo>>"%%F" sharedFolder2.enabled = "TRUE"
                Echo>>"%%F" sharedFolder2.readAccess = "TRUE"
                Echo>>"%%F" sharedFolder2.writeAccess = "TRUE"
                Echo>>"%%F" sharedFolder2.hostPath = "D:\workspace"
                Echo>>"%%F" sharedFolder2.guestName = "workspace"
                Echo>>"%%F" sharedFolder2.expiration = "never"
                Echo>>"%%F" sharedFolder.maxNum = "3"
                If /I "!SET_UUID!" NEQ "" (
                    Echo>>"%%F" uuid.bios = "!SET_UUID!"
                    Echo>>"%%F" uuid.location = "!SET_UUID!"
                )
            )
        )
    )

Rem *** ��ƏI�� **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** ��ƏI�� ******************************************************************
    Echo [Enter]���������Ă��������B
    Pause > Nul 2>&1
    Echo On
