/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 11:47:21
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-29 17:53:59
 * @Description: 
 */

/* 
 * 热更新的错误类型
 */
enum HotFixErrorType {
  UnKnow,
  PathInvalid,
  ResourceListInvalid,
  ResourceSumNotExists,
  ResourceSumMd5NotEqual,
  NetResourceIsWrong,
  DiffResourceIsWrong,
  URLInvalid
}

/*
 * 当前可用资源
 */
enum HotFixValidResource {
  None,
//基准包资源
  Base,
//更新包(交替使用)
  Fix,
//更新包（交替使用） 考虑到更新包也会被更新，所以这里建立一个临时情况
  FixTmp,
}

/*
 * 进行异步检测资源完备性的结果机制
 */
enum HotFixResourceIntegrityType {
  //第一次异步校验
  First,
  //已有资源，加载的时候异步校验
  After,
//已有资源完备性检测失败，重新解压检测
  AfterAgain
}
