//TODO: Mejorar el mapa con navegación turn by turn

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import '../../private_config.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapaRuta extends StatefulWidget {
  LugarInteres lugar;
  MapaRuta(this.lugar);

  @override
  _MapaRutaState createState() => _MapaRutaState();
}

class _MapaRutaState extends State<MapaRuta> {
  MapboxMapController? _controller;
  Position? _currentPosition;
  MapboxApi mapbox = MapboxApi(
    accessToken: Config.mapboxAccessToken,
  );

  // final mapbox.DirectionsApi _directionsApi = mapbox.DirectionsApi(
  //   mapbox.DirectionsCriteria.PROFILE_WALKING, // Perfil de caminar
  //   accessToken: Config.mapboxAccessToken,
  // );
  @override
  void didUpdateWidget(MapaRuta oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lugar != oldWidget.lugar) {
      _limpiarMapa();
      _getAndShowRoute(widget.lugar.getLatitud, widget.lugar.getLongitud);
    }
  }

  // Método para limpiar el mapa
  Future<void> _limpiarMapa() async {
    if (_controller != null) {
      // Quitar la línea del mapa
      await _controller!.clearLines();
      // Quitar el círculo del mapa
      await _controller!.clearCircles();
    }
  }

  Future<void> _getAndShowRoute(double latitud, double longitud) async {
    if (_currentPosition == null) {
      print("No se puede obtener la ruta sin la ubicación actual.");
      return;
    }

    // try {
    var response = await mapbox.directions.request(
      profile: NavigationProfile.WALKING,
      steps: true,
      coordinates: <List<double>>[
        <double>[
          _currentPosition?.latitude ?? 0.0, // Provide a default value if null
          _currentPosition?.longitude ?? 0.0,
        ],
        <double>[
          latitud,
          longitud,
        ],
      ],
    );
    if (response.error != null)
      print(response.error);
    else if (response != null && response.routes?.isNotEmpty == true) {
      // Extraer la geometría de la ruta
      var routeGeometry = response.routes?[0].geometry;

      print(routeGeometry);

      final route = response.routes![0];
      final polyline = PolylinePoints().decodePolyline(routeGeometry);
      // this path will contains points
      // from Mapbox Direction API
      final path = <LatLng>[];

      for (var i = 0; i < polyline.length; i++) {
        path.add(
          LatLng(
            polyline[i].latitude,
            polyline[i].longitude,
          ),
        );
      }

      // draw our line to MapboxMapController
      if (path.length > 0) {
        await _controller!.addLine(
          LineOptions(
            geometry: path,
            lineColor: ColoresAplicacion.colorPrimario.toHexStringRGB(),
            lineWidth: 6.0,
            lineOpacity: 1,
            draggable: false,
          ),
        );
      }

      _addDestinationMarker(latitud, longitud);

      // Agregar una capa de línea al mapa con la ruta
      // _controller!.addLine(
      //   LineOptions(
      //     geometry: routeGeometry,
      //     lineColor: ColoresAplicacion.colorPrimario.toHexStringRGB(),
      //     lineWidth: 3.0,
      //   ),
      // );
    } else {
      print("No se encontró ninguna ruta.");
    }
    // } catch (e) {
    //   print("Error al obtener la ruta: $e");
    // }
  }

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    try {
      var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _getAndShowRoute(widget.lugar.getLatitud, widget.lugar.getLongitud);
      });
    } catch (e) {
      print("Error al obtener la ubicación: $e");
    }
  }

  void _moveToCurrentLocation() {
    if (_controller != null && _currentPosition != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          15.0,
        ),
      );
    }
  }

  void _addDestinationMarker(double latitud, double longitud) {
    if (_controller != null) {
      _controller!.addCircle(
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

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MapboxMap(
        //Clave privada de mapbox
        accessToken: Config.mapboxAccessToken,
        onMapCreated: (controller) {
          setState(() {
            _controller = controller;
            _setCameraPosition();
          });
          // _getAndShowRoute(widget.lugar.getLatitud, widget.lugar.getLongitud);
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition?.latitude ?? 37.7749,
            _currentPosition?.longitude ?? -122.4194,
          ),
          zoom: 15.0,
        ),
        myLocationEnabled: true,
        myLocationRenderMode: MyLocationRenderMode.GPS,
        myLocationTrackingMode: MyLocationTrackingMode.Tracking,
        //Url hacia el estilo elegido para los mapas
        styleString: Config.styleMapboxUrl,
      ),
      Positioned(
        top: 16.0,
        right: 16.0,
        child: FloatingActionButton(
          backgroundColor: ColoresAplicacion.colorPrimario,
          onPressed: _moveToCurrentLocation,
          child:
              Icon(Icons.my_location, color: Color.fromRGBO(255, 255, 255, 1)),
        ),
      ),
    ]);
  }

  void _setCameraPosition() {
    if (_controller != null && _currentPosition != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
        ),
      );
    }
  }
}

// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:io' as io;
// import 'package:geolocator/geolocator.dart';
// import 'package:pfg_app/constants/color.dart';
// import 'package:pfg_app/modelo/lugarInteres.dart';
// import '../../private_config.dart';
// import 'package:mapbox_api/mapbox_api.dart';
// import 'package:navigation_with_mapbox/navigation_with_mapbox.dart';

// class MapaRuta extends StatefulWidget {
//   LugarInteres lugar;
//   MapaRuta(this.lugar);

//   @override
//   _MapaRutaState createState() => _MapaRutaState();
// }

// class _MapaRutaState extends State<MapaRuta> {
//   Position? _currentPosition;
//   MapboxApi mapbox = MapboxApi(
//     accessToken: Config.mapboxAccessToken,
//   );
//   final _navigationWithMapboxPlugin = NavigationWithMapbox();
//   bool _isNavigating = false;

//   @override
//   void initState() {
//     super.initState();
//     _initLocationService();
//   }

//   Future<void> _initLocationService() async {
//     try {
//       var position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _currentPosition = position;
//       });
//     } catch (e) {
//       print("Error al obtener la ubicación: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Center(
//           child: Column(
//             children: [
//               Flexible(
//                 child: Stack(
//                   children: [
//                     Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: io.Platform.isAndroid
//                                 ? () async {
//                                     await _navigationWithMapboxPlugin
//                                         .startNavigation(
//                                       origin: WayPoint(
//                                           latitude:
//                                               _currentPosition?.latitude ?? 0.0,
//                                           longitude:
//                                               _currentPosition?.longitude ??
//                                                   0.0),
//                                       destination: WayPoint(
//                                           latitude: widget.lugar.getLatitud,
//                                           longitude: widget.lugar.getLongitud),
//                                       setDestinationWithLongTap: true,
//                                       simulateRoute: false,
//                                       alternativeRoute: true,
//                                       style: 'traffic_night',
//                                       language: 'es',
//                                       profile: 'walking',
//                                       voiceUnits: 'metric',
//                                       msg:
//                                           '¡Buen viaje, disfruta de tu recorrido!',
//                                     );
//                                   }
//                                 : null,
//                             child: const Text('Start Navigation Android'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOriginalScreen() {
//     return Stack(
//       children: [
//         Positioned(
//           top: 16.0,
//           right: 16.0,
//           child: FloatingActionButton(
//             backgroundColor: ColoresAplicacion.colorPrimario,
//             onPressed: _startNavigation,
//             child: Icon(Icons.navigation, color: Colors.white),
//           ),
//         ),
//         // Other UI elements for your original screen
//       ],
//     );
//   }

//   void _startNavigation() async {
//     setState(() {
//       _isNavigating = true;
//     });

//     // Start navigation
//     await _navigationWithMapboxPlugin.startNavigation(
//       origin: WayPoint(
//           latitude: _currentPosition?.latitude ?? 0.0,
//           longitude: _currentPosition?.longitude ?? 0.0),
//       destination: WayPoint(latitude: 4.759335, longitude: -75.923914),
//       setDestinationWithLongTap: true,
//       simulateRoute: false,
//       alternativeRoute: true,
//       style: 'traffic_night',
//       language: 'es',
//       profile: 'walking',
//       voiceUnits: 'metric',
//       msg: '¡Buen viaje, disfruta de tu recorrido!',
//     );
//   }

//   void _stopNavigation() {
//     setState(() {
//       _isNavigating = false;
//     });
//   }
// }
