---
layout: post
title:  "Suricata 学习笔记"
date:   2019-7-30 16:18:43
categories: Development
author: co0ontty
categories: 安全开发 ALL
tags: 安全开发 ALL
describe: Suricata 学习笔记
cover: '/assets/img/posts/suricata-cover.jpg'
---

## Suricata 学习笔记

### Suricata 安装步骤：

官网介绍使用 wget 下载压缩包解压后进行安装，流程相对复杂

经测试在 ubuntu 下可以直接使用`sudo apt install Suricata`进行安装  

### Suricata 使用方法：

重放 pcap 包：

```bash
suricata -c suricata.yaml -k none -r cve-2018-7600.pcap
```

监听网卡：

```bash
suricata -c /etc/suricata/suricata.yaml -i wlan0
```

使用原理：

Suricata 通过用户自己编写的.rules 规则文件对流量进行匹配，如果发现与规则匹配的流量则进行进一步的操作

### Suricata 规则编写

完整规则：

```bash
alert http any any -> any any (msg: "ATTACK [PTsecurity] Kibana < 6.4.3 <5.6.13 Arbitrary File Inclusion/Disclosure/RCE attempt (CVE-2018-17245)"; flow: established, to_server; content: "/api/console/api_server"; http_uri; content: "SENSE_VERSION"; nocase; http_uri; distance: 0; pcre: "/apis\s*=\s*[^&]*(?:(?:%2e|\.)(?:%2e|\.)(?:%5c|%2f|\/|\\))/Ui"; reference: cve, 2018-17245; reference: url, www.cyberark.com/threat-research-blog/execute-this-i-know-you-have-it; reference: url, github.com/ptresearch/AttackDetection; metadata: Open Ptsecurity.com ruleset; classtype: attempted-admin; sid: 30000027; rev: 1; )
```

#### alert：

该参数用于指定规则触发的效果，包括一下四个参数可以选择：

`alert`:Suricata 将触发警报，提示管理员系统存在异常操作行为。

`reject`:拒绝该数据包。

`drop`:这仅涉及 IPS /内联模式，匹配到规则后，停止传送该数据包

`pass`:如果匹配成功，将停止扫描并跳过扫描该条数据

#### msg：

该条配置指定如果流量中包含攻击流量，匹配成功后在日志中显示的信息。

#### flow：

用于匹配流的方向，flow 关键字也可以用来表示签名必须仅在流上匹配（only_stream）或仅在数据包（no_stream）上匹配。

flow 参数可以包括以下几个关键词：

```
to_client                       established           only_stream
from_client                     stateless             no_stream
to_server 
from_server
```

from_server 和 to_client 是一样的，to_server 和 from_client 也是一样的。 这来自原始的 Snort 语言，我们支持它的兼容性的原因。

使用方法：

```bash
flow:to_client, established;
flow:from_client, established, only_stream;
```

##### flowbits：

适用于两个流量包进行比对时，

![avatar](/assets/img/posts/Suricata-1.png)

第一条规则如果匹配成功，默认则会弹出警报，如果不需要警报则需要在后面追加参数`'flowbits：noalert`

此规则的目的是检查`userlogin`上的匹配，并在流程中标记该匹配。 所以，没有必要产生一个警报。  
第二条规则没有第一条规则就没有效果。 如果第一条规则匹配，则流程将该特定条件设置为在流中存在。 现在用第二个规则可以检查前一个分组是否满足第一个条件。 如果第二条规则匹配，则会生成警报。


#### content

使用 content 的参数对流量进行关键字匹配

`http_url`说明 content 中内容匹配的数据存在于 http 的 url 中，还可以设置为`http_cookie`等

`nocase`设置 content 中的值不区分大小写

`distance`：表示第一次匹配后到下次匹配中间的偏移量

### reference
标明这条规则对应的信息所在的 URL
```bash
reference:url,www.info.nl
如果在reference.config配置文件中存在关键字的引用关系，可以引用已经定义的关键字与url的对应关系例如：
reference.config中定义cve对应的url为：http://cve.mitre.org/cgi-bin/cvename.cgi?name=
则下面语句：
reference:cve,2019-2653
调用的url则为：http://cve.mitre.org/cgi-bin/cvename.cgi?name=2019-2653
```
### sid
表示这条规则的 id
```bash
sid:number;
```
### rev
表示该条规则的版本号
```bash
rev:number;
```
#### pcre

pcre 关键字使用 PCRE 来匹配 payload 中的内容，用法一般是首先使用 content 匹配到指定字符串，然后根据 pcre 对相应的 payload 进行正则匹配

参考：[https://www.cnblogs.com/xh13dream/p/8604366.html](https://www.cnblogs.com/xh13dream/p/8604366.html)  

![pcre匹配案例](/assets/img/posts/pcre-1.png)  
pcre 匹配 / 的时候需要配合 \ 进行转义  

![pcre匹配案例](/assets/img/posts/pcre-2.png)  
pcre 匹配 webshell  

模式匹配中常用特殊字符

**点号 .** ：  
匹配任何单个字符(换行符\n 除外)  
**反斜杠 \\** ：  
转义字符，用于特殊符号前，使其失去特殊字符的作用变成普通字符  
**加号 +** ：  
匹配该字符前面的<font color=red>字符（单个）</font>至少一次；1 次，2 次...n 次  
**星号 \*** ：  
匹配该字符前面的字符任意次：0 次，1 次...n 次  
**问号 ？** ：  
匹配该字符前面的字符 0 次或者一次  
**.\*** ：  
匹配任意字符任意次（换行符除外）  
**{count}** ：  
匹配前面的字符 count 次  
**{min，}** ：  
匹配前面的字符至少 min 次  
**{min，max}** ：  
匹配至少 min，至多 max  
**\*？** ：   
匹配该字符前面的字符任意次：0 次，1 次...n 次，倾向于短字符，非贪婪量词  
**+？** ：  
匹配该字符前面的字符（单个）至少一次；1 次，2 次...n 次，倾向于短字符，非贪婪量词  
**（）** ：  
模式分组字符 eg：/(perl)+/  #有()匹配模式是 perl，没有括号，匹配模式是单个字符 l；  