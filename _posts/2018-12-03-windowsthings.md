---
layout: post
title:  "windows 事件触发器"
date:   2018-12-03 20:49:43 
author: co0ontty
cover: '/assets/img/posts/xtsj.jpg'
categories: windows 运维 ALL
tags: windows 运维 ALL
describe: 使用 windows 事件触发器监视系统活动
---
### 方法一：使用 windows 触发器记录系统日志
打开 windows 事件查看器  
手动触发事件  
在 windows 事件触发器中找到想要添加触发器的事件  
点击右下方，将任务附加到此事件  
### 方法二：任务计划程序  
打开 windows 任务计划程序  
创建任务  
设置名称，位置  
选中触发器细节（当任何用户登陆时候）   
根据需求调整其他选项（可以打开脚本实现读写和新建文件等操作）    
### 实际应用
当后台有新用户建立的时候，系统日志触发器被触发，运行事先预设的程序或者脚本  
脚本源码：  
backup.bat 当后台建立 3389 连接的时候，将连接信息记录在 D 盘的 data.txt 文件中  
```sh
for /F %%i in ('date /t') do ( set tt=%%i)
echo %tt:~0,10% >> D:\data.txt
echo %tt:~0,10% >> C:\phpStudy\PHPTutorial\WWW\data.txt
time /t >> D:\data.txt
time /t >> C:\phpStudy\PHPTutorial\WWW\data.txt
netstat -n -p tcp | find ":3389" >> D:\data.txt
netstat -n -p tcp | find ":3389" >> C:\phpStudy\PHPTutorial\WWW\data.txt
copy /y C:\Windows\System32\winevt\Logs\Security.evtx D:\backuplogs\
copy /y C:\Windows\System32\winevt\Logs\Security.evtx C:\phpStudy\PHPTutorial\WWW\
```
pop.bat 当后台新建用户的时候，记录并弹窗提醒  
```sh
msg %username% /time:60 "WARNING:a backdoor account is created"
time /t >> D:\data.txt
time /t >> C:\phpStudy\PHPTutorial\WWW\data.txt
echo USER CREATED >>  D:\data.txt
echo USER CREATED >>  C:\phpStudy\PHPTutorial\WWW\data.txt
```
double.bat 将应用程序和脚本绑定在一起，启动程序的同时记录日志  
```sh
cd D:\
start V15.lnk
time /t >> D:\data.txt
echo Siemens TIA Portal V15 has been opend >>D:\data.txt
```
检测 shell 反弹的脚本正在进一步完善   
