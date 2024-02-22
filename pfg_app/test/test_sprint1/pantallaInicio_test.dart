import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:pfg_app/vistas/pantallaInicio.dart';
import 'package:pfg_app/test/test_const.dart';
import 'package:pfg_app/vistas/elementos/tarjetaRuta.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/usuario.dart';

void main() {
  testWidgets('PantallaInicio muestra las tarjetas de rutas correctamente',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      // Construye nuestra aplicación y desencadena una renderización.
      await tester.pumpWidget(
        MaterialApp(
          home: PantallaInicio(
            rutas: [
              ClaseTest().ruta,
            ],
          ),
        ),
      );

      // Verifica que se muestre correctamente la pantalla de inicio.
      expect(find.text('Rutas disponibles'), findsOneWidget);

      // Verifica que se muestren las tarjetas de ruta en la lista.
      expect(find.byType(TarjetaRuta), findsOneWidget);

      // Realiza más verificaciones según sea necesario.
    });
  });

  // Agrega más pruebas según sea necesario.
}
