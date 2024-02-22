import 'package:pfg_app/constants/network_const.dart';
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

  factory RutaTuristica.fromJson(Map<String, dynamic> json) {
    // Convierte la duración de String a Duration
    // final durationParts = json['duracion'].split(':');
    // // final duration = Duration(
    // //   hours: int.parse(durationParts[0]),
    // //   minutes: int.parse(durationParts[1]),
    // // );
    String img = json['ruta_imagen'];
    // Construye y devuelve una instancia de RutaTuristica
    return RutaTuristica(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      distancia: json['distancia'].toDouble(),
      duracion: json['duracion'],
      rutaImagen: '${NetworkConst.baseUrlImagenes}/$img',
      lugares: List<LugarInteres>.from(
        json['lugares'].map((lugarJson) => LugarInteres.fromJson(lugarJson)),
      ),
    );
  }
}
