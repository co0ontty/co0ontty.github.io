---
layout: post
title:  "php 文件上传"
date:   2018-11-26
author: co0ontty
cover: '/assets/img/posts/phpuplode1234.png'
categories: PHP ALL
tags: PHP ALL
describe: PHP 上传功能代码示例
---
### 使用 input 标签上传
```php
<form action="read_sql.php" method="post" enctype="multipart/form-data">
	请选择文件：<input type="file" name="file" /><input type="submit" value="上传" />
</form>
```
### 处理上传的文件
```php
<?php 
$arr = $_FILES["file"];  //读取文件信息  
if(($arr["type"]=="text/plain") && $arr["size"]<10241000 ) //添加限制条件：1.文件类型 2.文件的大小 3.文件名不能重复  
{
$arr["tmp_name"]; //临时文件的路径  上传的文件存放的位置 避免文件重复:  1.加时间戳.time()加用户名.$uid或者加.date('YmdHis') 
$filename = $arr["name"];  //保存之前判断该文件是否存在  
  if(file_exists($filename))
  {
    echo "该文件已存在".$filename."<br/>";
  }
  else
  {
 
  $filename = iconv("UTF-8","gb2312",$filename);  //中文名的文件出现问题，所以需要转换编码格式  
  
  move_uploaded_file($arr["tmp_name"],$filename);//移动临时文件到上传的文件存放的位置（核心代码） 括号里：1.临时文件的路径, 2.存放的路径  
  }
}
else
{
  echo "上传的文件大小或类型不符";
}
?>
```
### 输出文件
#### 输出文件全部内容：
```php
$myfile = fopen($filename,"r");  //打开文件
echo fread($myfile,filesize($filename));  //输出全部文件内容
fclose($myfile);  //关闭文件，减少系统资源占用
```
#### 逐列循环列表文件内容：
```php
$line_num = count(file('data.txt')); 
//输出文件中的总行数
echo "该文件总共：".$line_num."行"."<br/>"; 
$file = file("data.txt");
for ($i=0; $i < $line_num; $i++) {  //以文件中包含的行数来循环输出
	$line = $file[$i];
	$start_line = substr($line,0,1); //判断每行第一个字
	if ($start_line == 2) {
		echo $line; //如果这一行的第一个字是2则输出这一行
	} else {
		echo "第一个字不是2"."<br/>"; 
	}
```