import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/services/notificationservice.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/timezone.dart';

class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class _MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class _FakeInitializationSettings extends Fake
    implements InitializationSettings {}

class _FakeTZDateTime extends Fake implements TZDateTime {}

class _FakeNotificationDetails extends Fake implements NotificationDetails {}

void main() {
  late NotificationService notificationService;
  late FlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;
  late AndroidFlutterLocalNotificationsPlugin
      mockAndroidFlutterLocalNotificationsPlugin;

  setUpAll(() {
    registerFallbackValue(_FakeInitializationSettings());
    registerFallbackValue(_FakeTZDateTime());
    registerFallbackValue(_FakeNotificationDetails());
    registerFallbackValue(UILocalNotificationDateInterpretation.absoluteTime);
  });

  setUp(() {
    mockFlutterLocalNotificationsPlugin =
        _MockFlutterLocalNotificationsPlugin();
    mockAndroidFlutterLocalNotificationsPlugin =
        _MockAndroidFlutterLocalNotificationsPlugin();

    when(() => mockFlutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidFlutterLocalNotificationsPlugin);

    notificationService = NotificationService();
  });

  tearDown(() {
    verify(() => mockAndroidFlutterLocalNotificationsPlugin.requestPermission())
        .called(1);

    verifyNoMoreInteractions(mockFlutterLocalNotificationsPlugin);
    verifyNoMoreInteractions(mockAndroidFlutterLocalNotificationsPlugin);
  });

  group('init', () {
    test(
      'should initialize flutterLocalNotificationsPlugin when init is called',
      () async {
        when(() =>
                mockAndroidFlutterLocalNotificationsPlugin.requestPermission())
            .thenAnswer((_) async => false);

        await notificationService.init(
          flutterLocalNotificationsPluginInstance:
              mockFlutterLocalNotificationsPlugin,
        );

        expect(notificationService.flutterLocalNotificationsPlugin, isNotNull);
        verify(() => mockFlutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()).called(1);
      },
    );

    test(
      'should request permission when init is called',
      () async {
        when(() =>
                mockAndroidFlutterLocalNotificationsPlugin.requestPermission())
            .thenAnswer((_) async => false);

        await notificationService.init(
          flutterLocalNotificationsPluginInstance:
              mockFlutterLocalNotificationsPlugin,
        );

        verify(() => mockFlutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestPermission()).called(1);
      },
    );

    test(
      'should initialize flutterLocalNotificationsPlugin when permission is granted',
      () async {
        when(() => mockFlutterLocalNotificationsPlugin.initialize(any()))
            .thenAnswer((_) async => true);
        when(() =>
                mockAndroidFlutterLocalNotificationsPlugin.requestPermission())
            .thenAnswer((_) async => true);

        await notificationService.init(
          flutterLocalNotificationsPluginInstance:
              mockFlutterLocalNotificationsPlugin,
        );

        verify(() => mockFlutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()).called(1);
        verify(() => mockFlutterLocalNotificationsPlugin.initialize(any()))
            .called(1);
      },
    );
  });
  group('scheduleNotification', () {
    setUp(() {
      when(() => mockFlutterLocalNotificationsPlugin.initialize(any()))
          .thenAnswer((_) async => true);
      when(() => mockAndroidFlutterLocalNotificationsPlugin.requestPermission())
          .thenAnswer((_) async => true);
    });

    tearDown(() {
      verify(() => mockFlutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()).called(1);
      verify(() => mockFlutterLocalNotificationsPlugin.initialize(any()))
          .called(1);
    });

    test(
      'should schedule notification when deadline is in the future',
      () async {
        final now = DateTime.now().toUtc();
        final deadline = now.add(const Duration(days: 1));
        when(
          () => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation:
                any(named: 'uiLocalNotificationDateInterpretation'),
          ),
        ).thenAnswer((_) async => true);

        await notificationService.init(
          flutterLocalNotificationsPluginInstance:
              mockFlutterLocalNotificationsPlugin,
        );

        notificationService.scheduleNotification(
          'title',
          'body',
          1,
          false,
          deadline,
        );

        verify(
          () => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'title',
            'body',
            any(),
            any(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          ),
        ).called(1);
      },
    );

    test(
      'should not schedule notification when deadline is in the past',
      () async {
        final now = DateTime.now().toUtc();
        final deadline = now.subtract(const Duration(days: 1));
        when(
          () => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            any(),
            any(),
            any(),
            any(),
            any(),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            uiLocalNotificationDateInterpretation:
                any(named: 'uiLocalNotificationDateInterpretation'),
          ),
        ).thenAnswer((_) async => true);

        await notificationService.init(
          flutterLocalNotificationsPluginInstance:
              mockFlutterLocalNotificationsPlugin,
        );

        notificationService.scheduleNotification(
          'title',
          'body',
          1,
          false,
          deadline,
        );

        verify(
          () => mockFlutterLocalNotificationsPlugin.zonedSchedule(
            1,
            'title',
            'body',
            any(),
            any(),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          ),
        ).called(1);
      },
    );
  });
}
