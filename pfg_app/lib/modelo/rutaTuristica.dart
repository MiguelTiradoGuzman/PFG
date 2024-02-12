import 'package:pfg_app/modelo/lugarInteres.dart';

class RutaTuristica {
  String nombre;
  String descripcion;
  double distancia;
  String duracion;
  String rutaImagen;
  List<LugarInteres> lugares;

  RutaTuristica(
      {required this.nombre,
      required this.descripcion,
      required this.distancia,
      required this.duracion,
      required this.rutaImagen,
      required this.lugares});

  String get getNombre => nombre;
  String get getDescripcion => descripcion;
  double get getDistancia => distancia;
  String get getDuracion => duracion;
  String get getRutaImagen => rutaImagen;
  List<LugarInteres> get getLugares => lugares;
}
