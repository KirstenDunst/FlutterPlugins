/*
 * @Author: Cao Shixin
 * @Date: 2021-02-04 15:25:31
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-07 14:13:23
 * @Description: 
 */
import 'package:date_format/date_format.dart';

class TimeUtils {
  static String toTimeString(int time) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(time),
        [HH, ":", nn, ":", ss, ".", nn]);
  }
}

class ByteUtil {
  static String toByteString(int bytes, {int toStringAsFixed = 2}) {
    if (bytes <= 1024) {
      return '${bytes}B';
    } else if (bytes <= 1024 * 1024) {
      return '${(bytes / (1024)).toStringAsFixed(toStringAsFixed)}K';
    } else if (bytes <= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(toStringAsFixed)}M';
    } else if (bytes <= 1024 * 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(toStringAsFixed)}G';
    } else {
      return '${(bytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(toStringAsFixed)}T';
    }
  }
}
