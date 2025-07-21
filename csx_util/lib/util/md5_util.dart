import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Md5Util {
  //获取文件md5（适用大文件）
  Future<String> getFileMd5(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }
    //字节流式读取，避免大文件一次性读取oom
    final input = file.openRead();
    //分片流式计算 MD5
    final md5Digest = await md5.bind(input).first;
    return md5Digest.toString();
  }

  //获取字符串md5
  static Future<String> getStrMd5(String msg) async {
    return getUnit8ListMd5(utf8.encode(msg));
  }

  //获取md5
  static Future<String> getUnit8ListMd5(List<int> input) async {
    return md5.convert(input).toString();
  }
}
