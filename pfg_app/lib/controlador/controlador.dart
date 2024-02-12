import 'package:flutter/material.dart';

import 'api.dart';
import '../modelo/usuario.dart';
import '../modelo/rutaTuristica.dart';
import '../vistas/pantallaInicio.dart';
import '../vistas/template.dart';
import '../vistas/pantallaRuta.dart';

class Controlador {
  static final Controlador _instance = Controlador._internal();
  Controlador._internal();
  factory Controlador() => _instance;

  final API _api = API();
  late Usuario _usuario;
  API get api => _api;

  set user(String username) {
    _usuario = Usuario(username: username);
  }

  Future<void> login(
      String username, String password, BuildContext context) async {
    //try {
    _usuario = await _api.login(username, password);
    //rutas = _api.get_rutas();

    //TODO: Completar con la lista de rutas de pruebas
    List<RutaTuristica> rutas = [];
    // Navega a la siguiente pantalla y reemplaza la actual
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateApp(
          titulo: "Descubre Granada",
          body: PantallaInicio(rutas: rutas),
          usuario: _usuario,
        ),
      ),
    );
    // } catch (e) {
    //   // Manejar excepciones o mostrar mensajes de error según sea necesario
    //   print('Error de inicio de sesión: $e');
    // }
  }

  void loadPaginaRuta(RutaTuristica rutaTuristica, BuildContext context) {
    // Navega a la siguiente pantalla y reemplaza la actual
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateApp(
          titulo: "Ruta test",
          body: PantallaRuta(ruta: rutaTuristica),
          usuario: _usuario,
        ),
      ),
    );
  }
}
