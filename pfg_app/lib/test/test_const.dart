import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/usuario.dart';

class ClaseTest {
  final List<LugarInteres> lugares = [
    LugarInteres(
        nombre: "C/ Carrera del Darro",
        descripcion: "Descripcion de prueba de la calle Carrera del Darro",
        latitud: 37.1783098,
        longitud: -3.5928579,
        recursos: [
          "http://localhost:8080/recursos/rutas/alhambra_test/carrera_del_darro/carrera_del_darro.jpg",
          "assets/images/carrera_del_darro2.jpeg"
        ]),
    LugarInteres(
        nombre: "C/ Navas",
        descripcion: "Descripcion de prueba de la calle Navas",
        latitud: 37.1734542,
        longitud: -3.6003842,
        recursos: [
          "http://localhost:8080/recursos/rutas/alhambra_test/navas/calle_navas.jpg"
        ]),
    LugarInteres(
        nombre: "C/ Reyes Católicos",
        descripcion: "Descripcion de prueba de la calle Reyes Católicos",
        latitud: 37.1753278,
        longitud: -3.6008475,
        recursos: [
          "assets/images/calle_reyes_catolicos.jpeg",
          "assets/images/calle_reyes_catolicos2.jpeg"
        ]),
    LugarInteres(
        nombre: "Plaza Nueva",
        descripcion: "Descripcion de prueba de Plaza Nueva",
        latitud: 37.1767291,
        longitud: -3.5984913,
        recursos: [
          "assets/images/plaza_nueva.jpg",
          "assets/images/plaza_nueva2.jpg"
        ]),
  ];
  late RutaTuristica ruta;

  Usuario user = Usuario(nombreUsuario: "test", correo: "test@gmail.com");
  ClaseTest() {
    ruta = RutaTuristica(
        nombre: 'Alhambra test',
        descripcion: 'Descripción de Alhambra',
        distancia: 1.5, // Distancia en km (cambia según tu necesidad)
        duracion: '1:45',
        rutaImagen:
            'http://localhost:8080/recursos/rutas/alhambra_test/alhambra.jpeg',
        lugares: lugares);
  }
}
