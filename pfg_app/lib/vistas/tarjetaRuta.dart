import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/color.dart';
import '../modelo/rutaTuristica.dart';
import '../controlador/controlador.dart';

class TarjetaRuta extends StatelessWidget {
  final RutaTuristica rutaTuristica;

  const TarjetaRuta({required this.rutaTuristica});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: GestureDetector(
        onTap: () {
          Controlador().loadPaginaRuta(rutaTuristica, context);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.12,
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
                offset: Offset(4, 4),
                blurRadius: 4,
              )
            ],
            color: ColoresAplicacion.colorFondo,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                  image: DecorationImage(
                    image: AssetImage(rutaTuristica.rutaImagen),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        rutaTuristica.nombre,
                        style: const TextStyle(
                          color: ColoresAplicacion.colorPrimario,
                          fontFamily: 'Inter',
                          fontSize: 28,
                          letterSpacing: 0,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
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
                                  left:
                                      MediaQuery.of(context).size.width * 0.01,
                                  right:
                                      MediaQuery.of(context).size.width * 0.03),
                              child: Text(
                                rutaTuristica.duracion,
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
                                // right:
                                //     MediaQuery.of(context).size.width * 0.03
                              ),
                              child: Text(
                                '${rutaTuristica.distancia} km',
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
