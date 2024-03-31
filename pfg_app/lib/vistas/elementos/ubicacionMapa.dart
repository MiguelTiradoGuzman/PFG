import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pfg_app/private_config.dart';

class UbicacionMapa extends StatefulWidget {
  @override
  _UbicacionMapaState createState() => _UbicacionMapaState();
  CameraPosition? obtenerPosicion() {
    print(
        '-------------------: ${_UbicacionMapaState()._controller?.cameraPosition!.target.longitude.toString()}');
    return _UbicacionMapaState()._controller?.cameraPosition!;
  }
}

class _UbicacionMapaState extends State<UbicacionMapa> {
  MapboxMapController? _controller;
  Position? _currentPosition;

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
      });
    } catch (e) {
      print("Error al obtener la ubicación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      //Clave privada de mapbox
      accessToken: Config.mapboxAccessToken,
      onMapCreated: (controller) {
        setState(() {
          _controller = controller;
          _setCameraPosition();
        });
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
      myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
      trackCameraPosition: true,
      //Url hacia el estilo elegido para los mapas
      styleString: Config.styleMapboxUrl,
    );
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
