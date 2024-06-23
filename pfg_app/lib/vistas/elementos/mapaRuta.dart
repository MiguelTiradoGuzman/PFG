import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/private_config.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// Widget MapaRuta. Muestra todas las indicaciones para llegar hasta el lugar de interés
class MapaRuta extends StatefulWidget {
  // Lugar de interés sobre el que se ofrecen las indicaciones
  LugarInteres lugar;
  MapaRuta(this.lugar);

  @override
  _MapaRutaState createState() => _MapaRutaState();
}

class _MapaRutaState extends State<MapaRuta> {
  // Controlador del mapa de MapBox
  MapboxMapController? _controladorMapa;
  // Posición actual para actualizar el mapa
  Position? _posicionActual;
  // Objeto Cliente de la API MapBox
  MapboxApi mapbox = MapboxApi(
    // Token de acceso de mapbox.
    accessToken: Config.mapboxAccessToken,
  );

  // Recarga del widget cuando se cambia de lugar de interés.
  @override
  void didUpdateWidget(MapaRuta oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lugar != oldWidget.lugar) {
      _limpiarMapa();
      _obtenerMostrarRecorrido(
          widget.lugar.getLatitud, widget.lugar.getLongitud);
    }
  }

  // Método para limpiar el mapa
  Future<void> _limpiarMapa() async {
    if (_controladorMapa != null) {
      // Quitar la línea del mapa
      await _controladorMapa!.clearLines();
      // Quitar el círculo del mapa
      await _controladorMapa!.clearCircles();
    }
  }

  // Función para obtener y mostrar la ruta en el mapa hacia la posición pasada por parámetro.
  Future<void> _obtenerMostrarRecorrido(double latitud, double longitud) async {
    // Obtener la posición actual
    _posicionActual = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Si no se pudiese obtener la ubicación actual se maneja el posible error
    if (_posicionActual == null) {
      print("No se puede obtener la ruta sin la ubicación actual.");
      return;
    }

    // Petición a la API de Mapboox para obtener indicaciones para ir andando desde la ubicación actual hasta el lugar de interés.
    var response = await mapbox.directions.request(
      profile: NavigationProfile.WALKING,
      steps: true,
      coordinates: <List<double>>[
        <double>[
          _posicionActual?.latitude ?? 0.0, // Provide a default value if null
          _posicionActual?.longitude ?? 0.0,
        ],
        <double>[
          latitud,
          longitud,
        ],
      ],
    );
    // Manejo de errores. No se mostrará ruta en la pantalla, solo ubicación del lugar de interés
    if (response.error != null)
      print(response.error);
    // Si responde con una ruta válida
    else if (response != null && response.routes?.isNotEmpty == true) {
      // Extraer la geometría de la ruta. Lugares de paso
      var routeGeometry = response.routes?[0].geometry;

      // Creación de la polilinea que pasa por todos los puntos de la ruta para pintarla sobre el mapa.
      final polyline = PolylinePoints().decodePolyline(routeGeometry);

      // Vector con todas las posiciones que marca la polilínea.
      final path = <LatLng>[];

      // Rellenar el vector con todas las posiciones de la polilínea
      for (var i = 0; i < polyline.length; i++) {
        path.add(
          LatLng(
            polyline[i].latitude,
            polyline[i].longitude,
          ),
        );
      }

      // Pintar la polilínea en el mapa de MapBox.
      if (path.length > 0) {
        await _controladorMapa!.addLine(
          LineOptions(
            geometry: path,
            lineColor: ColoresAplicacion.colorPrimario.toHexStringRGB(),
            lineWidth: 6.0,
            lineOpacity: 1,
            draggable: false,
          ),
        );
      }

      // Añadir en el mapa un marcador en el Lugar de Interés
      _aniadirMarcadorDestino(latitud, longitud);
    } else {
      print("No se encontró ninguna ruta.");
    }
  }

  @override
  void initState() {
    super.initState();
    _iniciarServicioUbicacion();
  }

  // Inicializar servicio de ubicación
  Future<void> _iniciarServicioUbicacion() async {
    try {
      // Obtiene la posición actual
      var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // Actualiza el estado del mapa en consecuencia
      setState(() {
        _posicionActual = position;
        _obtenerMostrarRecorrido(
            widget.lugar.getLatitud, widget.lugar.getLongitud);
      });
    } catch (e) {
      print("Error al obtener la ubicación: $e");
    }
  }

  // Mueve la cámara del mapa a la ubicación actual del usuario
  void _moverAUbicacionActual() async {
    // Obtener la posición actual
    _posicionActual = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (_controladorMapa != null && _posicionActual != null) {
      // Animación de la camara para establecer el foco en la posición actual
      _controladorMapa!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            _posicionActual!.latitude,
            _posicionActual!.longitude,
          ),
          15.0,
        ),
      );
    }
  }

  // Añade en el mapa un marcador en la ubicación del lugar de interés
  void _aniadirMarcadorDestino(double latitud, double longitud) {
    if (_controladorMapa != null) {
      // Añadir un Círculo en la posición pasada por parámetros
      _controladorMapa!.addCircle(
        CircleOptions(
            geometry: LatLng(latitud, longitud),
            circleColor: Color.fromRGBO(255, 255, 255, 1)
                .toHexStringRGB(), // Puedes personalizar el marcador
            circleRadius: 20,
            circleStrokeColor: Color.fromRGBO(0, 0, 0, 0.2).toHexStringRGB(),
            circleStrokeWidth: 5,
            circleStrokeOpacity: 0.2),
      );
    }
  }

  // Método para establecer la posición inicial de la cámara.
  void _establecerPosicionCamara() async {
    if (_controladorMapa != null && _posicionActual != null) {
      _controladorMapa!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            _posicionActual!.latitude,
            _posicionActual!.longitude,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Inicialización del Widget MapBox map. Se inicia con el token de acceso.
      MapboxMap(
        //Clave privada de mapbox
        accessToken: Config.mapboxAccessToken,
        onMapCreated: (controller) {
          // Inicialización del estado del mapa.
          setState(() {
            _controladorMapa = controller;
            _establecerPosicionCamara();
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
        styleString: MapboxStyles.MAPBOX_STREETS,
      ),
      // Botón para reestablecer el mapa a la ubicación actual.
      Positioned(
        top: 16.0,
        right: 16.0,
        child: FloatingActionButton(
          backgroundColor: ColoresAplicacion.colorPrimario,
          onPressed: _moverAUbicacionActual,
          child:
              Icon(Icons.my_location, color: Color.fromRGBO(255, 255, 255, 1)),
        ),
      ),
    ]);
  }
}
