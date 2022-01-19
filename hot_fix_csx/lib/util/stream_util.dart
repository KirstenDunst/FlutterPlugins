/*
 * @Author: Cao Shixin
 * @Date: 2021-06-28 10:51:39
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2021-06-28 10:51:40
 * @Description: 
 */
import 'dart:async';

extension StreamRepeatLatestExtension<T> on Stream<T> {
  /// 该 Stream 每次被listen时都会emit 最近的值
  Stream<T> repeatLatest() {
    var done = false;
    T? latest;
    var currentListeners = <MultiStreamController<T>>{};
    listen((event) {
      latest = event;
      for (var listener in [...currentListeners]) {
        listener.addSync(event);
      }
    }, onError: (Object error, StackTrace stack) {
      for (var listener in [...currentListeners]) {
        listener.addErrorSync(error, stack);
      }
    }, onDone: () {
      done = true;
      latest = null;
      final listens = List.from(currentListeners);
      listens.forEach((element) {
        element.closeSync();
      });
      currentListeners.clear();
    });
    return Stream.multi((controller) {
      if (done) {
        controller.close();
        return;
      }
      currentListeners.add(controller);
      var latestValue = latest;
      if (latestValue != null) controller.add(latestValue);
      controller.onCancel = () {
        currentListeners.remove(controller);
      };
    });
  }
}
