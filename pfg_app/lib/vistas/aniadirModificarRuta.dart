import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/private_config.dart';
import 'package:pfg_app/vistas/elementos/tarjetaLugar.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

double tamTitulos = 23;

// Pantalla para añadir o modificar una ruta
class AniadirModificarRuta extends StatefulWidget {
  // Ruta turística a modificar. Si se quiere usar esta clase para añadir una nueva, se pasa null por parámetro
  final RutaTuristica? rutaModificar;
  const AniadirModificarRuta({this.rutaModificar});

  @override
  // ignore: library_private_types_in_public_api
  _AniadirModificarRutaState createState() => _AniadirModificarRutaState();
}

class _AniadirModificarRutaState extends State<AniadirModificarRuta> {
  // Controlador del campo de texto del nombre de la ruta.
  final TextEditingController _nombreRuta = TextEditingController();
  // Controlador del campo de texto de la descripción de la ruta.
  final TextEditingController _descripcion = TextEditingController();
  // Controlador del campo de texto de modificación de la descripción de la ruta. Sirve para reestablecer la descripción si el usuario pulsa el botón cancelar.
  final TextEditingController _descripcionTmp = TextEditingController();

  // Lista de lugares de interés a crear o modificar
  late List<LugarInteres> lugaresInteres;
  // Lista de lista de imágendes de cada lugar de interés a modificar o crear
  late List<List<File>> imagenesLugares = [];
  bool estaCargando = false;

