/*
 * @Author: Cao Shixin
 * @Date: 2021-03-26 10:17:59
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-29 12:30:23
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
import 'dart:async';

import 'package:flutter/services.dart';
import 'result_base.dart';
import 'specific_enum.dart';

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
}
