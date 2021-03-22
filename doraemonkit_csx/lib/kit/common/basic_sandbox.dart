/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 11:37:24
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-11 11:27:37
 * @Description: 沙盒浏览器
 */

import 'dart:async';
import 'dart:io';
import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:doraemonkit_csx/model/sandbox_info.dart';
import 'package:doraemonkit_csx/widget/sandbox_cell.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'common.dart';

class BasicSandBoxKit extends CommonKit {
  @override
  String getIcon() {
    return Images.dk_file_explorer;
  }

  @override
  String getKitName() {
    return CommonKitName.KIT_BASE_SANDBOX;
  }

  @override
  Widget createDisplayPage() {
    return SandBoxPage();
  }
}

class SandBoxPage extends StatefulWidget {
  final String basePath;
  SandBoxPage({this.basePath});
  @override
  _SandBoxPageState createState() => _SandBoxPageState();
}

class _SandBoxPageState extends State<SandBoxPage>
    with AutomaticKeepAliveClientMixin {
  var _sandboxStreamController;
  String _basePath;

  @override
  void initState() {
    super.initState();
    _sandboxStreamController = StreamController<List<SandBoxModel>>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _getSandBoxPath().then((path) {
      _basePath = path;
      _getFileStream();
    });
    return StreamBuilder(
      stream: _sandboxStreamController.stream,
      initialData: [SandBoxModel()],
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        List<SandBoxModel> arr = snapshot.data;
        return ListView.separated(
          itemCount: arr.length,
          itemBuilder: (BuildContext context, int index) {
            return SandboxCell(arr[index], () {
              _getFileStream();
            });
          },
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(left: 30),
              child: Divider(
                color: Colors.grey,
                height: 2,
              ),
            );
          },
        );
      },
    );
  }

  Future _getSandBoxPath() async {
    if (widget.basePath != null) {
      return widget.basePath;
    } else {
      Directory storageDirectory;
      if (Platform.isIOS) {
        storageDirectory = await getApplicationDocumentsDirectory();
      } else {
        storageDirectory = await getExternalStorageDirectory();
      }
      return storageDirectory.parent.path;
    }
  }

  void _getFileStream() async {
    var tempArr = <SandBoxModel>[];
    var baseDire = Directory(_basePath);
    if (await baseDire.exists()) {
      baseDire.listSync().forEach((fileSys) async {
        var isDire = await Directory(fileSys.path).exists();
        var byte = 0;
        if (!isDire) {
          byte = (await File(fileSys.path).length());
        }
        tempArr.add(SandBoxModel(
          name: fileSys.path.replaceAll(fileSys.parent.path + '/', ''),
          path: fileSys.path,
          byte: byte,
          fileType: isDire ? FileType.Directory : FileType.File,
        ));
      });
    }
    _sandboxStreamController.sink.add(tempArr);
  }

  @override
  bool get wantKeepAlive => true;
}
