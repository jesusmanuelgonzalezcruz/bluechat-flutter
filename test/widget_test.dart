import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluechat1/main.dart';

void main() {
  testWidgets('La app BlueChat carga correctamente', (WidgetTester tester) async {
    // Construye la app
    await tester.pumpWidget(const MyApp());

    // Verifica que el título principal esté visible
    expect(find.text('BlueChat Pro'), findsOneWidget);

    // Verifica que las pestañas "Dispositivos" y "Chat" existan
    expect(find.text('Dispositivos'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
  });
}