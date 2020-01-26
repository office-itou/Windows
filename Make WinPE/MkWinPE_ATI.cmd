Rem ****************************************************************************
    @Echo Off
    Cls

Rem 作業開始 *******************************************************************
:START
    Echo *** 作業開始 *******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

    If /I "%WinPERoot%" EQU "" (
        Echo 管理者特権:展開およびイメージング ツール環境で実行して下さい。
        GoTo :DONE
    )

    If /I "%USERNAME%" NEQ "Administrator" (
        If /I "%SESSIONNAME%" NEQ "" (
            Echo 管理者特権で実行して下さい。
            GoTo :DONE
        )
    )

    If /I "%1" EQU "COMMIT"  (
        Echo *** 作業を有効にしてアンマウントする *******************************************
        Dism /UnMount-Wim /MountDir:"%2" /Commit
        GoTo :DONE
    )

    If /I "%1" EQU "DISCARD" (
        Echo *** 作業を中止にしてアンマウントする *******************************************
        Dism /UnMount-Wim /MountDir:"%2" /Discard
        GoTo :DONE
    )

Rem --- Windowsのアーキテクチャー設定 ------------------------------------------
:INPUT_CPU_TYPE
    Echo --- Windowsのアーキテクチャー設定 ----------------------------------------------
    Echo 0: 作業を中止する
    Echo 1: 32bit版
    Echo 2: 64bit版
    Set /P IDX_CPU=Windowsのアーキテクチャーを1～2の数字から選んで下さい。

    If /I "%IDX_CPU%" EQU "0" (GoTo :DONE)
    If /I "%IDX_CPU%" EQU "1" (Set CPU_TYP=x86&Set CPU_BIT=x32&Set WPE_TYP=x86)
    If /I "%IDX_CPU%" EQU "2" (Set CPU_TYP=x64&Set CPU_BIT=x64&Set WPE_TYP=amd64)
    If /I "%CPU_TYP%" EQU "" (GoTo :INPUT_CPU_TYPE)

Rem 環境変数設定 ---------------------------------------------------------------
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

Rem --- WinPE作業フォルダーの作成 ---------------------------------------------
    Echo --- WinPE作業フォルダーの作成 -------------------------------------------------
    If Exist "%WPE_TOP%" (
        TakeOwn /F "%WPE_TOP%\*.*" /A /R /D Y > NUL 2>&1 || GoTo :DONE
        ICacls "%WPE_TOP%" /reset /T /Q                  || GoTo :DONE
        RmDir /S /Q "%WPE_TOP%"                          || GoTo :DONE
    )
    %ComSpec% /C CopyPE %WPE_TYP% "%WPE_TOP%"                                           || GoTo :DONE
    Copy /B /Y "%USERPROFILE%\Desktop\AcronisBootablePEMedia %CPU_TYP%.wim" "%WPE_WIM%" || GoTo :DONE

Rem --- 指定ドライブにイメージを展開 ------------------------------------------
    Echo --- 指定ドライブにイメージを展開 ----------------------------------------------
    If Not Exist "%WPE_MNT%" (MkDir "%WPE_MNT%")
    Dism /Apply-Image /ImageFile:"%WPE_WIM%" /Index:1 /ApplyDir:"%WPE_MNT%"  || GoTo :DONE

Rem --- フォント：TrueType コレクション (TTC) ファイルとしてパッケージ化された 2 つの日本語フォント ファミリ ----------
    Echo --- 日本語言語パックと日本語フォント ------------------------------------------
    Dism /Image:"%WPE_MNT%" /Add-package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-FontSupport-JA-JP.cab"           || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Add-package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\lp.cab"                          || GoTo :DONE

Rem --- スクリプト：Windows Management Instrumentation (WMI) プロバイダーのサブセット ---------------------------------
    Echo --- WMI：Windows Management Instrumentation (WinPE-WMI) -----------------------
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-WMI.cab"                         || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-WMI_ja-jp.cab"             || GoTo :DONE

