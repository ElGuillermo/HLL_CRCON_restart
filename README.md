# HLL_CRCON_restart
Stand alone tool to restart an Hell Let Loose (HLL) CRCON (see : https://github.com/MarechJ/hll_rcon_tool) install.

What it does :  
- `(optional)` rebuild CRCON  
- stop CRCON  
- `(optional)` delete logs  
- restart CRCON  
- `(optional)` delete obsoleted Docker containers and images  
- report disk usage of various CRCON components

> [!NOTE]
> The shell commands given below assume your CRCON is installed in `/root/hll_rcon_tool`  
> You may have installed CRCON in a different folder  
>   
> ie : some Ubuntu Linux distributions disable the `root` user and folder by default  
> In these, your default user is `ubuntu`, using the `/home/ubuntu` folder  
> You should then find your CRCON in `/home/ubuntu/hll_rcon_tool`  
>   
> If so, you'll have to adapt the commands below accordingly

## Install
- Log into your CRCON host machine using SSH and enter these commands (one line at at time) :
```shell
cd /root/hll_rcon_tool
wget https://raw.githubusercontent.com/ElGuillermo/HLL_RCON_restart/refs/heads/main/restart.sh
```

## Config
- Edit `restart.sh` and set parameters to fit your needs in the "configuration" part

## Use
- Log into your CRCON host machine using SSH and enter these commands (one line at at time) :
```shell
cd /root/hll_rcon_tool
sudo sh ./restart.sh
```
