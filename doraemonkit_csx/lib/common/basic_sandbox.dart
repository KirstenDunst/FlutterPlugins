/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 11:37:24
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-11 11:27:37
 * @Description: 沙盒浏览器
 */

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../model/sandbox_info.dart';
import '../widget/sandbox_cell.dart';
import 'common.dart';

class BasicSandBoxKit extends CommonKit {
  @override
  String getIcon() {
    return 'assets/images/dk_file_explorer.png';
  }

  @override
  String getKitName() {
    return CommonKitName.kitBaseSandbox;
  }

  @override
  Widget createDisplayPage() {
    return SandBoxPage();
  }
}

class SandBoxPage extends StatefulWidget {
  final String? basePath;
  const SandBoxPage({super.key, this.basePath});
  @override
  State<SandBoxPage> createState() => _SandBoxPageState();
}

class _SandBoxPageState extends State<SandBoxPage> {
  late StreamController<List<SandBoxModel>> _sandboxStreamController;
  String? _basePath;

  @override
  void initState() {
    super.initState();
    _sandboxStreamController = StreamController<List<SandBoxModel>>();
    _checkData();
  }

  void _checkData() {
    _getSandBoxPath().then((path) {
      _basePath = path;
      _getFileStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SandBoxModel>>(
      stream: _sandboxStreamController.stream,
      initialData: [SandBoxModel()],
      builder: (context, snapshot) {
        var arr = snapshot.data!;
        return ListView.separated(
          itemCount: arr.length,
          itemBuilder: (BuildContext context, int index) =>
              SandboxCell(arr[index], () => _getFileStream()),
          separatorBuilder: (BuildContext context, int index) => Padding(
            padding: EdgeInsets.only(left: 30),
            child: Divider(color: Colors.grey, height: 2),
          ),
        );
      },
    );
  }

  Future _getSandBoxPath() async {
    if (widget.basePath != null) {
      return widget.basePath;
    } else {
      Directory? storageDirectory;
      if (Platform.isIOS) {
        storageDirectory = await getApplicationDocumentsDirectory();
      } else {
        storageDirectory = await getExternalStorageDirectory();
      }
      return storageDirectory?.parent.path;
    }
  }

  Future _getFileStream() async {
    var tempArr = <SandBoxModel>[];
    if (_basePath?.isNotEmpty ?? false) {
      var baseDire = Directory(_basePath!);
      if (await baseDire.exists()) {
        final entities = baseDire.listSync();
        //文件夹在前，文件在后，且都按名称字母排序
        entities.sort((a, b) {
          var aIsDir = a.statSync().type == FileSystemEntityType.directory;
          final bIsDir = b.statSync().type == FileSystemEntityType.directory;
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return a.path.compareTo(b.path);
        });

        for (var fileSys in entities) {
          var isDire = await Directory(fileSys.path).exists();
          var byte = 0;
          if (!isDire) {
            byte = (await File(fileSys.path).length());
          }
          tempArr.add(
            SandBoxModel(
              name: fileSys.path.replaceAll('${fileSys.parent.path}/', ''),
              path: fileSys.path,
              byte: byte,
              fileType: isDire ? FileType.directory : FileType.file,
            ),
          );
        }
      }
    }
    _sandboxStreamController.sink.add(tempArr);
  }

  @override
  void dispose() {
    _sandboxStreamController.close();
    super.dispose();
  }
}
