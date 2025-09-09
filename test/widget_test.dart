// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:thinkeasy_mini/app.dart';
import 'package:thinkeasy_mini/core/di/injector.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    // Setup dependency injection for tests with mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    await setupDI();
  });

  tearDownAll(() {
    // Clean up GetIt
    GetIt.instance.reset();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that our app builds without errors.
    expect(find.byType(App), findsOneWidget);
  });
}
