import 'package:flutter_test/flutter_test.dart';
import 'package:responsi_praktikum/main.dart';

void main() {
  testWidgets('App renders successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the initial welcome or search prompt appears
    expect(find.text('Selamat Datang!'), findsOneWidget);
  });
}
