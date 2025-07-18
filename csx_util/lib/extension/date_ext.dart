import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;

//中国标准时区
const _chinaTimeZone = 'Asia/Shanghai';

extension DateFormatStrExt on DateTime {
  //按照格式生成字符串
  String formatToStr(
    String format, {
    String? timezone,
    String defaulttimeZone = _chinaTimeZone,
  }) {
    //有传入时区使用传入的时区，没有的话直接用手机时区
    if (timezone != null) {
      tz.Location? tzLocation;
      try {
        tzLocation = tz.getLocation(timezone);
      } catch (e) {
        tzLocation = tz.getLocation(defaulttimeZone);
      }
      var localizedDt = tz.TZDateTime.from(this, tzLocation);
      var dateString = DateFormat(format).format(localizedDt);
      return dateString;
    } else {
      var dateString = DateFormat(format).format(this);
      return dateString;
    }
  }

  //转换为yyyy-MM-dd HH:mm:ss的字符串
  String formatToYMDHMS(DateTime dateTime) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(this);

  //转换为yyyy-MM-dd HH:mm的字符串
  String formatYMDHM() => DateFormat('yyyy-MM-dd HH:mm').format(this);

  //转换为yyy-MM-dd的字符串
  String formatYMD({String? locale}) =>
      DateFormat('yyyy-MM-dd', locale).format(this);

  //转换为yyy-MM的字符串
  String formatYM({String? locale}) =>
      DateFormat('yyyy-MM', locale).format(this);

  //转换为HH:mm:ss的字符串
  String formatHHmmss({String? locale}) =>
      DateFormat('HH:mm:ss', locale).format(this);

  //转换为HH:mm的字符串
  String formatHHmm({String? locale}) =>
      DateFormat('HH:mm', locale).format(this);

  //计算这个月的天数
  int daysOfThisMonth() {
    int nextMonthYear = year;
    int nextMonth = month + 1;
    if (nextMonth > 12) {
      nextMonth = 1;
      nextMonthYear++;
    }
    var nextDateTime = DateTime(nextMonthYear, nextMonth, 1);
    var lastDateTime = nextDateTime.subtract(const Duration(days: 1));
    return lastDateTime.day;
  }
}
