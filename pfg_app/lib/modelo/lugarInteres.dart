import 'package:pfg_app/constants/network_const.dart';

class LugarInteres {
  // Nombre del lugar de interés.
  String nombre;
  // Descripción del lugar de interés
  String descripcion;
  // Longitud de la ubicación del lugar de interés
  double longitud;
  // Latitud de la ubicación del lugar de interés
  double latitud;
  // Lista de las URL de los recursos del lugar de interés
  List<String> recursos;
  // Constructor del lugar de interés
  LugarInteres(
      {required this.nombre,
      required this.descripcion,
      required this.latitud,
      required this.longitud,
      required this.recursos});

  // Consultores de las variables de instancia
  String get getNombre => nombre;
  String get getDescripcion => descripcion;
  double get getLatitud => latitud;
  double get getLongitud => longitud;
  List<String> get getRecursos => recursos;

  //Método factoría de la clase. Crea una instancia a partir del contenido de un archivo en formato Json
  factory LugarInteres.serializacion(Map<String, dynamic> json) {
    // Mapear las fotos y agregar el baseUrl
    List<String> recursos = List<String>.from(json['fotos'] ?? []);
    recursos = recursos
        .map((foto) => '${NetworkConst.baseUrlImagenes}/$foto')
        .toList();

    return LugarInteres(
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      latitud: json['latitud'] != null ? json['latitud'].toDouble() : 0.0,
      longitud: json['longitud'] != null ? json['longitud'].toDouble() : 0.0,
      recursos: recursos,
    );
  }
  // Convierte una instancia de la clase a archivo en formato Json.
  Map<String, dynamic> deserializacion() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nombre'] = this.nombre;
    data['descripcion'] = this.descripcion;
    data['latitud'] = this.latitud;
    data['longitud'] = this.longitud;
    data['fotos'] = this.recursos;
    return data;
  }
}
