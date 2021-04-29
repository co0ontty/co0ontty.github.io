---
layout: post
title:  "suricat vs snort" 
date:   2019-10-21 11:10:51
categories: Development
author: co0ontty
categories: 安全开发 ALL
tags: 安全开发 ALL
describe: suricata 与 snort 对比
cover: '/assets/img/posts/Jietu20191021-111823.png'
---

## 前言

由于前段时间国庆期间，工作任务比较多，而且接手了部分涉密项目，所以博客暂停更新。

直到近期，所有的工作都告了一个段落，所以准备近期整理下之前工作中的一些心得。

##  suricata 

### 介绍

Suricata 是一个高性能的网络 ID、IP 和网络安全监控引擎。它是开源的，由一个社区经营的非营利基金会开放信息安全基金会（OISF）拥有。Suricata 由 OISF 开发。

### 安装

安装的时候可以通过 apt-get 安装，同时也可以使用源码安装，如果不需要使用新版本的一些功能的话，建议使用 apt-get 安装，方便快捷

### 使用

suricata 的使用方法是通过编写相应的规则来检测流量中的关键点来进行告警，可以检测实时的流量和通过回放流量包进行检测。在日常的开发调试环节大多数情况下是通过回放流量包进行的。

``` bash
# 回放一个流量包
suricata -c /etc/suricata/suricata.yaml -k none -r /mnt/hgfs/work/gringotts/pcaps/cve_2019_0232_success.pcap
# 回放一个文件夹中的所有流量包
suricata -c /etc/suricata/suricata.yaml -k none -r /mnt/hgfs/work/gringotts/pcaps/ 
```

使用中需要注意的几点：

1. 使用的流量包尽量为 pcap 格式
2. 使用过程中偶尔会出现无法将 http 和 tcp 做准确区分的情况

### 优点

1. suricata 相对于 snort 来说，有一个很大的区别就是，suricata 支持自动提取文件并计算文件的 hash 值，简单的说就是，书写 suricata 规则的时候可以使用文件的 hash 作为检测标准，但是在实际生产环境中测试，问加你提取的完整度还是不太行的，导致稍微大点或者复杂点的文件就检测不出来，实测成功率百分之三十左右。

2. 看到有的人说 suricata 的性能优化的比较好，可能我没有使用过大流量的关系，并没有感觉出什么明显的区别

### 规则

下面是部分规则，也没做什么筛选，简单的举个栗子，优点基础的一看就明白，具体的可以参考官方文档

``` bash
alert http any any -> any any (msg: "Apache struts2 RCE (CVE-2018-11776)"; flow: established, to_server;pcre:"/.+%7B(.+?)(ProcessBuilder|getRuntime|denyMethodExecution|FileOutputStream|memberAccess)(.+?)%7D.+(\.do|\.action)/iI";reference: cve, 2017-11776; sid: 30000064; rev: 1; )
#alert http any any -> any any (msg: "Apache struts2 RCE (CVE-2017-9791)"; flow: established, to_server;pcre:"/.+%7B(.+?)%7D.+(\.do|\.action)/iI";reference: cve, 2017-11776; sid: 30000064; rev: 1; )
alert http any any -> any any (msg: "Apache Struts2(S2-016) RCE";flow:to_server;pcre:"/(redirect%3A|redirectAction%3A|action%3A)/iI";pcre:"/%7B(.+?)(ProcessBuilder|getRuntime|denyMethodExecution|FileOutputStream|memberAccess)(.+?)%7D/i";sid:30000062;rev:1;)
alert http any any -> any any (msg: "Apache Struts2(S2-012 or S2-001 or s2-013) RCE";flow:to_server;pcre:"/(action|do)/iI";pcre:"/=(%23|%24|%25)%7B(.+?)(ProcessBuilder|getRuntime|denyMethodExecution|FileOutputStream|memberAccess)(.+?)%7D/iI";sid:30000060;rev:1;)
#alert http any any -> any any (msg: "Apache Struts2(S2_012 or S2_001) RCE";flow:to_server;pcre:"/(action|do)/iI";pcre:"/=.+?java\.lang\.ProcessBuilder/i";sid:30000060;rev:1;)
alert http any any -> any any (msg: "Apache Struts2(S2-008) RCE";flow:to_server;content:"debug";http_uri;pcre:"/debug=command&expression=((.+?)(ProcessBuilder|getRuntime|denyMethodExecution|FileOutputStream)(.+?))/i";sid:30000059;rev:1;)
#alert http any any -> any any (msg: "Apache Struts2(S2_008) RCE";flow:to_server;content:"debug";http_uri;content:"denyMethodExecution";content:"allowStaticMethodAccess";pcre:"/debug=command&expression=((.+?)getRuntime(%28%29|\(\))\.exec(.+?))/i";sid:30000059;rev:1;)
```

