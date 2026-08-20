// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:msb_store/main.dart'; // Ensure this import is correct

void main() {
  test('MSB Store app widget is available', () {
    expect(MSBStoreApp(), isA<MSBStoreApp>());
  });
}
