@echo off
    if /i "%1" == ""   goto PWOFF
    if /i "%1" == "-R" goto REBOOT
    if /i "%1" == "/R" goto REBOOT
    if /i "%1" == "-S" goto PWOFF
    if /i "%1" == "/S" goto PWOFF
    if /i "%1" == "-C" goto NOEXIT
    if /i "%1" == "/C" goto NOEXIT

:HELP
    echo ati -r/-c
    echo -r: True Image�I����ɍċN�����܂��B
    echo -c: True Image�I����ɃR�}���h�v�����v�g�֖߂�܂� �B
    echo �f�t�H���g��True Image�I����ɃV���b�g�_�E�����܂��B
    goto DONE

:REBOOT
    "X:\Program Files\Acronis\TrueImageHome\trueimage.exe"
    wpeutil reboot
    goto DONE

:PWOFF
    "X:\Program Files\Acronis\TrueImageHome\trueimage.exe"
    wpeutil shutdown
    goto DONE

:NOEXIT
    "X:\Program Files\Acronis\TrueImageHome\trueimage.exe"
    goto DONE

:DONE
