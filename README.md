# HLL_CRCON_restart

## Description
Stand alone tool to restart an Hell Let Loose (HLL) CRCON (see : https://github.com/MarechJ/hll_rcon_tool) install.

What it does :  
- `(optional)` rebuild CRCON  
- stop CRCON  
- `(optional)` delete logs  
- restart CRCON  
- `(optional)` delete obsoleted Docker containers and images  
- report disk usage of various CRCON components

## Install
Download the `restart.sh` file in CRCON's folder using these commands :
```shell
cd /root/hll_rcon_tool
wget https://raw.githubusercontent.com/ElGuillermo/HLL_RCON_restart/refs/heads/main/restart.sh
```

## Config
- Edit `restart.sh` and edit the "configuration" part

## Use
- Get into CRCON's root and launch the script using these commands :
```shell
cd /root/hll_rcon_tool
sudo sh ./restart.sh
```
