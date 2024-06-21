import 'package:flutter/material.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';
import 'elementos/tarjetaRuta.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectorModificarRuta extends StatefulWidget {
  final List<RutaTuristica>? rutas;
  SelectorModificarRuta({required this.rutas});
  @override
  _SelectorModificarRutaState createState() => _SelectorModificarRutaState();
}

class _SelectorModificarRutaState extends State<SelectorModificarRuta> {
  List<RutaTuristica>? rutas = [];

  @override
  void initState() {
    super.initState();
    rutas = widget.rutas;
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
                AppLocalizations.of(context)!.rutasDisponibles,
                style: TextStyle(
                  color: ColoresAplicacion.colorLetrasPrincipal,
                  fontFamily: 'Inter',
                  fontSize: 30,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.0,
                  left: MediaQuery.of(context).size.width * 0.04,
                ),
                child: Container(
                    width: MediaQuery.of(context).size.width *
                        0.9, // Ancho total del 90%
                    height: MediaQuery.of(context).size.height * 0.52,
                    child: rutas != null
                        ? ListView.builder(
                            padding: const EdgeInsets.only(top: 0.1),
                            scrollDirection: Axis.vertical,
                            itemCount: rutas!.length,
                            itemBuilder: (context, index) {
                              RutaTuristica ruta = rutas!.elementAt(index);

                              return GestureDetector(
                                  child: TarjetaRuta(
                                    rutaTuristica: ruta,
                                  ),
                                  onTap: () => Controlador()
                                      .cargarAniadirModificarRuta(
                                          context, ruta));
                            },
                          )
                        : Text(""))),
          ],
        ),
      ),
    );
  }
}
