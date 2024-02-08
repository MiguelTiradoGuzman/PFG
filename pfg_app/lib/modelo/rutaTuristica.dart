class RutaTuristica {
  String nombre;
  String descripcion;
  double distancia;
  String duracion;
  String rutaImagen;

  RutaTuristica({
    required this.nombre,
    required this.descripcion,
    required this.distancia,
    required this.duracion,
    required this.rutaImagen,
  });

  String get getNombre => nombre;
  String get getDescripcion => descripcion;
  double get getDistancia => distancia;
  String get getDuracion => duracion;
  String get getRutaImagen => rutaImagen;
}
