// TODO: Bug cuando pulsas 2 veces seguidas boton anterior o siguiente
import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import '../constants/color.dart';
import '../controlador/controlador.dart';

class PantallaLugarInteres extends StatefulWidget {
  LugarInteres lugar;
  PantallaLugarInteres({super.key, required this.lugar});

  @override
  _PantallaLugarInteresState createState() => _PantallaLugarInteresState();
}

class _PantallaLugarInteresState extends State<PantallaLugarInteres> {
  int indice = 0;

  void setSiguienteIndice() {
    setState(() {
      indice = (indice + 1) % (widget.lugar.fotos.length);
    });
  }

  void setAnteriorIndice() {
    setState(() {
      indice = (indice - 1) % (widget.lugar.fotos.length);
    });
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
                '${this.widget.lugar.getNombre}',
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
                height: MediaQuery.of(context).size.height * 0.30,
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
                child: Image.network(widget.lugar.getFotos.elementAt(indice)),
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
                                  'Anterior Imagen',
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
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.0,
                      left: MediaQuery.of(context).size.width * 0.1),
                  child: GestureDetector(
                      onTap: () {
                        setSiguienteIndice();
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
                                Icon(Icons.arrow_forward,
                                    color: ColoresAplicacion.colorFondo,
                                    size: MediaQuery.of(context).size.height *
                                        0.03),
                                const Text(
                                  'Siguiente Imagen',
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
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.01),
              child: Row(
                children: [
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05),
                    child: ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                ColoresAplicacion.colorPrimario)),
                        onPressed: () => {},
                        child: const Icon(
                          Icons.voice_chat,
                          color: ColoresAplicacion.colorFondo,
                        )),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.00,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border(
                      bottom: BorderSide(width: 1),
                      left: BorderSide(width: 1),
                      right: BorderSide(width: 1),
                      top: BorderSide(width: 1),
                    )),
                child: ListView(padding: EdgeInsets.all(10), children: [
                  Text(
                    "${widget.lugar.descripcion}",
                    style: const TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 12,
                      letterSpacing: 0,
                      fontWeight: FontWeight.normal,
                      height: 1,
                    ),
                  )
                ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: Text(
                        'Volver a la Ruta',
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
