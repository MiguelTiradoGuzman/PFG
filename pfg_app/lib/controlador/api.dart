import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/adapter.dart';
import 'package:http/http.dart' as http;
import 'package:pfg_app/constants/network_const.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

class API {
  static final API _instance = API._internal();
  factory API() => _instance;

  String _baseUrl = NetworkConst.baseUrl;

  API._internal();

  String _token = '';

  String get token => _token;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convierte la contraseña a bytes.
    var digest = sha256.convert(bytes); // Calcula el hash SHA-256.
    return digest.toString();
  }

  Future<Usuario> login(String email, String password) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSH autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    //var data = {'username': username, 'password': _hashPassword(password)};
    var data = {'email': email, 'password': password};

    // Realizar la solicitud POST
    try {
      Response response = await dio.post(
        '$_baseUrl/login',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: FormData.fromMap(data),
      );
      Usuario usuario = Usuario.fromJson(response.data['user_info']);
      _token = response.data['access_token']!;
      // Imprimir la respuesta del servidor
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.data}');

      dio.close();
      return usuario;
    } catch (e) {
      throw ('Error: $e');
    }
    // Cerrar el cliente
  }

  Future<void> registrarUsuario(
      String username, String password, String correo) async {
    print("Antes peticion");
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));
    print("Despues peticion");

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSH autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    print("Despues desactivar");

    var data = {'username': username, 'password': password, 'correo': correo};

    // Realizar la solicitud POST
    try {
      Response response = await dio.post(
        '$_baseUrl/signin',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: FormData.fromMap(data),
      );
      print("Despues respuesta");

      print(_token);
      // Imprimir la respuesta del servidor
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.data}');

      dio.close();
    } catch (e) {
      throw ('Error: $e');
    }
    // Cerrar el cliente
  }

  Future<Map<String, dynamic>> getRutas() async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSH autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }
    print("Antes de  petición 3");
    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud POST
    try {
      Response response = await dio.get(
        '$_baseUrl/rutas',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      print("Despues de  petición");

      if (response.statusCode == 200) {
        dio.close();
        print("Respuesta de servidor");
        print(response.data);
        return response.data;
      } else {
        throw Exception('Error al obtener las rutas: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error: $e');
    }
    // Cerrar el cliente
  }

  Future<RutaTuristica?> getRuta(String nombreRuta) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSH autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud POST
    try {
      Response response = await dio.get(
        '$_baseUrl/ruta/$nombreRuta',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      if (response.statusCode == 200) {
        RutaTuristica ruta = RutaTuristica.fromJson(response.data['ruta']);
        dio.close();
        return ruta;
      } else if (response.statusCode == 404) {
        dio.close();
        return null;
      } else {
        throw Exception('Error al obtener las ruta: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error: $e');
    }
  }

  void insertarRuta(
      RutaTuristica ruta, List<List<File>> imagenes, File imagenPortada) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSH autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }

    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // // Crear un objeto FormData para enviar datos binarios
    String rutaJson = jsonEncode(ruta.toJson());

    // Realizar la solicitud POST
    try {
      Response response = await dio.post(
        '$_baseUrl/ruta/',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: rutaJson,
      );

      if (response.statusCode == 200) {
        print("Ruta insertada correctamente");
      } else {
        throw Exception('Error al insertar la ruta: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error: $e');
    }

// Obtener el nombre de la ruta
    String nombreRuta = ruta.nombre;
    FormData formData = FormData();
    // Crear FormData para enviar imágenes junto con el nombre de la ruta
    formData.fields.add(MapEntry('ruta', nombreRuta));
// Agregar la imagen de portada al FormData
    formData.files.add(MapEntry(
      'imagen_portada',
      await MultipartFile.fromFile(imagenPortada.path),
    ));
    // Realizar la solicitud POST para enviar las imágenes
    Response responseImagenes = await dio.post(
      '$_baseUrl/ruta/imagen',
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
      data: formData,
    );

    if (responseImagenes.statusCode == 200) {
      print("Imagen de la ruta insertada correctamente");
    } else {
      throw Exception(
          'Error al insertar la imagen de la ruta: ${responseImagenes.statusCode}');
    }
    for (var i = 0; i < ruta.lugares.length; i++) {
      // Agregar todas las imágenes al FormData
      for (var j = 0; j < imagenes.elementAt(i).length; j++) {
        formData = FormData();
        formData.fields.add(MapEntry('ruta', nombreRuta));
        formData.fields
            .add(MapEntry('lugar', ruta.lugares.elementAt(i).nombre));
        formData.files.add(MapEntry(
          'imagen_lugar',
          await MultipartFile.fromFile(imagenes.elementAt(i).elementAt(j).path),
        ));
        // Realizar la solicitud POST para enviar las imágenes
        Response responseImagenes = await dio.post(
          '$_baseUrl/lugar/imagen',
          options: Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
          data: formData,
        );

        if (responseImagenes.statusCode == 200) {
          print("Imagen del lugar insertada correctamente");
        } else {
          throw Exception(
              'Error al insertar la imagen del lugar: ${responseImagenes.statusCode}');
        }
      }
    }
  }

  Future<void> cerrarSesion() async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSH autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }
    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud POST
    try {
      Response response = await dio.post(
        '$_baseUrl/logout',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      _token = '';
      if (response.statusCode == 200) {
        dio.close();
        print("Respuesta de servidor");
        print(response.data);
        return response.data;
      } else {
        throw Exception('Error al cerrar sesión: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error: $e');
    }
  }

  Future<void> borrarUsuario() async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSH autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }
    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud POST
    try {
      Response response = await dio.post(
        '$_baseUrl/delete/usuario/me',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      _token = '';

      if (response.statusCode == 200) {
        dio.close();
        print("Respuesta de servidor");
        print(response.data);
        return response.data;
      } else {
        throw Exception('Error al cerrar sesión: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error: $e');
    }
  }
}
