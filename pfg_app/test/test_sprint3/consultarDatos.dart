import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_app/vistas/miCuenta.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:pfg_app/controlador/controlador.dart';

void main() {
  testWidgets('Información del usuario se muestra correctamente',
      (WidgetTester tester) async {
    // Creamos un usuario de ejemplo
    Usuario usuario = Usuario(
      nombreUsuario: 'usuarioEjemplo',
      correo: 'usuario@example.com',
      // Puedes agregar más información aquí según la estructura de tu modelo de usuario
    );
    Controlador().usuario = usuario;
    // Construimos la pantalla MiCuenta con el usuario de ejemplo
    await tester.pumpWidget(MaterialApp(
      home: MiCuenta(),
    ));

    // Verificamos que la información del usuario se muestre correctamente
    expect(find.text('usuarioEjemplo'),
        findsOneWidget); // Verifica que el nombre de usuario esté presente
    expect(find.text('usuario@example.com'),
        findsOneWidget); // Verifica que el correo electrónico esté presente
    // Puedes agregar más expectativas para verificar otras partes de la información del usuario si es necesario
  });
}
