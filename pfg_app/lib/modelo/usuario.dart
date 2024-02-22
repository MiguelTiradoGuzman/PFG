import 'dart:convert';

class Usuario {
  String username;
  Usuario({required this.username});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      username: json['username'],
    );
  }

  String get getUsername => username;
}
