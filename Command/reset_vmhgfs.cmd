reg delete "HKEY_LOCAL_MACHINE\ SYSTEM\CurrentControlSet\Control\NetworkProvider\Order" /v "ProviderOrder" /f
reg add    "HKEY_LOCAL_MACHINE\ SYSTEM\CurrentControlSet\Control\NetworkProvider\Order" /v "ProviderOrder" /t "REG_SZ" /d "vmhgfs,RDPNP, LanmanWorkstation,webclient" /f
pause.
