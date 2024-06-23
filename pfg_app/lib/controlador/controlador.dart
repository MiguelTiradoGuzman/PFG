import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/vistas/aniadirModificarLugar.dart';
import 'package:pfg_app/vistas/pantallaAjustes.dart';
import 'package:pfg_app/vistas/pantallaLugarInteres.dart';
import 'package:pfg_app/vistas/pantallaRecorrido.dart';
import 'package:pfg_app/vistas/login.dart';
import 'package:pfg_app/vistas/selectorRutaModificar.dart';
import 'package:pfg_app/vistas/selectorRutasFavoritas.dart';
import 'clienteAPI.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/vistas/pantallaInicio.dart';
import 'package:pfg_app/vistas/elementos/menuLateral.dart';
import 'package:pfg_app/vistas/pantallaRuta.dart';
import 'package:pfg_app/vistas/pantallaRegistro.dart';
import 'package:pfg_app/vistas/miCuenta.dart';
import 'package:pfg_app/vistas/aniadirModificarRuta.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Importa la clase Placemark desde la biblioteca geocoding

class Controlador {
  // Se establece el patrón Singleton para la clase Controlador
  static final Controlador _instance = Controlador._internal();
  Controlador._internal();
  factory Controlador() => _instance;

  // Posicion actual del dispositivo móvil
  late var _posicion;

  // Instancia del cliente de la API
  ClienteAPI _api = ClienteAPI();

  // Usuario que está utilizando la aplicación
  late Usuario _usuario;

  // // Rutas que se han cargado para mostrar en la página inicial
  // late List<RutaTuristica> _rutas;

  // Método para establecer la API. Necesario para poder usar la clase MockAPI en las pruebas.
  set api(var apiParam) {
    _api = apiParam;
  }

  // Método para establecer el usuario que está utilizando la aplicación
  set usuario(Usuario usuario) {
    _usuario = usuario;
  }

  // Método para obtener la variable _usuario.
  Usuario getUsuario() {
    return _usuario;
  }

  // Función para hacer el inicio de sesión del usuario
  Future<void> iniciarSesion(
      String correo, String contrasenia, BuildContext context) async {
    try {
      // Se llama a la api para comprobar si el usuario y la contraseña existen y coinciden.
      _usuario = await _api.login(correo, contrasenia);
      // Llamar a cargaPaginaInicial solo si el usuario se ha autenticado correctamente. Si el servidor responde con error la clase API lanza excepción.
      cargaPantallaInicial(context);
    } catch (e) {
      // Maneja errores de autenticación
      throw (e);
    }
  }

  // Función para registrar un usuario
  Future<void> registrarUsuario(String nombreUsuario, String contrasenia,
      String correo, BuildContext context) async {
    // Le pasa los datos del nuevo usuario al cliente de la API para que mande la petición hacia la parte del servidor
    await _api.registrarUsuario(nombreUsuario, contrasenia, correo);
  }

