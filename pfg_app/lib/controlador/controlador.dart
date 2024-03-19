import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/vistas/pantallaLugarInteres.dart';
import 'package:pfg_app/vistas/pantallaRecorrido.dart';
import 'package:pfg_app/vistas/login.dart';

import 'api.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/vistas/pantallaInicio.dart';
import 'package:pfg_app/vistas/elementos/template.dart';
import 'package:pfg_app/vistas/pantallaRuta.dart';
import 'package:pfg_app/test/test_const.dart';
import 'package:pfg_app/test/apiMockup.dart';
import 'package:pfg_app/vistas/pantallaRegistro.dart';

class Controlador {
  static final Controlador _instance = Controlador._internal();
  Controlador._internal();
  factory Controlador() => _instance;
  //API _api = MockAPI();
  API _api = API();
  //late var _api;
  late Usuario _usuario;
  //var get api => _api;

  set api(var apiParam) {
    _api = apiParam;
  }

  set user(Usuario user) {
    _usuario = user;
  }

  List<RutaTuristica> _rutasDesdeJson(Map<String, dynamic> rutasJson) {
    print(rutasJson);
    List<dynamic> data = rutasJson['rutas'];
    print("Despues de coger Data");

    List<RutaTuristica> rutas = data.map((rutaJson) {
      return RutaTuristica.fromJson(rutaJson);
    }).toList();
    print("Convertiar a lista de rutas");

    return rutas;
  }

  Future<List<RutaTuristica>> _obtenerRutas() async {
    print("Obtener json de rutas");
    Map<String, dynamic> rutasJson = await _api.getRutas();
    print(rutasJson);

    print("Despues de obtener json de rutas");

    List<RutaTuristica> rutas = _rutasDesdeJson(rutasJson);
    print("Despues de obtener RUTAS");
    print(rutas);
    return rutas;
  }

  Future<void> login(
      String username, String password, BuildContext context) async {
    //try {
    _usuario = await _api.login(username, password);
    List<RutaTuristica> rutas = await _obtenerRutas();

    // Parsear la lista de rutas desde el JSON

    // Navega a la siguiente pantalla y reemplaza la actual
    // ignore: use_build_context_synchronously
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
  }

  Future<void> registrarUsuario(String username, String password, String correo,
      BuildContext context) async {
    await _api.registrarUsuario(username, password, correo);
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

  void loadPaginaRegistro(BuildContext context) {
// Navega a la siguiente pantalla y reemplaza la actual
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaginaRegistro(),
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

  void cargaPaginaInicial(BuildContext context) async {
    List<RutaTuristica> rutas = await _obtenerRutas();
    // ignore: use_build_context_synchronously
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

  void cerrarSesion(BuildContext context) async {
    _api.cerrarSesion();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaginaLogin(),
      ),
    );
  }

  void borrarUsuario(BuildContext context) async {
    _api.borrarUsuario();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaginaLogin(),
      ),
    );
  }
}
