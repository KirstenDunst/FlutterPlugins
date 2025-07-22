import 'package:flutter/material.dart';

mixin PopInterceptorMixin<T extends StatefulWidget> on State<T> {
  // 子类可以覆盖此方法返回要回传的参数
  Future<dynamic> onPopIntercept() async => null;

  // 是否拦截 pop 操作
  Future<bool> handlePop(BuildContext context) async {
    final result = await onPopIntercept();
    if (result != null) {
      if (context.mounted) {
        Navigator.of(context).pop(result);
      }
      return false;
    }
    return true;
  }
}
