/*
 * @Author: Cao Shixin
 * @Date: 2021-02-08 11:58:36
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-08 16:57:03
 * @Description: 
 */
import 'dart:convert';
import 'dart:io';

import 'package:doraemonkit_csx/resource/assets.dart';
import 'package:doraemonkit_csx/dokit.dart';
import 'package:doraemonkit_csx/kit/common/basic_sandbox.dart';
import 'package:doraemonkit_csx/model/sandbox_info.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class SandboxCell extends StatefulWidget {
  final SandBoxModel model;
  final VoidCallback refreshBlock;
  SandboxCell(this.model, this.refreshBlock);
  @override
  _SandboxCellState createState() => _SandboxCellState();
}

class _SandboxCellState extends State<SandboxCell> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _ontapDeal,
      onLongPress: _onLongPressDeal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            Image.asset(
              widget.model.fileType == FileType.File
                  ? Images.dokit_file
                  : Images.dokit_dir,
              width: 30,
              height: 30,
              package: DoKit.PACKAGE_NAME,
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              width: 200,
              child: Text(
                widget.model.name ?? '',
                maxLines: 1000,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            widget.model.fileType == FileType.File
                ? Container()
                : Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(Images.dokit_expand_no,
                            width: 10, height: 20, package: DoKit.PACKAGE_NAME)
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
    if (widget.model.fileType == FileType.File) {
      try {
        final File file = File('${widget.model.path}');
        file.readAsBytes().then((byte) {
          String str = utf8.decode(byte, allowMalformed: true);
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.model.name),
              ),
              body: Text(str),
            );
          }));
        });
      } catch (e) {
        print("Couldn't read file:$e");
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.model.name),
            ),
            body: SandBoxPage(
              basePath: widget.model.path,
            ));
      }));
    }
  }

  void _onLongPressDeal() {
//文件夹提示删除，文件提示分享or删除
    var style = TextStyle(
        color: Colors.black, fontSize: 15, decoration: TextDecoration.none);
    var widgets = <Widget>[
      RaisedButton(
        onPressed: () {
          //删除
          if (widget.model.fileType == FileType.File) {
            File(widget.model.path).deleteSync(recursive: true);
          } else {
            Directory(widget.model.path).deleteSync(recursive: true);
          }
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            if (widget.refreshBlock != null) {
              widget.refreshBlock();
            }
          });
        },
        child: Container(
          alignment: Alignment.center,
          height: 50,
          child: Text(
            '删除',
            style: style,
          ),
        ),
      )
    ];
    if (widget.model.fileType == FileType.File) {
      widgets.add(Container(
        color: Colors.transparent,
        height: 4,
        width: context.size.width - 50,
      ));
      widgets.add(RaisedButton(
        onPressed: () {
          //系统分享桥接
          Share.shareFiles([widget.model.path]);
          Navigator.of(context, rootNavigator: true).pop();
        },
        child: Container(
          alignment: Alignment.center,
          height: 50,
          child: Text(
            '分享',
            style: style,
          ),
        ),
      ));
    }
    showDialog(
      context: context,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widgets,
        ),
      ),
    );
  }
}
