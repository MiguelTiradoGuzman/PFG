import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/filtro/filtro.dart';

class FiltroNombreRuta extends Filtro {
  String nombre;

  FiltroNombreRuta(this.nombre);

  @override
  List<RutaTuristica> aplicar(List<RutaTuristica> rutas) {
    // Filtrar las rutas cuyos nombres comienzan con el string 'nombre'
    return rutas.where((ruta) => ruta.nombre.contains(nombre)).toList();
  }
}
