/*
 * @Author: Cao Shixin
 * @Date: 2021-03-26 10:17:59
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-31 17:05:03
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

import 'result_base.dart';
import 'specific_enum.dart';

export 'result_base.dart';
export 'specific_enum.dart';

class IosSpecificCsx {
  static const MethodChannel _channel = const MethodChannel('ios_specific_csx');

  /*添加正念,要求iOS系统版本在iOS10以及以上
   * 返回是否添加成功
   */
  static Future<ResultBase> addHealthMindfulness(
      DateTime startDate, DateTime endDate) async {
    var tempStr = '';
    if (startDate == null) {
      tempStr = '开始时间不能为空';
    } else if (endDate == null) {
      tempStr = '结束时间不能为空';
    }
    if (tempStr.isNotEmpty) {
      return ResultBase(success: false, errorDescri: tempStr);
    } else {
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
  }

  static Future<bool> gotoHealthApp() async {
    return _channel.invokeMethod('gotoHealthApp');
  }

  static Future<bool> isHealthDataAvailable() async {
    return _channel.invokeMethod('isHealthDataAvailable');
  }

  static Future<ResultBase> requestHealthAuthority() async {
    var result = await _channel.invokeMethod('requestHealthAuthority');
    return ResultBase.fromJson(result);
  }

  /*
   * 获取当前所访问的健康管理内部子程序的权限
   */
  static Future<AuthorityStatus> getHealthAuthorityStatus(
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
   * 将身高写入健康，单位cm
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  static Future<ResultBase> addHealthStature(double height,
      {DateTime startDate, DateTime endDate}) async {
    height = max(height, 0);
    var result = await _channel.invokeMethod('addHealthStature', {
      'height': height,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将身高体重指数写入健康 单位BMI
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  static Future<ResultBase> addHealthBodyMassIndex(double bodyMassIndex,
      {DateTime startDate, DateTime endDate}) async {
    var result = await _channel.invokeMethod('addHealthBodyMassIndex', {
      'bodyMassIndex': bodyMassIndex,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将体脂率写入健康 单位%
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  static Future<ResultBase> addHealthBodyFatPercentage(double bodyFatPercentage,
      {DateTime startDate, DateTime endDate}) async {
    var result = await _channel.invokeMethod('addHealthBodyFatPercentage', {
      'bodyFatPercentage': bodyFatPercentage,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将体重写入健康， 单位千克
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  static Future<ResultBase> addHealthBodyMass(double bodyMass,
      {DateTime startDate, DateTime endDate}) async {
    var result = await _channel.invokeMethod('addHealthBodyMass', {
      'bodyMass': bodyMass,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将去脂体重写入健康，单位千克
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  static Future<ResultBase> addHealthLeanBodyMass(double leanBodyMass,
      {DateTime startDate, DateTime endDate}) async {
    var result = await _channel.invokeMethod('addHealthLeanBodyMass', {
      'leanBodyMass': leanBodyMass,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }

  /*
   * 将步数写入健康，单位步
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  static Future<ResultBase> addHealthStepCount(double stepCount,
      {DateTime startDate, DateTime endDate}) async {
    var result = await _channel.invokeMethod('addHealthStepCount', {
      'stepCount': stepCount,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }
  /*
   * 将步行+跑步写入健康，单位：公里（千米）
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  static Future<ResultBase> addHealthWalkingRunning(double walkingRunning,
      {DateTime startDate, DateTime endDate}) async {
    var result = await _channel.invokeMethod('addHealthWalkingRunning', {
      'walkingRunning': walkingRunning,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }
  /*
   * 将骑行写入健康，单位：公里（千米）
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  static Future<ResultBase> addHealthCycling(double cycling,
      {DateTime startDate, DateTime endDate}) async {
    var result = await _channel.invokeMethod('addHealthCycling', {
      'cycling': cycling,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }
  /*
   * 将心率写入健康，单位：次/分
   * 开始时间和结束时间不设置默认按照设备当前的时间
   */
  static Future<ResultBase> addHealthHeartRate(double heartRate,
      {DateTime startDate, DateTime endDate}) async {
    var result = await _channel.invokeMethod('addHealthHeartRate', {
      'heartRate': heartRate,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch
    });
    return ResultBase.fromJson(result);
  }
  
}
