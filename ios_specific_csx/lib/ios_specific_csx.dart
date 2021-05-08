/*
 * @Author: Cao Shixin
 * @Date: 2021-03-26 10:17:59
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-05-08 16:55:37
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */
export 'headlth_handle.dart';
export 'result_base.dart';
export 'specific_enum.dart';
export 'common_handle.dart';

import 'package:ios_specific_csx/headlth_handle.dart';
import 'common_handle.dart';

class IosSpecificCsx {
  factory IosSpecificCsx() => _getInstance();
  static IosSpecificCsx get instance => _getInstance();
  static IosSpecificCsx? _instance;
  static IosSpecificCsx _getInstance() {
    if (_instance == null) {
      _instance = IosSpecificCsx._internal();
    }
    return _instance!;
  }

  IosSpecificCsx._internal();

  //关于健康app的特殊处理
  HealthHandle get healthHandle {
    if (_healthHandle == null) {
      _healthHandle = HealthHandle();
    }
    return _healthHandle!;
  }

  HealthHandle? _healthHandle;

  //一般通用处理(目前只是占位)
  CommonHandle get commonHandle {
    if (_commonHandle == null) {
      _commonHandle = CommonHandle();
    }
    return _commonHandle!;
  }

  CommonHandle? _commonHandle;
}
