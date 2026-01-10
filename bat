@echo off
title RDP HARD FIX
color 0C

echo === RDP REGISTRY ENABLE ===
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowTSConnections /t REG_DWORD /d 1 /f

echo === NLA ENABLE ===
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f

echo === RDP PORT RESET (3389) ===
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 3389 /f

echo === SERVICES FIX ===
sc config TermService start= auto
sc config UmRdpService start= auto

net stop TermService /y
net start TermService

echo === FIREWALL RESET + RDP RULES ===
netsh advfirewall reset
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes

netsh advfirewall firewall add rule name="RDP TCP 3389" dir=in action=allow protocol=TCP localport=3389
netsh advfirewall firewall add rule name="RDP UDP 3389" dir=in action=allow protocol=UDP localport=3389

echo === USER PERMISSION FIX ===
net localgroup "Remote Desktop Users" /add %USERNAME%

echo === DONE ===
echo RESTART REQUIRED !!!
pause
shutdown /r /t 5
