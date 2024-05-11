import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/filtro/filtro.dart';

class FiltroNombreLugar extends Filtro {
  String nombre;

  FiltroNombreLugar(this.nombre);

  @override
  List<RutaTuristica> aplicar(List<RutaTuristica> rutas) {
    // Filtrar las rutas que tienen algún lugar de interés cuyo nombre coincide con 'nombre'
    return rutas
        .where((ruta) => ruta.getLugares.any((lugar) => lugar.nombre == nombre))
        .toList();
  }
}
