import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/test/test_const.dart';
import 'package:pfg_app/vistas/elementos/lugaresPasoTree.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/vistas/pantallaRuta.dart';

void main() {
  testWidgets('PantallaRuta muestra correctamente',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      // Crear una RutaTuristica de prueba
      RutaTuristica rutaPrueba = ClaseTest().ruta;

      // Construir nuestra pantalla y agregarla al widget tester
      await tester.pumpWidget(MaterialApp(
        home: PantallaRuta(ruta: rutaPrueba),
      ));

      // Verificar que la imagen de la ruta se muestra correctamente
      expect(find.byType(Image), findsOneWidget);

      // Verificar que la lista de lugares se muestra correctamente
      expect(find.byType(ListaLugares), findsOneWidget);

      // Verificar que los íconos de reloj y distancia se muestran
      expect(find.byType(SvgPicture), findsNWidgets(2));

      // Verificar que la descripción se muestra
      expect(find.text('Descripción'), findsOneWidget);

      // Verificar que los botones "Más Información" e "Iniciar" se muestran
      expect(find.text('Más Información'), findsOneWidget);
      expect(find.text('Iniciar'), findsOneWidget);

      // Realizar acciones, por ejemplo, tocar el botón "Iniciar"
      await tester.tap(find.text('Iniciar'));
      await tester.pump();
    });
  });
}
