import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/vistas/pantallaLugarInteres.dart';
import 'package:pfg_app/vistas/pantallaRecorrido.dart';

import 'api.dart';
import '../modelo/usuario.dart';
import '../modelo/rutaTuristica.dart';
import '../vistas/pantallaInicio.dart';
import '../vistas/elementos/template.dart';
import '../vistas/pantallaRuta.dart';
import '../constants/test_const.dart';

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
    List<RutaTuristica> rutas = [];
    //TODO: Completar con la lista de rutas de pruebas
    rutas = [ClaseTest().ruta];
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
    Navigator.push(
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

  void iniciarRuta(RutaTuristica rutaTuristica, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateApp(
          titulo: "Ruta test",
          body: PantallaRecorrido(ruta: rutaTuristica),
          usuario: _usuario,
        ),
      ),
    );
  }

  void cargaPaginaLugarInteres(
      BuildContext context, LugarInteres lugar, RutaTuristica ruta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateApp(
          titulo: ruta.nombre,
          body: PantallaLugarInteres(lugar: lugar),
          usuario: _usuario,
        ),
      ),
    );
  }

  void cargaPaginaInicial(BuildContext context) {
    List<RutaTuristica> rutas = [];
    rutas.insert(0, ClaseTest().ruta);
    _usuario = ClaseTest().user;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateApp(
          titulo: "Descubre",
          body: PantallaInicio(rutas: rutas),
          usuario: _usuario,
        ),
      ),
    );
  }
}
