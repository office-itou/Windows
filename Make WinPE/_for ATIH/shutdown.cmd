@echo off
    if /i "%1" == "-R" goto REBOOT
    if /i "%1" == "/R" goto REBOOT
    if /i "%1" == "-S" goto PWOFF
    if /i "%1" == "/S" goto PWOFF

:USAGE
    echo �d���Ǘ��R�}���h
    echo �g����: shutdown -r/-s
    echo -r: �R���s���[�^���ċN�������܂��B
    echo -s: �R���s���[�^�̓d����؂�܂��B
    goto DONE

:REBOOT
    wpeutil reboot
    goto DONE

:PWOFF
    wpeutil shutdown
    goto DONE

:DONE
