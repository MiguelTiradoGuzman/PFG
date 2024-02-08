import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import '../controlador/controlador.dart';
import '../constants/color.dart';

class PaginaLogin extends StatefulWidget {
  const PaginaLogin({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaginaLoginState createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final Controlador _controlador = Controlador();
  Future<void> _iniciarSesion() async {
    String correo = _correoController.text;
    String contrasena = _contrasenaController.text;

    try {
      await _controlador.login(correo, contrasena);
    } catch (e) {
      // Error al iniciar sesión, muestra un SnackBar con el mensaje de error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicio de sesión fallido. Verifica tus credenciales.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Figma Flutter Generator PaginaLogin - FRAME
    return Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: ColoresAplicacion.colorFondo,
            ),
            child: Stack(children: <Widget>[
              Positioned(
                  top: MediaQuery.of(context).size.height * -0.25,
                  // left: -1,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/alhambra.jpeg'),
                            fit: BoxFit.fitWidth),
                      ))),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: 0,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: ColoresAplicacion.colorFondo,
                        borderRadius: BorderRadius.all(Radius.elliptical(
                            MediaQuery.of(context).size.width * 1.7,
                            MediaQuery.of(context).size.height)),
                      ))),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  left: MediaQuery.of(context).size.width * 0.3,
                  child: SvgPicture.asset(
                    'assets/images/user-circle.svg',
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.height,
                    semanticsLabel: 'User',
                    color: ColoresAplicacion.colorPrimario,
                  )),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.50,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: Container(
                      width: 264,
                      height: 39,
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
                                    color:
                                        ColoresAplicacion.colorLetrasPrincipal,
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    height: 1))),
                      ))),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.47,
                  left: MediaQuery.of(context).size.width * 0.15,
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
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.6,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: Container(
                      width: 264,
                      height: 39,
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
                                    height: 1))),
                      ))),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.57,
                  left: MediaQuery.of(context).size.width * 0.15,
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
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.7,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: GestureDetector(
                      onTap: _iniciarSesion,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(65),
                              topRight: Radius.circular(65),
                              bottomLeft: Radius.circular(65),
                              bottomRight: Radius.circular(65),
                            ),
                            color: ColoresAplicacion.colorPrimario,
                          ),
                          child: const Center(
                              child: Text(
                            'Iniciar Sesión',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColoresAplicacion.colorFondo,
                                fontFamily: 'Inter',
                                fontSize: 20,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.bold,
                                height: 1),
                          ))))),
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.8,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.07,
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
                        'Registrar',
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
            ])));
  }
}
