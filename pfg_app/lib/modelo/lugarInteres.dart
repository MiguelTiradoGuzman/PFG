import 'package:pfg_app/constants/network_const.dart';

class LugarInteres {
  String nombre;
  String descripcion;
  double longitud;
  double latitud;
  List<String> fotos;
  LugarInteres(
      {required this.nombre,
      required this.descripcion,
      required this.latitud,
      required this.longitud,
      required this.fotos});

  String get getNombre => nombre;
  String get getDescripcion => descripcion;
  double get getLatitud => latitud;
  double get getLongitud => longitud;
  List<String> get getFotos => fotos;

  factory LugarInteres.fromJson(Map<String, dynamic> json) {
// Mapear las fotos y agregar el baseUrl
    List<String> fotos = List<String>.from(json['fotos'] ?? []);
    fotos =
        fotos.map((foto) => '${NetworkConst.baseUrlImagenes}/$foto').toList();

    return LugarInteres(
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      latitud: json['latitud'] != null ? json['latitud'].toDouble() : 0.0,
      longitud: json['longitud'] != null ? json['longitud'].toDouble() : 0.0,
      fotos: fotos,
    );
  }
}
