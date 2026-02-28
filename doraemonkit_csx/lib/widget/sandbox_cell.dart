/*
 * @Author: Cao Shixin
 * @Date: 2021-02-08 11:58:36
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-10 19:14:17
 * @Description: 
 */
import 'dart:convert';
import 'dart:io';

import 'package:doraemonkit_csx/dokit.dart';
import 'package:doraemonkit_csx/page/kits_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import '../common/basic_sandbox.dart';
import '../model/sandbox_info.dart';

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
            CommonPageInsertTool.overlayInsert(
              widget.model.name,
              Scaffold(
                appBar: AppBar(title: Text(widget.model.name)),
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
      CommonPageInsertTool.overlayInsert(
        widget.model.name,
        Scaffold(
          appBar: AppBar(title: Text(widget.model.name)),
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
    var widgets = <Widget>[
      ElevatedButton(
        onPressed: () {
          //删除
          if (widget.model.fileType == FileType.file) {
            File(widget.model.path).deleteSync(recursive: true);
          } else {
            Directory(widget.model.path).deleteSync(recursive: true);
          }
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            widget.refreshBlock?.call();
          });
        },
        child: Container(
          alignment: Alignment.center,
          height: 50,
          child: Text('删除', style: style),
        ),
      ),
    ];
    if (widget.model.fileType == FileType.file) {
      widgets.add(
        Container(
          color: Colors.transparent,
          height: 4,
          width: context.size!.width - 50,
        ),
      );
      widgets.add(
        ElevatedButton(
          onPressed: () {
            //系统分享桥接
            Share.shareFiles([widget.model.path]);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Container(
            alignment: Alignment.center,
            height: 50,
            child: Text('分享', style: style),
          ),
        ),
      );
    }
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: widgets),
      ),
    );
  }
}
