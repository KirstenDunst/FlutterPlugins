import 'package:flutter/material.dart';

mixin DelayedInitMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => afterFirstLayout());
  }

  void afterFirstLayout();
}
