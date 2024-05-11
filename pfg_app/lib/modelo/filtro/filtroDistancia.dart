import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/filtro/filtro.dart';

class FiltroDistancia extends Filtro {
  double? maximo;
  double? minimo;

  // Constructor de la clase. Debe establecerse el máximo y mínimo de distancia.
  FiltroDistancia({this.maximo, this.minimo});

  @override
  List<RutaTuristica> aplicar(List<RutaTuristica> rutas) {
    // Filtrar las rutas por distancia
    return rutas.where((ruta) {
      // Si el máximo no es nulo, se comprueba si satisface las restricciones
      if (maximo != null && ruta.distancia > maximo!) {
        return false;
      }
      // Si el mínimo no es nulo, se comprueba si satisface las restricciones
      if (minimo != null && ruta.distancia < minimo!) {
        return false;
      }
      // Si no ha satisfecho ninguna de las condiciones anteriores es porque cumple el filtro y se debe mantener
      return true;
    }).toList();
  }
}
