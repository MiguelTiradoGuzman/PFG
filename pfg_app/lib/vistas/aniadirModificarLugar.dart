import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:pfg_app/private_config.dart';

double tamTitulos = 23;

// Pantalla para añadir o modificar un lugar de interés
// ignore: must_be_immutable
class AniadirModificarLugar extends StatefulWidget {
  // Ruta en la que se añade el lugar de interés
  late RutaTuristica _ruta;
  // Lugar a crear/modificar. Si le llega por parámetro un lugar de interés se procede a modificar. Si no, se procede a crear uno nuevo.
  LugarInteres? _lugar;
  // Lista de imágenes del lugar de interés.
  List<File>? _imgs;
  // Constructor de la clase
  AniadirModificarLugar(BuildContext context, LugarInteres? l, RutaTuristica r,
      List<File>? imagenes) {
    _lugar = l;
    _ruta = r;
    _imgs = imagenes;
  }

  @override
  // ignore: library_private_types_in_public_api
  _AniadirModificarLugarState createState() => _AniadirModificarLugarState();
}

class _AniadirModificarLugarState extends State<AniadirModificarLugar> {
  // Controlador del campo de texto del nombre del lugar de interés.
  final TextEditingController _nombreLugar = TextEditingController();
  // Controlador del campo de texto de la descripción del lugar de interés.
  final TextEditingController _descripcion = TextEditingController();
  // Controlador del campo de texto de modificación de la descripción del lugar de interés. Sirve para reestablecer la descripción si el usuario pulsa el botón cancelar.
  final TextEditingController _descripcionTmp = TextEditingController();
  // Controlador del campo de texto de la latitud.
  final TextEditingController _controladorLatitud = TextEditingController();
  // Controlador del campo de texto de la longitud.
  final TextEditingController _controladorLongitud = TextEditingController();
  // Lista de imágenes que tiene el lugar de interés resultante.
  List<File> images = [];
  //Manejador Evento: Usuario pulsa el botón de modificar la descripción del lugar de interés.
  void _mostrarMenuEditarDescripcion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Etiqueta: Editar descripción.
          insetPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(AppLocalizations.of(context)!.editarDescripcion),
          content: SizedBox(
            // Ajusta el tamaño del contenido del diálogo
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: null,
              initialValue: _descripcion.text,
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
            // Si pulsa botón cancelar se pierden los cambios
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                setState(() {
                  _descripcionTmp.text = _descripcion.text;
                });
              },
              child: Text(AppLocalizations.of(context)!.cerrar),
            ),
            // Si pulsa botón guardar, se almacenan los cambios
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
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

  @override
  void initState() {
    super.initState();
    if (widget._lugar != null) {
      _nombreLugar.text = widget._lugar!.nombre ?? '';
      _descripcion.text = widget._lugar!.descripcion ?? '';
      _controladorLatitud.text = widget._lugar!.latitud?.toString() ?? '';
      _controladorLongitud.text = widget._lugar!.longitud?.toString() ?? '';
      images = List.from(widget._imgs!);
    }
  }

  // Método para abrir el selector de imágenes del dispositivo móvil.
  Future<File?> seleccionarImagen() async {
    try {
      // Abre la galería del dispositivo móvil
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      // Crea un File a partir de la imagen seleccionado. Este tipo de archivo después se mandará al servidor
      final imageTemp = File(image.path);
      return imageTemp;
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
    return null;
  }

  // Método para comprobar que no existe ningún otro lugar de interés con el mismo nombre en la ruta.
  bool _nombreEnRuta() {
    bool existe = false;
    for (int i = 0; i < this.widget._ruta.lugares.length && !existe; i++) {
      if (this.widget._ruta.lugares.elementAt(i) == this._nombreLugar)
        existe = true;
    }

    return existe;
  }

  // Manejador de evento: Usuario pulsa botón 'Guardar'
  void _comprobarInformacion() {
    // Si no se ha escrito ningún nombre, descripción o insertado imagen sale error en pantalla
    if (_descripcion.text.isEmpty ||
        _nombreLugar.text.isEmpty ||
        images.isEmpty) {
      // Mostrar aviso de error si falta información
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
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

// Validar que la latitud y longitud sean números
    double? latitud;
    double? longitud;
    try {
      latitud = double.parse(_controladorLatitud.text);
      longitud = double.parse(_controladorLongitud.text);
    } catch (e) {
      // Mostrar mensaje de error si no se pueden convertir a double
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            title: Text(AppLocalizations.of(context)!.error),
            content:
                Text(AppLocalizations.of(context)!.errorFormatoCoordenadas),
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

    // Validar que la latitud esté en el rango [-90, 90]
    if (latitud < -90 || latitud > 90) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(AppLocalizations.of(context)!.errorRangoLatitud),
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

    // Validar que la longitud esté en el rango [-180, 180]
    if (longitud < -180 || longitud > 180) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(AppLocalizations.of(context)!.errorRangoLongitud),
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
    // Validar que no exista otro lugar de interés con el mismo nombre en la ruta
    if (_nombreEnRuta()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            title: Text(AppLocalizations.of(context)!.error),
            content: Text(AppLocalizations.of(context)!.nombreLugarExiste),
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

    // Se inserta el nuevo lugar en la ruta y se cierra la pantalla
    List dev = [];

    dev.add(LugarInteres(
        nombre: this._nombreLugar.text,
        descripcion: this._descripcion.text,
        latitud: latitud,
        longitud: longitud,
        recursos: []));
    dev.add(images);
    if (this.widget._lugar != null) {
      this.widget._imgs = images;
      this.widget._lugar = LugarInteres(
          nombre: this._nombreLugar.text,
          descripcion: this._descripcion.text,
          latitud: latitud,
          longitud: longitud,
          recursos: []);
    }

    Navigator.pop(context, dev);
  }

  // Controlador del mapa de MapBox
  MapboxMapController? _controladorMapa;
  // Posición actual para actualizar el mapa
  Position? _posicionActual;

  void _actualizarPosicionMarcador(LatLng latLng) {
    setState(() {});
  }

  double? latitud = 0;
  double? longitud = 0;
// Agrega este método para mostrar el diálogo con el mapa
  void _mostrarMapa(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.establerUbicacion),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: // Inicialización del Widget MapBox map. Se inicia con el token de acceso.

                MapboxMap(
              //Clave privada de mapbox
              accessToken: Config.mapboxAccessToken,
              onMapCreated: (controller) {
                // Inicialización del estado del mapa.
                setState(() {
                  _controladorMapa = controller;
                });
              },
              // Establece la posición inicial de la cámara. Si no se pudiese obtener la posición actual, se establece una posición por defecto cualquiera.
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _posicionActual?.latitude ?? 37.7749,
                  _posicionActual?.longitude ?? -122.4194,
                ),
                zoom: 15.0,
              ),
              // Opciones del mapa. Puede obtener la ubicación del usuario.
              myLocationEnabled: true,
              // Se renderiza el icono de ubicación del usuario
              myLocationRenderMode: MyLocationRenderMode.GPS,
              // Se hace un seguimiento continuo de la ubicación del usuario y se actualiza el mapa en consecuencia
              myLocationTrackingMode: MyLocationTrackingMode.Tracking,
              //Url hacia el estilo elegido para los mapas
              styleString: Config.styleMapboxUrl,
              onMapLongClick: (point, coordinates) {
                latitud = coordinates.latitude;
                longitud = coordinates.longitude;
                if (_controladorMapa!.circles.isNotEmpty) {
                  _controladorMapa!.clearCircles();
                }
                _controladorMapa?.addCircle(CircleOptions(
                  geometry: LatLng(latitud!, longitud!),
                  circleRadius: 10, // Radio del círculo en metros
                  circleColor: "#FF0000",
                ));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancelar),
            ),
            TextButton(
              onPressed: () {
                // Actualizar los controladores de latitud y longitud
                setState(() {
                  _controladorLatitud.text = latitud.toString();
                  _controladorLongitud.text = longitud.toString();
                });
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.aceptar),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Campo de texto para introducir nombre del lugar de interés
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.07,
                left: MediaQuery.of(context).size.width * 0.05,
              ),
              child: TextField(
                controller: _nombreLugar,
                onChanged: (value) {
                  setState(() {
                    _nombreLugar.text = value;
                  });
                },
                style: const TextStyle(
                    color: ColoresAplicacion.colorLetrasPrincipal,
                    fontFamily: 'Inter',
                    fontSize: 25,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    height: 1),
                decoration: widget._lugar == null
                    ? InputDecoration(
                        icon: const Icon(Icons.edit),
                        border: InputBorder.none,
                        hintText: AppLocalizations.of(context)!.nombreLugar,
                        hintStyle: const TextStyle(
                            color: ColoresAplicacion.colorLetrasPrincipal,
                            fontFamily: 'Inter',
                            fontSize: 25,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold,
                            height: 1))
                    : const InputDecoration(
                        icon: Icon(Icons.edit),
                        border: InputBorder.none,
                      ),
              ),
            ),
            // Contenedor de previsualización de imágenes añadidas.
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.01,
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
                child: images.isEmpty
                    ? const Icon(Icons.add_a_photo)
                    : GridView.count(
                        crossAxisCount: 3,
                        children: List.generate(images.length, (index) {
                          return GestureDetector(
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.17,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
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
                                child: Image.file(
                                  images.elementAt(index),
                                  fit: BoxFit.cover,
                                )),
                            onDoubleTap: () {
                              setState(() {
                                images.remove(images.elementAt(index));
                              });
                            },
                          );
                        }),
                      ),
              ),
            ),
            // Etiqueta: Con dos toques se borra la imagen de la selección.
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Expanded(
                child: Text(
                  AppLocalizations.of(context)!.avisoDobleTapBorraImagen,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: ColoresAplicacion.colorPrimario,
                    fontFamily: 'Inter',
                    fontSize: 18,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
            // Botón añadir imagen
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: () async {
                    File? image = await seleccionarImagen();
                    if (image != null)
                      setState(() {
                        images.add(image);
                      });
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
                              left: MediaQuery.of(context).size.width * 0.25,
                              right: MediaQuery.of(context).size.width * 0.02),
                          child: Icon(Icons.image_search,
                              color: ColoresAplicacion.colorPrimario, size: 25),
                        ),
                        Text(
                          AppLocalizations.of(context)!.anadirImagen,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: ColoresAplicacion.colorPrimario,
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
            // Etiqueta: Descripción y botón para modificar descripción
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.descripcion,
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
                      onPressed: () {
                        _mostrarMenuEditarDescripcion(context);
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: ColoresAplicacion.colorLetrasSecundario,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Etiqueta: Establecer Ubicación y campos para insertar latitud y longitud.
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.establerUbicacion,
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
                      onPressed: () {
                        _mostrarMapa(context); // Mostrar el diálogo del mapa
                      },
                      icon: const Icon(
                        Icons.map,
                        color: ColoresAplicacion.colorLetrasSecundario,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.only(
            //     top: MediaQuery.of(context).size.height * 0.02,
            //     left: MediaQuery.of(context).size.width * 0.05,
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         width: MediaQuery.of(context).size.width * 0.4,
            //         height: MediaQuery.of(context).size.height * 0.1,
            //         child: TextFormField(
            //           controller: _controladorLatitud,
            //           keyboardType: const TextInputType.numberWithOptions(
            //               decimal: true, signed: true),
            //           decoration: InputDecoration(
            //             focusedBorder: const OutlineInputBorder(
            //               borderSide: BorderSide(
            //                   color: ColoresAplicacion
            //                       .colorPrimario), // Cambia el color aquí
            //             ),
            //             labelText: AppLocalizations.of(context)!.latitud,
            //             floatingLabelStyle: const TextStyle(
            //               color: ColoresAplicacion.colorPrimario,
            //             ),
            //             border: const OutlineInputBorder(),
            //           ),
            //           onChanged: (value) {
            //             setState(() {
            //               _latitud = double.tryParse(value);
            //             });
            //           },
            //         ),
            //       ),
            //       SizedBox(width: MediaQuery.of(context).size.width * 0.1),
            //       Container(
            //         width: MediaQuery.of(context).size.width * 0.4,
            //         height: MediaQuery.of(context).size.height * 0.1,
            //         child: TextFormField(
            //           controller: _controladorLongitud,
            //           keyboardType: const TextInputType.numberWithOptions(
            //               decimal: true, signed: true),
            //           decoration: InputDecoration(
            //             focusedBorder: const OutlineInputBorder(
            //               borderSide: BorderSide(
            //                   color: ColoresAplicacion
            //                       .colorPrimario), // Cambia el color aquí
            //             ),
            //             labelText: AppLocalizations.of(context)!.longitud,
            //             floatingLabelStyle: const TextStyle(
            //                 color: ColoresAplicacion.colorPrimario),
            //             border: const OutlineInputBorder(),
            //           ),
            //           onChanged: (value) {
            //             setState(() {
            //               _longitud = double.tryParse(value);
            //             });
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // Botones Cancelar y guardar
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.015,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context, null);
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: MediaQuery.of(context).size.height * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: ColoresAplicacion.colorPrimario,
                                width: 2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            color: ColoresAplicacion.colorFondo,
                          ),
                          child: Center(
                              child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.0425,
                                    right: MediaQuery.of(context).size.width *
                                        0.015),
                                child: const Icon(Icons.cancel,
                                    color: ColoresAplicacion.colorPrimario),
                              ),
                              Text(
                                AppLocalizations.of(context)!.cancelar,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: ColoresAplicacion.colorPrimario,
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              )
                            ],
                          )))),
                  Padding(
                      padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.0725)),
                  GestureDetector(
                      onTap: _comprobarInformacion,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.425,
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
                                    left: MediaQuery.of(context).size.width *
                                        0.04,
                                    right: MediaQuery.of(context).size.width *
                                        0.015),
                                child: const Icon(Icons.save,
                                    color: ColoresAplicacion
                                        .colorLetrasSecundario),
                              ),
                              Text(
                                AppLocalizations.of(context)!.guardar,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: ColoresAplicacion.colorFondo,
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              )
                            ],
                          ))))
                ],
              ),
            ),
          ]),
    ));
  }
}
