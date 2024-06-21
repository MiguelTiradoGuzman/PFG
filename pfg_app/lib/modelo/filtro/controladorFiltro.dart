import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/filtro/filtro.dart';

// Clase que representa un controlador de filtros
class ControladorFiltros {
  List<Filtro> filtros = [];

  // Método para añadir un filtro a la lista de filtros
  void aniadirFiltro(Filtro filtro) {
    filtros.add(filtro);
  }

  // Método para aplicar todos los filtros a una lista de rutas turísticas
  List<RutaTuristica> aplicar(List<RutaTuristica> rutas) {
    // Aplicar cada filtro a la lista de rutas sucesivamente
    for (var filtro in filtros) {
      rutas = filtro.aplicar(rutas);
    }
    return rutas;
  }
}
