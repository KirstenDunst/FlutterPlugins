import 'dart:collection';

abstract class IInfo {
  dynamic getValue();
}

abstract class IStorage {
  bool save(IInfo info);

  bool edit(int index, IInfo info);

  bool delete(int index);

  bool contains(IInfo info);

  List<IInfo> getAll();

  void clear();
}

abstract class IKit {
  String getKitName();

  String getIcon();

  void tabAction();
}

class CommonStorage implements IStorage {
  final int maxCount;
  Queue<IInfo> items = Queue();

  CommonStorage({this.maxCount = 100});

  @override
  List<IInfo> getAll() {
    return items.toList();
  }

  @override
  bool save(IInfo info) {
    if (items.length >= maxCount) {
      items.removeFirst();
    }
    items.add(info);
    return true;
  }

  @override
  bool contains(IInfo info) {
    return items.contains(info);
  }

  @override
  void clear() {
    return items.clear();
  }

  @override
  bool edit(int index, IInfo info) {
    List<IInfo> list = items.toList();
    list[index] = info;
    items = Queue.from(list);
    return true;
  }

  @override
  bool delete(int index) {
    List<IInfo> list = items.toList();
    list.removeAt(index);
    items = Queue.from(list);
    return true;
  }
}
