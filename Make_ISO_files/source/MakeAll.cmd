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

Rem *** ��ƏI�� **************************************************************
:DONE
    CD "!CUR_DIR!"
Rem EndLocal
    Echo *** ��ƏI�� ******************************************************************
    Echo %DATE% %TIME%
    Echo [Enter]���������ĉ������B
    Pause > Nul 2>&1
    Echo On
