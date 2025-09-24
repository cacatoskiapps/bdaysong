// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:happybday_song_app/app.dart';

void main() {
  testWidgets('Name input and play button are visible', (tester) async {
    await tester.pumpWidget(const HappyBdaySongApp());

    // Intro akışını geçerek ana ekrana ulaş.
    await tester.tap(find.text('Geç'));
    await tester.pumpAndSettle();

    expect(find.text('Kimin için çalıyoruz?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Şarkıyı Çal'), findsOneWidget);
  });
}
