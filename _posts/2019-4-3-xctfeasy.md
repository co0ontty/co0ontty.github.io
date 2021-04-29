---
layout: post
title: "Xctf 练习题"
date: 2019-4-3 20:49:43
author: co0ontty
categories: CTF ALL
tags: CTF ALL
describe: xctf 攻防世界 wp!
cover: 'https://i.loli.net/2019/04/04/5ca5717a1a74b.png'
---

## 1.view_source

无法使用右键查看代码，所以使用  
view-source:URL  

## 2.get_post

url?a=1 传递 get 值，使用 hackbar 传递 b 的值得到 flag  

## 3.robots

访问网站 url/robots.txt 发现网页包含 f1ag_1s_h3re.php 文件，访问得到 flag  

## 4.backup

访问网站 index.php 的备份文件 index.php.bak 得到 flag  

## 5.cookie

使用 burp 抓包看响应头  

## 6.disable_button

①可以将代码中的 disable=""标签删除   
②可以使用 hackbar 传递 post 的值

```php
<form action="" method="post" > <input disabled class="btn btn-default"style="height:50px;width:200px;"type="submit" value="flag"name="auth" /> 
</form>
```

post 传递参数 auth=flag  

## 7.xff_referer

X-Forwarded-For:简称 XFF 头，它代表客户端，也就是 HTTP 的请求端真实的 IP，只有在通过了 HTTP 代理或者负载均衡服务器时才会添加该项
HTTP Referer 是 header 的一部分，当浏览器向 web 服务器发送请求的时候，一般会带上 Referer，告诉服务器我是从哪个页面链接过来的，服务器基此可以获得一些信息用于处理
解题步骤：
使用 burp 抓包修改 X-Forwarded-For 和 Referer 参数
![avatar](/assets/img/posts/xctf-1.png)  

## 8.weak_auth

爆破得到 flag  

## 9.webshell

链接 webshell 得到 flag  
