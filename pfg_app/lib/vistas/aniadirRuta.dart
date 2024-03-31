import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:pfg_app/vistas/elementos/tarjetaLugar.dart';
import 'package:pfg_app/test/test_const.dart';

double tamTitulos = 23;

class AniadirRuta extends StatefulWidget {
  final Usuario usuario;
  const AniadirRuta({required this.usuario});

  @override
  // ignore: library_private_types_in_public_api
  _AniadirRutaState createState() => _AniadirRutaState();
}

class _AniadirRutaState extends State<AniadirRuta> {
  final TextEditingController _nombreRuta = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();

  String _contrasenaErrorText = '';
  late List<LugarInteres> lugaresInteres;

  void _mostrarMenuEditarDescripcion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 4),
          title: Text('Editar Descripción'),
          content: SizedBox(
            // Ajusta el tamaño del contenido del diálogo
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: TextFormField(
              initialValue: _descripcion.text,
              onChanged: (value) {
                setState(() {
                  _descripcion.text = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Ingrese la nueva descripción',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Aquí puedes realizar alguna acción con la nueva descripción
                // Por ejemplo, enviarla a la API
                print('Nueva descripción: $_descripcion');
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  File? image;
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
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
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: TextField(
                style: TextStyle(
                    color: ColoresAplicacion.colorLetrasPrincipal,
                    fontFamily: 'Inter',
                    fontSize: 25,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    height: 1),
                decoration: const InputDecoration(
                    icon: Icon(Icons.edit),
                    border: InputBorder.none,
                    hintText: 'Introduce un nombre',
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
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.11,
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
                child: image != null
                    ? Image.file(
                        image!,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/alhambra.jpeg',
                        fit: BoxFit.cover,
                      ),
                // You can adjust the fit based on your needs
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: () {
                    pickImage();
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
                      'Modificar Imagen',
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
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: () {
                    _mostrarMenuEditarDescripcion(context);
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
                      color: ColoresAplicacion.colorPrimario,
                      border: Border.all(
                        color: ColoresAplicacion.colorPrimario,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                        child: Text(
                      'Modificar Descripción',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColoresAplicacion.colorLetrasSecundario,
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
                      'Lugares de Interés',
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

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColoresAplicacion.colorPrimario,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.add,
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
                  top: MediaQuery.of(context).size.height * 0.0,
                  left: MediaQuery.of(context).size.width * 0.04,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.9, // Ancho total del 90%

                  // TODO: El size height estaba a 52, lo cambio al no usar un listview builder
                  height: MediaQuery.of(context).size.height * 0.32,

                  child: Column(
                    children: [
                      TarjetaLugarInteres(
                          lugarInteres: ClaseTest().lugares.elementAt(0)),
                      TarjetaLugarInteres(
                          lugarInteres: ClaseTest().lugares.elementAt(1))
                    ],
                  ),
                  // child: ListView.builder(
                  //   padding: const EdgeInsets.only(top: 0.1),
                  //   scrollDirection: Axis.vertical,
                  //   // itemCount: widget.lugaresInteres.length,
                  //   // itemBuilder: (context, index) {
                  //   //   lugaresInteres ruta = widget.lugaresInteres[index];

                  //   //   return TarjetaLugar(lugarInteres: ruta);
                  //   // },
                  // ),
                )),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: GestureDetector(
                  onTap: () {},
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
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
                      child: const Center(
                          child: Text(
                        'Añadir Ruta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColoresAplicacion.colorFondo,
                            fontFamily: 'Inter',
                            fontSize: 30,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      )))),
            ),
          ]),
    ));
  }
}
