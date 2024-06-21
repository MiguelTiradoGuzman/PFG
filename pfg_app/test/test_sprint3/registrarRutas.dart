import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_app/vistas/aniadirModificarRuta.dart'; // Importa el widget que quieres probar

void main() {
  group('AniadirModificarRuta Widget Tests', () {
    testWidgets('Botón para añadir lugar visible', (WidgetTester tester) async {
      // Construye la pantalla AniadirModificarRuta
      await tester.pumpWidget(MaterialApp(home: AniadirModificarRuta()));

      // Verifica que el botón para añadir lugar esté visible
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Pantalla de añadir lugar se abre al tocar el botón',
        (WidgetTester tester) async {
      // Construye la pantalla AniadirModificarRuta
      await tester.pumpWidget(MaterialApp(home: AniadirModificarRuta()));

      // Toca el botón para añadir lugar
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verifica que se abra la pantalla de añadir lugar
      expect(find.text('Añadir Lugar de Interés'), findsOneWidget);
    });

    testWidgets('Lugar añadido se muestra en la lista',
        (WidgetTester tester) async {
      // Construye la pantalla AniadirModificarRuta
      await tester.pumpWidget(MaterialApp(home: AniadirModificarRuta()));

      // Toca el botón para añadir lugar
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Ingresa información y guarda el lugar
      await tester.enterText(find.byType(TextField), 'Nombre del lugar');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Verifica que el lugar añadido se muestre en la lista
      expect(find.text('Nombre del lugar'), findsOneWidget);
    });

    testWidgets('Lugar se elimina de la lista al pulsar el botón eliminar',
        (WidgetTester tester) async {
      // Construye la pantalla AniadirModificarRuta
      await tester.pumpWidget(MaterialApp(home: AniadirModificarRuta()));

      // Toca el botón para añadir lugar
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Ingresa información y guarda el lugar
      await tester.enterText(find.byType(TextField), 'Nombre del lugar');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Toca el botón para eliminar el lugar
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verifica que el lugar se elimine de la lista
      expect(find.text('Nombre del lugar'), findsNothing);
    });
  });
}
