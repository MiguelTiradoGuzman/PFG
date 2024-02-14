import '../modelo/lugarInteres.dart';
import '../modelo/rutaTuristica.dart';
import '../modelo/usuario.dart';

class ClaseTest {
  final List<LugarInteres> lugares = [
    LugarInteres(
        nombre: "C/ Carrera del Darro",
        descripcion: "Descripcion de prueba de la calle Carrera del Darro",
        latitud: 37.1783098,
        longitud: -3.5928579),
    LugarInteres(
        nombre: "C/ Navas",
        descripcion: "Descripcion de prueba de la calle Navas",
        latitud: 37.1734542,
        longitud: -3.6003842),
    LugarInteres(
        nombre: "C/ Reyes Católicos",
        descripcion: "Descripcion de prueba de la calle Reyes Católicos",
        latitud: 37.1753278,
        longitud: -3.6008475),
    LugarInteres(
        nombre: "Plaza Nueva",
        descripcion: "Descripcion de prueba de Plaza Nueva",
        latitud: 37.1767291,
        longitud: -3.5984913),
  ];
  late RutaTuristica ruta;

  Usuario user = Usuario(username: "test");
  ClaseTest() {
    ruta = RutaTuristica(
        nombre: 'Alhambra test',
        descripcion: 'Descripción de Alhambra',
        distancia: 1.5, // Distancia en km (cambia según tu necesidad)
        duracion: '1:45',
        rutaImagen: 'assets/images/alhambra.jpeg',
        lugares: lugares);
  }
}
