/*
 * @Author: Cao Shixin
 * @Date: 2021-07-23 09:21:03
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-07-29 15:23:31
 * @Description: 
 */
import 'package:flutter/foundation.dart';
import 'package:flutter_utils/flutter_utils.dart';

/// 在notifyListener前校验是否已经销毁
mixin SafeNotifier on ChangeNotifier {
  bool _disposed = false;

  bool get disposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_disposed) {
      LogUtil.log('$runtimeType has disposed, ignore notifyListeners');
      return;
    }
    super.notifyListeners();
  }
}
