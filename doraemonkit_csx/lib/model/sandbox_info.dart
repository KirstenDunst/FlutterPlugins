/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 16:06:28
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-10 19:09:14
 * @Description: 
 */

import 'package:doraemonkit_csx/util/extension/num_ext.dart';

//沙盒文件的类型
enum FileType {
  //文件夹
  Directory,
  // 文件
  File,
}

class SandBoxModel {
  String name;
  String path;
  num byte;
  String get byteStr => (byte ?? 0).byteFormat();
  FileType fileType;
  List<SandBoxModel> childrens;
  SandBoxModel({this.name = '', this.path = '', this.byte = 0, this.fileType});
}
