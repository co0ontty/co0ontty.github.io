---
layout: post
title:  "Bugku-web结题思路(持续更新)"
date:   2019-1-16 20:49:43 
author: co0ontty
categories: CTF  WEB ALL
tags: CTF  WEB ALL
describe: Bugku web wp
cover: 'https://i.loli.net/2019/04/04/5ca5adcb6096c.png'
---

## 1、web2：

查看网页源码即可看到flag  

## 2、计算器：

发现计算结果均为二位数，但是只能输入一个数字。使用检查功能（F12）将输入框中的maxlength="1"改为maxlength="2"即可  

## 3、web基础$_GET

阅读代码发现需要使用GET方法传递参数，$what=='flag'。根据GET方法通过URL传递参数的特点，在题目URL后面添加 ?what=flag 即可获得答案。  

## 4、wen基础$——Post

同$_GET题目，但是需要使用Post方法传递参数，使用FireFox中的hackbar插件传递参数值，如下图。  
![avatar](/assets/img/posts/Bugkuweb-1.png)  

## 5、矛盾

代码中使用!is_numeric($num)函数判断num是否为数字，题目要求num的值不为数字且值为1。所以构造值为一的非数字值。可以使用 1%00 （%00截断符）构造payload 获得flag  

## 6、web3

查看网页源代码在最后可以发现字符串“&#75;&#69;&#89;&#123;&#74;&#50;&#115;&#97;&#52;&#50;&#97;&#104;&#74;&#75;&#45;&#72;&#83;&#49;&#49;&#73;&#73;&#73;&#125;”，该字符串为常见的unicode编码，可以使用站长工具在线解析，同时可以使用html编码格式进行解析，将该字符串直接复制到html文件中即可自动解析出原有格式“KEY{J2sa42ahJK-HS11III}” 

## 7、域名解析

通过设置本机hosts文件实现无权限直接访问需要域名解析才能访问的ip，设置hosts文件后访问flag.baidu.com 即可

## 8.你必须让他停下来

打开发现网页一直在变，使用burp抓包，send to repeter 使用 go 逐一显示网页，即可看到flag。

## 9.本地包含

源代码：

```php

<?php 
    include "flag.php"; 
    $a = @$_REQUEST['hello']; 
    eval( "var_dump($a);"); 
    show_source(__FILE__); 
?>
```

eval应该是此题的突破口，能够执行php代码。
hello是接受参数的变量，接下来就是构建hello变量，使其能够闭合var_dump，利用print_r输出  
首先闭合var_dump: 1);
第二步构建print_r：print_r(file("./flag.php"));
URL构建结束：
http://123.206.87.240:8003/index.php?hello=1);print_r(file("./flag.php")
构建的URL触发的 eval操作为

```php
eval("var_dump(1);print_r(file("./flag.php")")
```

#### 方法二：

直接将文件包含在参数hello中  

```php
?hello=get_file_contents('flag.php')
?hello=file('flag.php')
```

## 11.web5

查看题目源代码发现存在Jsfuck，在控制台中输入该串代码，得到flag  
![avatar](/assets/img/posts/Bugkuweb-2.png)     

## 12.头等舱

使用burpsuit抓包得到flag  
![avatar](/assets/img/posts/Bugkuweb-3.png)    

## 13.网站被黑

查看题目URL发现路径十分的有特点，怀疑是通过上传webshell获得网站权限来挂载黑页。使用burp爆破后台目录，发现存在shell.php。爆破shell.php的密码为hack，登录获得flag。  

## 14.管理员系统

打开网页尝试登录后发现对ip进行了过滤  
![avatar](/assets/img/posts/Bugkuweb-4.png)      
查看源码发下在最末尾有base64加密的字符串dGVzdDEyMw==，解码后为test123  
使用Burp进行抓包，传递X-Forwarded-For: 127.0.0.1 测试本地上传是否可以绕过ip过滤限制  
绕过ip过滤限制后使用admin和test123登录得到flag  
![avatar](/assets/img/posts/Bugkuweb-5.png)    

## 15.web4

查看源码

