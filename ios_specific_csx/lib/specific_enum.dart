/*
 * @Author: Cao Shixin
 * @Date: 2021-03-29 09:32:48
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-07-26 09:23:08
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
  mindfulness,
  //身高 （单位cm）
  height,
  //身高体重指数
  bodyMassIndex,
  //体脂率
  bodyFatPercentage,
  //体重
  bodyMass,
  //去脂体重
  leanBodyMass,
  //步数
  stepCount,
  //步行+跑步
  walkingRunning,
  //骑行
  cycling,
  //心率（单位：次/分）
  heartRate,
  //血氧
  bloodOxygen
}
const HealthAppSubclassMap = {
  '正念': HealthAppSubclassification.mindfulness,
  '身高': HealthAppSubclassification.height,
  '身高体重指数': HealthAppSubclassification.bodyMassIndex,
  '体脂率': HealthAppSubclassification.bodyFatPercentage,
  '体重': HealthAppSubclassification.bodyMass,
  '去脂体重': HealthAppSubclassification.leanBodyMass,
  '步数': HealthAppSubclassification.stepCount,
  '步行+跑步': HealthAppSubclassification.walkingRunning,
  '骑行': HealthAppSubclassification.cycling,
  '心率': HealthAppSubclassification.heartRate,
  '血氧': HealthAppSubclassification.bloodOxygen,
};
