import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_app/vistas/pantallaRegistro.dart';

void main() {
  group('PaginaRegistro', () {
    testWidgets('Introducir todos los datos correctos',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PantallaRegistro()));

      // Ingresa datos válidos en todos los campos
      await tester.enterText(
          find.byType(TextField).at(0), 'correo_valido@ejemplo.com');
      await tester.enterText(find.byType(TextField).at(1), 'NombreUsuario');
      await tester.enterText(find.byType(TextField).at(2), '12345');
      await tester.enterText(find.byType(TextField).at(3), '12345');

      // Toca el botón de registro
      await tester.tap(find.text('Registrarme'));

      // Espera a que se complete la animación
      await tester.pumpAndSettle();

      // Verifica que no se muestre un SnackBar de error
      expect(find.text('Correo no válido!'), findsNothing);
      expect(find.text('Las contraseñas no coinciden'), findsNothing);
      expect(find.text('Contraseña demasiado corta'), findsNothing);
    });

    testWidgets('Introducir correo no válido', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PantallaRegistro()));

      // Ingresa un correo inválido en el campo de correo electrónico
      await tester.enterText(find.byType(TextField).at(0), 'correo_invalido');
      await tester.enterText(find.byType(TextField).at(1), 'NombreUsuario');
      await tester.enterText(find.byType(TextField).at(2), '12345');
      await tester.enterText(find.byType(TextField).at(3), '12345');
      // Toca el botón de registro
      await tester.tap(find.text('Registrarme'));

      // Espera a que se complete la animación
      await tester.pumpAndSettle();

      // Verifica que se muestre un SnackBar de error
      expect(find.text('Correo no válido!'), findsOneWidget);
      expect(find.text('Las contraseñas no coinciden'), findsNothing);
      expect(find.text('La contraseña debe tener al menos 5 caracteres'),
          findsNothing);
    });

    testWidgets('Introducir contraseña demasiado corta',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PantallaRegistro()));

      await tester.enterText(
          find.byType(TextField).at(0), 'correo_valido@ejemplo.com');
      await tester.enterText(find.byType(TextField).at(1), 'NombreUsuario');

      // Ingresa una contraseña demasiado corta
      await tester.enterText(find.byType(TextField).at(2), '1234');
      await tester.enterText(find.byType(TextField).at(3), '1234');

      // Toca el botón de registro
      await tester.tap(find.text('Registrarme'));

      // Espera a que se complete la animación
      await tester.pumpAndSettle();

      // Verifica que se muestre un SnackBar de error
      expect(find.text('Correo no válido!'), findsNothing);
      expect(find.text('Las contraseñas no coinciden'), findsNothing);
      expect(find.text('Contraseña demasiado corta'), findsOneWidget);
    });

    testWidgets('Introducir contraseñas que no sean iguales',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: PantallaRegistro()));

      await tester.enterText(
          find.byType(TextField).at(0), 'correo_valido@ejemplo.com');
      await tester.enterText(find.byType(TextField).at(1), 'NombreUsuario');

      // Ingresa contraseñas que no coinciden
      await tester.enterText(find.byType(TextField).at(2), 'contrasena1');
      await tester.enterText(find.byType(TextField).at(3), 'contrasena2');

      // Toca el botón de registro
      await tester.tap(find.text('Registrarme'));

      // Espera a que se complete la animación
      await tester.pumpAndSettle();

      // Verifica que se muestre un SnackBar de error
      expect(find.text('Correo no válido!'), findsNothing);
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
      expect(find.text('La contraseña debe tener al menos 5 caracteres'),
          findsNothing);
    });

    // Puedes agregar más pruebas según los casos de uso específicos que necesites cubrir
  });
}
