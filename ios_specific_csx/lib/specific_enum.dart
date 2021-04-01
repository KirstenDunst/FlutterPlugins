/*
 * @Author: Cao Shixin
 * @Date: 2021-03-29 09:32:48
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-31 15:46:59
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
  //身高
  Height,
  //身高体重指数
  BodyMassIndex,
  //体脂率
  BodyFatPercentage,
  //体重
  BodyMass,
  //去脂体重
  LeanBodyMass,
  //步数
  StepCount,
  //步行+跑步
  WalkingRunning,
  //骑行
  Cycling,
  //心率
  HeartRate,
}
