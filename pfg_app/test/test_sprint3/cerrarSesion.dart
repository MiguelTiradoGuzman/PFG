import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_app/vistas/elementos/menuLateral.dart';
import 'package:pfg_app/vistas/pantallaRegistro.dart';
import 'package:pfg_app/vistas/login.dart';

void main() {
  group('MenuLateral', () {
    testWidgets('Cerrar sesión muestra diálogo de confirmación',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: MenuLateral(
        body: PantallaRegistro(),
        titulo: '',
      )));

      // Toca el botón de cerrar sesión
      await tester.tap(find.text('Cerrar Sesión'));

      // Espera a que se complete la animación de transición
      await tester.pumpAndSettle();

      // Verifica que se muestre el diálogo de confirmación
      expect(find.text('¿Estás seguro de que deseas cerrar sesión?'),
          findsOneWidget);
    });

    testWidgets('Cerrar sesión muestra diálogo de confirmación',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: MenuLateral(
        body: PantallaRegistro(),
        titulo: '',
      )));

      // Toca el botón de cerrar sesión
      await tester.tap(find.text('Cerrar Sesión'));

      // Espera a que se complete la animación de transición
      await tester.pumpAndSettle();

      // Toca el botón de aceptar en el diálogo de confirmación
      await tester.tap(find.text('Aceptar'));

      // Espera a que se complete la animación de transición
      await tester.pumpAndSettle();

      // Verifica que se haya redirigido a la página de inicio de sesión
      expect(find.byType(PaginaLogin), findsOneWidget);
    });
  });
}
