/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 11:17:09
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-29 11:25:48
 * @Description: 
 */
import 'package:hot_fix_csx/model/resource_model.dart';

class ResourceHelper {
  factory ResourceHelper() => _getInstance();
  static ResourceHelper get instance => _getInstance();
  static ResourceHelper? _instance;
  static ResourceHelper _getInstance() {
    return _instance ??= ResourceHelper._internal();
  }

  late ResourceModel _model;
  ResourceHelper._internal() {
    _model = ResourceModel();
  }
  set changeResourceModel(ResourceModel model) => _model = model;
  /*
   * 获取项目基准资源包名称
   */
  String getBaseZipName() {
    return _model.baseZipName;
  }
}
