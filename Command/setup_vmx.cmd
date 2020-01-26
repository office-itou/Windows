Rem ****************************************************************************
    @Echo Off
    Cls

Rem 作業開始 *******************************************************************
:START
    Echo *** 作業開始 *******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

    Set /P INP_DIR=変換するVMXファイルのフォルダー名を入力して下さい。
    If /I "%INP_DIR:~0,1%%INP_DIR:~-1,1%" EQU """" (
        Set DRV_VMX=%INP_DIR:~1,-1%
    ) Else (
        Set DRV_VMX=%INP_DIR%
    )

    For /R "%DRV_VMX%" %%F In ("*.vmx") Do (
        If /I "%%~xF" EQU ".vmx" (
            If Not Exist "%%F.orig" (
                Echo "%%F" を変換します。
                Ren "%%F" "%%~nxF.orig"
                For /F "Usebackq Tokens=1* Delims==" %%I In ("%%F.orig") Do (
                    If /I "%%I" EQU "guestOS " (
                        Set PRM_OS=%%J
                        If /I "!PRM_OS:~2,7!" EQU "windows" (
                            Echo>>"%%F" %%I=%%J
                        ) Else (
                            Echo>>"%%F" %%I=%%J
                            Echo>>"%%F" svga.minVRAMSize = 8388608                                  # SVGAの最低VRAM設定値^(高解像度にならない時に設定^)
                            Echo>>"%%F" svga.minVRAM8MB = TRUE
Rem                         Echo>>"%%F" monitor.phys_bits_used = "43"
Rem                         Echo>>"%%F" vmotion.checkpointFBSize = "8388608"
Rem                         Echo>>"%%F" vmotion.checkpointSVGAPrimarySize = "33554432"
                        )
                    ) Else If /I "%%I" EQU "tools.syncTime " (
                        Echo>>"%%F" tools.syncTime = "TRUE"                                     # 時刻同期の有効化
                    ) Else If /I "%%I" EQU "mem.hotadd " (
                        Echo>>"%%F" mem.hotadd = "FALSE"                                        # メモリ hot-add 機能の無効化
                    ) Else If /I "%%I" EQU "ethernet0.virtualDev " (
                        Set PRM_NIC=%%J
                        If /I "!PRM_NIC:~2,-1!" EQU "e1000" (
                            If /I "!PRM_OS:~2,7!" EQU "windows" (
                                Echo>>"%%F" %%I=%%J
                            ) Else (
                                Echo>>"%%F" ethernet0.virtualDev = "vmxnet3"                            # エミュレート・ドライバー
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
                    ) Else (
                        Echo>>"%%F" %%I=%%J
                    )
                )
                Echo>>"%%F" bios.bootDelay = "5000"                                     # BIOSのキー受け付け^(表示時間^)を長くする^(ms単位で指定^)
                Echo>>"%%F" logging = "false"                                           # ログ記録をオフにする
                Echo>>"%%F" mainMem.useNamedFile = "FALSE"                              # ゲストのメモリはファイルではなく実メモリを使う
                Echo>>"%%F" MemAllowAutoScaleDown = "FALSE"                             # 仮想マシンのメモリサイズを自動調節しないようにする
                Echo>>"%%F" MemTrimRate = "0"                                           # 未使用の物理メモリを解放しないようにする
                Echo>>"%%F" pciSound.enableVolumeControl = "FALSE"                      # ホストとゲストで音量を連動させない
                Echo>>"%%F" prefvmx.useRecommendedLockedMemSize = "TRUE"                # メモリ使用量が変化した時のメモリサイズを固定化
                Echo>>"%%F" sched.mem.pshare.enable = "FALSE"                           # ページ共有機能の無効化
                Echo>>"%%F" usb.generic.keepStreamsEnabled = "FALSE"                    # USB 3.0 マス ストレージ デバイスの強制設定^(UAS デバイスの不具合回避^)
                Echo>>"%%F" devices.hotplug = "FALSE"                                   # HotAdd/HotPlug 機能の無効化
                Echo>>"%%F" mks.keyboardFilter = "allow"
                Echo>>"%%F" isolation.tools.hgfs.disable = "FALSE"
                Echo>>"%%F" sharedFolder0.present = "TRUE"
                Echo>>"%%F" sharedFolder0.enabled = "TRUE"
                Echo>>"%%F" sharedFolder0.readAccess = "TRUE"
                Echo>>"%%F" sharedFolder0.writeAccess = "TRUE"
                Echo>>"%%F" sharedFolder0.hostPath = "D:\Share"
                Echo>>"%%F" sharedFolder0.guestName = "Share"
                Echo>>"%%F" sharedFolder0.expiration = "never"
                Echo>>"%%F" sharedFolder1.present = "TRUE"
                Echo>>"%%F" sharedFolder1.enabled = "TRUE"
                Echo>>"%%F" sharedFolder1.readAccess = "TRUE"
                Echo>>"%%F" sharedFolder1.writeAccess = "TRUE"
                Echo>>"%%F" sharedFolder1.hostPath = "D:\VMware"
                Echo>>"%%F" sharedFolder1.guestName = "VMware"
                Echo>>"%%F" sharedFolder1.expiration = "never"
                Echo>>"%%F" sharedFolder.maxNum = "2"
                If /I "!SET_UUID!" NEQ "" (
                    Echo>>"%%F" uuid.bios = "!SET_UUID!"
                    Echo>>"%%F" uuid.location = "!SET_UUID!"
                )
            )
        )
    )

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** 作業終了 ******************************************************************
    Echo [Enter]を押下してください。
    Pause > Nul 2>&1
    Echo On
