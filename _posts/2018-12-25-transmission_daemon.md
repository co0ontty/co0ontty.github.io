---
layout: post
title:  "VPS BT远程下载"
date:   2018-12-25 20:49:43 
author: co0ontty
categories: 运维 Tools ALL
tags: 运维 Tools ALL
describe: 使用VPS搭建远程下载器  
cover: '/assets/img/posts/tran-1.png'
---
### 使用transmission实现BT任务远程下载
#####安装：
```sh
apt-get install transmission-daemon -y
```
#####配置：
打开文件/var/lib/transmission-daemon/info/settings.json，修改配置参数如下：  
``` sh
{  
    ......  
    "rpc-authentication-required": true  
    "rpc-bind-address": "0.0.0.0",   
    "rpc-enabled": true,   
    "rpc-password": "123456",   
    "rpc-port": 9091,   
    "rpc-url": "/transmission/",   
    "rpc-username": "transmission",   
    "rpc-whitelist": "*",   
    "rpc-whitelist-enabled": true,   
    ......
}
```
rpc-username:用户名  
rpc-password:密码  
rpc-whitelist:允许访问的IP白名单  
#####开启服务：
```sh
service transmission-daemon start  
```
#####使用：
访问http://ip:9091/transmission/web/#files  
点击左上角的文件夹上传BT文件   
![avatar](/assets/img/posts/tran-1.png)