/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 11:19:53
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-11 10:24:34
 * @Description: 资源配置
 */
class ResourceModel {
  //基准压缩包的本地路径地址
  String baseZipPath;
  //解压之后的文件夹名称,不设置表示直接解压在下面，没有中间文件夹的名称
  String? zipFileName;

  ResourceModel({
    required this.baseZipPath,
    this.zipFileName,
  });
}
