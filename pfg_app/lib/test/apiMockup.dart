import 'dart:io';

import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:pfg_app/controlador/api.dart';
import 'package:pfg_app/test/test_const.dart';

class MockAPI implements API {
  //MockAPI() : super(); // Llamar al constructor de la superclase
  @override
  Future<Usuario> login(String username, String password) async {
    // Simula una respuesta exitosa en lugar de realizar una solicitud real

    if (username != "user1" || password != "password1") {
      throw Exception("Error de usuario/contrasenia");
    } else {
      return Usuario(username: 'mock_user', email: 'mock@gmail.com');
    }
  }

  @override
  Future<void> cerrarSesion() async {}

  Future<void> borrarUsuario() async {}

  @override
  Future<void> registrarUsuario(
      String username, String password, String correo) async {
    // Simula una respuesta exitosa en lugar de realizar una solicitud real
  }

  Map<String, dynamic> deconstruirRutaTuristica(RutaTuristica ruta) {
    return {
      'rutas': [
        {
          'nombre': 'Alhambra test',
          'descripcion': 'Descripción de Alhambra',
          'distancia': 1.5,
          'duracion': '1:45',
          'ruta_imagen': 'recursos/rutas/alhambra_test/alhambra.jpeg',
          'lugares': [
            {
              'nombre': 'C/ Carrera del Darro',
              'descripcion':
                  'Descripcion de prueba de la calle Carrera del Darro',
              'latitud': 37.1783,
              'longitud': -3.59286,
              'fotos': [
                'recursos/rutas/alhambra_test/carrera_del_darro/carrera_del_darro.jpg',
                'recursos/rutas/alhambra_test/carrera_del_darro/carrera_del_darro2.jpeg',
              ],
            },
            {
              'nombre': 'C/ Navas',
              'descripcion': 'Descripcion de prueba de la calle Navas',
              'latitud': 37.1735,
              'longitud': -3.60038,
              'fotos': [
                'recursos/rutas/alhambra_test/navas/calle_navas.jpg',
              ],
            },
            {
              'nombre': 'C/ Reyes Católicos',
              'descripcion':
                  'Descripcion de prueba de la calle Reyes Católicos',
              'latitud': 37.1753,
              'longitud': -3.60085,
              'fotos': [
                'recursos/rutas/alhambra_test/reyes_catolicos/calle_reyes_catolicos.jpeg',
                'recursos/rutas/alhambra_test/reyes_catolicos/calle_reyes_catolicos2.jpeg',
              ],
            },
          ],
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getRutas() async {
    List<RutaTuristica> rutas = [ClaseTest().ruta];

    return deconstruirRutaTuristica(ClaseTest().ruta);
  }

  Future<RutaTuristica> getRuta(String nombre) async {
    return ClaseTest().ruta;
  }

  @override
  void insertarRuta(RutaTuristica ruta, List<List<File>> imagenes,
      File imagenPortada) async {}
  @override
  // TODO: implement token
  String get token => throw UnimplementedError();
}
