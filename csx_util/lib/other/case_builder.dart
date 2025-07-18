class _Condition<T> {
  final bool Function() condition;
  final T Function() value;
  _Condition({required this.condition, required this.value});
}

class CaseBuilder<T> {
  final List<_Condition<T>> _conditions = [];

  CaseBuilder.on(bool Function() condition, T Function() value) {
    _conditions.add(_Condition(condition: condition, value: value));
  }

  CaseBuilder<T> on(bool Function() condition, T Function() value) {
    _conditions.add(_Condition(condition: condition, value: value));
    return this;
  }

  T build({T Function()? orElse}) {
    assert(
      _conditions.isNotEmpty,
      "CaseBuilder: you must provide at least one condition.",
    );
    for (final condition in _conditions) {
      if (condition.condition()) {
        return condition.value();
      }
    }
    if (orElse != null) {
      return orElse();
    }
    throw StateError(
      "CaseBuilder: No condition was met and no orElse value was provided.",
    );
  }
}
