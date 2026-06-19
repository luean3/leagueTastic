import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaguetastic/models/challenge_state.dart';
import 'package:leaguetastic/widgets/segment_card.dart';

void main() {
  Widget createTestWidget({
    required ChallengeSegment segment,
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

  ChallengeSegment createSegment({
    required String name,
    required int weekIndex,
    bool isActive = false,
    bool isPast = false,
    bool isUpcoming = false,
  }) {
    return ChallengeSegment(
      id: '$weekIndex',
      name: name,
      polyline: '',
      weekIndex: weekIndex,
      isActive: isActive,
      isPast: isPast,
      isUpcoming: isUpcoming,
    );
  }

  testWidgets('zeigt Segmentname und aktive Statusanzeige an', (tester) async {
    final segment = createSegment(
      name: 'Balmberg Segment',
      weekIndex: 0,
      isActive: true,
    );

    await tester.pumpWidget(createTestWidget(segment: segment));

    expect(find.text('Balmberg Segment'), findsOneWidget);
    expect(find.text('Aktiv'), findsOneWidget);
    expect(find.text('W1'), findsOneWidget);
  });

  testWidgets('zeigt abgeschlossenen Status an', (tester) async {
    final segment = createSegment(
      name: 'Weissenstein Segment',
      weekIndex: 1,
      isPast: true,
    );

    await tester.pumpWidget(createTestWidget(segment: segment));

    expect(find.text('Weissenstein Segment'), findsOneWidget);
    expect(find.text('Abgeschlossen'), findsOneWidget);
    expect(find.text('W2'), findsOneWidget);
  });

  testWidgets('zeigt bevorstehenden Status an', (tester) async {
    final segment = createSegment(
      name: 'Grenchenberg Segment',
      weekIndex: 2,
      isUpcoming: true,
    );

    await tester.pumpWidget(createTestWidget(segment: segment));

    expect(find.text('Grenchenberg Segment'), findsOneWidget);
    expect(find.text('Bevorstehend'), findsOneWidget);
    expect(find.text('W3'), findsOneWidget);
  });

  testWidgets('führt onTap aus, wenn auf die Card geklickt wird', (
    tester,
  ) async {
    var tapped = false;

    final segment = createSegment(
      name: 'Test Segment',
      weekIndex: 0,
      isActive: true,
    );

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
