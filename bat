@echo off
color 0C
title ULTIMATE RDP FIX - NO BS

echo ===== KILL GPO CACHE =====
rd /s /q "%windir%\System32\GroupPolicy"
rd /s /q "%windir%\System32\GroupPolicyUsers"
gpupdate /force

echo ===== ENABLE RDP REGISTRY =====
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowTSConnections /t REG_DWORD /d 1 /f

echo ===== FORCE RDP TCP SETTINGS =====
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 3389 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t REG_DWORD /d 0 /f

echo ===== FORCE SERVICES =====
sc config TermService start= auto
sc config UmRdpService start= auto
sc config SessionEnv start= auto

net stop TermService /y
net start TermService

echo ===== FULL FIREWALL NUKE + REBUILD =====
netsh advfirewall reset
netsh advfirewall set allprofiles state off

netsh advfirewall firewall add rule name="RDP TCP 3389" dir=in action=allow protocol=TCP localport=3389
netsh advfirewall firewall add rule name="RDP UDP 3389" dir=in action=allow protocol=UDP localport=3389

netsh advfirewall set allprofiles state on

echo ===== USER PERMISSION =====
net localgroup "Remote Desktop Users" /add %USERNAME%
net localgroup Administrators %USERNAME% /add

echo ===== NETWORK RESET =====
netsh int ip reset
ipconfig /flushdns

echo ===== DONE =====
echo 10 mp mulva ujrainditas...
timeout /t 10
shutdown /r /f /t 0