Rem --- スクリプト：バッチ ファイル処理などのシステム管理タスクを自動化するのに最適な多言語スクリプト環境 -------------
Rem Echo --- WSH：Windows Scripting Host (WinPE-Scripting) -----------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-Scripting.cab"                   || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-Scripting_ja-jp.cab"       || GoTo :DONE

Rem --- HTML：HTML アプリケーション (HTA) のサポートを提供 ------------------------------------------------------------
Rem Echo --- HTML アプリケーションサポート (WinPE-HTA) ---------------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-HTA.cab"                         || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-HTA_ja-jp.cab"             || GoTo :DONE

Rem --- ファイル管理：Windows PE File Management API (FMAPI) へのアクセスを提供 ---------------------------------------
Rem Echo --- 削除されたファイルを検出し、回復する操作をサポートするAPI (WinPE-FMAPI) ---
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-FMAPI.cab"                       || GoTo :DONE

Rem --- Microsoft .NET：クライアント アプリケーション向けに作られた、.NET Framework 4.5 のサブセット ------------------
Rem Echo --- 機能限定版の.net Framework 4.5 (WinPE-NetFX) ------------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-NetFx.cab"                       || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-NetFx_ja-jp.cab"           || GoTo :DONE

Rem --- ネットワーク：Remote Network Driver Interface Specification (リモート NDIS) のサポート ------------------------
Rem Echo --- 802.1Xを含む有線ネットワークのサポート (WinPE-RNDIS) ----------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-RNDIS.cab"                       || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-RNDIS_ja-jp.cab"           || GoTo :DONE

Rem --- ネットワーク：有線ネットワークでの IEEE 802.X 認証プロトコルのサポート ----------------------------------------
Rem Echo --- 802.1Xを含む有線ネットワークのサポート (WinPE-Dot3Svc) --------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-Dot3Svc.cab"                     || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-Dot3Svc_ja-jp.cab"         || GoTo :DONE

Rem --- ネットワーク：イメージ キャプチャ ツールと、カスタムの Windows 展開サービス クライアント ----------------------
Rem Echo --- イメージキャプチャツールと展開サービスクライアント (WinPE-WDS-Tools) ------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-WDS-Tools.cab"                   || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-WDS-Tools_ja-jp.cab"       || GoTo :DONE

Rem --- Windows PowerShell：WMI を使ってハードウェアを照会するプロセスを簡素化する Windows PowerShell ベースの診断 ----
Rem Echo --- 機能限定版のWindows PowerShell (WinPE-PowerShell) -------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-PowerShell.cab"                  || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-PowerShell_ja-jp.cab"      || GoTo :DONE

Rem --- Windows PowerShell：Windows イメージの管理を行うコマンドレットを含む DISM PowerShell モジュール ---------------
Rem Echo --- DISM コマンドユーティリティ (WinPE-DismCmdlets) ---------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-DismCmdlets.cab"                 || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-DismCmdlets_ja-jp.cab"     || GoTo :DONE

Rem --- Windows PowerShell：セキュア ブート用の UEFI 環境変数を管理するための PowerShell コマンドレット ---------------
Rem Echo --- セキュアブート環境での環境変数管理用PowerShellコマンドユーティリティ (WinPE-SecureBootCmdlets) ---
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-SecureBootCmdlets.cab"           || GoTo :DONE

Rem --- Windows PowerShell：記憶域の管理のための PowerShell コマンドレット --------------------------------------------
Rem Echo --- iSCSIなどの記憶域管理用 PowerShellコマンドユーティリティ (WinPE-StorageWMI) ---
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-StorageWMI.cab"                  || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-StorageWMI_ja-jp.cab"      || GoTo :DONE

Rem --- スタートアップ：BitLocker とトラステッド プラットフォーム モジュール (TPM) のプロビジョニングと管理 -----------
Rem Echo --- BitLockerとTPMのサポート (WinPE-SecureStartup) ----------------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-SecureStartup.cab"               || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-SecureStartup_ja-jp.cab"   || GoTo :DONE

