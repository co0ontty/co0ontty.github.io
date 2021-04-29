---
layout: post
title:  "钟馗之眼 python 调用框架"
date:   2019-8-8 16:18:43
categories: Development
author: co0ontty
categories: 安全开发  ALL
tags: 安全开发  ALL
describe: 钟馗之眼 python 调用框架
cover: '/assets/img/posts/zoomeye.jpg'
---
## python 调用 zoomeye-api
编写原因：使用 pocsuite 框架调用 zoomeye 测试 poc 的过程中发现 pocsuite 中的 dork 参数要求很严格，所以打算写一个调用 zoomeye 的 python 程序，将查询结果写入文件然后使用 pocsuite 读文件测试
### 源码
**下载 zoomeye 目标到 txt**
* 面向过程：

```python
# coding=UTF-8
import optparse
import os  
import sys  
import requests   
parse=optparse.OptionParser(usage='python zoomeye-api.py -K gitstack -P 4 ',version="phoenix zoomeye-api version:1.0")
parse.add_option('-U','--user',dest='user',type=str,metavar='user',help='Enter zoomeye username!!')
parse.add_option('-P','--passwd',dest='passwd',type=str,metavar='passwd',help='Enter zoomeye password!!')
parse.add_option('-K','--key',dest='key',type=str,metavar='key',help='Enter search key!!')
parse.add_option('-L','--limit',dest='limit',type=str,metavar='limit',default='4',help='Enter limit pages!!')
options,args=parse.parse_args()
#输入个人账号密码  
user = options.user
passwd = options.passwd
page = 1
#验证用户名密码，返回access_token     
def Check():
    data_info = {'username' : user,'password' : passwd} 
    try:
        respond = requests.post(url = 'https://api.zoomeye.org/user/login',json = data_info)
    except requests.RequestException as e:
        print("[-] %s" % e)
        print("[-] 连接失败!")
    else:
        if respond.status_code==200:
            access_token=respond.json()
            return access_token
        else:
            print("[-] %s %s \n[-] %s" % (respond.status_code, respond.json()["error"], respond.json()["message"]))
            print("[-] 连接失败!")
      
          
def search():  
    global mode,query
    mode = "host"
    query = options.key
 
def getRespose(access_token):   
    authorization = {'Authorization' : 'JWT ' + access_token["access_token"]}
    try:
        respond = requests.get(url = 'https://api.zoomeye.org/'+mode+'/search?query=' + query+"&page=" + str(page),headers = authorization)
    except requests.RequestException as e:
        print("[-] %s" % e)
        print("[-] %s 检索失败!" % mode.capitalize())
    else:
        if respond.status_code == 200:
            return respond.json()  
        else:
            print("[-] %s %s \n[-] %s" % (respond.status_code, respond.json()["error"], respond.json()["message"]))
            print("[-] %s 检索失败!" % mode.capitalize())
              
def output_data(temp):
    result = list()
    if mode == "host":
        for line in temp["matches"]:
            result.append(line["ip"] + ":" + str(line["portinfo"]["port"]) + "\n")
    else:
        for line in temp["matches"]:
            result.append(line["site"] + "\n")
    return result
          
def mian():
    global page
    access_token = Check()
    search()
    if not access_token:
        sys.exit()
    else:
        pass
    result = list()
    if search:
        max_page = int(options.limit)
        while page<=max_page:
            temp=getRespose(access_token)
            if not temp:
                print('[-]检索完成!')
                break
            else:
                if not temp["matches"]:
                    print ('[-]没有数据!')
                    break
                else:
                    result.extend(output_data(temp))
                    print('[-]开始下载第 %s 页'% page)
            page +=1
    result = set(result)
    with open('ZoomEyes.txt', "w") as f:
        f.writelines(result)
        f.close()
if __name__ == '__main__':
    mian()
```
* 面向对象：