  // Método para mostrar en menú de diálogo un cuadro de texto para modificar la descripción
  void _mostrarMenuEditarDescripcion(BuildContext context) {
    // Muestra el cuadro de diálogo.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 4),
          // Etiqueta: Modificar descripción
          title: Text(AppLocalizations.of(context)!.editarDescripcion),
          content: SizedBox(
            // Ajusta el tamaño del contenido del diálogo
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            // Cuadro de texto para modificar la descripción.
            child: TextFormField(
              initialValue: _descripcion.text,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  _descripcionTmp.text = value;
                });
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.ingreseNuevaDescripcion,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                setState(() {
                  _descripcionTmp.text = _descripcion.text;
                });
              },
              child: Text(AppLocalizations.of(context)!.cancelar),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                // Aplicar los cambios en la descripción
                setState(() {
                  _descripcion.text = _descripcionTmp.text;
                });
              },
              child: Text(AppLocalizations.of(context)!.guardar),
            ),
          ],
        );
      },
    );
  }

  // Método para descargar todas las imágenes de la ruta.
  void iniciarImagenes() async {
    // Obtener la imagen de portada de la ruta.
    image = await Controlador()
        .fileDesdeURLImagen(this.widget.rutaModificar!.rutaImagen);

    // Obtener las imagenes de cada uno de los lugares de interés de la ruta.
    for (int i = 0; i < lugaresInteres.length; i++) {
      List<File> l = [];
      for (int j = 0; j < lugaresInteres.elementAt(i).recursos.length; j++) {
        File? f = await Controlador().fileDesdeURLImagen(
            lugaresInteres.elementAt(i).recursos.elementAt(j));
        if (f != null) l.add(f);
      }
      imagenesLugares.add(l);
    }
    setState(() {
      estaCargando = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.rutaModificar != null) {
      _nombreRuta.text = widget.rutaModificar!.nombre;
      _descripcion.text = widget.rutaModificar!.descripcion;
      lugaresInteres = widget.rutaModificar!.lugares;
      _ruta = widget.rutaModificar!;
      estaCargando = true;
      iniciarImagenes();
    }
  }

  // Objeto RutaTuristica virtual el cual modificar durante la creación de la nueva ruta.
  late RutaTuristica _ruta = RutaTuristica(
      nombre: '',
      descripcion: '',
      distancia: 0,
      duracion: '',
      rutaImagen: '',
      lugares: <LugarInteres>[]);
  // Imagen de portada de la ruta.
  File? image;

  // Método para abrir el selector de imágenes del dispositivo móvil.
  Future seleccionImagen() async {
    try {
      // Abre la galería del dispositivo móvil
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      // Crea un File a partir de la imagen seleccionado. Este tipo de archivo después se mandará al servidor
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  // Método para calcular la distancia y tiempo requerido para completar una ruta turística.
  Future<void> _calcularDistanciaTiempo(RutaTuristica ruta) async {
    // Se obtienen todos los lugares de interés de la ruta.
    List<LugarInteres> lugares = ruta.lugares;
    // Position? _posicionActual = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.high,
    // );
    MapboxApi mapbox = MapboxApi(
      accessToken: Config.mapboxAccessToken,
    );

    //if (_posicionActual == null || lugares.isEmpty) {
    if (lugares.isEmpty) {
      print(
          "No se puede obtener la ruta sin la ubicación actual o los lugares de interés.");
      return;
    }

    List<List<double>> coordinates = [];
    //coordinates.add([_posicionActual!.latitude, _posicionActual!.longitude]);
    // Se rellena el vector de coordenadas
    for (var lugar in lugares) {
      coordinates.add([lugar.getLatitud, lugar.getLongitud]);
    }
    // Se manda una petición a la API Mapbox para que simule el recorrido andando y diga la distancia total en kilómetros y la duración.
    try {
      var response = await mapbox.directions.request(
        profile: NavigationProfile.WALKING,
        steps: true,
        coordinates: coordinates,
      );

      if (response.error != null) {
        print(response.error);
        return;
      }
      // Comprobación de errores en la respuesta
      var route = response.routes?.first;
      if (route == null) {
        print("No se encontró ninguna ruta.");
        return;
      }
      print(response);
      // Distancia total de la ruta en metros
      var totalDistance = route.distance;
      // Tiempo total en segundos para hacer la ruta
      var totalTime = route.duration;

      // Convertir el tiempo total de segundos a horas y minutos
      int hours = totalTime! ~/ 3600;
      int minutes = (totalTime % 3600) ~/ 60;
      double distanceInKm = totalDistance! / 1000;

      // Obtener los kilómetros con un sólo decimal
      distanceInKm = double.parse(distanceInKm.toStringAsFixed(1));
      // Formatear el tiempo en horas y minutos
      String formattedTime = '$hours:${minutes.toString().padLeft(2, '0')}';
      ruta.distancia = distanceInKm;
      ruta.duracion = formattedTime;
    } catch (e) {
      throw (e);
    }
  }

  // Manejador del evento: El usuario pulsa el botón Introducir Ruta
  // Introduce la nueva ruta en el sistema
  Future<void> _aniadirRuta() async {
    if (_descripcion.text.isEmpty ||
        _nombreRuta.text.isEmpty ||
        image == null) {
      // Mostrar aviso de error si falta información por insertar
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(AppLocalizations.of(context)!.errorCamposVacios),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    // Comprobación de si la ruta existe en el sistema
    RutaTuristica? r = await Controlador().getRuta(_nombreRuta.text);
    if (r != null) {
      // Si existe en el sistema pero se ha iniciado la pantalla para modificar se hace la modificación en el sistema
      if (this.widget.rutaModificar != null) {
        _ruta.nombre = _nombreRuta.text;
        _ruta.descripcion = _descripcion.text;
        await _calcularDistanciaTiempo(_ruta);
        Controlador()
            .modificarRuta(context, this._ruta, this.imagenesLugares, image!);
        return;
      } else {
        // Si se estaba creando una nueva ruta y se ha insertado un nombre existente
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.error),
              content: Text(AppLocalizations.of(context)!.errorRutaExistente),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
    }
    // Se inserta la nueva ruta en el sistema
    _ruta.nombre = _nombreRuta.text;
    _ruta.descripcion = _descripcion.text;
    await _calcularDistanciaTiempo(_ruta);
    await Controlador()
        .insertarRuta(context, this._ruta, this.imagenesLugares, image!);
    return;
  }

  // Manejador evento: Usuario pulsa botón + para añadir un lugar de interés
  // Carga la pantalla para añadir/modificar lugar de interés y una vez que el usuario sale se procesa el nuevo lugar.
  void funcionAniadirLugar(
      RutaTuristica r, LugarInteres l, List<File> imgs) async {
    // Llama a la función para agregar o modificar el lugar de interés
    List dev =
        await Controlador().cargarAniadirModificarLugar(context, l, r, imgs);

    // Obtén el índice del lugar de interés en la lista de la ruta turística
    int index = r.lugares.indexOf(l);

    // Reemplaza el lugar de interés en la lista de la ruta turística
    if (index != -1) {
      setState(() {
        r.lugares[index] = dev[0];
        imagenesLugares[index] = dev[1];
      });
    } else {
      setState(() {
        r.lugares.add(l);
      });
    }
  }

  // Función a pasar por parámetro para cada tarjeta de lugar de interés. De esta forma se borra el lugar de interés del recorrido turístico
  void funcionBorrarLugar(RutaTuristica r, LugarInteres l) {
    setState(() {
      r.lugares.remove(l);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Campo de texto del nombre de la ruta
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: this.widget.rutaModificar != null
                  ? Text(
                      this._nombreRuta.text,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        fontFamily: 'Inter',
                        fontSize: tamTitulos,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    )
                  : TextField(
                      onChanged: (value) {
                        setState(() {
                          _nombreRuta.text = value;
                        });
                      },
                      style: const TextStyle(
                          color: ColoresAplicacion.colorLetrasPrincipal,
                          fontFamily: 'Inter',
                          fontSize: 25,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                          height: 1),
                      decoration: InputDecoration(
                          icon: const Icon(Icons.edit),
                          border: InputBorder.none,
                          hintText:
                              AppLocalizations.of(context)!.hintIntroduceNombre,
                          hintStyle: const TextStyle(
                              color: ColoresAplicacion.colorLetrasPrincipal,
                              fontFamily: 'Inter',
                              fontSize: 25,
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold,
                              height: 1)),
                    ),
            ),
            // Imagen de portada de la ruta turística.
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
                child: this.widget.rutaModificar != null
                    ? estaCargando
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: ColoresAplicacion.colorPrimario))
                        : Image.file(
                            image!,
                            fit: BoxFit.cover,
                          )
                    : image == null
                        ? const Icon(Icons.add_a_photo)
                        : Image.file(
                            image!,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            // Selector de imagen de portada de la ruta.
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: () {
                    seleccionImagen();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.05,
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
                    child: Center(
                        child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.17,
                              right: MediaQuery.of(context).size.width * 0.02),
                          child: Icon(Icons.image_search,
                              color: ColoresAplicacion.colorPrimario, size: 25),
                        ),
                        Text(
                          AppLocalizations.of(context)!.modificarImagen,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: ColoresAplicacion.colorPrimario,
                              fontFamily: 'Inter',
                              fontSize: 20,
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        )
                      ],
                    )),
                  ),
                )),
            // Botón para modificar la descripción
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: () {
                    _mostrarMenuEditarDescripcion(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.05,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(65),
                        topRight: Radius.circular(65),
                        bottomLeft: Radius.circular(65),
                        bottomRight: Radius.circular(65),
                      ),
                      color: ColoresAplicacion.colorPrimario,
                      border: Border.all(
                        color: ColoresAplicacion.colorPrimario,
                        width: 2,
                      ),
                    ),
                    child: Center(
                        child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.13,
                              right: MediaQuery.of(context).size.width * 0.02),
                          child: Icon(Icons.description,
                              color: ColoresAplicacion.colorFondo, size: 25),
                        ),
                        Text(
                          AppLocalizations.of(context)!.modificarDescripcion,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: ColoresAplicacion.colorLetrasSecundario,
                              fontFamily: 'Inter',
                              fontSize: 20,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        )
                      ],
                    )),
                  ),
                )),
            // Botón para añadir un lugar de interés
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.etiquetaLugaresDeInteres,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        fontFamily: 'Inter',
                        fontSize: tamTitulos,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width *
                            0.05), // Ajusta el espacio a la derecha del botón

                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColoresAplicacion.colorPrimario,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        List l = await Controlador()
                            .cargarAniadirModificarLugar(
                                context, null, this._ruta, null);
                        if (l != null) {
                          setState(() {
                            _ruta.lugares.add(l.elementAt(0));
                            imagenesLugares.add(l.elementAt(1));
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.add,
                        color: ColoresAplicacion.colorLetrasSecundario,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lista de lugares de interés de la ruta
            Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.0,
                  left: MediaQuery.of(context).size.width * 0.04,
                ),
                child: estaCargando
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: ColoresAplicacion.colorPrimario))
                    : Container(
                        width: MediaQuery.of(context).size.width *
                            0.9, // Ancho total del 90%

                        // TODO: El size height estaba a 52, lo cambio al no usar un listview builder
                        height: MediaQuery.of(context).size.height * 0.32,
                        child: _ruta.lugares.length != 0
                            ? ListView.builder(
                                padding: const EdgeInsets.only(top: 0.1),
                                scrollDirection: Axis.vertical,
                                itemCount: _ruta.lugares.length,
                                itemBuilder: (context, index) {
                                  print(
                                      "Inserto tarjeta ${imagenesLugares.elementAt(index)}");
                                  LugarInteres lugar =
                                      _ruta.lugares.elementAt(index);

                                  return TarjetaLugarInteres(
                                    ruta: this._ruta,
                                    lugarInteres: lugar,
                                    imgs: imagenesLugares.elementAt(
                                        index), // Usamos null-aware operator para manejar el caso en que snapshot.data sea null
                                    onTapFuncion: funcionAniadirLugar,
                                    onTapFuncion2: funcionBorrarLugar,
                                  );
                                },
                              )
                            : Container(
                                child: const Text(""),
                              ),
                      )),
            // Botón para añadir la ruta en el sistema
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: GestureDetector(
                  onTap: _aniadirRuta,
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
                      child: Center(
                          child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.13,
                                right:
                                    MediaQuery.of(context).size.width * 0.02),
                            child: Icon(Icons.add_box,
                                color: ColoresAplicacion.colorFondo, size: 25),
                          ),
                          Text(
                            AppLocalizations.of(context)!.introducirRuta,
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
          ]),
    ));
  }
}
