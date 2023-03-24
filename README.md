# ZigWAF
[![License](https://img.shields.io/badge/license-MIT-red.svg)](https://github.com/bruzistico/zigwaf/blob/main/LICENSE.md) [![Version](https://img.shields.io/badge/Release-1.0-red.svg?maxAge=259200)]() [![Build](https://img.shields.io/badge/Supported_OS-Linux-yellow.svg)]()  [![Build](https://img.shields.io/badge/Supported_WSL-Windows-blue.svg)]() [![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/bruzistico/zigwaf/issues) [![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/donate/?hosted_button_id=E79FWLM24RKTW)

The purpose of this tool is to try to validate if real IPs (predefined list) resolve to the site behind the WAF.

It is worth noting that this bypass is only possible if the server does not have firewall rules applied to the WAF.

![zigwaf](https://user-images.githubusercontent.com/90929569/227417228-67d3fd8e-a107-41ff-9718-1c12e7fd484b.png)

## Usage modes
<p align="center">
<img align="center" alt="mortomuitolouco" class="center" src="https://user-images.githubusercontent.com/90929569/227417422-a8e85932-6a38-4047-b7b4-27ae5825946d.png">
</p>

```
Options:
 -d,  --domain		 Analyzing one target subdomain/domain (e.g example.com, https://example.com)
  -dL, --domain-list	 Analyzing multiple targets in a text file 
  -i,  --ip		 Parse DNS via real IP, bypass WAF (e.g 192.168.0.10)
  -iL, --ip-list	 Parse DNS via real IP, bypass WAF in a text file
  -o,  --output		 Output (eg. output.txt)
  -v,  --verbose	 Verbose
  -h,  --help		 Help [Usage]

 Basic usage:

  ./zigwaf.sh -d example.com -i 192.168.0.10
  ./zigwaf.sh -d example.com -iL listips.txt
  ./zigwaf.sh -dL domainlist.txt -i 192.168.0.10
  ./zigwaf.sh -dL domainlist.txt -iL listip.txt -v
  ./zigwaf.sh -dL domainlist.txt -iL listip.txt -v -o result.txt

 [INFO] It is mandatory to inform domain targets [-d or -dL] and IP targets [-i or -iL]

```

## Tips [target IPs]

 - Search for IP [ASN] targets related to the company that owns the domain
 - Look up associated IPs on [shodan.io](https://www.shodan.io/) or [censys.io](https://censys.io/)
 - Search SPF records and TXT records
 - Check history on [securitytrails.com](https://securitytrails.com/)


## What to do after finding the correct IPS?

You can change your local host file to force dns resolution in:

- Linux: /etc/hosts
- Windows: C:\Windows\System32\Drivers\etc\hosts 

example:

```
44.201.229.201 zigwaf.bruzistico.com
```

### Change in Burp Suite

Settings >> Network >> Connections >> Hostname resolution overrides

![Captura de tela de 2023-03-24 00-24-36](https://user-images.githubusercontent.com/90929569/227418573-c61c297a-ecae-4535-bc1e-83d0072327ec.png)

## To Do [Implementation]:

- Add port options other than the defaults 80,443 [list via command and via file]
- [CIDR] IP ranges and blocks via command line [Eg. 200.54.20.0/24, 200.54.20.10-15]
- Direct queries from ASN
- More file output options [output]


## Thanks

- [Leandro Carvalho](https://github.com/skateforever) - Skateforever
