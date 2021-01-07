/*
 * @Author: Cao Shixin
 * @Date: 2020-10-15 02:38:18
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-01-06 17:08:58
 * @Description: 
 */
import 'dart:async';

import 'package:image_compress_csx/image_compress_csx.dart';

class TryCatchExample {
  Future<List<int>> compressAndTryCatch(String path) async {
    List<int> result;
    try {
      result = await ImageCompressCsx.compressWithFile(path,
          format: CompressFormat.heic);
    } on UnsupportedError catch (e) {
      print(e.message);
      result = await ImageCompressCsx.compressWithFile(path,
          format: CompressFormat.jpeg);
    } on Error catch (e) {
      print(e.toString());
      print(e.stackTrace);
    } on Exception catch (e) {
      print(e.toString());
    }
    return result;
  }
}
