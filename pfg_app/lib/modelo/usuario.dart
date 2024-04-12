import 'dart:convert';

class Usuario {
  String username;
  String email;

  Usuario({required this.username, required this.email});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(username: json['nombre'], email: json['email']);
  }

  String get getUsername => username;
  String get getCorreo => email;
}
