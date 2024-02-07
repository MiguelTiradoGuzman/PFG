import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class API {
  static final API _instance = API._internal();
  factory API() => _instance;

  API._internal();

  final String _baseUrl = 'http://192.168.1.135:8080';
  String _token = '';

  String get token => _token;
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convierte la contraseña a bytes.
    var digest = sha256.convert(bytes); // Calcula el hash SHA-256.
    return digest.toString();
  }

  Future<void> login(String username, String password) async {
    print(_baseUrl);

    final hashedPassword = _hashPassword(password);

    final response = await http.post(
      Uri.parse('$_baseUrl/login?username=$username&password=$hashedPassword'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      _token = data['access_token'];
      print('Inicio de sesión exitoso. Token: $_token');
    } else {
      throw Exception('Contraseña o Usuario incorrecto');
    }
  }
}
