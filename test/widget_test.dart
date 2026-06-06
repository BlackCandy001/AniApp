import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aniapp/main.dart';

void main() {
  testWidgets('App renders correctly and shows main structure', (WidgetTester tester) async {
    // Build our app under a ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify if it displays the main App structure
    expect(find.byType(MyApp), findsOneWidget);
  });
}
