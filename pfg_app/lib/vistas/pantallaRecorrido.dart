// TODO: Bug cuando pulsas 2 veces seguidas boton anterior o siguiente
import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/vistas/elementos/mapaRuta.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// PantallaRecorrido: El usuario puede ver el mapa y obtener indicaciones
// ignore: must_be_immutable
class PantallaRecorrido extends StatefulWidget {
  // Ruta que se está realizando
  RutaTuristica ruta;
  PantallaRecorrido({super.key, required this.ruta});

  @override
  _PantallaRecorridoState createState() => _PantallaRecorridoState();
}

class _PantallaRecorridoState extends State<PantallaRecorrido> {
  // Índice del lugar que se va a visitar
  int indice = 0;
  // Obtener el lugar que marca el índice actual
  LugarInteres getLugarActual() {
    return widget.ruta.getLugares.elementAt(indice);
  }

  // Manejador del botón: Siguiente Lugar.
  // Suma 1 en el índice, marcando al siguiente lugar de interés en la ruta.
  void setSiguienteIndice() {
    setState(() {
      indice = (indice + 1) % (widget.ruta.lugares.length);
    });
  }

  // Manejador del botón: Anterior Lugar.
  // Resta 1 en el índice, marcando al anterior lugar de interés en la ruta.
  void setAnteriorIndice() {
    setState(() {
      indice = (indice - 1) % (widget.ruta.lugares.length);
    });
  }

  // Comprobación para saber si es el último lugar de interés a visitar en la ruta.
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
            // Etiqueta: Dirígete hacia
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.01),
              child: Text(
                AppLocalizations.of(context)!
                    .dirigeteHacia(getLugarActual().getNombre),
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
            // MapaRuta
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.57,
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
            // Botones siguiente lugar y anterior lugar
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
                                Text(
                                  AppLocalizations.of(context)!.anteriorLugar,
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
                // Si es el último lugar de interés, se carga botón de finalizar ruta.
                esUltimoLugar()
                    ? Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.0,
                            left: MediaQuery.of(context).size.width * 0.1),
                        child: GestureDetector(
                            onTap: () {
                              Controlador().cargaPantallaInicial(context);
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
                                      Text(
                                        AppLocalizations.of(context)!.finalizar,
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
                                      Text(
                                        AppLocalizations.of(context)!
                                            .siguienteLugar,
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
            ),
            // Botón Más Información
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: GestureDetector(
                onTap: () {
                  Controlador().cargaPantallaLugarInteres(
                      context, getLugarActual(), widget.ruta);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.08,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    color: ColoresAplicacion.colorFondo,
                    border: Border.all(
                      color: ColoresAplicacion.colorPrimario,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05,
                            right: MediaQuery.of(context).size.width * 0.15),
                        child: Icon(Icons.info,
                            color: ColoresAplicacion.colorPrimario),
                      ),
                      Center(
                          child: Text(
                        AppLocalizations.of(context)!.heLlegado,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColoresAplicacion.colorPrimario,
                            fontFamily: 'Inter',
                            fontSize: 25,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      ))
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
