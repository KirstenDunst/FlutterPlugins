/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 11:19:53
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-22 18:15:59
 * @Description: 资源配置
 */
class HotFixModel {
  //基准压缩包的本地路径地址
  String baseZipPath;
  //解压前文件夹的名称,
  String unzipDirName;

  HotFixModel({
    required this.baseZipPath,
    required this.unzipDirName,
  });
}