Rem --- 記憶域：記憶装置の追加機能や、Trusted Computing Group と IEEE 1667 の仕様を組み合わせた実装 -------------------
Rem Echo --- 暗号化ドライブなどのサポート (WinPE-EnhancedStorage) ----------------------
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\WinPE-EnhancedStorage.cab"             || GoTo :DONE
Rem Dism /Image:"%WPE_MNT%" /Add-Package /PackagePath:"%WPE_KIT%\WinPE_OCs\ja-jp\WinPE-EnhancedStorage_ja-jp.cab" || GoTo :DONE

Rem --- SMBv1の有効化 ---------------------------------------------------------
    Echo --- SMBv1の有効化 -------------------------------------------------------------
    Dism /Image:"%WPE_MNT%" /Enable-Feature /All /FeatureName:SMB1Protocol                                        || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Enable-Feature /All /FeatureName:SMB1Protocol-Client                                 || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Enable-Feature /All /FeatureName:SMB1Protocol-Server                                 || GoTo :DONE

Rem --- Windows PEの日本語化 --------------------------------------------------
    Echo --- Windows PEの日本語化 ------------------------------------------------------
    Dism /Image:"%WPE_MNT%" /Set-AllIntl:ja-jp                                                                    || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Set-InputLocale:0411:00000411                                                        || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Set-LayeredDriver:6                                                                  || GoTo :DONE
    Dism /Image:"%WPE_MNT%" /Set-TimeZone:"Tokyo Standard Time"                                                   || GoTo :DONE

Rem --- ドライバーの追加 ------------------------------------------------------
Rem Echo --- ドライバーの追加 ----------------------------------------------------------
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

Rem --- カスタマイズ処理 ------------------------------------------------------
    Echo --- カスタマイズ処理 ----------------------------------------------------------
    Xcopy /Y    "%WPE_ATI%\_for ATIH\*.*" "%WPE_MNT%\windows\system32\" || GoTo :Done

Rem --- 空フォルダーの作成 ----------------------------------------------------
    Echo --- 空フォルダーの作成 --------------------------------------------------------
    If Exist "%WPE_EMP%" (RmDir /S /Q "%WPE_EMP%")
    MkDir "%WPE_EMP%"

Rem --- boot.wimの作成 --------------------------------------------------------
    Echo --- boot.wimの作成 ------------------------------------------------------------
    If Exist "%WPE_WIM%" (Del /F /Q "%WPE_WIM%")
    Dism /Capture-Image /ImageFile:"%WPE_WIM%" /CaptureDir:"%WPE_EMP%" /Name:"EmptyIndex" /Compress:Max || GoTo :DONE
    Dism /Capture-Image /ImageFile:"%WPE_WIM%" /CaptureDir:"%WPE_MNT%" /Name:"%WPE_NME%" /Description:"%WPE_NME%" /Compress:Max /Bootable || GoTo :DONE
    Dism /Get-WimInfo /WimFile:"%WPE_WIM%" /Index:1 || GoTo :DONE

Rem --- DVDイメージの作成 -----------------------------------------------------
    Echo --- DVDイメージの作成 ---------------------------------------------------------
    Oscdimg -m -o -u2 -udfver102 -bootdata:2#p0,e,b"%WPE_EFI%\etfsboot.com"#pEF,e,b"%WPE_EFI%\efisys.bin" "%WPE_IMG%" "%WPE_ISO%" || GoTo :DONE

Rem --- WinPE作業フォルダーの削除 ---------------------------------------------
    Echo --- WinPE作業フォルダーの削除 -------------------------------------------------
    If Exist "%WPE_TOP%" (
        TakeOwn /F "%WPE_TOP%\*.*" /A /R /D Y > NUL 2>&1 || GoTo :DONE
        ICacls "%WPE_TOP%" /reset /T /Q                  || GoTo :DONE
        RmDir /S /Q "%WPE_TOP%"                          || GoTo :DONE
    )

Rem *** 作業終了 **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** 作業終了 ******************************************************************
    Echo [Enter]を押下してください。
    Pause > Nul 2>&1
    Echo On
