import '../modelo/lugarInteres.dart';
import '../modelo/rutaTuristica.dart';
import '../modelo/usuario.dart';

class ClaseTest {
  final List<LugarInteres> lugares = [
    LugarInteres(
        nombre: "C/ Carrera del Darro",
        descripcion: "Descripcion de prueba de la calle Carrera del Darro"),
    LugarInteres(
        nombre: "C/ Navas",
        descripcion: "Descripcion de prueba de la calle Navas"),
    LugarInteres(
        nombre: "C/ Reyes Católicos",
        descripcion: "Descripcion de prueba de la calle Reyes Católicos"),
    LugarInteres(
        nombre: "Plaza Nueva",
        descripcion: "Descripcion de prueba de Plaza Nueva"),
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
