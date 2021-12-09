/*
 * @Author: Cao Shixin
 * @Date: 2021-02-08 14:07:47
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-08 15:10:52
 * @Description: 
 */
class UserDefaultModel {
  //是都属于flutter存储的
  bool isFlutter;
  // 键
  String key;
  // 值
  dynamic value;

  UserDefaultModel({this.key = '', this.value, this.isFlutter = false});
}
