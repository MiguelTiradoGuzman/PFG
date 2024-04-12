import 'package:flutter/material.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PantallaAjustesState createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final Controlador _controlador = Controlador();
  String _idioma = "Español";

  String _tamanioLetra = "Normal";

  @override
  void initState() {
    super.initState();
  }

  void _asegurarDeBorrarUsuario() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColoresAplicacion.colorFondo,
          title: const Text('Confirmar borrado',
              style: TextStyle(
                  color: ColoresAplicacion.colorPrimario,
                  fontFamily: 'Inter',
                  fontSize: 20,
                  letterSpacing:
                      0 /*percentages not used in flutter. defaulting to zero*/,
                  fontWeight: FontWeight.bold,
                  height: 1)),
          content: const Text('¿Está seguro de que desea borrar el usuario?',
              style: TextStyle(
                  color: ColoresAplicacion.colorLetrasPrincipal,
                  fontFamily: 'Inter',
                  fontSize: 20,
                  letterSpacing:
                      0 /*percentages not used in flutter. defaulting to zero*/,
                  height: 1)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar',
                  style: TextStyle(color: ColoresAplicacion.colorPrimario)),
            ),
            TextButton(
              onPressed: () {
                // Aquí puedes realizar la acción de borrado
                Controlador().borrarUsuario(context);
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar',
                  style: TextStyle(color: ColoresAplicacion.colorPrimario)),
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
            // Padding(
            //     padding: EdgeInsets.only(
            //         top: MediaQuery.of(context).size.height * 0.1,
            //         left: MediaQuery.of(context).size.width * 0.05),
            //     child: const Text(
            //       'Ajustes',
            //       textAlign: TextAlign.left,
            //       style: TextStyle(
            //           color: ColoresAplicacion.colorLetrasPrincipal,
            //           fontFamily: 'Inter',
            //           fontSize: 40,
            //           letterSpacing:
            //               0 /*percentages not used in flutter. defaulting to zero*/,
            //           fontWeight: FontWeight.bold,
            //           height: 1),
            //     )),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: const Text(
                  'Seleccione Idioma',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1),
                )),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: DropdownButton<String>(
                  value: _idioma,
                  items: <String>["Español", "English"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? nuevoValor) {
                    setState(() {
                      _idioma = nuevoValor!;
                    });
                  },
                )),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: const Text(
                  'Tamaño de la letra',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1),
                )),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: DropdownButton<String>(
                  value: _tamanioLetra,
                  items: <String>["Normal", "Grande"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? nuevoValor) {
                    setState(() {
                      _tamanioLetra = nuevoValor!;
                    });
                  },
                )),
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: _asegurarDeBorrarUsuario,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.07,
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
                    child: const Center(
                        child: Text(
                      'Borrar Usuario',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: ColoresAplicacion.colorPrimario,
                          fontFamily: 'Inter',
                          fontSize: 20,
                          letterSpacing:
                              0 /*percentages not used in flutter. defaulting to zero*/,
                          fontWeight: FontWeight.bold,
                          height: 1),
                    )),
                  ),
                ))
          ]),
    ));
  }
}
