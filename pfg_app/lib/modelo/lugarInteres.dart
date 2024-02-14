class LugarInteres {
  String nombre;
  String descripcion;
  double longitud;
  double latitud;
  LugarInteres(
      {required this.nombre,
      required this.descripcion,
      required this.latitud,
      required this.longitud});

  String get getNombre => nombre;
  String get getDescripcion => descripcion;
  double get getLatitud => latitud;
  double get getLongitud => longitud;
}
