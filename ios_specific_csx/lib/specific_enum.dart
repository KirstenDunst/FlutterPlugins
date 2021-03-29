/*
 * @Author: Cao Shixin
 * @Date: 2021-03-29 09:32:48
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-29 11:31:40
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */

//权限的申请状态
enum AuthorityStatus {
  //未申请
  NotDetermined,
  //拒绝
  SharingDenied,
  //已授权
  SharingAuthorized,
}

// 健康app的内部的子分类，定义和iOS枚举index同步
enum HealthAppSubclassification {
  //正念
  Mindfulness,
}
