/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:47:21
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-18 14:46:29
 * @Description: 
 */

/// 内部log信息
typedef LogInfoCall = Function(String log);

/// 热更新的错误类型
enum HotFixErrorType {
  //未知错误
  unknow,
  //路径错误
  pathInvalid,
  //资源列表清单错误
  resourceListInvalid,
  //资源清单不存在
  resourceSumNotExists,
  //资源清单不一致
  resourceSumMd5NotEqual,
  //网络资源错误
  netResourceIsWrong,
  //差量资源错误
  diffResourceIsWrong,
  //url不可用
  urlInvalid
}

/// 当前可用资源
enum HotFixValidResource {
  //基准包资源
  base,
  //更新包(交替使用)
  fix,
  //更新包（交替使用） 考虑到更新包也会被更新，所以这里建立一个临时情况
  fixTmp,
}