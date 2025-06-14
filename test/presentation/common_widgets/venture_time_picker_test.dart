import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venturelink/presentation/common_widgets/venture_time_picker.dart';

void main() {
  group('VentureTimePicker', () {
    testWidgets('renders correctly with default values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: VentureTimePicker(),
          ),
        ),
      );

      expect(find.byType(VentureTimePicker), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('shows clear button when time is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: VentureTimePicker(
              selectedTime: TimeOfDay(hour: 14, minute: 30),
              showClearButton: true,
            ),
          ),
        ),
      );

      expect(find.byType(VentureTimePicker), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('calls onTimeSelected when clear button is pressed',
        (WidgetTester tester) async {
      TimeOfDay? selectedTime = const TimeOfDay(hour: 14, minute: 30);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: Scaffold(
            body: VentureTimePicker(
              selectedTime: selectedTime,
              showClearButton: true,
              onTimeSelected: (time) {
                selectedTime = time;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(selectedTime, isNull);
    });

    testWidgets('shows time picker dialog when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: VentureTimePicker(),
          ),
        ),
      );

      await tester.tap(find.byType(VentureTimePicker));
      await tester.pumpAndSettle();

      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('does not show time picker dialog when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: VentureTimePicker(
              enabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VentureTimePicker));
      await tester.pumpAndSettle();

      expect(find.byType(TimePickerDialog), findsNothing);
    });

    testWidgets('does not show time picker dialog when readOnly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
          ),
          home: const Scaffold(
            body: VentureTimePicker(
              readOnly: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VentureTimePicker));
      await tester.pumpAndSettle();

      expect(find.byType(TimePickerDialog), findsNothing);
    });
  });
}
