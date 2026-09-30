import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mhaje_assignment/main.dart';

void main() {
  testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
    //builds the app with ProviderScope and triggers a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    //verifies that the app title is displayed
    expect(find.text('Mindful Calories'), findsOneWidget);

    //verifys that the scan button is displayed
    expect(find.widgetWithIcon(FilledButton, Icons.barcode_reader), findsOneWidget);

    //verifies that the search bar is displayed
    expect(find.byType(TextField), findsOneWidget);

    //verifies that recent products section is not initially visible (no recent products)
    expect(find.text('Recent Products'), findsNothing);
  });

  testWidgets('Search functionality works', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    //finds the search field and enters text
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'test product');

    //verifies the search field has the entered text
    expect(find.text('test product'), findsOneWidget);
  });

  testWidgets('Barcode scanner button triggers scan', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    //finds and taps the scan button
    final scanButton = find.widgetWithIcon(FilledButton, Icons.barcode_reader);
    await tester.tap(scanButton);
    await tester.pump(); // build after state changes

    //verifies that the app is still responsive after scan attempt
    expect(find.text('Mindful Calories'), findsOneWidget);
  });
}