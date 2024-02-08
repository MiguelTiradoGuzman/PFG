import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controlador/controlador.dart';
import '../modelo/usuario.dart';
import 'dart:math' as math;
import '../constants/color.dart';
import '../vistas/tarjetaRuta.dart';
import '../modelo/rutaTuristica.dart';

class PantallaInicio extends StatefulWidget {
  // final Controlador controlador;
  // final Usuario usuario;
  //final RutaTuristica rutaTuristica;

  PantallaInicio(
      //   {
      //   required this.controlador,
      //   required this.usuario,
      //   required this.rutaTuristica,
      // }
      );

  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: ColoresAplicacion.colorFondo,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: const Text(
                'Descubre Granada',
                style: TextStyle(
                  color: ColoresAplicacion.colorLetrasPrincipal,
                  fontFamily: 'Inter',
                  fontSize: 28,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
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
                  // image: DecorationImage(
                  //   image: AssetImage('assets/images/Capturamapa1.png'),
                  //   fit: BoxFit.fitWidth,
                  // ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.01),
              child: const Text(
                'Rutas disponibles',
                style: TextStyle(
                  color: ColoresAplicacion.colorLetrasPrincipal,
                  fontFamily: 'Inter',
                  fontSize: 30,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
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
                  height: MediaQuery.of(context).size.height * 0.52,
                  child: ListView(
                    padding: const EdgeInsets.only(top: 0.1),
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      TarjetaRuta(
                        rutaTuristica: RutaTuristica(
                          nombre: 'Alhambra test',
                          descripcion: 'Descripción de Alhambra',
                          distancia:
                              1.5, // Distancia en km (cambia según tu necesidad)
                          duracion: '1:45',
                          rutaImagen: 'assets/images/alhambra.jpeg',
                        ),
                      ),
                      TarjetaRuta(
                        rutaTuristica: RutaTuristica(
                          nombre: 'Alhambra test',
                          descripcion: 'Descripción de Alhambra',
                          distancia:
                              1.5, // Distancia en km (cambia según tu necesidad)
                          duracion: '1:45',
                          rutaImagen: 'assets/images/alhambra.jpeg',
                        ),
                      ),
                      TarjetaRuta(
                        rutaTuristica: RutaTuristica(
                          nombre: 'Alhambra test',
                          descripcion: 'Descripción de Alhambra',
                          distancia:
                              1.5, // Distancia en km (cambia según tu necesidad)
                          duracion: '1:45',
                          rutaImagen: 'assets/images/alhambra.jpeg',
                        ),
                      ),
                      TarjetaRuta(
                        rutaTuristica: RutaTuristica(
                          nombre: 'Alhambra test',
                          descripcion: 'Descripción de Alhambra',
                          distancia:
                              1.5, // Distancia en km (cambia según tu necesidad)
                          duracion: '1:45',
                          rutaImagen: 'assets/images/alhambra.jpeg',
                        ),
                      ),
                      TarjetaRuta(
                        rutaTuristica: RutaTuristica(
                          nombre: 'Alhambra test',
                          descripcion: 'Descripción de Alhambra',
                          distancia:
                              1.5, // Distancia en km (cambia según tu necesidad)
                          duracion: '1:45',
                          rutaImagen: 'assets/images/alhambra.jpeg',
                        ),
                      ),
                      TarjetaRuta(
                        rutaTuristica: RutaTuristica(
                          nombre: 'Alhambra test',
                          descripcion: 'Descripción de Alhambra',
                          distancia:
                              1.5, // Distancia en km (cambia según tu necesidad)
                          duracion: '1:45',
                          rutaImagen: 'assets/images/alhambra.jpeg',
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
