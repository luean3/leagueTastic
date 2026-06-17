import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaguetastic/widgets/app_header.dart';

void main() {
  testWidgets('renders the shared app header', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppHeader(title: 'LeagueTastic')),
      ),
    );

    expect(find.text('LeagueTastic'), findsOneWidget);
  });
}
