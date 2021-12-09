/*
 * @Author: Cao Shixin
 * @Date: 2021-02-09 13:40:36
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-02-09 13:40:47
 * @Description: 
 */
import 'package:date_format/date_format.dart';

class TimeUtils {
  static String toTimeString(int time) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(time),
        [HH, ":", nn, ":", ss, ".", nn]);
  }
}
