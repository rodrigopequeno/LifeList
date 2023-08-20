import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart'
    as flutter_email_sender;
import 'package:lifelist/services/email_sender_service.dart';
import 'package:mocktail/mocktail.dart';

class _FakeEmail extends Fake implements flutter_email_sender.Email {}

void main() {
  final methodCallLog = <MethodCall>[];
  late EmailSenderService emailSenderService;

  setUpAll(() {
    registerFallbackValue(_FakeEmail());
  });

  setUp(() {
    emailSenderService = EmailSenderService();
  });

  tearDown(() {
    methodCallLog.clear();
  });

  void mockFlutterEmailSender() {
    const channel = MethodChannel('flutter_email_sender');
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      return methodCallLog.add(methodCall);
    });
  }

  group('send', () {
    test('should call send with email', () async {
      mockFlutterEmailSender();
      const subject = 'subject';
      const body = 'body';
      await emailSenderService.sendEmail(
        subject: subject,
        body: body,
      );
      expect(methodCallLog, isNotEmpty);
    });
  });
}
