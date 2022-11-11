/*
 * @Author: Cao Shixin
 * @Date: 2022-11-02 23:11:50
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-11-11 14:31:06
 * @Description: 
 */
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'extension.dart';

typedef OnWidgetSizeChange = void Function(Size? size);

class MeasureSize extends StatefulWidget {
  final Widget? child;
  final OnWidgetSizeChange onSizeChange;

  const MeasureSize({
    Key? key,
    required this.onSizeChange,
    required this.child,
  }) : super(key: key);

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  Widget build(BuildContext context) {
    ambiguate(SchedulerBinding.instance)
        ?.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  GlobalKey widgetKey = GlobalKey();
  Size? oldSize;

  void postFrameCallback(Duration timestamp) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onSizeChange(newSize);
  }
}
