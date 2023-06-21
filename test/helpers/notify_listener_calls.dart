import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class NotifyListenerCalls<T extends Listenable> {
  NotifyListenerCalls(this.service) {
    service.addListener(_count);
  }

  final T service;
  int callCount = 0;

  void _count() {
    callCount++;
  }

  void called(int matcher) {
    expect(
      callCount,
      equals(matcher),
      reason: 'Unexpected number of calls',
    );
  }

  void dispose() {
    service.removeListener(_count);
  }
}
