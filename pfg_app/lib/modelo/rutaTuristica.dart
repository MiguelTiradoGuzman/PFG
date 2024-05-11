import 'dart:convert';

import 'package:pfg_app/constants/network_const.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';

class RutaTuristica {
  // Nombre del recorrido turístico
  String nombre;
  // Descripción del recorrido turístico guiado
  String descripcion;
  // Distancia en km para realizar el recorrido turístico
  double distancia;
  // Duración en formato HH:MM del recorrido
  String duracion;
  // URL de la imagen de portada del recorrido
  String rutaImagen;
  // Lista de lugares de interés a visitar durante el recorrido
  List<LugarInteres> lugares;
  String? autor;

  RutaTuristica(
      {required this.nombre,
      required this.descripcion,
      required this.distancia,
      required this.duracion,
      required this.rutaImagen,
      required this.lugares,
      this.autor});

  String get getNombre => nombre;
  String get getDescripcion => descripcion;
  double get getDistancia => distancia;
  String get getDuracion => duracion;
  String get getRutaImagen => rutaImagen;
  List<LugarInteres> get getLugares => lugares;
  String? get getAutor => autor;

  factory RutaTuristica.fromJson(Map<String, dynamic> json) {
    String img = json['ruta_imagen'];
    // Construye y devuelve una instancia de RutaTuristica
    return RutaTuristica(
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      distancia: json['distancia'].toDouble(),
      duracion: json['duracion'],
      rutaImagen: '${NetworkConst.baseUrlImagenes}/$img',
      lugares: List<LugarInteres>.from(
        json['lugares'].map((lugarJson) => LugarInteres.fromJson(lugarJson)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nombre'] = this.nombre;
    data['descripcion'] = this.descripcion;
    data['distancia'] = this.distancia;
    data['duracion'] = this.duracion;
    data['ruta_imagen'] = this.rutaImagen;
    data['lugares'] = this.lugares.map((lugar) => lugar.toJson()).toList();
    if (this.getAutor != null) {
      data['autor'] = this.getAutor;
    } else {
      data['autor'] = null;
    }

    return data;
  }
}
