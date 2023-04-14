/*
 * @Author: Cao Shixin
 * @Date: 2023-04-13 17:38:50
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2023-04-13 17:44:51
 * @Description: 
 */

import 'package:flutter/material.dart';

/// controll gif
class GifController extends AnimationController {
  GifController(
      {required TickerProvider vsync,
      double value = 0.0,
      Duration? reverseDuration,
      Duration? duration,
      AnimationBehavior? animationBehavior})
      : super.unbounded(
            value: value,
            reverseDuration: reverseDuration,
            duration: duration,
            animationBehavior: animationBehavior ?? AnimationBehavior.normal,
            vsync: vsync);

  @override
  void reset() {
    // TODO: implement reset
    value = 0.0;
  }
}
