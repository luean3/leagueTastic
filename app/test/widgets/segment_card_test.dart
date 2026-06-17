import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Passe den Import an deinen Projektpfad an
import 'package:leaguetastic/widgets/segment_card.dart';

void main() {
  Widget createTestWidget({
    required Map<String, dynamic> segment,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SegmentCard(
          segment: segment,
          activeLabel: 'Aktiv',
          finishedLabel: 'Abgeschlossen',
          upcomingLabel: 'Bevorstehend',
          onTap: onTap,
        ),
      ),
    );
  }

  testWidgets('zeigt Segmentname und aktive Statusanzeige an', (tester) async {
    final segment = {
      'name': 'Balmberg Segment',
      'isActive': true,
      'isPast': false,
      'isUpcoming': false,
      'weekIndex': 0,
    };

    await tester.pumpWidget(createTestWidget(segment: segment));

    expect(find.text('Balmberg Segment'), findsOneWidget);
    expect(find.text('Aktiv'), findsOneWidget);
    expect(find.text('W1'), findsOneWidget);
  });

  testWidgets('zeigt abgeschlossenen Status an', (tester) async {
    final segment = {
      'name': 'Weissenstein Segment',
      'isActive': false,
      'isPast': true,
      'isUpcoming': false,
      'weekIndex': 1,
    };

    await tester.pumpWidget(createTestWidget(segment: segment));

    expect(find.text('Weissenstein Segment'), findsOneWidget);
    expect(find.text('Abgeschlossen'), findsOneWidget);
    expect(find.text('W2'), findsOneWidget);
  });

  testWidgets('zeigt bevorstehenden Status an', (tester) async {
    final segment = {
      'name': 'Grenchenberg Segment',
      'isActive': false,
      'isPast': false,
      'isUpcoming': true,
      'weekIndex': 2,
    };

    await tester.pumpWidget(createTestWidget(segment: segment));

    expect(find.text('Grenchenberg Segment'), findsOneWidget);
    expect(find.text('Bevorstehend'), findsOneWidget);
    expect(find.text('W3'), findsOneWidget);
  });

  testWidgets('führt onTap aus, wenn auf die Card geklickt wird', (tester) async {
    var tapped = false;

    final segment = {
      'name': 'Test Segment',
      'isActive': true,
      'isPast': false,
      'isUpcoming': false,
      'weekIndex': 0,
    };

    await tester.pumpWidget(
      createTestWidget(
        segment: segment,
        onTap: () {
          tapped = true;
        },
      ),
    );

    await tester.tap(find.byType(ListTile));
    await tester.pump();

    expect(tapped, true);
  });
}