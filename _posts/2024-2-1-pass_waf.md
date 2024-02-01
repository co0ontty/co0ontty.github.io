---
layout: post
title:  "盘点 2023 公开的攻击面发现平台"
date:   2024-2-1 17:18:43
categories: Development
author: co0ontty
categories: ALL
tags: ALL
describe: 盘点 2023 公开的攻击面发现平台
cover: '/assets/img/posts/atlantis-1.png'
---
## 一、目录遍历漏洞
![](https://ctstack-oss.oss-cn-beijing.aliyuncs.com/blog/6e47dbd45f6be3c3cbb93978d5af85a5.png)


测试用例：Apache 目录遍历漏洞

测试环境搭建：

``` bash
## ubuntu
apt intsall apache2 && rm -f /var/www/html/index.html
```

无法拦截原因：
请求中无明显恶意特征，无法判断为攻击行为

实战数据：
截止发稿日，云图极速版发现 1109 家用户在有 WAF 防护的情况下存在公网可利用的同类风险。

## 二、未授权访问
![](https://ctstack-oss.oss-cn-beijing.aliyuncs.com/blog/6675341d69e6e02a73b7eb9246ad873e.png)


测试用例：Swagger Api接口未授权访问漏洞

测试环境搭建：

``` bash
无快速部署方案
```

无法拦截原因：
请求中无明显恶意特征，无法判断为攻击行为

实战数据：
截止发稿日，云图极速版发现 1020 家用户在有 WAF 防护的情况下存在公网可利用的同类风险。
## 三、备份文件泄露

![](https://ctstack-oss.oss-cn-beijing.aliyuncs.com/blog/72cbc226018e5cc1ce48799346666d34.png)

测试用例：web 目录放置一个文件

测试环境搭建：

``` bash
 apt install apache2 && touch /var/www/html/www.tar.gz
```

无法拦截原因：
请求中无明显恶意特征，无法判断为攻击行为

实战数据：
截止发稿日，云图极速版发现 1199 家用户在有 WAF 防护的情况下存在公网可利用的同类风险。
## 四、数据泄露

![](https://ctstack-oss.oss-cn-beijing.aliyuncs.com/blog/d96e790f0af7a062846acbb8f7d882ae.png)

测试用例：任意信息泄露漏洞

测试环境搭建：

 可参考 vulhub ：https://vulhub.org/#/environments/thinkphp/in-sqlinjection/

无法拦截原因：
请求中无明显恶意特征，无法判断为攻击行为

实战数据：
截止发稿日，云图极速版发现 2716 家用户在有 WAF 防护的情况下存在公网可利用的同类风险。
## 五、源站暴露

![](https://ctstack-oss.oss-cn-beijing.aliyuncs.com/blog/59e03ab6df3015e505ae3f26ef5311fd.png)


无法拦截原因：
WAF 一般只会拦截来自域名的访问请求，攻击者通过域名解析后的 IP 地址进行直接访问无需经过 WAF ，可实现绕过 WAF 的效果。

实战数据：
截止发稿日，云图极速版发现 2266 家用户在有 WAF 防护的情况下存在公网可利用的同类风险。
## 六、QPS 超限

无法拦截原因：
部分 WAF 在遇到请求量激增，超出 QPS 处理上限后的请求会直接放行至服务器，无法进行分析和拦截。

实战数据：
截止发稿日，云图极速版还不会给用户 QPS 打超限。
## 七 、慢速爆破

无法拦截原因：
慢速猜解目录的场景下，只要计数周期内的探测次数小于 WAF 阈值就不会触发告警。

实战数据：
截止发稿日，云图极速版周期性满速探测均可额外发现更多漏洞。
## 八、未开启拦截功能

无法拦截原因：
部分 WAF 误报太多，不敢开启拦截功能。

实战数据：
截止发稿日，云图极速版已帮助大量用户发现其购买的 WAF 无法开启拦截功能。


## 写在最后：

统计数据来自于：云图极速版 - SAAS 攻击面发现及管理工具

市场上各家安全产品众多，技术思路各有千秋。破局之战必须拿出一些看家本领。

1. 不依赖开源工具的安全能力，不受制于开源工具的能力上限
2. 正向研发，从用户实际需求出发，解决实际问题
3. 明码标价，不割韭菜

