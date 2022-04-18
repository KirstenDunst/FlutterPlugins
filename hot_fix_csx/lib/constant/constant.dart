/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 10:25:42
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-18 14:23:24
 * @Description: 
 */

class Constant {
  //通用路径文件名称
  static const String _hotfixPrefix = '';
  static const hotfixBaseResourceDirName =
      '${_hotfixPrefix}base/resource'; //基本解压w文件的跟路径
  static const hotfixFixResourceDirName =
      '${_hotfixPrefix}fix/resource'; //合并一次热更新的跟路径
  static const hotfixFixTmpResourceDirName =
      '${_hotfixPrefix}fixtmp/resource'; //再次热更新合并的跟路径
  static const hotfixFixTempResourceDirName =
      '${_hotfixPrefix}fixtemp/resource'; //做内容解压的时候临时存储旧的文件，防止清除之后没解压成功导致下次加载问题。
  static const hotfixConfigDirName = '${_hotfixPrefix}config'; //配置资源的路径
  static const hotfixDownloadDirName = '${_hotfixPrefix}download'; //下载资源目录名

  static const hotfixDiffDirName = 'diff'; //下载资源临时目录名
  static const hotfixResourceListFile = 'resource-bundle.manifest'; //清单文件名
  static const hotfixConfigJsonFile = 'config.json'; //本地热更新的资源文件
  static const hotfixTotalResourceFile = 'total.zip'; //全量包
  static const hotfixMakeupResourceFile = 'makeup.zip'; //合并增量包生成的压缩包
  static const hotfixLatestResourceFile =
      'latest.zip'; //同makeup.zip一致，只用来中间合并再次新的增量包过渡使用

  //热更新处理操作时间间隔
  static const hotfixSpeceTime = 10; //app从后台进入到前台触发热更新的时间间隔
}
