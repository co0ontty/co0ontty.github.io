---
layout: post
title:  "Suricata学习笔记"
date:   2019-9-16 16:18:43
categories: Development
author: co0ontty
categories: 安全开发 ALL
tags: 安全开发 ALL
describe: Suricata学习笔记
---

## Suricata学习笔记

### Suricata安装步骤：

官网介绍使用wget下载压缩包解压后进行安装，流程相对复杂

经测试在ubuntu下可以直接使用`sudo apt install Suricata`进行安装  

### Suricata 使用方法：

重放pcap包：

```bash
suricata -c suricata.yaml -k none -r cve-2018-7600.pcap
```

监听网卡：

```bash
suricata -c /etc/suricata/suricata.yaml -i wlan0
```

使用原理：

Suricata通过用户自己编写的.rules规则文件对流量进行匹配，如果发现与规则匹配的流量则进行进一步的操作

### Suricata 规则编写

完整规则：

```bash
alert http any any -> any any (msg: "ATTACK [PTsecurity] Kibana < 6.4.3 <5.6.13 Arbitrary File Inclusion/Disclosure/RCE attempt (CVE-2018-17245)"; flow: established, to_server; content: "/api/console/api_server"; http_uri; content: "SENSE_VERSION"; nocase; http_uri; distance: 0; pcre: "/apis\s*=\s*[^&]*(?:(?:%2e|\.)(?:%2e|\.)(?:%5c|%2f|\/|\\))/Ui"; reference: cve, 2018-17245; reference: url, www.cyberark.com/threat-research-blog/execute-this-i-know-you-have-it; reference: url, github.com/ptresearch/AttackDetection; metadata: Open Ptsecurity.com ruleset; classtype: attempted-admin; sid: 30000027; rev: 1; )
```

#### alert：

该参数用于指定规则触发的效果，包括一下四个参数可以选择：

`alert`:Suricata将触发警报，提示管理员系统存在异常操作行为。

`reject`:拒绝该数据包。

`drop`:这仅涉及IPS /内联模式，匹配到规则后，停止传送该数据包

`pass`:如果匹配成功，将停止扫描并跳过扫描该条数据

#### msg：

该条配置指定如果流量中包含攻击流量，匹配成功后在日志中显示的信息。

#### flow：

用于匹配流的方向，flow关键字也可以用来表示签名必须仅在流上匹配（only_stream）或仅在数据包（no_stream）上匹配。

flow参数可以包括以下几个关键词：

```
to_client                       established           only_stream
from_client                     stateless             no_stream
to_server 
from_server
```

from_server和to_client是一样的，to_server和from_client也是一样的。 这来自原始的Snort语言，我们支持它的兼容性的原因。

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

作者：明翼  
链接：https://www.jianshu.com/p/2d54c0461904  
来源：简书  
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。

#### content

使用content的参数对流量进行关键字匹配

`http_url`说明content中内容匹配的数据存在于http的url中，还可以设置为`http_cookie`等

`nocase`设置content中的值不区分大小写

`distance`：表示第一次匹配后到下次匹配中间的偏移量

#### 

### pcre

pcre关键字使用PCRE来匹配payload中的内容，用法一般是首先使用content匹配到指定字符串，然后根据pcre对相应的payload进行正则匹配

参考：[https://redmine.openinfosecfoundation.org/projects/suricata/wiki/Pcre_(Perl_Compatible_Regular_Expressions)](https://redmine.openinfosecfoundation.org/projects/suricata/wiki/Pcre_(Perl_Compatible_Regular_Expressions)
### reference
标明这条规则对应的信息所在的URL
```bash
reference:url,www.info.nl
如果在reference.config配置文件中存在关键字的引用关系，可以引用已经定义的关键字与url的对应关系例如：
reference.config中定义cve对应的url为：http://cve.mitre.org/cgi-bin/cvename.cgi?name=
则下面语句：
reference:cve,2019-2653
调用的url则为：http://cve.mitre.org/cgi-bin/cvename.cgi?name=2019-2653
```
### sid
表示这条规则的id
```bash
sid:number;
```
### rev
表示该条规则的版本号
```bash
rev:number;
```