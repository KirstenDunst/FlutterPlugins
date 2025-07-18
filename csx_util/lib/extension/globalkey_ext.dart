import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  /// 获取当前组件的 RenderBox
  RenderBox? renderBox() {
    return findRenderObject() is RenderBox
        ? (findRenderObject() as RenderBox)
        : null;
  }

  /// 获取当前组件的 position
  Offset? position({Offset offset = Offset.zero}) {
    return renderBox()?.localToGlobal(offset);
  }
}

extension GlobalKeyExt on GlobalKey {
  /// 获取当前组件的 RenderBox
  RenderBox? renderBox() => currentContext?.renderBox();

  /// 获取当前组件的 position
  Offset? position({Offset offset = Offset.zero}) =>
      currentContext?.position(offset: offset);

  /// 获取当前组件的 Size
  Size? get size => currentContext?.size;
}
