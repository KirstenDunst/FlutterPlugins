import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'ios_specific_csx.dart';
import 'result_base.dart';
import 'specific_enum.dart';

class HealthHandle {
  final MethodChannel _channel = const MethodChannel('ios_specific_csx_health');

  /*添加正念,要求iOS系统版本在iOS10以及以上
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
   */
  Future<ResultBase> requestHealthAuthority(
      HealthAppSubclassification subclassification) async {
    var result = await _channel.invokeMethod(
        'requestHealthAuthority', subclassification.index);
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
   * 将身高体重指数写入健康 单位BMI，外部可以不用单独再请求和状态判断
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
   * 将体重写入健康， 单位千克，外部可以不用单独再请求和状态判断
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
   * 将去脂体重写入健康，单位千克，外部可以不用单独再请求和状态判断
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
   * 将步数写入健康，单位步，外部可以不用单独再请求和状态判断
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
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  Future<ResultBase> addHealthHeartRate(double heartRate,
      {DateTime? startDate, DateTime? endDate}) async {
    var result = await _channel.invokeMethod('addHealthHeartRate', {
      'heartRate': heartRate,
      'startDate': (startDate ?? DateTime.now()).millisecondsSinceEpoch,
      'endDate': (endDate ?? DateTime.now()).millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }
}
