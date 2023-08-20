import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:lifelist/constants/consts.dart';

class EmailSenderService {
  EmailSenderService();

  Future<void> sendEmail({
    required String subject,
    required String body,
  }) async {
    final email = Email(
      subject: subject,
      body: body,
      recipients: [FEEDBACK_EMAIL],
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }
}
