---
layout: post
title: "Xctf练习题"
date: 2019-4-3 20:49:43
author: co0ontty
categories: CTF ALL
tags: CTF ALL
describe: xctf攻防世界wp!
cover: 'https://i.loli.net/2019/04/04/5ca5717a1a74b.png'
---

## 1.view_source

无法使用右键查看代码，所以使用  
view-source:URL  

## 2.get_post

url?a=1传递get值，使用hackbar传递b的值得到flag  

## 3.robots

访问网站url/robots.txt发现网页包含f1ag_1s_h3re.php文件，访问得到flag  

## 4.backup

访问网站index.php的备份文件index.php.bak得到flag  

## 5.cookie

使用burp抓包看响应头  

## 6.disable_button

①可以将代码中的disable=""标签删除   
②可以使用hackbar传递post的值

```php
<form action="" method="post" > <input disabled class="btn btn-default"style="height:50px;width:200px;"type="submit" value="flag"name="auth" /> 
</form>
```

post传递参数auth=flag  

## 7.xff_referer

X-Forwarded-For:简称XFF头，它代表客户端，也就是HTTP的请求端真实的IP，只有在通过了HTTP 代理或者负载均衡服务器时才会添加该项
HTTP Referer是header的一部分，当浏览器向web服务器发送请求的时候，一般会带上Referer，告诉服务器我是从哪个页面链接过来的，服务器基此可以获得一些信息用于处理
解题步骤：
使用burp抓包修改X-Forwarded-For和Referer参数
![avatar](/assets/img/posts/xctf-1.png)  

## 8.weak_auth

爆破得到flag  

## 9.webshell

链接webshell得到flag  
