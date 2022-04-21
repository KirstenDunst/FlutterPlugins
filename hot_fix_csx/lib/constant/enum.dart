/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:47:21
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-20 16:18:22
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
