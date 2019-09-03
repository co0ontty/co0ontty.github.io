---
layout: post
title:  "Mysql 基本操作"
date:   2018-11-23 16:18:43 
author: co0ontty
cover: '/assets/img/posts/mysql1234321.png'
categories: MYSQL Tools 运维 ALL
tags: MYSQL Tools 运维 ALL
describe: Mysql 基本操作语句
---

## 查询语句：

```sql
mysql -u root -p 后使用：
show databases；查询所有的数据库
show tables from bd_name；查询指定数据库内的所有表单
show columns from db_name.tb_name;查询制定数据库，指定表单中的所有列
use mysql;选择操作所运行的目标数据库：
SELECT column_name,column_nameFROM table_name基本语句
select host form user;查看 user（mysql数据库中）表中的host列所存储的信息
```

## 创建语句：

#### 创建 databases：

```sql
CREATE database DB_name;
```

#### 创建 tables:

```sql
CREATE TABLE TCP (num int,ip VARCHAR(20),date Date,time VARCHAR(5));
```

#### 插入数据：

```sql
INSERT INTO TCP (num,date,time,ip)VALUES("12","2018-2-3","08:59","192.168.1.3”);
```

#### 更新数据：

```sql
UPDATE TCP SET num=“2" WHERE ip=“192.168.5.5”;
```
