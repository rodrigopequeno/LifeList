import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/models/task.dart';

void main() {
  test('instance of Task', () {
    final task = Task();
    expect(task, isA<Task>());
  });
}
