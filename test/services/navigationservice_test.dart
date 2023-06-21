import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelist/constants/consts.dart';
import 'package:mockingjay/mockingjay.dart';

void main() {
  late MockNavigator navigator;

  setUp(() {
    navigator = MockNavigator();
    when(() => navigator.pushNamed(any())).thenAnswer((_) async {
      return;
    });
    when(() => navigator.pushNamedAndRemoveUntil(any(), any()))
        .thenAnswer((_) async {
      return;
    });
    when(() => navigator.pop()).thenAnswer((_) async {
      return;
    });
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MockNavigatorProvider(
          navigator: navigator,
          child: Builder(builder: (context) {
            return Column(
              children: [
                TextButton(
                  onPressed: () => navigationService.navigateNext(
                    context,
                    'navigateNext',
                  ),
                  child: const Text('Next'),
                ),
                TextButton(
                  onPressed: () => navigationService.navigateReset(
                    context,
                    'navigateReset',
                  ),
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () => navigationService.navigatePop(
                    context,
                  ),
                  child: const Text('Pop'),
                ),
              ],
            );
          }),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'should navigate to next screen',
    (tester) async {
      await pumpPage(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Next'));

      verify(
        () => navigator.pushNamed('navigateNext'),
      ).called(1);
    },
  );

  testWidgets(
    'should reset all screen and navigate to next screen',
    (tester) async {
      await pumpPage(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Reset'));

      verify(() => navigator.pushNamedAndRemoveUntil('navigateReset', any()))
          .called(1);
    },
  );

  testWidgets(
    'should pop current screen',
    (tester) async {
      await pumpPage(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Pop'));

      verify(
        () => navigator.pop(),
      ).called(1);
    },
  );
}
