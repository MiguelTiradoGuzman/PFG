import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/adapter.dart';
import 'package:http/http.dart' as http;
import '../modelo/usuario.dart';
import 'package:dio/dio.dart';

class API {
  static final API _instance = API._internal();
  factory API() => _instance;

  API._internal();

  final String _baseUrl = 'https://192.168.1.140';
  String _token = '';

  String get token => _token;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convierte la contraseña a bytes.
    var digest = sha256.convert(bytes); // Calcula el hash SHA-256.
    return digest.toString();
  }

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
}
