import 'package:pfg_app/modelo/rutaTuristica.dart';

abstract class Filtro {
  // Método abstracto sin implementación. Las clases que hereden de ella deben implementar este método.
  List<RutaTuristica> aplicar(List<RutaTuristica> rutas);
}
