/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 13:45:22
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-09 10:36:31
 * @Description: 
 */
import 'dart:async';
import 'dart:math';

import 'package:doraemonkit_csx/dokit.dart';
import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:doraemonkit_csx/vm/cache_vm.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class BasicClearCacheKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_data_clean;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_CLEARCACHE;
  }

  @override
  Widget createDisplayPage() {
    return CachePage();
  }
}

class CachePage extends StatefulWidget {
  @override
  _CachePageState createState() => _CachePageState();
}

class _CachePageState extends State<CachePage> {
  var _streamController = StreamController<String>();
  @override
  Widget build(BuildContext context) {
    _streamController.addStream(CacheVM.loadCache().asStream());
    return Column(children: [
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
              SizedBox(
                width: 10,
              ),
              Image.asset(Images.dokit_expand_no,
                  width: 10, height: 20, package: DoKit.PACKAGE_NAME),
            ],
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 30),
        child: Divider(
          color: Colors.grey,
          height: 2,
        ),
      )
    ]);
  }

  void clearDialog(BuildContext context) => showDialog(
        context: context,
        child: Center(
          child: InkWell(
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              CacheVM.clearCache(callback: () async {
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
                    decoration: TextDecoration.none),
              ),
            ),
          ),
        ),
      );
}
