---
layout: post
title: "服务器端口异常微信通知"
date: 2018-12-18 
author: co0ontty
categories: 运维 Tools ALL
tags: 运维 Tools ALL
describe: 服务器运行异常发送微信通知 
---

## 服务器端口异常消息报警
## 注册得到 sckey
进入网站http://sc.ftqq.com/ 按照提示登录并获得 sckey
## 绑定微信
获得 sckey 后，绑定微信，测试是否可以通信
## 使用 bash 脚本测试并发信息
```bash
#!/bin/bash

ip=("104.36.68.99" "213.236.37.69") //需要检测的ip

key=SCU37902Tb86700dc99c22215a38c28fde51bf10f5c18f91cde979  //你的sckey

content=梯子倒了 //自定义需要发送的信息

port=8388 //需要检测的端口

for i in ${ip[@]};

do

check_ip=`nmap $i -p $port|grep open|wc -l`

if [ $check_ip -eq 0 ];then

curl "https://sc.ftqq.com/$key.send?text=$i&desp=$content" >/dev/null 2>&1 &

fi

done
```
## 使用 crontab 设置定时任务
设置五分钟检查一次
*/5 * * * * /bin/bash check_ip_port.sh
