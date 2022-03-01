/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:47:21
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-01-21 15:22:47
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
  //资源清单
  resourceSumMd5NotEqual,
  netResourceIsWrong,
  diffResourceIsWrong,
  urlInvalid
}

/// 当前可用资源
enum HotFixValidResource {
  none,
  //基准包资源
  base,
  //更新包(交替使用)
  fix,
  //更新包（交替使用） 考虑到更新包也会被更新，所以这里建立一个临时情况
  fixTmp,
}

/// 进行异步检测资源完备性的结果机制
enum HotFixResourceIntegrityType {
  //第一次异步校验
  first,
  //已有资源，加载的时候异步校验
  after,
  //已有资源完备性检测失败，重新解压检测
  afterAgain
}
