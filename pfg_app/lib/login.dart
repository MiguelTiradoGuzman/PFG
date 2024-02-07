import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';

class PantallainiciosesinregistroWidget extends StatefulWidget {
  const PantallainiciosesinregistroWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PantallainiciosesinregistroWidgetState createState() =>
      _PantallainiciosesinregistroWidgetState();
}

class _PantallainiciosesinregistroWidgetState
    extends State<PantallainiciosesinregistroWidget> {
  @override
  Widget build(BuildContext context) {
    // Figma Flutter Generator PantallainiciosesinregistroWidget - FRAME
    return MaterialApp(
      home: Scaffold(
          body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
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
                          color: const Color.fromRGBO(255, 252, 252, 1),
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
                      color: const Color.fromRGBO(227, 0, 53, 1),
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
                            color: const Color.fromRGBO(0, 0, 0, 1),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.02),
                          child: const TextField(
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'ejemplo@correo.ugr.es',
                                  hintStyle: TextStyle(
                                      color: Color.fromRGBO(0, 0, 0, 1),
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
                          color: Color.fromRGBO(0, 0, 0, 1),
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
                            color: const Color.fromRGBO(0, 0, 0, 1),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.02),
                          child: const TextField(
                              obscureText: true,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '* * * * * * *',
                                  hintStyle: TextStyle(
                                      color: Color.fromRGBO(0, 0, 0, 1),
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
                          color: Color.fromRGBO(0, 0, 0, 1),
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
                        onTap: () {
                          // Acciones que deseas realizar al hacer clic en el botón
                        },
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
                              color: Color.fromRGBO(227, 0, 53, 1),
                            ),
                            child: const Center(
                                child: Text(
                              'Iniciar Sesión',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
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
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          border: Border.all(
                            color: const Color.fromRGBO(227, 0, 53, 1),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                            child: Text(
                          'Registrar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color.fromRGBO(227, 0, 53, 1),
                              fontFamily: 'Inter',
                              fontSize: 20,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        )),
                      ),
                    )),
              ]))),
    );
  }
}
