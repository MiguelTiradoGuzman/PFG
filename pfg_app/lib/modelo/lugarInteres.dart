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
}
