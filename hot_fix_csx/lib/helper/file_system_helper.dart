/*
 * @Author: Cao Shixin
 * @Date: 2021-06-29 10:27:02
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-29 14:56:29
 * @Description: 文件处理小助手
 */
import 'dart:io';

class FileSystemHelper {
  
Future<bool> isExistsWithDirectoryName(String dirName) {
    return Directory(dirName).exists();
}

}