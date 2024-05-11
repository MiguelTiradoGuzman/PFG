import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:model_viewer_plus/model_viewer_plus.dart';

enum TtsState { playing, stopped, paused, continued }

// Pantalla de descripción del lugar de interés
// ignore: must_be_immutable
class PantallaLugarInteres extends StatefulWidget {
  // Lugar de interés sobre el que mostrar información.
  LugarInteres lugar;
  PantallaLugarInteres({super.key, required this.lugar});

  @override
  _PantallaLugarInteresState createState() => _PantallaLugarInteresState();
}

class _PantallaLugarInteresState extends State<PantallaLugarInteres> {
  // Variable para controlar el botón a mostrar
  bool reproducir = false;
  // Controlador del paquete TextToSpeech
  late FlutterTts flutterTts;
  // Lenguaje del usuario.
  String? idioma;
  // Identificador del motor de lectura
  String? motor;
  // Volumen del lector. Por defecto al máximo para que se pueda controlar a través de los botones del dispositivo.
  double volumen = 1.0;
  // Tono de la voz del lector
  double tono = 1.0;
  // Número de palabras por segundo
  double rate = 0.5;
  //Estado del reproductor
  TtsState ttsState = TtsState.stopped;
  // Variable para controlar el final del texto a leer
  int end = 0;
  String _textoVoz = "";

