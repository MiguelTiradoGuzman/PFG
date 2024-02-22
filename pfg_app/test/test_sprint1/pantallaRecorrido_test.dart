import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/test/test_const.dart';
import 'package:pfg_app/vistas/elementos/mapaRuta.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/vistas/pantallaRecorrido.dart';

void main() {
  testWidgets('PantallaRecorrido muestra correctamente',
      (WidgetTester tester) async {
    // Crear una RutaTuristica de prueba
    RutaTuristica rutaPrueba = ClaseTest().ruta;

    // Construir nuestra pantalla y agregarla al widget tester
    await tester.pumpWidget(MaterialApp(
      home: PantallaRecorrido(ruta: rutaPrueba),
    ));

    // Verificar que el mensaje "Dirígete hacia..." se muestra correctamente
    expect(
        find.text(
            'Dirígete hacia ${rutaPrueba.lugares.elementAt(0).getNombre}'),
        findsOneWidget);

    // Verificar que el MapaRuta se muestra
    expect(find.byType(MapaRuta), findsOneWidget);

    // Verificar que los botones Anterior/Siguiente Lugar se muestran
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

    // Realizar acciones, por ejemplo, tocar el botón Siguiente Lugar
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();
  });
}
