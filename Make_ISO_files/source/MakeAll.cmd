Rem ***************************************************************************
@Echo Off
    Cls

Rem *** 作業開始 **************************************************************
:START
    Echo *** 作業開始 ******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableExtensions
    SetLocal EnableDelayedExpansion

Rem --- 作業環境確認 ----------------------------------------------------------
    If /I "%USERNAME%" NEQ "Administrator" (
        If /I "%SESSIONNAME%" NEQ "" (
            Echo 管理者特権で実行して下さい。
            GoTo DONE
        )
    )

Start       /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 1 1 "F:" 4 0
TimeOut /T 3
Start /Wait /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 1 2 "G:" 4 0
TimeOut /T 3
Start       /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 2 1 "H:" 1 0
TimeOut /T 3
Start /Wait /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 2 2 "I:" 1 0
TimeOut /T 3
Start       /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 3 1 "J:" 3 0
TimeOut /T 3
Start /Wait /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 3 2 "K:" 3 0
TimeOut /T 3
Start /Wait /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 1 2 "G:" 4 1
TimeOut /T 3
Start /Wait /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 1 2 "G:" 4 2
TimeOut /T 3
Start /Wait /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 3 2 "K:" 3 1
TimeOut /T 3
Start /Wait /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 3 2 "K:" 3 2
TimeOut /T 3
Start /Wait /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 3 2 "K:" 3 3
TimeOut /T 3
Start /Wait /Realtime MakeIsoFile.cmd "Make-Auto" "D:\WimWK" 3 1 "J:" 3 3

Rem *** 作業終了 **************************************************************
:DONE
    CD "!CUR_DIR!"
Rem EndLocal
    Echo *** 作業終了 ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]を押下して下さい。
    Pause > Nul 2>&1
    Echo On
