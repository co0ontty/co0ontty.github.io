---
layout: post
title: "内网渗透总结（持续更新）"
date: 2019-5-24 11:49:43
author: co0ontty
categories: 渗透 ALL
tags: 渗透 ALL 
---
## 添加路由：
### 获取内网网段地址：
```shell
meterpreter > run get_local_subnets
```
###  添加去往目标网段的转发路由：
```shell
meterpreter > run autoroute -s 172.17.0.0/24
```
### 查看路由添加状况：  
```shell
meterpreter > run autoroute -p
```
### 使用：  
将添加路由完成的meterpreter进程添加到backgroup，让回话在后台持续运行   
使用相应的脚本对目标内网进行探测  
## 内网主机发现：
### cmd：
for /l %p in (1,1,254) do @ping -l 1 -n 3 -w 40 192.168.1.%p & if errorlevel 1 (echo 192.168.1.%p>>na.txt) else (echo 192.168.1.%p>>ok.txt)  