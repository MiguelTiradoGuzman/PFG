import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/test/apiMockup.dart';
import 'package:pfg_app/vistas/pantallaAjustes.dart'; // Asegúrate de importar el archivo correcto

void main() {
  // Configuración inicial de la prueba
  setUp(() {
    // Configura el controlador mock en lugar del controlador real
    MockAPI apiMockup = MockAPI();

    Controlador().api = apiMockup;
  });

  testWidgets('Confirmación de borrado de usuario muestra diálogo',
      (WidgetTester tester) async {
    // Construye la pantalla de ajustes
    await tester.pumpWidget(MaterialApp(
      home: PantallaAjustes(),
    ));

    // Toca el botón de borrar usuario
    await tester.tap(find.text('Borrar Usuario'));

    // Espera a que se complete la animación de transición
    await tester.pumpAndSettle();

    // Verifica que se muestre el diálogo de confirmación
    expect(find.text('¿Estás seguro de que deseas borrar tu cuenta?'),
        findsOneWidget);
  });

  testWidgets('Confirmación de borrado de usuario realiza la acción',
      (WidgetTester tester) async {
    // Construye la pantalla de ajustes
    await tester.pumpWidget(MaterialApp(
      home: PantallaAjustes(),
    ));

    // Toca el botón de borrar usuario
    await tester.tap(find.text('Borrar Usuario'));

    // Espera a que se complete la animación de transición
    await tester.pumpAndSettle();

    // Toca el botón de aceptar en el diálogo de confirmación
    await tester.tap(find.text('Aceptar'));

    // Espera a que se complete la animación de transición
    await tester.pumpAndSettle();
  });
}