### reference ：

> [suricata 官网](https://suricata-ids.org/)

>[官方帮助文档](https://suricata.readthedocs.io/en/suricata-5.0.0)

>[第三方帮助文档](https://www.osgeo.cn/suricata/)

## snort

### 介绍

Snort 是一套开放源代码的网络入侵预防软件与网络入侵检测软件 Snort 使用了以侦测签名 signature-based 与通信协议的侦测方法。截至当前为止，Snort 的被下载次数已达到数百万次。 Snort 被认为是全世界最广泛使用的入侵预防与侦测软件。

### 安装

安装依赖环境
```bash
apt install -y gcc flex bison zlib1g-dev libpcap-dev libdnet-dev luajit liblua5.1-0-dev liblua5.1-0-dev liblua50-dev liblualib50-dev build-essential libpcre3-dev libdumbnet-devopenssl libssl-dev openssl libssl-dev 
apt-cache search lua
```
源码下载与编译
```bash
wget https://www.snort.org/downloads/snort/daq-2.0.6.tar.gz
wget https://www.snort.org/downloads/snort/snort-2.9.15.tar.gz
tar xvzf daq-2.0.6.tar.gz
tar xvzf snort-2.9.15.tar.gz
cd daq-2.0.6
./configure && make && sudo make install
cd snort-2.9.15
./configure --enable-sourcefire && make && sudo make install
```

### 使用

snort 也是可以支持实时流量检测和流量包回放功能

```bash
# 实时流量检测：
snort -c /etc/snort/rules/snort.conf -v
# 流量包回放
snort -c /etc/snort/rules/snort.conf -r /mnt/hgfs/work/gringotts/pcaps/cve_2019_17511_success.pcap
```

### 优点

1. snort 相对于 suricata 的优点可能就是说，snort 的结果方便阅读一些 

snort 结果：

![](/assets/img/posts/Jietu20191021-111823.png)

suricata 结果：

![](/assets/img/posts/Jietu20191021-112351.png)

suricata 的结果可能更方便做后续的开发，但是对于写规则的人来说可能太不友好了

### 规则

下面截取部分 snort 的规则，仅作参考，并不包含所有功能的实现，二者在规则上貌似没有什么区别

```bash
alert tcp any any -> any any (content: "log_get.php";msg: "IMAP buffer overflow!";sid:100;)
alert tcp any any -> any any (msg: "dlink Information leakage (CVE-2019-17511)";flow:to_server;flowbits:set,30000120;content:"log_get.php";http_uri;sid:1002;reference:cve,2019-17511;rev:1;)
alert tcp any any -> any any (msg: "dlink Information leakage attack success (CVE-2019-17511)";flow:to_client;flowbits:isset,30000120;content:"Time";content:"Message:1";sid:1001;rev:1;)
alert tcp any any -> any any (msg: "maccms_backdoor "; flow: to_server; flowbits:set,30000118;content: "POST"; http_method; content:"extend";http_uri;content: "getpwd"; http_client_body;pcre:"/(extend\/Qcloud\/Sms\/Sms.php)|(extend\/upyun\/src\/Upyun\/Api\/Format.php)/";sid: 1003; rev: 1; )
alert tcp any any -> any any (msg:"Joomla! Core SQL injection (CVE-2018-8045)";flow: established, to_server; flowbits:set,30000102;flowbits:noalert; content:"POST"; http_method; content:"option=com_users"; http_uri; content:"view=notes"; http_uri; distance:0; content:"filter[category_id]"; pcre: "/(updatexml|extractvalue|select)/Pi"; distance:1; reference: url, www.seebug.org/vuldb/ssvid-97205; reference:cve,2018-8045;sid:1004; rev:1;)
alert tcp any any -> any any (msg:"Joomla! Core SQL injection (CVE-2018-8045)";flow: established, to_client; flowbits:isset,30000102; content:"500"; http_stat_code; reference:cve,2018-8045;sid: 30000103; rev:1;)
```

### reference

>[snort 官网](https://www.snort.org/)

> [官方帮助文档](https://www.snort.org/#documents)

>[中文帮助文档](http://www.kaiyuanba.cn/content/network/snort/Snortman.htm)

## 总结

总体来说，suricata 更像是一个刚出道的伙子，年轻力壮，可以干很多工作，但却不是很细心。相比之下，snort 更像是混迹江湖多年的老手，会的不多但也足够，而且总能做好自己份内的事情

## reference 

> [suricata vs snort 技术指标对比(原文)](https://www.aldeid.com/wiki/Suricata-vs-snort)

> [suricata vs snort 技术指标对比(译文)](https://zhuanlan.zhihu.com/p/34329072)