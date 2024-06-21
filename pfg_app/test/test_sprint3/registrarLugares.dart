import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pfg_app/vistas/aniadirModificarLugar.dart'; // Importa el widget que quieres probar
import 'package:pfg_app/test/test_const.dart';

void main() {
  group('AniadirModificarLugar Widget Tests', () {
    testWidgets('Prueba de construcción del widget',
        (WidgetTester tester) async {
      // Crea un widget raíz que contendrá el widget AniadirModificarLugar
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              // Usa un Builder para obtener un BuildContext válido
              return AniadirModificarLugar(
                  context, null, ClaseTest().ruta, null);
            },
          ),
        ),
      );

      // Bomba de widgets una vez para construir los widgets
      await tester.pump();

      // Verifica que el widget AniadirModificarLugar se haya construido correctamente
      expect(find.byType(AniadirModificarLugar), findsOneWidget);

      // Verifica que el campo de texto para nombre del lugar esté visible
      expect(find.byType(TextField), findsOneWidget);

      // Verifica que se muestre la imagen por defecto cuando no hay imágenes añadidas
      expect(find.byIcon(Icons.add_a_photo), findsOneWidget);

      // Verifica que el botón para añadir imagen esté visible
      expect(find.byIcon(Icons.image_search), findsOneWidget);

      // Verifica que el botón cancelar esté visible
      expect(find.text('Cancelar'), findsOneWidget);

      // Verifica que el botón guardar esté visible
      expect(find.text('Guardar'), findsOneWidget);
    });
  });
}
