import 'package:flutter/material.dart';

mixin SingleAnimationMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late AnimationController animationController;
  Duration get animationDuration => const Duration(seconds: 1);

  bool get repeatInReverse => true;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: animationDuration,
    )..repeat(reverse: repeatInReverse);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
