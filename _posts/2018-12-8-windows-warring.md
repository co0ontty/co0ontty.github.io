---
layout: post
title:  "evtx-windows 系统日志比对系统"
date:   2018-12-07 20:49:43 
author: co0ontty
categories: python windows  ALL 
tags: python windows  ALL
describe: windows 系统日志变化发生变化时发出警告
---

# windwos 系统安全日志监视系统
### 思路：
该脚本使用 python 的 evtx 库，对 windwos 的系统日志进行读取和比对，当发现系统日志中的信息被删除则出现弹框进行提示
### 源代码分享
```py
#-*-coding:utf-8-*-
import mmap
import contextlib
import Tkinter  #弹窗库
import tkMessageBox #弹窗信息库
from Evtx.Evtx import FileHeader
from Evtx.Views import evtx_file_xml_view
import ctypes 
whnd = ctypes.windll.kernel32.GetConsoleWindow()
if whnd != 0:
	ctypes.windll.user32.ShowWindow(whnd,0)
	ctypes.windll.kernel32.CloseHandle(whnd)
output = open("1.txt","r")
number = output.read()
output.close()
output = open("1.txt","w")
count = 1
EvtxPath = "security.evtx" 
with open(EvtxPath,'r') as f:
    with contextlib.closing(mmap.mmap(f.fileno(),0,access=mmap.ACCESS_READ)) as buf:
        fh = FileHeader(buf,0)
        print "Please wating..."
        for xml, record in evtx_file_xml_view(fh):
            count = count+1 
output.write(str(count))
output.close()
if int(count) >= int(number):
    print "No change"
else:
    def show():
        tkMessageBox.showinfo(title='日志更改提醒', message='日志更改')
    show()
exit()
```
使用 vbs 脚本在调用 py，并隐藏窗口运行  
```py
set ws = WScript.CreateObject("WScript.Shell")
ws.Run "python evtx2.py",0
```
### 后续工作
使用 windows 系统计划任务管理器设置定时任务，每隔一段时间运行一次脚本，发现系统日志中的信息被删除则发出报警