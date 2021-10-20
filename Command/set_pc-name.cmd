Rem ****************************************************************************
    @Echo Off
    Cls

Rem ��ƊJ�n *******************************************************************
:START
    Echo *** ��ƊJ�n *******************************************************************
    Echo %DATE% %TIME%

    SetLocal EnableDelayedExpansion

Rem �R���s���[�^�[���ύX ------------------------------------------------------
    Set N=0
    For /f "Usebackq Tokens=*" %%I In (`Wmic BIOS Get SerialNumber`) Do (
        Set GET_TEXT[!N!]=%%I
        Set /A N=N+1
    )

    Set GET_UUID=%GET_TEXT[1]%
:Loop_UUID
    If /I "%GET_UUID:~-1%"==" " (
        Set GET_UUID=%GET_UUID:~0,-1%
        Goto Loop_UUID
    )

    Set SET_NAME=
           If /I "%GET_UUID%"=="VMware-xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx" (Set SET_NAME=VM-PC01
    ) Else If /I "%GET_UUID%"=="VMware-xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx" (Set SET_NAME=VM-PC02
    ) Else If /I "%GET_UUID%"=="VMware-xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx" (Set SET_NAME=VM-PC03
    ) Else If /I "%GET_UUID%"=="VMware-xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx" (Set SET_NAME=VM-PC04
    ) Else If /I "%GET_UUID%"=="VMware-xx xx xx xx xx xx xx xx-xx xx xx xx xx xx xx xx" (Set SET_NAME=VM-PC05
    ) Else                                                                              (Set /P SET_NAME=�ύX����R���s���[�^�[������͂��ĉ������B
    )

    If Not "%SET_NAME%"=="" (
        Echo "%ComputerName%" �� "%SET_NAME%" �ɕύX���܂��B
        Echo [Enter]���������Ă��������B
        Pause > Nul 2>&1
        Wmic ComputerSystem Where Name="%ComputerName%" Call Rename Name="%SET_NAME%"
    )

Rem �d���Ǘ��ύX --------------------------------------------------------------
    Set N=0
    For /f "Usebackq Tokens=*" %%I In (`Wmic BIOS Get Manufacturer`) Do (
        Set GET_TEXT[!N!]=%%I
        Set /A N=N+1
    )

    Set GET_MANUFACTURER=%GET_TEXT[1]%
:Loop_MANUFACTURER
    If /I "%GET_MANUFACTURER:~-1%"==" " (
        Set GET_MANUFACTURER=%GET_MANUFACTURER:~0,-1%
        Goto Loop_MANUFACTURER
    )

    If "%GET_MANUFACTURER%"=="VMware, Inc." (
        Echo "�d���Ǘ���ύX���܂��B
        Echo [Enter]���������Ă��������B
        Pause > Nul 2>&1
        PowerCfg /Change Monitor-Timeout-AC 0
        PowerCfg /Change Standby-Timeout-AC 0
    )

Rem *** ��ƏI�� **************************************************************
:DONE
    EndLocal
    Echo %DATE% %TIME%
    Echo *** ��ƏI�� ******************************************************************
    Echo [Enter]���������Ă��������B
    Pause > Nul 2>&1
    Echo On
