+++
date = "2019-01-13T12:48:20-07:00"
title = "Install Latest Hugo on Ubuntu/Debian"
description = "A few quick bash commands to install the latest Hugo Extended on an Ubuntu or Debian machine"
categories = "Software"
tags = ["Hugo", "System Administration"]
+++

Install the latest Hugo Extended on Ubuntu or Debain. This should work on Windows WSL.

```bash
wget $(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep -oP '"browser_download_url": "\K(.*)hugo_extended(.*)Linux-64bit.deb')
sudo dpkg -i hugo_extended*Linux-64bit.deb
```