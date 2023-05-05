import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'ios_specific_csx.dart';

class HealthHandle {
  final MethodChannel _channel = const MethodChannel('ios_specific_csx_health');
  final EventChannel _eventChannel = const EventChannel('ios_specific_csx_health_event');

  Stream get logStream => _eventChannel.receiveBroadcastStream('init');

  /*
   * 前往健康app
   */
  Future<bool?> gotoHealthApp() async {
    var result = await _channel.invokeMethod('gotoHealthApp');
    var resultBase = ResultBase.fromJson(result);
    return resultBase.success;
  }

  /*
   * 健康服务是否可用
   */
  Future<bool?> isHealthDataAvailable() async {
    return _channel.invokeMethod('isHealthDataAvailable');
  }

  /*
   * 请求对应健康app模块的权限
   * subclassification：对应权限类型
   * 调用前需要判断是否已经被用户拒绝，如果是拒绝状态需要应用内自己弹窗“需要用户打开相关健康数据开关”然后跳转健康做手动开启，否则调用请求仍然会返回success：true，error：
   */
  Future<ResultBase> requestHealthAuthority(
      HealthAppSubclassification subclassification) async {
    var result = await _channel.invokeMethod(
        'requestHealthAuthority', subclassification.index);
    return ResultBase.fromJson(result);
  }

  /*
   * 批量请求对应健康app模块的权限
   * subclassifications：对应权限类型数组
   * 调用前需要判断是否已经被用户拒绝，如果是拒绝状态需要应用内自己弹窗“需要用户打开相关健康数据开关”然后跳转健康做手动开启，否则调用请求仍然会返回success：true，error：
   */
  Future<ResultBase> requestHealthSubmodulesAuthority(
      List<HealthAppSubclassification> subclassifications) async {
    var result = await _channel.invokeMethod('requestHealthSubmodulesAuthority',
        subclassifications.map((e) => e.index).toList());
    return ResultBase.fromJson(result);
  }

  /*
   * 获取当前所访问的健康管理内部子程序的权限
   * subclassification：对应权限类型
   */
  Future<AuthorityStatus?> getHealthAuthorityStatus(
      HealthAppSubclassification subclassification) async {
    var result = await _channel.invokeMethod(
        'getHealthAuthorityStatus', subclassification.index);
    return {
      "0": AuthorityStatus.NotDetermined,
      "1": AuthorityStatus.SharingDenied,
      "2": AuthorityStatus.SharingAuthorized
    }["$result"];
  }

  /* 添加正念,要求iOS系统版本在iOS10以及以上
   * 返回是否添加成功
   */
  Future<ResultBase> addHealthMindfulness(
      DateTime startDate, DateTime endDate) async {
    var tempStartDate = startDate;
    var tempEndDate = endDate;
    if (endDate.isBefore(startDate)) {
      tempStartDate = endDate;
      tempEndDate = startDate;
    }
    var result = await _channel.invokeMethod('addHealthMindfulness', {
      'startDate': tempStartDate.millisecondsSinceEpoch,
      'endDate': tempEndDate.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将身高写入健康，单位cm，内部会对权限的一系列处理，外部可以不用单独再请求和状态判断
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthStature(double height,
      {DateTime? startDate, DateTime? endDate}) async {
    height = max(height, 0);
    var result = await _channel.invokeMethod('addHealthStature', {
      'height': height,
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 获取健康的身高，单位cm
   */
  Future<GetHealthData> getHealthStature(
      {DateTime? startDate, DateTime? endDate}) async {
    var result = await _channel.invokeMethod('getHealthStature', {
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return GetHealthData.fromJson(result);
  }

  /*
   * 将身高体重指数写入健康 单位count，外部可以不用单独再请求和状态判断
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthBodyMassIndex(double bodyMassIndex,
      {DateTime? startDate, DateTime? endDate}) async {
    var result = await _channel.invokeMethod('addHealthBodyMassIndex', {
      'bodyMassIndex': bodyMassIndex,
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将体脂率写入健康 单位%，外部可以不用单独再请求和状态判断
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthBodyFatPercentage(double bodyFatPercentage,
      {DateTime? startDate, DateTime? endDate}) async {
    var result = await _channel.invokeMethod('addHealthBodyFatPercentage', {
      'bodyFatPercentage': bodyFatPercentage,
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将体重写入健康， 单位kg，外部可以不用单独再请求和状态判断
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthBodyMass(double bodyMass,
      {DateTime? startDate, DateTime? endDate}) async {
    var result = await _channel.invokeMethod('addHealthBodyMass', {
      'bodyMass': bodyMass,
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将去脂体重写入健康，单位kg，外部可以不用单独再请求和状态判断
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthLeanBodyMass(double leanBodyMass,
      {DateTime? startDate, DateTime? endDate}) async {
    var result = await _channel.invokeMethod('addHealthLeanBodyMass', {
      'leanBodyMass': leanBodyMass,
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将步数写入健康，单位count，外部可以不用单独再请求和状态判断
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthStepCount(double stepCount,
      {DateTime? startDate, DateTime? endDate}) async {
    var result = await _channel.invokeMethod('addHealthStepCount', {
      'stepCount': stepCount,
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将步行+跑步写入健康，单位：公里（千米），外部可以不用单独再请求和状态判断
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthWalkingRunning(double walkingRunning,
      {DateTime? startDate, DateTime? endDate}) async {
    var result = await _channel.invokeMethod('addHealthWalkingRunning', {
      'walkingRunning': walkingRunning,
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将骑行写入健康，单位：公里（千米），外部可以不用单独再请求和状态判断
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthCycling(double cycling,
      {DateTime? startDate, DateTime? endDate}) async {
    var result = await _channel.invokeMethod('addHealthCycling', {
      'cycling': cycling,
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将心率写入健康，单位：次/分，外部可以不用单独再请求和状态判断˝
   * heartRate, 最低30
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthHeartRate(int heartRate, {DateTime? time}) async {
    var result = await _channel.invokeMethod('addHealthHeartRate', {
      'heartRate': heartRate,
      'time': (time ?? DateTime.now()).millisecondsSinceEpoch,
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将血氧写入健康，单位：%，外部可以不用单独再请求和状态判断˝
   * bloodOxygen：为0～1之间的double数值，（iOS健康app有安全判断，低于0.7会写入失败，属于异常情况）
   * 可自定义录入时间
   */
  Future<ResultBase> addHealthBloodOxygen(double bloodOxygen,
      {DateTime? time}) async {
    var result = await _channel.invokeMethod('addHealthBloodOxygen', {
      'bloodOxygen': bloodOxygen,
      'time': (time ?? DateTime.now()).millisecondsSinceEpoch,
    });
    return ResultBase.fromJson(result);
  }
}
