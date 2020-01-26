@echo off
    if /i "%1" == ""   goto STATUS
    if /i "%1" == "-R" goto RESET
    if /i "%1" == "/R" goto RESET
    if /i "%1" == "-S" goto CHANGE
    if /i "%1" == "/S" goto CHANGE

:HELP
    echo set_prefixpolicy -r/-s
    echo -r: IPv4/IPv6の優先順位を初期化します。
    echo -s: IPv4/IPv6の優先順位の変更をします。
    echo デフォルトはIPv4/IPv6の優先順位の表示をします。
    goto DONE

:STATUS
    netsh interface ipv6 show prefixpolicies
    goto DONE

:RESET
    netsh interface ipv6 reset
    goto DONE

:CHANGE
    netsh interface ipv6 set prefixpolicy ::1/128        50  0
    netsh interface ipv6 set prefixpolicy ::/0           40  1
    netsh interface ipv6 set prefixpolicy ::ffff:0:0/96  35  4
    netsh interface ipv6 set prefixpolicy 2002::/16      30  2
    netsh interface ipv6 set prefixpolicy 2001::/32       5  5
    netsh interface ipv6 set prefixpolicy fc00::/7        3 13
    netsh interface ipv6 set prefixpolicy fec0::/10       1 11
    netsh interface ipv6 set prefixpolicy 3ffe::/16       1 12
    netsh interface ipv6 set prefixpolicy ::/96         100  3
    goto DONE

:DONE
