/*
 * @Author: Cao Shixin
 * @Date: 2021-02-25 15:29:26
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-19 14:56:05
 * @Description: 
 * @Email: cao_shixin@yahoo.com
 * @Company: BrainCo
 */

//转换时间的枚举类型，有需要再添加再扩展。

enum TimeFormatType {
  //只有时分，没有小时，分钟数可以大于60
  onlyMSChinese,
  //简单的时分秒，不会自动补零，
  simHMSChinese,
}

/// 数字工具方法
extension NumExtension on num {
  /* byte转对应字符串显示
   * bytes:最小单位的数量
   * toStringAsFixed:转化过程中的小数保留位数，默认2位小数。
   */
  String byteFormat({int toStringAsFixed = 2}) {
    var result = this;
    if (result < 1024) {
      return '${result.toStringAsFixed(0)}B';
    } else {
      result = result / 1024;
    }
    if (result < 1024) {
      return '${result.toStringAsFixed(toStringAsFixed)}K';
    } else {
      result = result / 1024;
    }
    if (result < 1024) {
      return '${result.toStringAsFixed(toStringAsFixed)}M';
    } else {
      result = result / 1024;
    }
    if (result < 1024) {
      return '${result.toStringAsFixed(toStringAsFixed)}G';
    } else {
      result = result / 1024;
    }
    return '${result.toStringAsFixed(toStringAsFixed)}T';
  }

  /*
   * 时间转化，将秒为单位的数字转化为多少分多少秒，
   */
  String timeFormat({TimeFormatType type = TimeFormatType.onlyMSChinese}) {
    switch (type) {
      case TimeFormatType.onlyMSChinese:
        {
          var timeInMinutes = this ~/ 60;
          var lasSeconds = this % 60;
          return '$timeInMinutes分$lasSeconds秒';
        }
      case TimeFormatType.simHMSChinese:
        {
          var tempStr = '';
          var timeInMinutes = this ~/ 60;
          var lasSeconds = this % 60;
          if (timeInMinutes > 59) {
            var hours = timeInMinutes ~/ 60;
            tempStr = '$hours时$timeInMinutes分$lasSeconds秒';
          } else {
            tempStr = '$timeInMinutes分$lasSeconds秒';
          }
          return tempStr;
        }
      default:
        return '';
    }
  }
}
