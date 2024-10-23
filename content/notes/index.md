---
layout: page
---

<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [nixos](#nixos)
   * [network bridges](#network-bridges)
- [hardware](#hardware)
   * [RP 2040](#rp-2040)
      + [List of useful firmware](#list-of-useful-firmware)

<!-- TOC end -->

<!-- TOC --><a name="nixos"></a>
## nixos

<!-- TOC --><a name="network-bridges"></a>
### Network bridges

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


<!-- TOC --><a name="hardware"></a>
## hardware

<!-- TOC --><a name="rp-2040"></a>
### RP 2040

<!-- TOC --><a name="list-of-useful-firmware"></a>
#### List of useful firmware

- [DragonProbe](https://git.lain.faith/sys64738/DragonProbe)
> Adding Bus Pirate/..-style debugging & probing features to regular MCU boards such as the Raspberry Pi Pico

- [xvc-pico](https://github.com/kholia/xvc-pico)
> Raspberry Pico powered Xilinx Virtual Cable - Xilinx JTAG Cable! This is now quite fast, thanks to tom01h! We also support JTAG + serial terminal over a single cable now

- [pico-tpmsniffer](https://github.com/stacksmashing/pico-tpmsniffer)
> A simple, very experimental TPM sniffer for LPC bus
