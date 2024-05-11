import 'package:pfg_app/modelo/rutaTuristica.dart';

// Clase Usuario.
// Representación en Dart de un Usuario del sistema.
class Usuario {
  // Nombre de Usuario. Único en el sistema
  String _nombreUsuario;
  // Correo electrónico del usuario. Único en el sistema
  String _correo;
  // Rutas marcadas como favoritas por el usuario.
  late List<RutaTuristica> _rutasFavoritas;
  // Rutas creadas por el usuario.
  late List<RutaTuristica> _misRutas;

  // Constructor de la clase Usuario. Debe obtener un nombre de usuario y correo obligatoriamente.
  Usuario({required String nombreUsuario, required String correo})
      : _nombreUsuario = nombreUsuario,
        _correo = correo;

  // Metodo factoría de la clase Usuario. Construye una instancia de la clase Usuario a través de la información obtenida desde un documento Json.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(nombreUsuario: json['nombre'], correo: json['email']);
  }

  // Métodos para obtener las variables de instancia del usuario
  String get getNombreUsuario => _nombreUsuario;
  String get getCorreo => _correo;
  List<RutaTuristica> get getMisRutas => _misRutas;
  List<RutaTuristica> get getRutasFavoritas => _rutasFavoritas;

  // Establecer una lista de rutas como favoritas
  void setRutasFavoritas(List<RutaTuristica> r) {
    _rutasFavoritas = r;
  }

  // Establecer la variable rutasCreadas
  void setMisRutas(List<RutaTuristica> r) {
    _misRutas = r;
  }

  // Añadir una nueva ruta como favorita
  void aniadirRutaFavorita(RutaTuristica r) {
    _rutasFavoritas.add(r);
  }

  // Añadir una nueva ruta creada por el usuario
  void aniadirMisRutas(RutaTuristica r) {
    _misRutas.add(r);
    r.autor = this._correo;
  }

  // Desmarcar una ruta como favorita
  void desmarcarFavorita(RutaTuristica ruta) {
    // Se compara por nombre con la ruta que llega por parámetro ya que dart hace comparaciones por referencia y no por contenido de la instancia
    RutaTuristica? rutaAEliminar = _rutasFavoritas.firstWhere(
      (rutaFavorita) => rutaFavorita.nombre == ruta.nombre,
    );

    if (rutaAEliminar != null) {
      _rutasFavoritas.remove(rutaAEliminar);
    }
  }
}
