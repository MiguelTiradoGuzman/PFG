import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/vistas/login.dart'; // Asegúrate de importar el archivo correcto
import 'package:pfg_app/test/apiMockup.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pfg_app/src/localization/l10.dart';

import 'package:pfg_app/vistas/login.dart';
import 'package:pfg_app/src/localeProvider.dart';

void main() {
  MockAPI apiMockup = MockAPI();

  Controlador().api = apiMockup;

  void main() {
    group('LugarInteres', () {
      test('fromJson debería crear una instancia válida de LugarInteres', () {
        final json = {
          'nombre': 'Lugar de interés',
          'descripcion': 'Descripción del lugar de interés',
          'latitud': 37.7749,
          'longitud': -122.4194,
          'fotos': ['foto1.jpg', 'foto2.jpg'],
        };

        final lugar = LugarInteres.fromJson(json);

        expect(lugar.getNombre, 'Lugar de interés');
        expect(lugar.getDescripcion, 'Descripción del lugar de interés');
        expect(lugar.getLatitud, 37.7749);
        expect(lugar.getLongitud, -122.4194);
        expect(lugar.getRecursos.length, 2);
        expect(lugar.getRecursos[0], 'foto1.jpg');
        expect(lugar.getRecursos[1], 'foto2.jpg');
      });

      test(
          'toJson debería serializar correctamente la instancia de LugarInteres',
          () {
        final lugar = LugarInteres(
          nombre: 'Lugar de interés',
          descripcion: 'Descripción del lugar de interés',
          latitud: 37.7749,
          longitud: -122.4194,
          recursos: ['foto1.jpg', 'foto2.jpg'],
        );

        final json = lugar.toJson();

        expect(json['nombre'], 'Lugar de interés');
        expect(json['descripcion'], 'Descripción del lugar de interés');
        expect(json['latitud'], 37.7749);
        expect(json['longitud'], -122.4194);
        expect(json['fotos'].length, 2);
        expect(json['fotos'][0], 'foto1.jpg');
        expect(json['fotos'][1], 'foto2.jpg');
      });
    });
  }

  testWidgets('Pantalla de inicio de sesión se muestra correctamente',
      (WidgetTester tester) async {
    // Construye nuestra aplicación y desencadena una reconstrucción
    await mockNetworkImages(() async {
      await tester.pumpWidget(MaterialApp(
        home: PaginaLogin(),
        locale: const Locale('es'), // Establece el locale para la prueba
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));

      // Verifica que la pantalla se haya renderizado correctamente
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.text('Registrame'), findsOneWidget);
    });
  });

  testWidgets(
      'Iniciar Sesión con credenciales válidas muestra la pantalla siguiente',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      // Construye nuestra aplicación y desencadena una reconstrucción
      await tester.pumpWidget(const MaterialApp(
        home: PaginaLogin(),
        locale:
            const Locale('es'), // Establece el locale deseado para la prueba
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));

      // Ingresa credenciales válidas
      await tester.enterText(find.byType(TextField).first, 'user1');
      await tester.enterText(find.byType(TextField).last, 'password1');

      // Espera a que se complete la animación de transición
      await tester.pumpAndSettle();

      // Toca el botón de inicio de sesión
      await tester.tap(find.text('Iniciar Sesión'));

      // Espera a que se complete la animación de transición
      await tester.pumpAndSettle();
      // Verifica que la pantalla siguiente se haya mostrado correctamente
      expect(find.text('Rutas disponibles'), findsOneWidget);
    });
  });

  testWidgets('Intento de inicio de sesión fallido muestra un mensaje de error',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      // Construye nuestra aplicación y desencadena una reconstrucción
      await tester.pumpWidget(const MaterialApp(
        home: PaginaLogin(),
        locale:
            const Locale('es'), // Establece el locale deseado para la prueba
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));

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
