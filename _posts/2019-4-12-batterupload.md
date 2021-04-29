---
layout: post
title: "结合 CTF 详解条件竞争漏洞"
date: 2019-4-12 20:49:43
author: co0ontty
categories: CTF WEB ALL
tags: CTF WEB ALL 
describe: 利用 WEB 条件竞争漏洞进行上传绕过 
cover: 'https://i.loli.net/2019/04/12/5cb07b9862aee.jpg'
---
## 什么是条件竞争漏洞？ 
条件竞争漏洞是一种服务器端的漏洞，由于服务器端在处理不同用户的请求时是并发进行的，因此，如果并发处理不当或相关操作逻辑顺序设计的不合理时，将会导致此类问题的发生。  
## 漏洞分析
假设有这么一个代码，实现用户上传图片功能
```php
<?php
  if(isset($_GET['src'])){
    copy($_GET['src'],$_GET['dst']);
    //...
    //check file
    unlink($_GET['dst']);
    //...
 }
?>
```
该代码中通过  
```php
copy($_GET['src'],$_GET['dst'])
```
将上传的文件从源地址转换到目的地址进行储存。  
然后通过中间一系列 check file 代码，检查文件的安全性，如果发现该文件为不安全文件则使用 unlink 删除该文件。
但是如果判断时间过长，在该不安全文件被判定性质并且删除之前执行了该文件则会导致系统漏洞的形成。  
## 漏洞利用思路 
攻击者上传了一个用来生成恶意 shell 的文件，在上传完成和安全检查完成并删除它的间隙，攻击者通过不断地发起访问请求的方法访问了该文件，该文件就会被执行，并且在服务器上生成一个恶意 shell 的文件。至此，该文件的任务就已全部完成，至于后面发现它是一个不安全的文件并把它删除的问题都已经不重要了，因为攻击者已经成功的在服务器中植入了一个 shell 文件，后续的一切就都不是问题了。
## 漏洞利用详细步骤
1.抓包并根据过滤条件修改后发送到 Intruder 模块开多线程不断发包,使 WEB 服务不断接受该文件。
![屏幕快照 2019-04-12 18.26.16.png](https://img-blog.csdn.net/201803102006224?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvdTAxMTM3Nzk5Ng==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
2.然后写一个 python 脚本不断去访问那个文件，如果在 WEB 服务判定并删除不安全文件之前成功的访问则会达到效果。
```py

import requests
url = '你的文件路径'
while 1:
    r = requests.get(url)
    if 'moctf' in  r.text:
        print r.text


```
## 相关 CTF 题目  
### moctf web-没时间解释了  

进入题目发现 URL 为 index2.php,尝试访问 index.php 发现存在短暂跳转。抓包后发现
[![屏幕快照 2019-04-12 20.21.27.png](https://i.loli.net/2019/04/12/5cb082e3c7046.png)](https://i.loli.net/2019/04/12/5cb082e3c7046.png)
访问这个网页，发现为上传界面，随便输入两个值
[![屏幕快照 2019-04-12 20.28.44.png](https://i.loli.net/2019/04/12/5cb0849537251.png)](https://i.loli.net/2019/04/12/5cb0849537251.png)
访问这个网址后被告知太慢了，猜测可能为时间竞争类型。
使用 burp 多线程并发提交
### 抓取输入界面的包
[![屏幕快照 2019-04-12 20.41.41.png](https://i.loli.net/2019/04/12/5cb08929ce64a.png)](https://i.loli.net/2019/04/12/5cb08929ce64a.png)
sent to Intruder 
[![屏幕快照 2019-04-12 20.41.41.png](https://i.loli.net/2019/04/12/5cb089af69160.png)](https://i.loli.net/2019/04/12/5cb089af69160.png)
### 访问 Too slow 的页面并抓包
[![屏幕快照 2019-04-12 20.41.48.png](https://i.loli.net/2019/04/12/5cb08a119212e.png)](https://i.loli.net/2019/04/12/5cb08a119212e.png)
### 配置 Intruder
[![屏幕快照 2019-04-12 20.42.08.png](https://i.loli.net/2019/04/12/5cb08a7b2801b.png)](https://i.loli.net/2019/04/12/5cb08a7b2801b.png)
[![屏幕快照 2019-04-12 20.41.55.png](https://i.loli.net/2019/04/12/5cb08a7b2cdd8.png)](https://i.loli.net/2019/04/12/5cb08a7b2cdd8.png)
两个配置相同  
同时启动两个 Attack 进程，在 Too slow 页面发现 flag    
[![屏幕快照 2019-04-12 20.40.57.png](https://i.loli.net/2019/04/12/5cb08a35088ab.png)](https://i.loli.net/2019/04/12/5cb08a35088ab.png)