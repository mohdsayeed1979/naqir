// Minimal smoke test kept green while the app is under active development.
// The full suite (repository unit tests, notifier tests, more widget tests,
// and an integration_test happy path) is tracked as its own milestone — see
// PROJECT_PROGRESS.md.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';

void main() {
  testWidgets('PrimaryButton shows its label and reports taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('PrimaryButton hides its label while loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            label: 'Continue',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
