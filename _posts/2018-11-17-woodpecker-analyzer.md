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

1.将Github中的项目下载到web服务根目录中  

```
git clone https://github.com/co0ontty/Woodpecker-Analyzer.git
```

或者从csdn中下载  
https://download.csdn.net/download/weixin_38830346/10868100

2.设置数据库  
默认设置的Mysql数据库密码为123456
创建database：  

```
CREATE database rizhi;
```

在rizhi数据库中创建tables：   

```
use rizhi;  
CREATE TABLE TCP (num int,ip VARCHAR(30));
```

### 使用

本系统使用的日志为使用Windows中的bat脚本和系统安全事件对恶意流量进行分析生成data.txt日志文件  
详细配置及使用脚本可参考我的另一片博客，windows事件触发器  

##### 1.上传日志

·进入啄木鸟日志分析系统
![avatar](/assets/img/posts/woodpecker-index.png)  
·在主页敲击键盘回车进入系统
![avatar](/assets/img/posts/woodpecker-choice.png)  
·选择上传日志，上传data.txt
![avatar](/assets/img/posts/woodpecker-uplode.png)  

##### 2.分析日志

·上传完成后点击分析日志即可获取日志的详细信息  
![avatar](/assets/img/posts/woodpecker-uploded.png)  
![avatar](/assets/img/posts/woodpecker-fenxi.png)  
·点击统计情况即可获取统计图  
![avatar](/assets/img/posts/woodpecker-tongji.png)  

该系统仍在努力开发中，有什么好想法欢迎交流.  
