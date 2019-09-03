---
layout: post
title:  "Woodpecker-Analyzer 使用说明"
date:   2018-11-22 16:18:43
categories: Development
author: co0ontty
cover: '/assets/img/posts/woodpecker-tongji.png'
categories: PHP MYSQL HTML ALL
tags: PHP MYSQL HTML ALL
describe: 啄木鸟日志分析系统使用教程!
---

## Woodpecker-Analyzer 使用说明

### 环境搭建

1.将 Github 中的项目下载到 web 服务根目录中  

```
git clone https://github.com/co0ontty/Woodpecker-Analyzer.git
```

或者从 csdn 中下载  
https://download.csdn.net/download/weixin_38830346/10868100

2.设置数据库  
默认设置的 Mysql 数据库密码为 123456
创建 database：  

```
CREATE database rizhi;
```

在 rizhi 数据库中创建 tables：   

```
use rizhi;  
CREATE TABLE TCP (num int,ip VARCHAR(30));
```

### 使用

本系统使用的日志为使用 Windows 中的 bat 脚本和系统安全事件对恶意流量进行分析生成 data.txt 日志文件  
详细配置及使用脚本可参考我的另一片博客，windows 事件触发器  

##### 1.上传日志

·进入啄木鸟日志分析系统
![avatar](/assets/img/posts/woodpecker-index.png)  
·在主页敲击键盘回车进入系统
![avatar](/assets/img/posts/woodpecker-choice.png)  
·选择上传日志，上传 data.txt
![avatar](/assets/img/posts/woodpecker-uplode.png)  

##### 2.分析日志

·上传完成后点击分析日志即可获取日志的详细信息  
![avatar](/assets/img/posts/woodpecker-uploded.png)  
![avatar](/assets/img/posts/woodpecker-fenxi.png)  
·点击统计情况即可获取统计图  
![avatar](/assets/img/posts/woodpecker-tongji.png)  

该系统仍在努力开发中，有什么好想法欢迎交流.  
