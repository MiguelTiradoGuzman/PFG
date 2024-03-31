import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:pfg_app/vistas/elementos/tarjetaLugar.dart';
import 'package:pfg_app/test/test_const.dart';
import 'package:pfg_app/vistas/elementos/ubicacionMapa.dart';

double tamTitulos = 23;

class AniadirModificarLugar extends StatefulWidget {
  late RutaTuristica ruta;
  LugarInteres? lugar;
  late UbicacionMapa mapa;
  AniadirModificarLugar(
      BuildContext context, LugarInteres? l, RutaTuristica r) {
    lugar = l;
    ruta = r;
    mapa = UbicacionMapa();
  }

  @override
  // ignore: library_private_types_in_public_api
  _AniadirModificarLugarState createState() => _AniadirModificarLugarState();
}

class _AniadirModificarLugarState extends State<AniadirModificarLugar> {
  final TextEditingController _nombreLugar = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _descripcionTmp = TextEditingController();
  final TextEditingController _latitudController = TextEditingController();
  final TextEditingController _longitudController = TextEditingController();
  double? _latitud, _longitud;
  String _contrasenaErrorText = '';
  late List<LugarInteres> lugaresInteres;

  void _mostrarMenuEditarDescripcion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: const Text('Editar Descripción'),
          content: SizedBox(
            // Ajusta el tamaño del contenido del diálogo
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: TextFormField(
              initialValue: _descripcion.text,
              onChanged: (value) {
                setState(() {
                  _descripcionTmp.text = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Ingrese la nueva descripción',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                setState(() {
                  _descripcionTmp.text = _descripcion.text;
                });
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                setState(() {
                  _descripcion.text = _descripcionTmp.text;
                });
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _latitud = this.widget.mapa.obtenerPosicion()?.target.latitude;
    _longitud = this.widget.mapa.obtenerPosicion()?.target.longitude;
  }

  // void _mostrarMenuLocalizacion(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return
  //           // Padding(
  //           //   padding: EdgeInsets.only(
  //           //     top: MediaQuery.of(context).size.height * 0.02,
  //           //     left: MediaQuery.of(context).size.width * 0.05,
  //           //   ),
  //           //   child:
  //           AlertDialog(
  //         contentPadding: EdgeInsets.zero,
  //         content: SizedBox(
  //           width: MediaQuery.of(context).size.width * 1,
  //           height: MediaQuery.of(context).size.height * 0.9,
  //           child: Container(
  //             decoration: const BoxDecoration(
  //               borderRadius: BorderRadius.only(
  //                 topLeft: Radius.circular(30),
  //                 topRight: Radius.circular(30),
  //                 bottomLeft: Radius.circular(30),
  //                 bottomRight: Radius.circular(30),
  //               ),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Color.fromRGBO(0, 0, 0, 0.25),
  //                   offset: Offset(0, 4),
  //                   blurRadius: 4,
  //                 )
  //               ],
  //             ),
  //             clipBehavior: Clip.hardEdge,
  //             child: Stack(
  //               children: [
  //                 this.widget.mapa,
  //                 Align(
  //                   alignment: Alignment.center,
  //                   child: Icon(
  //                     Icons.location_pin,
  //                     size: 40,
  //                     color: Colors.red,
  //                   ),
  //                 ),
  //                 Positioned(
  //                   top: 10,
  //                   right: 10,
  //                   child: ElevatedButton(
  //                     onPressed: () {
  //                       late CameraPosition? pos =
  //                           this.widget.mapa.obtenerPosicion();
  //                       if (pos != null) {
  //                         setState(() {
  //                           _latitud = pos.target.latitude;
  //                           _longitud = pos.target.longitude;
  //                         });
  //                       }
  //                     },
  //                     child: Text('Seleccionar'),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   top: 10,
  //                   left: 10,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text('Latitud: ${_longitud.toString()}'),
  //                       Text('Longitud: ${_latitud.toString()}'),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       )
  //           //,
  //           //)
  //           ;
  //     },
  //   );
  // }

  List<File> images = [];
  Future<File?> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      final imageTemp = File(image.path);
      return imageTemp;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  bool _nombreEnRuta() {
    bool existe = false;
    for (int i = 0; i < this.widget.ruta.lugares.length && !existe; i++) {
      if (this.widget.ruta.lugares.elementAt(i) == this._nombreLugar)
        existe = true;
    }

    return existe;
  }

  void _comprobarInformacion() {
    if (_descripcion.text.isEmpty ||
        _nombreLugar.text.isEmpty ||
        images.isEmpty) {
      // Mostrar aviso de error si falta información
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Por favor, complete todos los campos y añada al menos una imagen.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

// Validar que la latitud y longitud sean números
    double? latitud;
    double? longitud;
    try {
      latitud = double.parse(_latitudController.text);
      longitud = double.parse(_longitudController.text);
    } catch (e) {
      // Mostrar mensaje de error si no se pueden convertir a double
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'La latitud y la longitud deben ser valores numéricos.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Validar que la latitud esté en el rango [-90, 90]
    if (latitud < -90 || latitud > 90) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('La latitud debe estar en el rango [-90, 90].'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Validar que la longitud esté en el rango [-180, 180]
    if (longitud < -180 || longitud > 180) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('La longitud debe estar en el rango [-180, 180].'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_nombreEnRuta()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('El nombre del lugar ya existe en la ruta'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      return;
    }

    List dev = [];

    dev.add(LugarInteres(
        nombre: this._nombreLugar.text,
        descripcion: this._descripcion.text,
        latitud: latitud,
        longitud: longitud,
        fotos: []));
    dev.add(images);

    Navigator.pop(context, dev);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.07,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _nombreLugar.text = value;
                  });
                },
                style: const TextStyle(
                    color: ColoresAplicacion.colorLetrasPrincipal,
                    fontFamily: 'Inter',
                    fontSize: 25,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    height: 1),
                decoration: const InputDecoration(
                    icon: Icon(Icons.edit),
                    border: InputBorder.none,
                    hintText: 'Nombre del lugar',
                    hintStyle: TextStyle(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        fontFamily: 'Inter',
                        fontSize: 25,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.22,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    )
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: images.isEmpty
                    ? const Icon(Icons.add_a_photo)
                    : GridView.count(
                        crossAxisCount: 3,
                        children: List.generate(images.length, (index) {
                          return GestureDetector(
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.17,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.25),
                                      offset: Offset(0, 4),
                                      blurRadius: 4,
                                    )
                                  ],
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Image.file(
                                  images.elementAt(index),
                                  fit: BoxFit.cover,
                                )),
                            onDoubleTap: () {
                              setState(() {
                                images.remove(images.elementAt(index));
                              });
                            },
                          );
                        }),
                      ),
                // You can adjust the fit based on your needs
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: const Expanded(
                child: Text(
                  '* Doble tap en imagen para borrar',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: ColoresAplicacion.colorPrimario,
                    fontFamily: 'Inter',
                    fontSize: 18,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: () async {
                    File? image = await pickImage();
                    if (image != null)
                      setState(() {
                        images.add(image);
                      });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.05,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(65),
                        topRight: Radius.circular(65),
                        bottomLeft: Radius.circular(65),
                        bottomRight: Radius.circular(65),
                      ),
                      color: ColoresAplicacion.colorFondo,
                      border: Border.all(
                        color: ColoresAplicacion.colorPrimario,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                        child: Text(
                      'Añadir Imagen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColoresAplicacion.colorPrimario,
                          fontFamily: 'Inter',
                          fontSize: 20,
                          letterSpacing:
                              0 /*percentages not used in flutter. defaulting to zero*/,
                          fontWeight: FontWeight.bold,
                          height: 1),
                    )),
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Descripción',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        fontFamily: 'Inter',
                        fontSize: tamTitulos,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width *
                            0.05), // Ajusta el espacio a la derecha del botón

                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColoresAplicacion.colorPrimario,
                    ),
                    child: IconButton(
                      onPressed: () {
                        _mostrarMenuEditarDescripcion(context);
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: ColoresAplicacion.colorLetrasSecundario,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Establecer Ubicación',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        fontFamily: 'Inter',
                        fontSize: tamTitulos,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(
                  //       right: MediaQuery.of(context).size.width *
                  //           0.05), // Ajusta el espacio a la derecha del botón

                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     color: ColoresAplicacion.colorFondo,
                  //   ),
                  //   child: IconButton(
                  //     onPressed: () {
                  //       _mostrarMenuLocalizacion(context);
                  //     },
                  //     icon: Icon(
                  //       Icons.add_location,
                  //       color: ColoresAplicacion.colorPrimario,
                  //       size: 40,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: TextFormField(
                      controller: _latitudController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColoresAplicacion
                                  .colorPrimario), // Cambia el color aquí
                        ),
                        labelText: 'Latitud',
                        floatingLabelStyle: TextStyle(
                          color: ColoresAplicacion.colorPrimario,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _latitud = double.tryParse(value);
                        });
                      },
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: TextFormField(
                      controller: _longitudController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColoresAplicacion
                                  .colorPrimario), // Cambia el color aquí
                        ),
                        labelText: 'Longitud',
                        floatingLabelStyle:
                            TextStyle(color: ColoresAplicacion.colorPrimario),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _longitud = double.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(
            //       top: MediaQuery.of(context).size.height * 0.01,
            //       left: MediaQuery.of(context).size.width * 0.05),
            //   child: Container(
            //     width: MediaQuery.of(context).size.width * 0.9,
            //     height: MediaQuery.of(context).size.height * 0.3,
            //     decoration: const BoxDecoration(
            //         borderRadius: BorderRadius.only(
            //           topLeft: Radius.circular(20),
            //           topRight: Radius.circular(20),
            //           bottomLeft: Radius.circular(20),
            //           bottomRight: Radius.circular(20),
            //         ),
            //         border: Border(
            //           bottom: BorderSide(width: 1),
            //           left: BorderSide(width: 1),
            //           right: BorderSide(width: 1),
            //           top: BorderSide(width: 1),
            //         )),
            //     child: ListView(padding: EdgeInsets.all(10), children: [
            //       Text(
            //         "${_descripcion.text}",
            //         style: const TextStyle(
            //           color: ColoresAplicacion.colorLetrasPrincipal,
            //           fontFamily: 'Inter',
            //           fontSize: 12,
            //           letterSpacing: 0,
            //           fontWeight: FontWeight.normal,
            //           height: 1,
            //         ),
            //       )
            //     ]),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.015,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context, this.widget.lugar);
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: ColoresAplicacion.colorPrimario,
                                width: 2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            color: ColoresAplicacion.colorFondo,
                          ),
                          child: Center(
                              child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.0425,
                                    right: MediaQuery.of(context).size.width *
                                        0.015),
                                child: const Icon(Icons.cancel,
                                    color: ColoresAplicacion.colorPrimario),
                              ),
                              const Text(
                                'Cancelar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColoresAplicacion.colorPrimario,
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              )
                            ],
                          )))),
                  Padding(
                      padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.0725)),
                  GestureDetector(
                      onTap: _comprobarInformacion,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.425,
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            color: ColoresAplicacion.colorPrimario,
                          ),
                          child: Center(
                              child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.04,
                                    right: MediaQuery.of(context).size.width *
                                        0.015),
                                child: const Icon(Icons.save,
                                    color: ColoresAplicacion
                                        .colorLetrasSecundario),
                              ),
                              const Text(
                                'Guardar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColoresAplicacion.colorFondo,
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              )
                            ],
                          ))))
                ],
              ),
            ),
          ]),
    ));
  }
}
