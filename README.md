<img align="left" style="vertical-align: middle" width="120" height="120" src="data/icons/com.fyralabs.Enigma.svg">

# Enigma

A simple text editor.

###

[![Please do not theme this app](https://stopthemingmy.app/badge.svg)](https://stopthemingmy.app)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

![Screenshot](data/shot.png)

## 🛠️ Dependencies

Please make sure you have these dependencies first before building.

```bash
gtk4
libgee-0.8
libhelium-1.0
meson
vala
```

## 🏗️ Building

Simply clone this repo, then:

```bash
meson _build --prefix=/usr && cd _build
sudo ninja install
```
