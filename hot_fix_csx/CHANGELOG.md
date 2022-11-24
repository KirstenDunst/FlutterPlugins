<!--
 * @Author: Cao Shixin
 * @Date: 2022-04-20 09:01:23
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-11-24 11:51:50
 * @Description: 
-->
## 0.0.8+4 20221105
* 修复批量下载中有暂停资源问题
* 升级flutter 3.*版本
* 添加资源下载oom检测以及toast提醒功能
* 添加flutter_downloader注解，避免release环境下载状态不回调


## 0.0.7 20220819
* 修复资源解压桥接flutter和原生名称字段不一致问题

## 0.0.6 20220811
* FlutterDownloader初始化支持http资源访问下载

## 0.0.5+3 20220718
* 修复ResourceProvider下载本地文件命名后缀被覆盖问题
* 补充下载管理，已下载资源的删除功能
* fix：本地资源不匹配，同步锁清理本地资源

## 0.0.4 20220627
* 扩展资源批量下载，总进度指使按照字节大小整体计算方法byteProgress

## 0.0.3 20220511
* 替换connectivity为connectivity_plus使用

## 0.0.2 20220507
* 修复时间转换ext插件计算问题

## 0.0.1
* 热修复基础版
