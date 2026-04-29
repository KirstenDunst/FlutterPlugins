/*
 * @Author: Cao Shixin
 * @Date: 2021-02-08 11:58:36
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-10 19:14:17
 * @Description: 
 */
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../common/basic_sandbox.dart';
import '../csx_dokit.dart';
import '../model/sandbox_info.dart';
import '../page/dokit_app.dart';

class SandboxCell extends StatefulWidget {
  final SandBoxModel model;
  final VoidCallback? refreshBlock;
  const SandboxCell(this.model, this.refreshBlock, {super.key});
  @override
  State<SandboxCell> createState() => _SandboxCellState();
}

class _SandboxCellState extends State<SandboxCell> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _ontapDeal,
      onLongPress: _onLongPressDeal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            Image.asset(
              widget.model.fileType == FileType.file
                  ? 'assets/images/dokit_file.png'
                  : 'assets/images/dokit_dir.png',
              width: 30,
              height: 30,
              package: dkPackageName,
            ),
            SizedBox(width: 5),
            SizedBox(
              width: 200,
              child: Text(widget.model.name, maxLines: 1000),
            ),
            SizedBox(width: 5),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  widget.model.fileType == FileType.file
                      ? Text(widget.model.byteStr)
                      : Image.asset(
                          'assets/images/dokit_expand_no.png',
                          width: 10,
                          height: 20,
                          package: dkPackageName,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ontapDeal() {
    //文件直接文本查看，文件夹进入下一级查看
    if (widget.model.fileType == FileType.file) {
      try {
        final File file = File(widget.model.path);
        file.readAsBytes().then((byte) {
          String str = utf8.decode(byte, allowMalformed: true);
          if (mounted) {
            enterNewOverLayer(
              (entry) => Scaffold(
                appBar: AppBar(
                  title: Text(widget.model.name),
                  leading: GestureDetector(
                    onTap: () => entry?.remove(),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                    ),
                  ),
                ),
                body: SingleChildScrollView(child: Text(str)),
              ),
            );
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print("Couldn't read file:$e");
        }
      }
    } else {
      enterNewOverLayer(
        (entry) => Scaffold(
          appBar: AppBar(
            title: Text(widget.model.name),
            leading: GestureDetector(
              onTap: () => entry?.remove(),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
            ),
          ),
          body: SandBoxPage(basePath: widget.model.path),
        ),
      );
    }
  }

  void _onLongPressDeal() {
    //文件夹提示删除，文件提示分享or删除
    var style = TextStyle(
      color: Colors.black,
      fontSize: 15,
      decoration: TextDecoration.none,
    );

    enterNewOverLayer(
      (entry) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton(
            onPressed: () {
              //删除
              if (widget.model.fileType == FileType.file) {
                File(widget.model.path).deleteSync(recursive: true);
              } else {
                Directory(widget.model.path).deleteSync(recursive: true);
              }
              entry?.remove();
              widget.refreshBlock?.call();
            },
            child: Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(minHeight: 50),
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '删除\n${widget.model.name}',
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (widget.model.fileType == FileType.file) ...[
            Container(
              color: Colors.transparent,
              height: 4,
            ),
            ElevatedButton(
              onPressed: () {
                //系统分享桥接
                SharePlus.instance.share(
                  ShareParams(files: [XFile(widget.model.path)]),
                );
                entry?.remove();
              },
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(minHeight: 50),
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  '分享\n${widget.model.name}',
                  style: style,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ]
        ]),
      ),
    );
  }
}