  // Carga la página para ver la información sobre una Ruta.
  void cargarPantallaRuta(RutaTuristica rutaTuristica, BuildContext context) {
    // Navega a la siguiente pantalla y reemplaza la actual
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuLateral(
          titulo: rutaTuristica.nombre,
          body: PantallaRuta(ruta: rutaTuristica),
        ),
      ),
    );
  }

  // Carga la pantalla de registro de usuario
  void cargarPantallaRegistro(BuildContext context) {
// Navega a la siguiente pantalla y reemplaza la actual
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PantallaRegistro(),
      ),
    );
  }

  // Comienza el recorrido turístico cargando la pantalla para llegar al primer lugar de interés
  void iniciarRuta(RutaTuristica rutaTuristica, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuLateral(
          titulo: rutaTuristica.nombre,
          body: PantallaRecorrido(ruta: rutaTuristica),
        ),
      ),
    );
  }

  // Carga la página con la información de un lugar de interés
  void cargaPantallaLugarInteres(
      BuildContext context, LugarInteres lugar, RutaTuristica ruta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuLateral(
          titulo: ruta.nombre,
          body: PantallaLugarInteres(lugar: lugar),
        ),
      ),
    );
  }

  // Carga la página inicial de la aplicación.
  void cargaPantallaInicial(BuildContext context) async {
    // Recarga la posición para comprobar si el usuario ha cambiado de ciudad y actualizar consecuentemente la interfaz
    _posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Obtener el nombre de la ciudad a partir de la ubicación
    List<Placemark> nombreCiudad =
        await placemarkFromCoordinates(_posicion.latitude, _posicion.longitude);

    // Establece el nombre de la ciudad
    String ciudad = nombreCiudad.isNotEmpty
        ? nombreCiudad[0].locality ?? "Desconocido"
        : "Desconocido";

    // Obtiene las rutas actualizadas del sistema
    List<RutaTuristica> rutas = await _api.getRutas();
    // Obtiene las rutas favoritas del usuario actualizadas desde el sistema
    List<RutaTuristica> favoritas = await _api.getRutasFavoritas();
    // Las establece en el usuario para mantenerlo actualizado.
    _usuario.setRutasFavoritas(favoritas);
    // ignore: use_build_context_synchronously
    // Establecer el titulo de la pantalla ajustado a la ciudad en la que se encuentra el usuario.
    String titulo = AppLocalizations.of(context)!.descubre + " " + ciudad;

    // Una vez actualizada toda la información, carga la pantalla de inicio.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MenuLateral(
          titulo: titulo,
          body: PantallaInicio(rutas: rutas, posicionActual: _posicion),
        ),
      ),
    );
  }

  // Cierra la sesión del usuario
  void cerrarSesion(BuildContext context) async {
    // El cliente de la API manda la petición para cerrar sesión
    _api.cerrarSesion();
    // Carga la página de inicio de sesión, sustituyendo la pila de anteriores pantallas.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PaginaLogin(),
      ),
    );
  }

  // Borra al usuario del sistema.
  void borrarUsuario(BuildContext context) async {
    // La API manda la petición para el borrado de la información del usuario en el servidor
    _api.borrarUsuario();
    // Carga la página de inicio de sesión, sustituyendo la pila de anteriores pantallas.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PaginaLogin(),
      ),
    );
  }

  // Carga la pantalla de Ajustes
  void cargarPantallaAjustes(BuildContext context) {
    // Carga la pantalla de ajustes para el usuario actual en la pila de pantallas.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuLateral(
          titulo: AppLocalizations.of(context)!.ajustes,
          body: const PantallaAjustes(),
        ),
      ),
    );
  }

  // Carga la pantalla MiCuenta.
  void cargarPantallaMiCuenta(BuildContext context) async {
    // Obtiene del backend las rutas favoritas y creadas por el usuario
    List<RutaTuristica> favoritas = await _api.getRutasFavoritas();
    _usuario.setRutasFavoritas(favoritas);
    _usuario.setMisRutas(await _api.getMisRutas());
    // Carga en la pila la pantalla MiCuenta
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuLateral(
              body: MiCuenta(), titulo: AppLocalizations.of(context)!.miCuenta),
        ));
  }

  // Carga la pantalla para modificar o crear una ruta.
  void cargarAniadirModificarRuta(BuildContext context, RutaTuristica? ruta) {
    // Carga la página para modificar o crear una ruta pasando la ruta que le llega por parámetro
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuLateral(
              body: AniadirModificarRuta(
                rutaModificar: ruta,
              ),
              titulo: AppLocalizations.of(context)!.anadirRuta),
        ));
  }

  // Carga la pantalla para modificar o crear un lugar de interés.
  Future<List> cargarAniadirModificarLugar(BuildContext context,
      LugarInteres? l, RutaTuristica r, List<File>? imgs) async {
    // Cuando se cierra esta página se debe obtener como resultado un nuevo lugar (ya sea el mismo modificado o uno nuevo) y una lista de imágenes.
    List dev = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AniadirModificarLugar(context, l, r, imgs)));
    return dev;
  }

  // Obtener una ruta desde el servidor por su nombre. Si no la encuentra devuelve null.
  Future<RutaTuristica?> getRuta(String nombreRuta) async {
    RutaTuristica? r = await _api.getRuta(nombreRuta);
    try {
      RutaTuristica? ruta = await r;
      return ruta;
    } catch (e) {
      print("Error al obtener la ruta: $e");
      return null;
    }
  }

  // Insertar una nueva ruta en el servidor
  Future<void> insertarRuta(BuildContext context, RutaTuristica ruta,
      List<List<File>> imagenes, File imagenPortada) async {
    // Establece como autor al usuario actual que está usando la aplicación.
    ruta.autor = this._usuario.getCorreo;
    // Manda la petición al servidor para que inserte la ruta así como las imágenes de los lugares de interés y la portada de la ruta.
    _api.insertarRuta(ruta, imagenes, imagenPortada);
    // Carga la página inicial.
    cargaPantallaInicial(context);
  }

  // Modifica una ruta en el sistema.
  void modificarRuta(BuildContext context, RutaTuristica ruta,
      List<List<File>> imagenes, File imagenPortada) {
    // Manda la petición para modificar la ruta en el servidor.
    _api.modificarRuta(ruta, imagenes, imagenPortada);
    Navigator.pop(context);
  }

  // Construye un archivo desde una url
  Future<File?> fileDesdeURLImagen(String url) async {
    return await _api.fileDesdeURLImagen(url);
  }

  //Carga el selector para modificar las rutas creadas por el usuario.
  void cargarSelectorModificarRutas(BuildContext context, Usuario usuario) {
    // Se carga la pantalla del selector pasando por parámetro el usuario de la aplicación, cuya variable de instancia misRutas contiene las rutas que ha creado.
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuLateral(
              body: SelectorModificarRuta(rutas: _usuario.getMisRutas),
              titulo: AppLocalizations.of(context)!.seleccionaRuta),
        ));
  }

  // Modifica la información de un usuario en el sistema.
  void modificarContrasenia(String contrasenia, String contraseniaAntigua,
      BuildContext context) async {
    // Primero comprueba si la contraseña antigua es correcta
    Usuario resultado =
        await _api.login(_usuario.getCorreo, contraseniaAntigua);
    // Si es correcta es porque la respuesta no es not-found
    if (resultado.getNombreUsuario != "not-found") {
      // Modifica la contraseña en el servidor
      await _api.modificarContrasenia(contrasenia);
      // Recarga la pantalla MiCuenta.
      cargarPantallaMiCuenta(context);
    }
  }

  // Marca una ruta como favorita en el servidor y en el usuario actual.
  void marcarFavorita(RutaTuristica ruta) async {
    _usuario.aniadirRutaFavorita(ruta);
    await _api.marcarFavorita(ruta);
  }

  // Desmarca una ruta como favorita en el servidor y en el usuario actual.
  void desmarcarFavorita(RutaTuristica ruta) async {
    _usuario.desmarcarFavorita(ruta);
    await _api.desmarcarFavorita(ruta);
  }

  // Carga el selector de rutas favoritas del usuario actual.
  void cargaSelectorFavoritas(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MenuLateral(
              body: SelectorRutasFavoritas(rutas: _usuario.getRutasFavoritas),
              titulo: AppLocalizations.of(context)!.misRutasFavoritas),
        ));
  }
}
