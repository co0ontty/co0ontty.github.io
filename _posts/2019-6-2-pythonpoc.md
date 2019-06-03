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
## Threadpool 多线程
### 多线程端口扫描：
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import socket
import sys
from datetime import datetime
from multiprocessing.dummy import Pool as ThreadPool
 
remote_server = sys.argv[1]
targetport = sys.argv[2].split("-")
startPort = targetport[0]
endPort = targetport[1]
remote_server_ip = socket.gethostbyname(remote_server)
ports = []
 
print '-' * 60
print '正在对目标： ', remote_server_ip + '进行扫描'
print '-' * 60
 
 
socket.setdefaulttimeout(0.5)
 
def scan_port(port):
    try:
        s = socket.socket(2,1)
        res = s.connect_ex((remote_server_ip,port))
        if res == 0: # 如果端口开启 发送 hello 获取banner
            print 'Port {}: OPEN'.format(port)
        s.close()
    except Exception,e:
        print str(e.message)
 
for i in range(int(startPort),int(endPort)+1):
    ports.append(i)
 
# Check what time the scan started
t1 = datetime.now()
 
# 创建线程
pool = ThreadPool(processes = 32)
results = pool.map(scan_port,ports)
pool.close()
pool.join()
 
print '本次端口扫描共用时 ', datetime.now() - t1
```
演示：
![portscan.gif](https://i.loli.net/2019/06/03/5cf4c2ba33b1e88447.gif)
## optparse库 python 命令解析模块
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
import optparse
import socket
import sys
from datetime import datetime
from multiprocessing.dummy import Pool as ThreadPool

print "------------------------------------------------------------------------------------------"
print "|             ___              _   _                            _                        |"
print "|   ___ ___  / _ \  ___  _ __ | |_| |_ _   _   _ __   ___  _ __| |_ ___  ___ __ _ _ __   |"
print "|  / __/ _ \| | | |/ _ \| '_ \| __| __| | | | | '_ \ / _ \| '__| __/ __|/ __/ _` | '_ \  |"
print "| | (_| (_) | |_| | (_) | | | | |_| |_| |_| | | |_) | (_) | |  | |_\__ \ (_| (_| | | | | |"
print "|  \___\___/ \___/ \___/|_| |_|\__|\__|\__, | | .__/ \___/|_|   \__|___/\___\__,_|_| |_| |"
print "|                                      |___/  |_|                                        |"
print "------------------------------------------------------------------------------------------"

parse=optparse.OptionParser(usage='python portscan.py -H 127.0.0.1 -P 60,90 -T 32',version="co0ontty portscan version:1.0")
parse.add_option('-H','--Host',dest='host',action='store',type=str,metavar='host',help='Enter Host!!')
parse.add_option('-P','--Port',dest='port',type=str,metavar='port',default='1,10000',help='Enter Port!!')
parse.add_option('-T','--Thread',dest='thread',type=int,metavar='thread')
parse.set_defaults(thread=32)  
options,args=parse.parse_args()

# optparse.OptionParser usage=''介绍使用方式
# dest='host',传递参数到名为host的变量
# type='str',传递参数的类型
# metavar='host', help中参数后的名称
# help=''，help中的语句
# parse.set_defaults(thread=32)  设置参数默认值的另一种方式
# 当你将所有的命令行参数都定义好了的时候，我们需要调用parse_args()方法add_option()函数依次传入的参数： options,args=parse.parse_args()

portList = options.port.split(",")
startPort = portList[0]
endPort = portList[1]
remote_server_ip = socket.gethostbyname(options.host)
ports = []
openPort = []

print '正在对目标： '+remote_server_ip + '  进行'+str(options.thread)+'线程扫描扫描'
socket.setdefaulttimeout(0.5)

def scan_port(port):
    try:
        s = socket.socket(2,1)
        res = s.connect_ex((remote_server_ip,port))
        if res == 0: 
            openPort.append(port)
        s.close()
    except Exception,e:
        print str(e.message)
 
for i in range(int(startPort),int(endPort)+1):
    ports.append(i)
 
# 扫描开始
t1 = datetime.now()
# 创建线程
pool = ThreadPool(processes = int(options.thread))
results = pool.map(scan_port,ports)
pool.close()
pool.join()

print openPort
print '本次端口扫描共用时 ', datetime.now() - t1
``` 