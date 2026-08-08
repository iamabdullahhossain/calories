// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:calories/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoodNutritionApp());

    // Verify that app bar title exists.
    expect(find.text('Gemini Food Scanner 🥗'), findsOneWidget);
  });
}
