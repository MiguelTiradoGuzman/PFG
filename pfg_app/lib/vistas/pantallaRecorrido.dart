// TODO: Bug cuando pulsas 2 veces seguidas boton anterior o siguiente
import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/vistas/elementos/mapaRuta.dart';
import '../constants/color.dart';
import '../modelo/rutaTuristica.dart';
import '../controlador/controlador.dart';

class PantallaRecorrido extends StatefulWidget {
  RutaTuristica ruta;
  PantallaRecorrido({super.key, required this.ruta});

  @override
  _PantallaRecorridoState createState() => _PantallaRecorridoState();
}

class _PantallaRecorridoState extends State<PantallaRecorrido> {
  int indice = 0;
  LugarInteres getLugarActual() {
    return widget.ruta.getLugares.elementAt(indice);
  }

  void setSiguienteIndice() {
    setState(() {
      indice = (indice + 1) % (widget.ruta.lugares.length);
    });
  }

  void setAnteriorIndice() {
    setState(() {
      indice = (indice - 1) % (widget.ruta.lugares.length);
    });
  }

  bool esUltimoLugar() {
    return indice == (widget.ruta.lugares.length - 1);
  }

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
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.01),
              child: Text(
                'Dirígete hacia ${getLugarActual().getNombre}',
                style: const TextStyle(
                  color: ColoresAplicacion.colorLetrasPrincipal,
                  fontFamily: 'Inter',
                  fontSize: 20,
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
                height: MediaQuery.of(context).size.height * 0.5,
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
                child: MapaRuta(getLugarActual()),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Row(children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.0,
                      left: MediaQuery.of(context).size.width * 0.0),
                  child: GestureDetector(
                      onTap: () {
                        setAnteriorIndice();
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
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
                              child: Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.01),
                            child: Column(
                              children: [
                                Icon(Icons.arrow_back,
                                    color: ColoresAplicacion.colorFondo,
                                    size: MediaQuery.of(context).size.height *
                                        0.03),
                                const Text(
                                  'Anterior Lugar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: ColoresAplicacion.colorFondo,
                                      fontFamily: 'Inter',
                                      fontSize: 17,
                                      letterSpacing:
                                          0 /*percentages not used in flutter. defaulting to zero*/,
                                      fontWeight: FontWeight.bold,
                                      height: 1),
                                )
                              ],
                            ),
                          )))),
                ),
                esUltimoLugar()
                    ? Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.0,
                            left: MediaQuery.of(context).size.width * 0.1),
                        child: GestureDetector(
                            onTap: () {
                              Controlador().cargaPaginaInicial(context);
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
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
                                    child: Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.01),
                                  child: Column(
                                    children: [
                                      Icon(Icons.flag,
                                          color: ColoresAplicacion.colorFondo,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.03),
                                      const Text(
                                        'Finalizar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: ColoresAplicacion.colorFondo,
                                            fontFamily: 'Inter',
                                            fontSize: 17,
                                            letterSpacing:
                                                0 /*percentages not used in flutter. defaulting to zero*/,
                                            fontWeight: FontWeight.bold,
                                            height: 1),
                                      )
                                    ],
                                  ),
                                )))),
                      )
                    : Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.0,
                            left: MediaQuery.of(context).size.width * 0.1),
                        child: GestureDetector(
                            onTap: () {
                              setSiguienteIndice();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
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
                                    child: Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.01),
                                  child: Column(
                                    children: [
                                      Icon(Icons.arrow_forward,
                                          color: ColoresAplicacion.colorFondo,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.03),
                                      const Text(
                                        'Siguiente Lugar',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: ColoresAplicacion.colorFondo,
                                            fontFamily: 'Inter',
                                            fontSize: 17,
                                            letterSpacing:
                                                0 /*percentages not used in flutter. defaulting to zero*/,
                                            fontWeight: FontWeight.bold,
                                            height: 1),
                                      )
                                    ],
                                  ),
                                )))),
                      )
              ]),
            )
          ],
        ),
      ),
    );
  }
}
