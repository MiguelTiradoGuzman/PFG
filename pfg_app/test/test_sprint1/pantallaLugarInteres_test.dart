import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/vistas/pantallaLugarInteres.dart';
import 'package:pfg_app/test/test_const.dart';

void main() {
  testWidgets('PantallaLugarInteres muestra correctamente',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      // Crear un LugarInteres de prueba
      LugarInteres lugar = ClaseTest().lugares.elementAt(0);

      // Construir nuestra pantalla y agregarla al widget tester
      await tester.pumpWidget(MaterialApp(
        home: PantallaLugarInteres(lugar: lugar),
      ));

      // Verificar que el nombre del lugar se muestra correctamente
      expect(find.text(lugar.getNombre), findsOneWidget);

      // Verificar que las imágenes se muestran correctamente
      expect(find.byType(Image), findsOneWidget);

      // Verificar que el botón de volver a la ruta está presente
      expect(find.text('Volver a la Ruta'), findsOneWidget);

      // Realizar una acción, por ejemplo, tocar el botón de volver a la ruta
      await tester.tap(find.text('Volver a la Ruta'));

      // Asegurarse de que la acción tenga efecto (en este caso, que la pantalla se cierre)
      await tester.pump();
    });
  });
}
