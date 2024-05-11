import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/filtro/controladorFiltro.dart';
import 'package:pfg_app/modelo/filtro/filtroDistancia.dart';
import 'package:pfg_app/modelo/filtro/filtroDuracion.dart';
import 'package:pfg_app/modelo/filtro/filtroNombreLugar.dart';
import 'package:pfg_app/modelo/filtro/filtroNombreRuta.dart';
import 'package:pfg_app/vistas/elementos/ubicacionMapa.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';
import 'elementos/tarjetaRuta.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';

class PantallaInicio extends StatefulWidget {
  final List<RutaTuristica> rutas;
  final posicionActual;
  PantallaInicio({required this.rutas, required this.posicionActual});

  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  // Controlador del campo de texto del buscador
  final TextEditingController _controladorBuscador = TextEditingController();

  // Lista de rutas filtradas
  List<RutaTuristica> rutasFiltradas = [];

  // Lista de nombres de lugares de interés. Información para el filtrado de rutas
  List<String> nombresLugaresInteres = [''];

  // Controladores de los campos de texto de lugares de interés
  List<TextEditingController> _controladoresLugares = [TextEditingController()];

  // Controlador del campo de texto del nombre de la ruta dentro del filtro
  TextEditingController _controladorRuta = TextEditingController();

  // Controlador del campo de texto de la duración mínima.
  TextEditingController _controladorDuracionMinima = TextEditingController();

  // Controlador del campo de texto de la duración máxima.
  TextEditingController _controladorDuracionMaxima = TextEditingController();

  // Valor de distancia mínima en el filtro
  double? distanciaMinima = null;

  // Valor de distancia máxima para filtrar
  double? distanciaMaxima = null;

  @override
  void initState() {
    super.initState();
    _controladorRuta = TextEditingController();
    _controladorDuracionMinima = TextEditingController();
    _controladorDuracionMaxima = TextEditingController();
    _controladoresLugares = [TextEditingController()];
    rutasFiltradas.addAll(widget.rutas);
    rutasFiltradas.sort((ruta1, ruta2) {
      double distancia1 = distanciaEntrePosiciones(
          widget.posicionActual,
          Position(
            latitude: ruta1.lugares.first.latitud,
            longitude: ruta1.lugares.first.longitud,
            timestamp: DateTime.now(), // Ejemplo de timestamp
            accuracy: 0.0, // Ejemplo de accuracy
            altitude: 0.0, // Ejemplo de altitude
            heading: 0.0, // Ejemplo de heading
            speed: 0.0, // Ejemplo de speed
            speedAccuracy: 0.0, // Ejemplo de speedAccuracy
          ));
      double distancia2 = distanciaEntrePosiciones(
          widget.posicionActual,
          Position(
            latitude: ruta2.lugares.first.latitud,
            longitude: ruta2.lugares.first.longitud,
            timestamp: DateTime.now(), // Ejemplo de timestamp
            accuracy: 0.0, // Ejemplo de accuracy
            altitude: 0.0, // Ejemplo de altitude
            heading: 0.0, // Ejemplo de heading
            speed: 0.0, // Ejemplo de speed
            speedAccuracy: 0.0, // Ejemplo de speedAccuracy
          ));

      return distancia1.compareTo(distancia2);
    });
  }

  // Método para filtrar rutas. Buscador simple.
  void filtrarRutas(String nombreRuta) {
    // Si la query está vacía se muestran todas las rutas en orden de distancia hacia el primer lugar de interés
    if (nombreRuta == "") {
      setState(() {
        // Establece rutasFiltradas a todas las rutas obtenidas inicialmente.
        rutasFiltradas = widget.rutas;
        rutasFiltradas.sort((ruta1, ruta2) {
          // Filtrado por distancia desde la posición actual hasta el primer lugar de interés
          double distancia1 = distanciaEntrePosiciones(
              widget.posicionActual,
              Position(
                latitude: ruta1.lugares.first.latitud,
                longitude: ruta1.lugares.first.longitud,
                timestamp: DateTime.now(), // Ejemplo de timestamp
                accuracy: 0.0, // Ejemplo de accuracy
                altitude: 0.0, // Ejemplo de altitude
                heading: 0.0, // Ejemplo de heading
                speed: 0.0, // Ejemplo de speed
                speedAccuracy: 0.0, // Ejemplo de speedAccuracy
              ));
          double distancia2 = distanciaEntrePosiciones(
              widget.posicionActual,
              Position(
                latitude: ruta2.lugares.first.latitud,
                longitude: ruta2.lugares.first.longitud,
                timestamp: DateTime.now(), // Ejemplo de timestamp
                accuracy: 0.0, // Ejemplo de accuracy
                altitude: 0.0, // Ejemplo de altitude
                heading: 0.0, // Ejemplo de heading
                speed: 0.0, // Ejemplo de speed
                speedAccuracy: 0.0, // Ejemplo de speedAccuracy
              ));
          return distancia1.compareTo(distancia2);
        });
      });
    } else {
      // Si no es una query vacía, se muestran aquellas rutas cuyo nombre comience por el string pasado por parámetro.
      setState(() {
        rutasFiltradas = widget.rutas
            .where((ruta) =>
                ruta.nombre.toLowerCase().startsWith(nombreRuta.toLowerCase()))
            .toList();
        rutasFiltradas.sort((ruta1, ruta2) {
          double distancia1 = distanciaEntrePosiciones(
              widget.posicionActual,
              Position(
                latitude: ruta1.lugares.first.latitud,
                longitude: ruta1.lugares.first.longitud,
                timestamp: DateTime.now(), // Ejemplo de timestamp
                accuracy: 0.0, // Ejemplo de accuracy
                altitude: 0.0, // Ejemplo de altitude
                heading: 0.0, // Ejemplo de heading
                speed: 0.0, // Ejemplo de speed
                speedAccuracy: 0.0, // Ejemplo de speedAccuracy
              ));
          double distancia2 = distanciaEntrePosiciones(
              widget.posicionActual,
              Position(
                latitude: ruta2.lugares.first.latitud,
                longitude: ruta2.lugares.first.longitud,
                timestamp: DateTime.now(), // Ejemplo de timestamp
                accuracy: 0.0, // Ejemplo de accuracy
                altitude: 0.0, // Ejemplo de altitude
                heading: 0.0, // Ejemplo de heading
                speed: 0.0, // Ejemplo de speed
                speedAccuracy: 0.0, // Ejemplo de speedAccuracy
              ));

          return distancia1.compareTo(distancia2);
        });
      });
    }
  }

