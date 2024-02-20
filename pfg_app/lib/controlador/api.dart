import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/adapter.dart';
import 'package:http/http.dart' as http;
import 'package:pfg_app/constants/network_const.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import '../modelo/usuario.dart';
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

  // Future<Image> getImagen(String url) async {
  //   final fullUrl = '$_baseUrl/$url';

  //   final response = await http.get(Uri.parse(fullUrl));

  //   if (response.statusCode == 200) {
  //     final List<int> bytes = response.bodyBytes;
  //     final Uint8List uint8List = Uint8List.fromList(bytes);
  //     final ByteData byteData = ByteData.sublistView(uint8List);
  //     final codec = await instantiateImageCodec(byteData.buffer.asUint8List());
  //     final frameInfo = await codec.getNextFrame();
  //     return frameInfo.image;
  //   } else {
  //     throw Exception('Error al cargar la imagen: ${response.statusCode}');
  //   }
  // }

  Future<Usuario> login(String username, String password) async {
    // print(_baseUrl);

    // final hashedPassword = _hashPassword(password);

    // final response = await http.post(
    //   Uri.parse('$_baseUrl/login'),
    //   headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    //   body: {'username': username, 'password': hashedPassword},
    // );

    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> data = jsonDecode(response.body);
    //   _token = data['access_token'];
    //   final Usuario usuario = Usuario.fromJson(data['user_info']);
    //   return usuario;
    // } else {
    //   throw Exception('Contraseña o Usuario incorrecto');
    // }

    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSH autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    var data = {'username': username, 'password': _hashPassword(password)};

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

  Future<List<RutaTuristica>> getRutas() async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSH autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Realizar la solicitud POST
    try {
      Response response = await dio.get(
        '$_baseUrl/rutas',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        // Parsear la lista de rutas desde el JSON
        List<dynamic> data = response.data['rutas'];
        List<RutaTuristica> rutas = data.map((rutaJson) {
          return RutaTuristica.fromJson(rutaJson);
        }).toList();

        dio.close();
        return rutas;
      } else {
        throw Exception('Error al obtener las rutas: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error: $e');
    }
    // Cerrar el cliente
  }
}
