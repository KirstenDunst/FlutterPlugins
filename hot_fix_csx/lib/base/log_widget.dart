/*
 * @Author: Cao Shixin
 * @Date: 2022-04-22 17:52:31
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-11-05 10:13:17
 * @Description: log显示器
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hot_fix_csx/helper/log_helper.dart';

class HotFixLogWidget extends StatefulWidget {
  const HotFixLogWidget({Key? key}) : super(key: key);

  @override
  State<HotFixLogWidget> createState() => _HotFixLogWidgetState();
}

class _HotFixLogWidgetState extends State<HotFixLogWidget> {
  late StreamSubscription _streamSubscription;
  late List<String> _historyLogs;
  @override
  void initState() {
    super.initState();
    _historyLogs = LogHelper.instance.historyLogs;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _streamSubscription = LogHelper.instance.logStream.listen((event) {
        setState(() {
          _historyLogs = LogHelper.instance.historyLogs;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200, minHeight: 200),
      child: ListView.separated(
        itemBuilder: (context, index) => Text(_historyLogs[index]),
        separatorBuilder: (context, index) => Container(
          height: 1,
          color: Colors.grey,
        ),
        itemCount: _historyLogs.length,
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
