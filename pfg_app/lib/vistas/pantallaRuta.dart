import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:pfg_app/vistas/elementos/lugaresPasoTree.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Pantalla para mostrar información sobre una ruta.
class PantallaRuta extends StatefulWidget {
  // Ruta sobre la que mostrar información
  final RutaTuristica ruta;

  const PantallaRuta({required this.ruta});

  @override
  _PantallaRutaState createState() => _PantallaRutaState();
}

class _PantallaRutaState extends State<PantallaRuta> {
  bool esFavorito = false;
  @override
  void initState() {
    super.initState();
    // Obtener el usuario actual.
    Usuario usuario = Controlador().getUsuario();

    // Obtener la lista de nombres de las rutas favoritas del usuario.
    List<String> nombresRutas =
        usuario.getRutasFavoritas.map((ruta) => ruta.nombre).toList();

    // Comprobar si la ruta está dentro de las favoritas del usuario.
    esFavorito = nombresRutas.contains(this.widget.ruta.nombre);
  }

  // Manejador del evento de pulsación del botón favorito
  void _manejadorFavorito() async {
    // Si no era favorita se marca como favorita.
    if (!esFavorito) {
      Controlador().marcarFavorita(this.widget.ruta);
      esFavorito = true;
      // Si era favorita se desmarca como favorita
    } else {
      Controlador().desmarcarFavorita(this.widget.ruta);
      esFavorito = false;
    }
  }

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
                    "${widget.ruta.descripcion}",
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
            // Imagen de portada de la ruta
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
                child: Image.network(
                  widget.ruta
                      .rutaImagen, // Assuming rutaImagen is a path to an asset
                  fit: BoxFit
                      .cover, // You can adjust the fit based on your needs
                ),
              ),
            ),
            // Widget ListaLugares
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.02,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.22,
                child: ListaLugares(
                  lugares: widget.ruta.getLugares,
                  ruta: this.widget.ruta,
                ),
              ),
            ),
            // Información sobre tiempo estimado de recorrido, distancia y marcar/desmarcar como favorito
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/clock.svg',
                    semanticsLabel: 'Reloj',
                    height: MediaQuery.of(context).size.height * 0.04,
                    width: MediaQuery.of(context).size.width * 0.04,
                    color: ColoresAplicacion.colorLetrasPrincipal,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.01,
                        right: MediaQuery.of(context).size.width * 0.07),
                    child: Text(
                      widget.ruta.duracion,
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
                  SvgPicture.asset(
                    'assets/images/distance.svg',
                    semanticsLabel: 'Distancia',
                    height: MediaQuery.of(context).size.height * 0.04,
                    width: MediaQuery.of(context).size.width * 0.04,
                    // ignore: deprecated_member_use
                    color: ColoresAplicacion.colorLetrasPrincipal,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.01,
                    ),
                    child: Text(
                      '${widget.ruta.distancia} km',
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
                      left: MediaQuery.of(context).size.width * 0.04,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _manejadorFavorito();
                        });
                      },
                      child: Icon(
                        Icons.favorite,
                        color: esFavorito ? Colors.red : Colors.black,
                        size: MediaQuery.of(context).size.width * 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Etiqueta descripción de la ruta
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.01),
              child: Text(
                AppLocalizations.of(context)!.descripcion,
                style: const TextStyle(
                  color: ColoresAplicacion.colorLetrasPrincipal,
                  fontFamily: 'Inter',
                  fontSize: 25,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
            // Descripción de la ruta
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.00,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.27,
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
                    child:
                        ListView(padding: const EdgeInsets.all(10), children: [
                      Text(
                        "${widget.ruta.descripcion}",
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
                  onTap: () => _mostrarDescripcion(context)),
            ),

            // Botón Iniciar Ruta
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: GestureDetector(
                  onTap: () {
                    Controlador().iniciarRuta(this.widget.ruta, context);
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.07,
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
                                left: MediaQuery.of(context).size.width * 0.3,
                                right:
                                    MediaQuery.of(context).size.width * 0.02),
                            child: Icon(Icons.start_outlined,
                                color: ColoresAplicacion.colorFondo, size: 30),
                          ),
                          Text(
                            AppLocalizations.of(context)!.iniciar,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: ColoresAplicacion.colorFondo,
                                fontFamily: 'Inter',
                                fontSize: 30,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.bold,
                                height: 1),
                          )
                        ],
                      )))),
            ),
          ],
        ),
      ),
    );
  }
}
