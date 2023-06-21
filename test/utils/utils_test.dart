import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/utils/utils.dart';

void main() {
  group(
    'daysBetween',
    () {
      test(
        'should return 0 when the dates are the same',
        () {
          final date1 = DateTime.utc(2023, 1, 1);
          final date2 = DateTime.utc(2023, 1, 1);
          final result = daysBetween(date1, date2);
          expect(result, equals(0));
        },
      );

      test(
        'should return 1 when the dates are 1 day apart',
        () {
          final date1 = DateTime.utc(2023, 1, 1);
          final date2 = DateTime.utc(2023, 1, 2);
          final result = daysBetween(date1, date2);
          expect(result, equals(1));
        },
      );

      test(
        'should return negative 1 when the dates are 1 day apart',
        () {
          final date1 = DateTime.utc(2023, 1, 2);
          final date2 = DateTime.utc(2023, 1, 1);
          final result = daysBetween(date1, date2);
          expect(result, equals(-1));
        },
      );

      test('should return 1 when the times difference is less than 24 hours',
          () {
        final date1 = DateTime.utc(2023, 1, 1, 23);
        final date2 = DateTime.utc(2023, 1, 2, 1);
        final result = daysBetween(date1, date2);
        expect(result, equals(1));
      });
    },
  );

  group(
    'getNotificationScheduleTime',
    () {
      test(
        'should return a time 1 hour before the deadline when the task is not completed',
        () {
          final deadline = DateTime.utc(2023, 1, 1);
          const isCompleted = false;
          const duration = Duration(hours: 1);
          final result = getNotificationScheduleTime(deadline, isCompleted);
          expect(deadline.difference(result), equals(duration));
        },
      );

      test(
        'should return a time 23 hours before the deadline when the task is completed',
        () {
          final deadline = DateTime.utc(2023, 1, 1);
          const isCompleted = true;
          const duration = Duration(hours: 23);
          final result = getNotificationScheduleTime(deadline, isCompleted);
          expect(result.difference(deadline), equals(duration));
        },
      );
    },
  );
}
