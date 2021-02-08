/*
 * @Author: Cao Shixin
 * @Date: 2021-02-07 16:06:28
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 16:10:08
 * @Description: 
 */

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
  FileType fileType;
  List<SandBoxModel> childrens;
  SandBoxModel({this.name = '', this.path = '', this.fileType});
}
