extension NullableStringExt on String? {
  bool get isNullOrEmpty => this?.isEmpty ?? true;
  bool get isNotNullOrEmpty => this?.isNotEmpty ?? false;
}

extension StringExt on String {
  bool isChinese() {
    return RegExp('[\u4e00-\u9fa5]').hasMatch(this);
  }

  /// 文字长度小于[targetLength]时，用[fillBy]填充首部，[fillBy]只能是长度为1的字符串；
  /// 文字长度大于[targetLength]时，不做处理
  String fillLength(int targetLength, {String fillBy = '0'}) {
    if (length > targetLength) return this;
    var result = '';
    for (var i = 0; i < targetLength - length; i++) {
      result += fillBy;
    }
    result += this;
    return result;
  }
}
