import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/vistas/aniadirModificarLugar.dart';
import 'package:pfg_app/vistas/pantallaAjustes.dart';
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
import 'package:pfg_app/vistas/miCuenta.dart';
import 'package:pfg_app/vistas/aniadirRuta.dart';

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
    //print(rutas);
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

  void loadPantallaRegistro(BuildContext context) {
// Navega a la siguiente pantalla y reemplaza la actual
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaRegistro(),
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
        builder: (context) => const PaginaLogin(),
      ),
    );
  }

  void borrarUsuario(BuildContext context) async {
    _api.borrarUsuario();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PaginaLogin(),
      ),
    );
  }

  void loadAjustes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateApp(
          titulo: "Ajustes",
          body: const PantallaAjustes(),
          usuario: _usuario,
        ),
      ),
    );
  }

  void loadMiCuenta(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TemplateApp(
              body: MiCuenta(
                usuario: _usuario,
              ),
              usuario: _usuario,
              titulo: "Mi Cuenta"),
        ));
  }

  void loadAniadirRuta(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TemplateApp(
              body: AniadirRuta(
                usuario: _usuario,
              ),
              usuario: _usuario,
              titulo: "Crea tu Ruta"),
        ));
  }

  Future<List> aniadirModificarLugar(
      BuildContext context, LugarInteres? l, RutaTuristica r) async {
    List dev = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AniadirModificarLugar(context, l, r)));
    return dev;
  }

  Future<RutaTuristica?> getRuta(String nombreRuta) async {
    Future<RutaTuristica?> r = _api.getRuta(nombreRuta);
    try {
      RutaTuristica? ruta = await r;
      if (ruta == null) {
        print("DEVUELVE NULO");
      } else {
        print(ruta);
      }
      return ruta;
    } catch (e) {
      print("Error al obtener la ruta: $e");
      return null;
    }
  }

  void insertarRuta(BuildContext context, RutaTuristica ruta,
      List<List<File>> imagenes, File imagenPortada) {
    _api.insertarRuta(ruta, imagenes, imagenPortada);
    cargaPaginaInicial(context);
  }
}
