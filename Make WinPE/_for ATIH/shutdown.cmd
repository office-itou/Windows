@echo off
    if /i "%1" == "-R" goto REBOOT
    if /i "%1" == "/R" goto REBOOT
    if /i "%1" == "-S" goto PWOFF
    if /i "%1" == "/S" goto PWOFF

:USAGE
    echo 電源管理コマンド
    echo 使い方: shutdown -r/-s
    echo -r: コンピュータを再起動させます。
    echo -s: コンピュータの電源を切ります。
    goto DONE

:REBOOT
    wpeutil reboot
    goto DONE

:PWOFF
    wpeutil shutdown
    goto DONE

:DONE
