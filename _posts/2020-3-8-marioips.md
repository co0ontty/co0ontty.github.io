---
layout: post
title:  "蔚蓝盾入侵检测系统"
date:   2020-3-8 13:18:43
categories: Development
author: co0ontty
categories: 安全开发  ALL
tags: 安全开发  ALL
describe: 蔚蓝盾入侵检测系统
cover: '/assets/img/posts/marioips.gif'
---
## 项目介绍  
- 系统采用服务端与客户端分离的设计方案，客户端仅负责恶意流量的拦截及日志反馈功能，服务端收集并处理日志。
- 客户端对所有的流量进行分析，并对流量中的 header,body,host,cookie,port,ip 等信息进行过滤及恶意行为识别，对识别成功的恶意流量进行告警、拦截、及主动阻断三种措施
- 部署方式上，服务端可选择脚本部署或者 docker 部署两种自动部署方式，客户端使用自动部署脚本进行部署。
- 后端代码使用 flask 进行架构，前端代码使用 react 进行编写，均为高效的轻量化框架，解决了传统 java 等编程语言带来的程序庞大的问题

## 已实现功能

- 客户端已经可以一键部署 `curl http://fenglipaipai:5000/install.sh | bash`
- 服务端可以部署在 docker ，也可部署在服务器主机上
- 服务端和客户端通过心跳进行连接，每三分钟客户端去服务端获取规则更新并提交入侵防御日志
- 客户端入侵防御日志ip 信息可精确到内网 ip
- 前端已经实现地图展示、已有规则展示、入侵检测详细信息展示

## 整体功能展示视频 (youtube)  

<iframe width="560" height="315" src="https://www.youtube.com/embed/aewCrbKuWfs" align="center" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>    

## [演示地址](http://fenglipaipai.xyz)
## 项目进展说明

- 客户端暂时仅支持 ubuntu 系统
- 请关注项目更新动态 [github](https://github.com/Mario-NDR/Mario)
