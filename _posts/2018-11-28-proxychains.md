---
layout: post
title:  "终端走代理"
date:   2018-11-28 
author: co0ontty
cover: '/assets/img/posts/proxychains-1.png'
categories: 运维 ALL
tags: 运维 ALL
describe: 通过 proxychains 实现终端的代理使用
---
## 何来此操作
在 linux 小飞机没有办法全局代理，即使使用一些方法进行了全剧代理，效果也不是很明显，大部分情况下终端都是没有办法走代理的。  
## 问题解决
使用 proxychains 解决终端代理的问题  
### 下载和安装 proxychains
```bash
git clone https://github.com/rofl0r/proxychains-ng.git #如果clone 不下来就下载zip 我就存在下载不动的情况

cd proxychains-ng

./configure --prefix=/usr --sysconfdir=/etc #此处的prefix路径一定是/usr 如果换成其他会出现couldnt locate libproxychains4.so

make #需要gcc环境

sudo make install

sudo make install-config (installs proxychains.conf)

```
### 配置 proxychains
```bash
sudo vi /etc/proxychains.conf

将最后一行的sock4 改为 sock5 代理地址和端口根据自己shadowsocks的设置来进行设置
[ProxyList]
# add proxy here ...
# meanwile
# defaults set to "tor"
socks5 	127.0.0.1 28125
```
### 使用  
首先使用 curl 查看自己的 IP 地址  
```bash
在终端中输入
curl ipinfo.io  
```
![avatar](/assets/img/posts/proxychains-1.png)  
  
使用 proxychains 代理自己的终端  
```bash
proxychains curl ipinfo.io  
```
![avatar](/assets/img/posts/proxychains-2.png)  

成功
### 功能拓展  
proxychains 可以代理你想代理的任何应用，只需要在终端中输入 proxychains firefox 就可以代理使用火狐，同理适用于其他应用  