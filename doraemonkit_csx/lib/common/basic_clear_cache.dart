/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:45:22
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-09 10:36:31
 * @Description: 
 */
import 'dart:async';

import 'package:doraemonkit_csx/dokit.dart';
import 'package:flutter/material.dart';

import '../vm/cache_vm.dart';
import 'common.dart';

class BasicClearCacheKit extends CommonKit {
  @override
  String getIcon() {
    return 'assets/images/dk_data_clean.png';
  }

  @override
  String getKitName() {
    return CommonKitName.kitBaseClearcache;
  }

  @override
  Widget createDisplayPage() {
    return CachePage();
  }
}

class CachePage extends StatefulWidget {
  const CachePage({super.key});

  @override
  State<CachePage> createState() => _CachePageState();
}

class _CachePageState extends State<CachePage> {
  final _streamController = StreamController<String>();
  @override
  Widget build(BuildContext context) {
    _streamController.addStream(CacheVM.loadCache().asStream());
    return Column(
      children: [
        InkWell(
          onTap: () => clearDialog(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: 60,
            child: Row(
              children: [
                Text('清理缓存'),
                Spacer(),
                StreamBuilder(
                  stream: _streamController.stream,
                  initialData: '加载中...',
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        return Text(snapshot.data.toString());
                      },
                ),
                SizedBox(width: 10),
                Image.asset(
                  'assets/images/dokit_expand_no.png',
                  width: 10,
                  height: 20,
                  package: dkPackageName,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 30),
          child: Divider(color: Colors.grey, height: 2),
        ),
      ],
    );
  }

  void clearDialog(BuildContext context) => showDialog(
    context: context,
    useRootNavigator: false,
    builder: (_) => Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).pop();
          CacheVM.clearCache(() async {
            _streamController.sink.add(await CacheVM.loadCache());
          });
        },
        child: Container(
          color: Colors.white,
          alignment: Alignment.center,
          height: 50,
          child: Text(
            '清除',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    ),
  );
}
