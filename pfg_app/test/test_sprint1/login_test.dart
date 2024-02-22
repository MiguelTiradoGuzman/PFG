import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/vistas/login.dart'; // Asegúrate de importar el archivo correcto
import 'package:pfg_app/test/apiMockup.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  MockAPI apiMockup = MockAPI();

  Controlador().api = apiMockup;

  testWidgets('Pantalla de inicio de sesión se muestra correctamente',
      (WidgetTester tester) async {
    // Construye nuestra aplicación y desencadena una reconstrucción
    await mockNetworkImages(() async {
      await tester.pumpWidget(const MaterialApp(home: PaginaLogin()));

      // Verifica que la pantalla se haya renderizado correctamente
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Registrar'), findsOneWidget);
    });
  });

  testWidgets(
      'Iniciar Sesión con credenciales válidas muestra la pantalla siguiente',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      // Construye nuestra aplicación y desencadena una reconstrucción
      await tester.pumpWidget(const MaterialApp(home: PaginaLogin()));

      // Ingresa credenciales válidas
      await tester.enterText(find.byType(TextField).first, 'user1');
      await tester.enterText(find.byType(TextField).last, 'password1');

      // Espera a que se complete la animación de transición
      await tester.pumpAndSettle();

      // Toca el botón de inicio de sesión
      await tester.tap(find.text('Iniciar Sesión'));

      // Espera a que se complete la animación de transición
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Verifica que la pantalla siguiente se haya mostrado correctamente
      expect(find.text('Rutas disponibles'), findsOneWidget);
    });
  });

  testWidgets('Intento de inicio de sesión fallido muestra un mensaje de error',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      // Construye nuestra aplicación y desencadena una reconstrucción
      await tester.pumpWidget(const MaterialApp(home: PaginaLogin()));

      // Ingresa credenciales inválidas y toca el botón de inicio de sesión
      await tester.enterText(
          find.byType(TextField).first, 'usuario@dominio.com');
      await tester.enterText(
          find.byType(TextField).last, 'contrasena_incorrecta');
      await tester.tap(find.text('Iniciar Sesión'));

      // Espera a que se complete la animación de transición
      await tester.pumpAndSettle();

      // Verifica que se muestre el mensaje de error
      expect(find.text('Inicio de sesión fallido. Verifica tus credenciales.'),
          findsOneWidget);
    });
  });
}
