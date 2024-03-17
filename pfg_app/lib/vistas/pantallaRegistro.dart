import 'package:flutter/material.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';

class PaginaRegistro extends StatefulWidget {
  const PaginaRegistro({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaginaRegistroState createState() => _PaginaRegistroState();
}

class _PaginaRegistroState extends State<PaginaRegistro> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaRepController =
      TextEditingController();
  String _contrasenaErrorText = '';

  final Controlador _controlador = Controlador();
  Future<void> _registrarUsuario() async {
    String correo = _correoController.text;
    String contrasena = _contrasenaController.text;
    String contrasenaRep = _contrasenaRepController.text;
    String nombreUsuario = _usuarioController.text;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(correo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Correo no válido!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width *
                            0.07, // Tamaño de fuente proporcional al ancho de la pantalla
                      ),
                    ),
                  ),
                ],
              )),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Cerrar',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    } else if (contrasena != contrasenaRep) {
// Error al iniciar sesión, muestra un SnackBar con el mensaje de error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Las contraseñas no coinciden',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width *
                            0.07, // Tamaño de fuente proporcional al ancho de la pantalla
                      ),
                    ),
                  ),
                ],
              )),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Cerrar',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    } else if (contrasena.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Contraseña demasiado corta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width *
                            0.07, // Tamaño de fuente proporcional al ancho de la pantalla
                      ),
                    ),
                  ),
                ],
              )),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Cerrar',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    } else {
      try {
        await Controlador()
            .registrarUsuario(nombreUsuario, contrasena, correo, context);
        await Controlador().login(correo, contrasena, context);
      } catch (e) {
        // Error al iniciar sesión, muestra un SnackBar con el mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width *
                            0.07, // Tamaño de fuente proporcional al ancho de la pantalla
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Cerrar',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

// Método para validar la longitud mínima de la contraseña
  void _validarContrasena(String value) {
    if (value.length < 5) {
      setState(() {
        _contrasenaErrorText = 'La contraseña debe tener al menos 5 caracteres';
      });
    } else {
      setState(() {
        _contrasenaErrorText = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Agregar un listener al controlador de la contraseña para validar dinámicamente
    _contrasenaController.addListener(() {
      _validarContrasena(_contrasenaController.text);
    });
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
                    top: MediaQuery.of(context).size.height * 0.1,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: const Text(
                  'Bienvenid@!',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 40,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1),
                )),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: const Text(
                  'Correo electrónico',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1),
                )),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.02),
                      child: TextField(
                          controller: _correoController,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'ejemplo@correo.ugr.es',
                              hintStyle: TextStyle(
                                  color: ColoresAplicacion.colorLetrasPrincipal,
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1))),
                    ))),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: const Text(
                  'Nombre de usuario',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1),
                )),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.02),
                      child: TextField(
                          controller: _usuarioController,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'NombreUsuario',
                              hintStyle: TextStyle(
                                  color: ColoresAplicacion.colorLetrasPrincipal,
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1))),
                    ))),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: const Text(
                  'Contraseña',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1),
                )),
            Column(
              children: [
                if (_contrasenaErrorText.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01,
                        left: MediaQuery.of(context).size.width * 0.04),
                    child: Text(
                      _contrasenaErrorText,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01,
                        left: MediaQuery.of(context).size.width * 0.05),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.15,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          border: Border.all(
                            color: ColoresAplicacion.colorLetrasPrincipal,
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.02),
                          child: TextField(
                            controller: _contrasenaController,
                            obscureText: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '* * * * * * *',
                                hintStyle: TextStyle(
                                    color:
                                        ColoresAplicacion.colorLetrasPrincipal,
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    height: 1)),
                            onChanged: (text) {
                              setState(() {
                                if (text.length < 5) {
                                  _contrasenaErrorText =
                                      'La contraseña debe tener al menos 5 caracteres';
                                } else {
                                  _contrasenaErrorText = '';
                                }
                              });
                            },
                          ),
                        )))
              ],
            ),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: const Text(
                  'Repetir Contraseña',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1),
                )),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.02),
                      child: TextField(
                          controller: _contrasenaRepController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '* * * * * * *',
                              hintStyle: TextStyle(
                                  color: ColoresAplicacion.colorLetrasPrincipal,
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1))),
                    ))),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: GestureDetector(
                  onTap: _registrarUsuario,
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
                        'Registrarme',
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
