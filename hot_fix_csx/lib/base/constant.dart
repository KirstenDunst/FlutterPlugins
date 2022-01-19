/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 10:25:42
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-29 15:39:16
 * @Description: 
 */

class Constant {
  //*********** 网络环境地址 **********
  static const hotfixAskBaseUrlDevelop =
      'https://fshows-app-dev.oss-cn-hangzhou.aliyuncs.com'; //测试基本路径
  static const hotfixAskBaseUrlBeta =
      'https://fshows-app-pre.oss-cn-hangzhou.aliyuncs.com'; //beta基本路径
  static const hotfixAskBaseUrlDistribute =
      'https://fshows-app-pro.oss-cn-hangzhou.aliyuncs.com'; //正式基本路径

//pragma mark  *********** 独立队列名称 **********
  static const hotfixDownloadQueueName = 'HotFixDownloadQueueName'; //下载队列
  static const hotfixResourceQueueName = 'FixResourceQueueName';
  static const hotfixQueueName = 'HotFixQueueName';

//pragma mark  *********** 通用路径文件名称 **********
  static const hotfixBaseResourceDirName = 'base/www'; //基本解压w文件的跟路径
  static const hotfixFixResourceDirName = 'fix/www'; //合并一次热更新的跟路径
  static const hotfixFixTmpResourceDirName = 'fixtmp/www'; //再次热更新合并的跟路径
  static const hotfixFixTempResourceDirName =
      'fixtemp/www'; //做内容解压的时候临时存储旧的文件，防止清除之后没解压成功导致下次加载问题。
  static const hotfixConfigDirName = 'config'; //配置资源的路径
  static const hotfixDownloadDirName = 'download'; //下载资源目录名

  static const hotfixDiffDirName = 'diff'; //下载资源临时目录名
  static const hotfixResourceListFile = 'resource-manifest.json'; //清单文件名
  static const hotfixConfigJsonFile = 'config.json'; //本地热更新的资源文件
  static const hotfixNetWorkJsonFile =
      'manifest.json'; //远端热更新的ios-update-manifest文件本地存储名称
  static const hotfixTotalResourceFile = 'total.zip'; //全量包
  static const hotfixMakeupResourceFile = 'makeup.zip'; //合并增量包生成的压缩包
  static const hotfixLatestResourceFile =
      'latest.zip'; //同makeup.zip一致，只用来中间合并再次新的增量包过渡使用

  //*********** 本地存储nmanifest.json同远端的ios-update-manifest内部的key值 **********
  static const hotfixNetWorkKeyBundleArchiveChecksum =
      'bundleArchiveChecksum'; //整体压缩包的md5key
  static const hotfixNetWorkKeyBundleManifestChecksum =
      'bundleManifestChecksum'; //解压之后的www包内resource-bundle.manifest的md5key
  static const hotfixNetWorkKeyEntireBundleUrl = 'entireBundleUrl'; //全量包路径地址
  static const hotfixNetWorkKeyPatchRootUrl = 'patchRootUrl'; //增量包跟路径

  //*********** 项目中的文件名 **********
  static const hotfixWWWZip = 'ios-www'; //项目中的初始基准包名
  static const hotfixWWWCheckSum = 'checksum'; //清单文件核对资源key值

  //*********** 热更新处理操作时间间隔 **********
  static const hotfixSpeceTime = 10; //app从后台进入到前台触发热更新的时间间隔

  //*********** 热更新持久化存储 **********
  static const hotfixCurrentDomainKey = 'hotfixCurrentDomainKey'; //当前域名环境

}
