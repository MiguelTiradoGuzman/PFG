import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/adapter.dart';
import 'package:http/http.dart' as http;
import 'package:pfg_app/constants/network_const.dart';
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
      print("Despues respuesta");

      Usuario usuario = Usuario.fromJson(response.data['user_info']);
      _token = response.data['access_token']!;
      print(_token);
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
