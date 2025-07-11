// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sushi_neska/main.dart';

void main() {
  testWidgets('Splash screen shows app title', (WidgetTester tester) async {
    await tester.pumpWidget(const SushiApp());

    // Verifikasi teks splash screen
    expect(find.text('Aneska Sushi'), findsOneWidget);

    // Menunggu splash screen selesai (2 detik)
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verifikasi halaman menu tampil
    expect(find.text('Our Menu'), findsOneWidget);
  });
}