```python
# coding=UTF-8
import optparse
import os
import sys
import requests
import argparse


def get_info():
    parse = argparse.ArgumentParser(
        usage='python phoenix-pocsuite.py -K gitstack -P 4 ', version="phoenix zoomeye-api version:1.1")
    parse.add_argument('-U', '--user', dest='user', type=str,
                       metavar='user', help='Enter zoomeye username!!')
    parse.add_argument('-P', '--passwd', dest='passwd', type=str,
                       metavar='passwd', help='Enter zoomeye password!!')
    parse.add_argument('-K', '--keyword', dest='keyword', type=str,
                       metavar='keyword', help='Enter search keyword!!')
    parse.add_argument('-L', '--maxpage', dest='maxpage', type=str,
                       metavar='maxpage', default='4', help='Enter maxpage!!')
    return parse.parse_args()


class zoomeye_api():
    def __init__(self, user, passwd, keyword, maxpage):
        self.user = user
        self.passwd = passwd
        self.keyword = keyword
        self.maxpage = maxpage

    def Check(self):
        data_info = {'username': self.user, 'password': self.passwd}
        try:
            respond = requests.post(
                url='https://api.zoomeye.org/user/login', json=data_info)
        except requests.RequestException as e:
            print("[-] %s" % e)
            print("[-] 连接失败!")
        else:
            if respond.status_code == 200:
                access_token = respond.json()
                return access_token
            else:
                print("[-] %s %s \n[-] %s" % (respond.status_code,
                                              respond.json()["error"], respond.json()["message"]))
                print("[-] 连接失败!")

    def getRespose(self, access_token):
        authorization = {'Authorization': 'JWT ' +
                         access_token["access_token"]}
        try:
            respond = requests.get(url='https://api.zoomeye.org/'+"host" +
                                   '/search?query=' + self.keyword+"&page=" + str(self.page), headers=authorization)
        except requests.RequestException as e:
            print("[-] %s" % e)
            print("[-] %s 检索失败!" )
        else:
            if respond.status_code == 200:
                response = respond.json()
                return response
            else:
                print("[-] %s %s \n[-] %s" % (respond.status_code,
                                              respond.json()["error"], respond.json()["message"]))
                print("[-] %s 检索失败!" )

    def out_data(self, temp):
        result = list()
        for line in temp["matches"]:
            result.append(line["ip"] + ":" +
                          str(line["portinfo"]["port"]) + "\n")
        return result

    def start_download(self):
        access_token = self.Check()
        if not access_token:
            sys.exit()
        else:
            pass
        result = list()
        for self.page in range(1,int(self.maxpage)+1):
            temp = self.getRespose(access_token)
            if not temp:
                print('[-]检索完成!')
                break
            else:
                if not temp["matches"]:
                    print('[-]没有数据!')
                    break
                else:
                    result.extend(self.out_data(temp))
                    print ('[-]开始下载第 %s 页' % self.page)


        result = set(result)
        with open('Zoomeye2.txt', "w") as f:
            f.writelines(result)
            f.close()


def main():
    args = get_info()
    Info = zoomeye_api(args.user, args.passwd, args.keyword, args.maxpage)
    Info.start_download()


if __name__ == '__main__':
    main()

```
**下载 zoomeye 目标到 txt，并调用 pocsuite 框架**
```python
# coding=UTF-8
import optparse
import os  
import sys  
import requests   
parse=optparse.OptionParser(usage='python phoenix-pocsuite.py -K gitstack -P 4 ',version="phoenix zoomeye-api version:1.0")
parse.add_option('-U','--user',dest='user',type=str,metavar='user',help='Enter zoomeye username!!')
parse.add_option('-P','--passwd',dest='passwd',type=str,metavar='passwd',help='Enter zoomeye password!!')
parse.add_option('-K','--key',dest='key',type=str,metavar='key',help='Enter search key!!')
parse.add_option('-L','--limit',dest='limit',type=str,metavar='limit',default='4',help='Enter limit pages!!')
parse.add_option('-F','--file',dest='pocname',type=str,metavar='pocname',help='Enter pocname!!')
options,args=parse.parse_args()
#输入个人账号密码  
user = options.user
passwd = options.passwd
pocname = options.pocname
page = 1
#验证用户名密码，返回access_token     
def Check():
    data_info = {'username' : user,'password' : passwd} 
    try:
        respond = requests.post(url = 'https://api.zoomeye.org/user/login',json = data_info)
    except requests.RequestException as e:
        print("[-] %s" % e)
        print("[-] 连接失败!")
    else:
        if respond.status_code==200:
            access_token=respond.json()
            return access_token
        else:
            print("[-] %s %s \n[-] %s" % (respond.status_code, respond.json()["error"], respond.json()["message"]))
            print("[-] 连接失败!")
      
          
def search():  
    global mode,query
    mode = "host"
    query = options.key
 
def getRespose(access_token):   
    authorization = {'Authorization' : 'JWT ' + access_token["access_token"]}
    try:
        respond = requests.get(url = 'https://api.zoomeye.org/'+mode+'/search?query=' + query+"&page=" + str(page),headers = authorization)
    except requests.RequestException as e:
        print("[-] %s" % e)
        print("[-] %s 检索失败!" % mode.capitalize())
    else:
        if respond.status_code == 200:
            return respond.json()  
        else:
            print("[-] %s %s \n[-] %s" % (respond.status_code, respond.json()["error"], respond.json()["message"]))
            print("[-] %s 检索失败!" % mode.capitalize())
              
def output_data(temp):
    result = list()
    if mode == "host":
        for line in temp["matches"]:
            result.append(line["ip"] + ":" + str(line["portinfo"]["port"]) + "\n")
    else:
        for line in temp["matches"]:
            result.append(line["site"] + "\n")
    return result
          
def mian():
    global page
    access_token = Check()
    search()
    if not access_token:
        sys.exit()
    else:
        pass
    result = list()
    if search:
        max_page = int(options.limit)
        while page<=max_page:
            temp=getRespose(access_token)
            if not temp:
                print('[-]检索完成!')
                break
            else:
                if not temp["matches"]:
                    print ('[-]没有数据!')
                    break
                else:
                    result.extend(output_data(temp))
                    print('[-]开始下载第 %s 页'% page)
            page +=1
    result = set(result)
    with open('ZoomEyes.txt', "w") as f:
        f.writelines(result)
        f.close()
    #传递参数调用pocsuite进行测试
    coomand = os.system("pocsuite -r {} -f {} --thread 20".format(pocname,"ZoomEyes.txt"))
    print coomand
if __name__ == '__main__':
    mian()
```
### 使用方法：
```bash
python phoenix-pocsuite.py -U zoomeye_username -P zoomeye_password -K search_keyword -L search_max_pages -F poc.py
```
