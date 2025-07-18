class DateUtil {
  //将一个日期解析为所在自然周的开始日期和结束日期
  static (DateTime startDate, DateTime endDate) parseDateToWeek(DateTime date) {
    var dateWeek = date.weekday;
    var startDate = DateTime(date.year, date.month, date.day - (dateWeek - 1));
    var endDate = DateTime(date.year, date.month, date.day + (7 - dateWeek));
    return (startDate, endDate);
  }

  //(总共几周, 当前时间在第几周)
  static (int, int?) getWeeksInMonth(int year, int month, {DateTime? nowDate}) {
    var firstDay = DateTime(year, month, 1);
    var daysInMonth = DateTime(year, month + 1, 0).day;
    var firstWeekDays = 7 - firstDay.weekday + 1;
    var remainingDays = daysInMonth - firstWeekDays;
    var fullWeeks = (remainingDays / 7).ceil();
    var allWeeks = 1 + fullWeeks;
    int? nowDateIndex;
    if (nowDate != null && nowDate.year == year && nowDate.month == month) {
      nowDateIndex =
          allWeeks -
          ((daysInMonth - (nowDate.day + (7 - nowDate.weekday))) / 7).ceil();
    }
    return (allWeeks, nowDateIndex);
  }

  //(总共几周, 当前时间在第几周)
  static (int, int?) getWeeksInMonthDay(
    int year,
    int month,
    int day, {
    DateTime? nowDate,
  }) {
    var firstDay = DateTime(year, month, 1);
    var firstWeekDays = 7 - firstDay.weekday + 1;
    var remainingDays = day - firstWeekDays;
    var fullWeeks = (remainingDays / 7).ceil();
    var allWeeks = 1 + fullWeeks;
    int? nowDateIndex;
    if (nowDate != null && nowDate.year == year && nowDate.month == month) {
      nowDateIndex =
          allWeeks - ((day - (nowDate.day + (7 - nowDate.weekday))) / 7).ceil();
    }
    return (allWeeks, nowDateIndex);
  }

  //将一个年月第几周解析成周一的日期和周末的日期
  static (DateTime startDate, DateTime endDate) parseWeekToDate(
    int year,
    int month,
    int weekNum,
  ) {
    var weekNumDay = DateTime(year, month, 1 + (weekNum - 1) * 7);
    var weekNumDayWeekDay = weekNumDay.weekday;
    var startDate = DateTime(year, month, weekNumDay.day - weekNumDayWeekDay);
    var endDate = DateTime(
      year,
      month,
      weekNumDay.day + (7 - weekNumDayWeekDay),
    );
    return (startDate, endDate);
  }
}
