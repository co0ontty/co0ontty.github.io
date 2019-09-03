---
layout: post
title: "内网渗透总结（持续更新）"
date: 2019-5-24 11:49:43
author: co0ontty
categories: 渗透 ALL
tags: 渗透 ALL 
---
## 获得cs连接： 
通过各种技术手段获得shell以后，制作cs的连接程序。
![屏幕快照 2019-05-28 17.26.39.png](https://i.loli.net/2019/05/28/5cecfeed4ba9298900.png)  
使用shell运行该程序，建立cs连接。
## 公网反弹meterpreter：  
生成cs的listener的时候，将msf的端口设置为公网服务器的某个端口，再将该端口通过frp映射到本地的msf中。
![屏幕快照 2019-05-28 17.17.00.png](https://i.loli.net/2019/05/28/5cecfcc20e98925613.png)
使用cs的spawn将目标的meterpreter反弹到msf中，进行下一步操作
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
## 内网扫描：
### 主机发现：
1、使用cs中的netview   
2、将路由切换到后台，使用use auxiliary/scanner/discovery/arp_sweep   对内网中的设备进行arpscan，发现内网存活的主机，并根据返回的信息对内网的主机进行进一步的渗透。 
### 端口扫描：
1、使用cs中的portscan  
2、使用msf中的use auxiliary/scanner/portscan/中的模块对目标内网中主机的端口进行扫描  
![屏幕快照 2019-05-28 18.26.34.png](https://i.loli.net/2019/05/28/5ced0ceeb792189976.png)
详细的使用说明可以参考：
>https://blog.csdn.net/qq_34841823/article/details/54016723
