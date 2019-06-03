---
layout: post
title: "Python编写Poc学习"
date: 2019-6-2 20:49:43
author: co0ontty
categories: 安全开发 python ALL
tags: 安全开发 python ALL 
---
## 介绍：
本篇学习笔记将记录使用python编写poc的学习路线
## sys库
### sys.argv[]
```python
import sys
# 实时显示百分比
sys.stdout.write("%.2f"%percent) 
sys.stdout.write("%\r")
sys.stdout.flush()
```
### sys.stdout
使用sys.argv[]可以在命令行运行python的时候传递参数。
![屏幕快照 2019-06-02 21.35.06.png](https://i.loli.net/2019/06/02/5cf3d0946417d50084.png)
## socket库
```python
import socket
```
### 端口扫描：
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import sys
from socket import *
# import socket

# 端口扫描模块
def portScan(ip,portStart,portEnd):
	open_ports=[]
	for port in range(int(portStart),int(portEnd)+1):
		# 显示扫描百分比
		percent = float(port)*100/float(int(portEnd))
		sys.stdout.write("%.2f"%percent)
		sys.stdout.write("%\r")
		sys.stdout.flush()
		# 发送数据，尝试建立连接
		sock = socket(AF_INET, SOCK_STREAM)
		# sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
		sock.settimeout(10)
		result = sock.connect_ex((ip,port))
		if result == 0:
			open_ports.append(port)
		pass
	print open_ports
	pass

# 获取ip和端口扫描范围
def main():
	ip = sys.argv[1]
	port = sys.argv[2].split("-")
	portStart = port[0]
	portEnd = port[1]
	portScan(ip,portStart,portEnd)

if __name__ == '__main__':
	main()
```