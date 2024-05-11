import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/filtro/filtro.dart';

class FiltroDuracion extends Filtro {
  String? maximo;
  String? minimo;

  // Construcctor de la clase. Se establece la duración máxima y mínima
  FiltroDuracion(String? duracionMax, String? duracionMin) {
    maximo = duracionMax;
    minimo = duracionMin;
  }

  @override
  List<RutaTuristica> aplicar(List<RutaTuristica> rutas) {
    // Convertir los strings de duración a minutos
    int? maximoMinutos =
        maximo != null ? _convertirStringADuracion(maximo!) : null;
    int? minimoMinutos =
        minimo != null ? _convertirStringADuracion(minimo!) : null;

    // Filtrar las rutas por duración
    return rutas.where((ruta) {
      // Si el máximo no es nulo, se comprueba si satisface las restricciones
      int duracionRuta = _convertirStringADuracion(ruta.duracion);
      if (maximoMinutos != null && duracionRuta > maximoMinutos) {
        return false;
      }
      // Si el mínimo no es nulo, se comprueba si satisface las restricciones
      if (minimoMinutos != null && duracionRuta < minimoMinutos) {
        return false;
      }
      // Si no ha satisfecho ninguna de las condiciones anteriores es porque cumple el filtro y se debe mantener
      return true;
    }).toList();
  }

  // Función para convertir un string en formato 'h:mm' a minutos
  int _convertirStringADuracion(String duracion) {
    List<String> partes = duracion.split(':');
    int horas = int.parse(partes[0]);
    int minutos = int.parse(partes[1]);
    return horas * 60 + minutos;
  }
}