  // Método para mostrar la descripción del lugar de interés en mayor tamaño
  void _mostrarDescripcion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.descripcion),
          // contentPadding: EdgeInsets.symmetric(horizontal: 48.0),
          elevation: 0, // Ajusta el ancho del contenido
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  // Envuelve el texto en un contenedor para ajustar el ancho
                  width: MediaQuery.of(context).size.width *
                      0.9, // Utiliza el ancho deseado
                  child: Text(
                    "${widget.lugar.descripcion}",
                    style: const TextStyle(
                      color: Colors
                          .black, // ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20, // Tamaño mayor para el mensaje flotante
                      letterSpacing: 0,
                      fontWeight: FontWeight.normal,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      ColoresAplicacion.colorPrimario)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cerrar,
                  style: const TextStyle(
                    color: ColoresAplicacion.colorFondo,
                    fontFamily: 'Inter',
                    fontSize: 20,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  )),
            ),
          ],
        );
      },
    );
  }

  // Funciones preimplementadas. Obtener el Motor por defecto del dispositivo.
  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  // Obtener la voz por defecto
  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  // Leer el texto de descripción del lugar de interés.
  Future<void> _speak() async {
    await flutterTts.setVolume(volumen);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(tono);

    if (widget.lugar.descripcion != null) {
      if (widget.lugar.descripcion!.isNotEmpty) {
        await flutterTts.speak(widget.lugar.descripcion!);
      }
    }
  }

  // Funciones preimplementadas
  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  // Parar de leer. Reinicia la lectura.
  Future<void> _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  // Pausa la lectura. Al volver a puldar el botón, sigue leyendo por la última palabra por donde se quedó.
  Future<void> _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  // Booleano de manejo si el dispositivo es android.
  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  // Inicializar el servicio Text To Speech
  dynamic initTts() {
    // Establece ell texto a leer.
    _textoVoz = widget.lugar.descripcion;
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    // Manejadores de eventos por defecto
    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      setState(() {
        end = endOffset;
      });
    });
  }

  // Construir barra de progreso. Se divide el tiempo en leer entre el número de palabras total a leer para indicar el progreso.
  Widget _barraProgreso(int end) => Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: LinearProgressIndicator(
        backgroundColor: Colors.red,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        value: end / _textoVoz!.length,
      ));

  // Función para construir la sección del lector de texto.
  Widget _construirSeccionLectura() {
    return Column(
      children: [_seccionBotones(), _barraProgreso(end)],
    );
  }

  // Función para construir un botón en una columna. Se le pasa por parámetro el color, color de pulsación, icono, etiqueta y función.
  Column _construirBoton(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }

  // Constructor de la sección de botones del lector de textos.
  Widget _seccionBotones() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          (ttsState == TtsState.paused || ttsState == TtsState.stopped)
              ? _construirBoton(Colors.green, Colors.greenAccent,
                  Icons.play_arrow, 'Reproducir', _speak)
              : _construirBoton(
                  Colors.blue, Colors.blueAccent, Icons.pause, 'Pausar', _pause)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initTts();
  }

  // Índice de la imagen a mostrar
  int indice = 0;

  // Manejador del botón: Siguiente Imagen.
  // Suma 1 en el índice, marcando a la siguiente imagen del lugar de interés.
  void setSiguienteIndice() {
    setState(() {
      indice = (indice + 1) % (widget.lugar.recursos.length);
    });
  }

  // Manejador del botón: Anterior Imagen.
  // Resta 1 en el índice, marcando a la anterior imagen del lugar de interés.
  void setAnteriorIndice() {
    setState(() {
      indice = (indice - 1) % (widget.lugar.recursos.length);
    });
  }

  void _cambiarModoEscucha() {
    setState(() {
      reproducir = !reproducir;
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
            // Espacio para mostrar los recursos del lugar de interés
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.30,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      offset: Offset(0, 4),
                      blurRadius: 4,
                    )
                  ],
                  image: widget.lugar.getRecursos.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                              widget.lugar.getRecursos.elementAt(indice)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                clipBehavior: Clip.hardEdge,
                child: widget.lugar.getRecursos.isNotEmpty &&
                        widget.lugar.getRecursos
                            .elementAt(indice)
                            .endsWith('.glb')
                    ? Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModelViewer(
                                  backgroundColor:
                                      Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
                                  src: widget.lugar.recursos.elementAt(indice),
                                  alt: widget.lugar.getNombre,
                                  ar: true,
                                  autoRotate: true,
                                  iosSrc:
                                      widget.lugar.recursos.elementAt(indice),
                                  disableZoom: true,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 60, // Tamaño del botón
                            height: 60, // Tamaño del botón
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // Forma circular
                              color: Colors.grey[200], // Color del botón
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_arrow,
                                size: 40, // Tamaño del icono
                                color: Colors.black, // Color del icono
                              ),
                            ),
                          ),
                        ))
                    : null,
              ),
            ),
            // Botón para mostrar el anterior recurso
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: this.widget.lugar.recursos.length > 1
                  ? Row(children: [
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
                                      Icon(Icons.arrow_back,
                                          color: ColoresAplicacion.colorFondo,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.03),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .anteriorImagen,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
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
                      // Botón para mostrar el siguiente recurso
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
                                            .siguienteImagen,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
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
                    ])
                  : Container(),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.01),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.descripcion,
                    style: const TextStyle(
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
                        onPressed: () => {_cambiarModoEscucha()},
                        child: reproducir == false
                            ? const Icon(
                                Icons.voice_chat,
                                color: ColoresAplicacion.colorFondo,
                              )
                            : Icon(
                                Icons.voice_over_off,
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
              child: reproducir == false
                  ? GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.20,
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
                        child: ListView(
                            padding: const EdgeInsets.all(10),
                            children: [
                              Text(
                                "${widget.lugar.descripcion}",
                                style: const TextStyle(
                                  color: ColoresAplicacion.colorLetrasPrincipal,
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1,
                                ),
                              )
                            ]),
                      ),
                      onTap: () => _mostrarDescripcion(context))
                  : _construirSeccionLectura(),
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
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.15,
                            right: MediaQuery.of(context).size.width * 0.02),
                        child: Icon(Icons.door_back_door,
                            color: ColoresAplicacion.colorPrimario, size: 30),
                      ),
                      Text(
                        AppLocalizations.of(context)!.volverRuta,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: ColoresAplicacion.colorPrimario,
                            fontFamily: 'Inter',
                            fontSize: 25,
                            letterSpacing:
                                0 /*percentages not used in flutter. defaulting to zero*/,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      )
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
