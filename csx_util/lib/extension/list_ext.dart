import 'dart:math';

extension ListExt<T> on List<T> {
  ///将一维数组拆分成大小为[len]的二维数组
  /// [1,2,3,4,5,6] len=3 => [[1,2,3],[4,5,6]]
  List<List<T>> splitByLength(int len) {
    assert(len > 0, '拆分长度$len要大于0');
    var result = <List<T>>[];
    var index = 1;
    while (true) {
      if (index * len < length) {
        var temp = skip((index - 1) * len).take(len).toList();
        result.add(temp);
        index++;
        continue;
      }
      var temp = skip((index - 1) * len).toList();
      result.add(temp);
      break;
    }
    return result;
  }

  ///随机返回列表中元素，如果列表为空抛出异常
  T random() {
    if (isEmpty) throw 'Collection is empty.';
    return elementAt(Random().nextInt(length));
  }
}

extension NumListExt<T extends num> on List<T> {
  ///计算平均值
  num avg() {
    if (isEmpty) return 0;
    return sum() / length;
  }

  ///求和
  num sum() {
    if (isEmpty) return 0;
    return reduce((a, b) => (a + b) as T);
  }
}

extension IterableExt<E> on Iterable<E> {
  /// Returns the first element that satisfies the given predicate [test].
  E? firstWhereNullable(bool Function(E element) test, {E Function()? orElse}) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return orElse == null ? null : orElse();
  }
}