  // Método para calcular distancia entre posiciones
  double distanciaEntrePosiciones(Position posicion1, Position posicion2) {
    // Cálculo de distancia entre posiciones utilizando el paquete Geolocator
    double distancia = Geolocator.distanceBetween(posicion1.latitude,
        posicion1.longitude, posicion2.latitude, posicion2.longitude);
    return distancia;
  }

  // Agregrar un nuevo lugar de interés
  void agregarNombreLugarInteres() {
    setState(() {
      nombresLugaresInteres.add('');
    });
  }

  // Método para validar que el formato de duración es h:mm
  bool validarFormatoDuracion(String duracion) {
    RegExp regex = RegExp(r'^[0-9]{1,2}:[0-5][0-9]$');
    return regex.hasMatch(duracion);
  }

  // Manejador del botón de filtros avanzado. Muestra un cuadro de diálogo para filtrar las rutas.
  void _mostrarDialogoFiltros(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.white,
          // Etiqueta de filtro de búsqueda
          title: Text(AppLocalizations.of(context)!.filtrosDeBusqueda,
              style: const TextStyle(
                color: ColoresAplicacion.colorLetrasPrincipal,
                fontFamily: 'Inter',
                fontSize: 30,
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
                height: 1,
              )),
          content: SingleChildScrollView(
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiqueta del nombre de ruta
                Text(
                  AppLocalizations.of(context)!.nombreDeLaRuta,
                  style: const TextStyle(
                    color: ColoresAplicacion.colorLetrasPrincipal,
                    fontFamily: 'Inter',
                    fontSize: 20,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                // Campo de texto de nombre de ruta
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      bottom: MediaQuery.of(context).size.height * 0.01),
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.1,
                      decoration: BoxDecoration(
                        color: ColoresAplicacion.colorFondo,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.02),
                          child: TextFormField(
                              controller: _controladorRuta,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              )))),
                ),
                Container(
                    color: const Color.fromARGB(255, 219, 219, 219),
                    child: Row(
                      children: [
                        // Etiqueta para añadir filtro de lugar
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.01),
                          child: Text(
                              AppLocalizations.of(context)!.nombreDeLugar,
                              style: const TextStyle(
                                color: ColoresAplicacion.colorLetrasPrincipal,
                                fontFamily: 'Inter',
                                fontSize: 20,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              )),
                        ),
                        // Boton para añadir filtro de búsqueda por nombre de lugar de interés
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.0),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _controladoresLugares = [
                                    TextEditingController()
                                  ];
                                });
                              },
                              icon: Icon(
                                Icons.restart_alt,
                                color: ColoresAplicacion.colorLetrasPrincipal,
                                size: MediaQuery.of(context).size.width * 0.07,
                              )),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _controladoresLugares
                                    .add(TextEditingController());
                              });
                            },
                            icon: Icon(
                              Icons.add,
                              color: ColoresAplicacion.colorLetrasPrincipal,
                              size: MediaQuery.of(context).size.width * 0.07,
                            ))
                      ],
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Container(
                    color: Color.fromARGB(255, 245, 245, 245),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ListView.builder(
                      itemCount: _controladoresLugares.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.width * 0.1,
                              decoration: BoxDecoration(
                                color: ColoresAplicacion.colorFondo,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.02,
                                      top: MediaQuery.of(context).size.height *
                                          0.017),
                                  child: TextField(
                                      controller: _controladoresLugares
                                          .elementAt(index),
                                      decoration: InputDecoration(
                                          border: const UnderlineInputBorder(
                                            borderSide: BorderSide
                                                .none, // Elimina la línea inferior
                                          ),
                                          hintText:
                                              '${AppLocalizations.of(context)!.lugar} $index')))),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Formato sobre como introducir la duración
                Text(AppLocalizations.of(context)!.duracionFormato,
                    style: const TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    )),
                // Campos de texto de duración
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _controladorDuracionMinima.text,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.minima,
                        ),
                        onChanged: (value) {
                          _controladorDuracionMinima.text = value;
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        initialValue: _controladorDuracionMaxima.text,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.maxima,
                        ),
                        onChanged: (value) {
                          _controladorDuracionMaxima.text = value;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Campo de texto para distancia
                Text(AppLocalizations.of(context)!.distanciaFormato,
                    style: const TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    )),
                // Campos de texto de distancia mínima y máxima
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.minima,
                        ),
                        onChanged: (value) {
                          distanciaMinima = double.tryParse(value) ?? null;
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.maxima,
                        ),
                        onChanged: (value) {
                          distanciaMaxima = double.tryParse(value) ?? null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            // Botón de cancelar
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(ColoresAplicacion.colorFondo)),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancelar,
                  style: const TextStyle(
                    color: ColoresAplicacion.colorLetrasPrincipal,
                    fontFamily: 'Inter',
                    fontSize: 20,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  )),
            ),
            // Botón de aplicar filtros
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.08),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        ColoresAplicacion.colorPrimario)),
                onPressed: () {
                  // Creación de las instancias del objeto Filtro
                  ControladorFiltros controladorFiltros = ControladorFiltros();
                  if (_controladorRuta.text != '')
                    controladorFiltros
                        .aniadirFiltro(FiltroNombreRuta(_controladorRuta.text));

                  for (int i = 0; i < _controladoresLugares.length; i++) {
                    if (_controladoresLugares.elementAt(i).text != '')
                      controladorFiltros.aniadirFiltro(FiltroNombreLugar(
                          _controladoresLugares.elementAt(i).text));
                  }

                  String? duracionMin = null;
                  String? duracionMax = null;

                  if (validarFormatoDuracion(_controladorDuracionMinima.text))
                    duracionMin = _controladorDuracionMinima.text;

                  if (validarFormatoDuracion(_controladorDuracionMaxima.text))
                    duracionMax = _controladorDuracionMaxima.text;
                  controladorFiltros
                      .aniadirFiltro(FiltroDuracion(duracionMax, duracionMin));

                  controladorFiltros.aniadirFiltro(FiltroDistancia(
                      maximo: distanciaMaxima, minimo: distanciaMinima));
                  // Aplicar filtros
                  setState(() {
                    rutasFiltradas =
                        controladorFiltros.aplicar(this.widget.rutas);
                  });
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.aplicar,
                    style: TextStyle(
                      color: ColoresAplicacion.colorFondo,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    )),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: ColoresAplicacion.colorFondo,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Mapa con la ubicación actual del usuario
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
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: UbicacionMapa(
                        posicionActual: this.widget.posicionActual),
                  ),
                ),
                // Etiqueta de rutas disponibles
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.01),
                  child: Text(
                    AppLocalizations.of(context)!.rutasDisponibles,
                    style: const TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 30,
                      letterSpacing: 0,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
                Row(
                  // Campo de texto para filtrado por nombre y filtro avanzado
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01,
                            left: MediaQuery.of(context).size.width * 0.05,
                            right: MediaQuery.of(context).size.width * 0.02),
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.width * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              border: Border.all(
                                color: Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.02),
                              child: TextField(
                                controller: _controladorBuscador,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: AppLocalizations.of(context)!
                                        .mensajeBuscador,
                                    hintStyle: const TextStyle(
                                        color: ColoresAplicacion
                                            .colorLetrasPrincipal,
                                        fontFamily: 'Inter',
                                        fontSize: 20,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.normal,
                                        height: 1)),
                                onChanged: (value) {
                                  filtrarRutas(value);
                                },
                              ),
                            ))),
                    // Botón para mostrar filtros avanzados
                    Container(
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width *
                              0.05), // Ajusta el espacio a la derecha del botón

                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColoresAplicacion.colorPrimario,
                      ),
                      child: IconButton(
                        onPressed: () {
                          _mostrarDialogoFiltros(context);
                        },
                        icon: const Icon(
                          Icons.filter_alt,
                          color: ColoresAplicacion.colorLetrasSecundario,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),

                // Lista de tarjetas de ruta
                Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.04,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width *
                          0.9, // Ancho total del 90%
                      height: MediaQuery.of(context).size.height * 0.48,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 0.1),
                        scrollDirection: Axis.vertical,
                        itemCount: rutasFiltradas.length,
                        itemBuilder: (context, index) {
                          RutaTuristica ruta = rutasFiltradas[index];

                          return GestureDetector(
                              child: TarjetaRuta(
                                rutaTuristica: ruta,
                              ),
                              onTap: () => Controlador()
                                  .cargarPantallaRuta(ruta, context));
                        },
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
