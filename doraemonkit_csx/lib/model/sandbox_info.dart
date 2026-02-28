/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 16:06:28
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-03-10 19:09:14
 * @Description: 
 */

//沙盒文件的类型
import 'package:doraemonkit_csx/utils/num_ext.dart';

enum FileType {
  //文件夹
  directory,
  // 文件
  file,
}

class SandBoxModel {
  String name;
  String path;
  num byte;
  String get byteStr => byte.byteFormat();
  FileType? fileType;
  List<SandBoxModel>? childrens;
  SandBoxModel({
    this.name = '',
    this.path = '',
    this.byte = 0,
    this.fileType,
    this.childrens,
  });
}
