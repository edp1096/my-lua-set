```powershell
make

lua player_simple.lua
```


## Linux
* WSL - Ubuntu
```sh
sudo apt install build-essential liblua5.4-dev libasound2-dev
```
* Ubuntu/Debian
```sh
sudo apt install build-essential lua5.4-dev libasound2-dev
```
* CentOS/RHEL/Fedora
```sh
sudo yum install gcc make lua-devel alsa-lib-devel
# or
sudo dnf install gcc make lua-devel alsa-lib-devel
```
* Arch / SteamOS(>=3.x)
```sh
sudo pacman -S base-devel lua alsa-lib
```
* SUSE
```sh
sudo zypper install gcc make lua-devel alsa-devel
```
* Alpine
```sh
apk add build-base lua5.4-dev alsa-lib-dev
```