```php
<script>
var p1 = '%66%75%6e%63%74%69%6f%6e%20%63%68%65%63%6b%53%75%62%6d%69%74%28%29%7b%76%61%72%20%61%3d%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%42%79%49%64%28%22%70%61%73%73%77%6f%72%64%22%29%3b%69%66%28%22%75%6e%64%65%66%69%6e%65%64%22%21%3d%74%79%70%65%6f%66%20%61%29%7b%69%66%28%22%36%37%64%37%30%39%62%32%62';
var p2 = '%61%61%36%34%38%63%66%36%65%38%37%61%37%31%31%34%66%31%22%3d%3d%61%2e%76%61%6c%75%65%29%72%65%74%75%72%6e%21%30%3b%61%6c%65%72%74%28%22%45%72%72%6f%72%22%29%3b%61%2e%66%6f%63%75%73%28%29%3b%72%65%74%75%72%6e%21%31%7d%7d%64%6f%63%75%6d%65%6e%74%2e%67%65%74%45%6c%65%6d%65%6e%74%42%79%49%64%28%22%6c%65%76%65%6c%51%75%65%73%74%22%29%2e%6f%6e%73%75%62%6d%69%74%3d%63%68%65%63%6b%53%75%62%6d%69%74%3b';
eval(unescape(p1) + unescape('%35%34%61%61%32' + p2));
</script>
```

按照最后一行代码的要求拼接字符串后进行URL DECODE 为  

```php
function checkSubmit(){var a=document.getElementById("password");if("undefined"!=typeof a){if("67d709b2b54aa2aa648cf6e87a7114f1"==a.value)return!0;alert("Error");a.focus();return!1}}document.getElementById("levelQuest").onsubmit=checkSubmit;
```

在输入框中输入67d709b2b54aa2aa648cf6e87a7114f1获得flag

## 16.flag在index里

题目URL为http://123.206.87.240:8005/post/index.php?file=show.php发现可以使用文件包含漏洞   
文件包含漏洞，发现了一种伪协议的方法， 为了读取包含有敏感信息的PHP等源文件，我们就要先将“可能引发冲突的PHP代码”编码一遍，这里就会用到php://filter ，可以将php中的代码呈现出来，具体用法如下：
http://123.206.87.240:8005/post/index.php?file=php://filter/read=convert.base64-encode/resource=index.php   

## 17.点击一百万次

查看网页源代码

```php
<script>
    var clicks=0
    $(function() {
      $("#cookie")
        .mousedown(function() {
          $(this).width('350px').height('350px');
        })
        .mouseup(function() {
          $(this).width('375px').height('375px');
          clicks++;
          $("#clickcount").text(clicks);
          if(clicks >= 1000000){
              var form = $('<form action="" method="post">' +
                        '<input type="text" name="clicks" value="' + clicks + '" hidden/>' +
                        '</form>');
                        $('body').append(form);
                        form.submit();
          }
        });
    });
  </script>
```

发现如下<script>代码，通过post传递clicks的参数  
![avatar](/assets/img/posts/Bugkuweb-6.png)  
获得flag   

## 18.备份是个好习惯

使用源码泄露工具测试网站是否存在备份文件泄露的漏洞
![avatar](/assets/img/posts/Bugkuweb-7.png)  
工具下载地址（https://coding.net/u/yihangwang/p/SourceLeakHacker/git?public=true） 
发现备份文件index.php.bak泄露  
打开index.php.bak发现如下代码：

```php
<?php
include_once "flag.php";
ini_set("display_errors", 0);
$str = strstr($_SERVER['REQUEST_URI'], '?');
$str = substr($str,1);
$str = str_replace('key','',$str);
parse_str($str);
echo md5($key1);

echo md5($key2);
if(md5($key1) == md5($key2) && $key1 !== $key2){
    echo $flag."取得flag";
}
?>
```

```php
$str = str_replace('key','',$str);
```

将key替换成空，即删除key字符串  

```php
if(md5($key1) == md5($key2) && $key1 !== $key2){
    echo $flag."取得flag";
```

md5弱类型比较漏洞，构造payload方式如下：
①使用弱类型比较漏洞，常用字符串如下：  
QNKCDZO

240610708

s878926199a

s155964671a

s214587387a

s214587387a
这些字符串md5加密后的值都为0exxxx形式，即为科学记数法，值相同。
payload：  
http://123.206.87.240:8002/web16/?kkeyey1=QNKCDZO&kekeyy2=240610708    
②md5()函数无法处理数组，如果传入的为数组，会返回NULL，所以两个数组经过加密后得到的都是NULL,也就是相等的。
payload:  
http://123.206.87.240:8002/web16/?kkeyey1[]=1&kekeyy2[]=2  
