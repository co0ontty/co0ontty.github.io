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
```
使用sys.argv[]可以在命令行运行python的时候传递参数。
![屏幕快照 2019-06-02 21.35.06.png](https://i.loli.net/2019/06/02/5cf3d0946417d50084.png)
## socket库
```python
import socket
```
### 端口扫描：
```python
import sys
from socket import *
# import socket
ip = sys.argv[1]
open_ports=[]
for port in range(1,4010):
	sock = socket(AF_INET, SOCK_STREAM)
	# sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.settimeout(10)
	print "[+]Trying to test "+str(ip)+":"+str(port)
	result = sock.connect_ex((ip,port))
	if result == 0:
		open_ports.append(port)
	pass
print open_ports
```