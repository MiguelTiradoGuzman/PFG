import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/controlador/controlador.dart';

class TarjetaLugarInteres extends StatelessWidget {
  final LugarInteres lugarInteres;

  const TarjetaLugarInteres({required this.lugarInteres});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: GestureDetector(
        onTap: () {},
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
                  width: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                    //image: ,
                  ),
                  child: Image.network(lugarInteres.fotos.elementAt(0))
                  // CachedNetworkImage(
                  //   imageUrl: lugarInteres.fotos.elementAt(0), // URL de la imagen
                  //   fit: BoxFit.cover,
                  //   placeholder: (context, url) => CircularProgressIndicator(
                  //       strokeWidth: 3), // Widget de carga
                  //   errorWidget: (context, url, error) =>
                  //       Icon(Icons.error), // Widget de error
                  // ),
                  ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lugarInteres.nombre,
                        style: const TextStyle(
                          color: ColoresAplicacion.colorLetrasPrincipal,
                          fontFamily: 'Inter',
                          fontSize: 20,
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
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height * 0.0,
                                  left:
                                      MediaQuery.of(context).size.width * 0.0),
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
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
                                          child: Padding(
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        child: Icon(Icons.arrow_downward,
                                            color: ColoresAplicacion.colorFondo,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03),
                                      )))),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height * 0.0,
                                  left:
                                      MediaQuery.of(context).size.width * 0.01),
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
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
                                          child: Padding(
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        child: Icon(Icons.arrow_upward,
                                            color: ColoresAplicacion.colorFondo,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03),
                                      )))),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  child: Icon(Icons.edit,
                      color: ColoresAplicacion.colorLetrasPrincipal),
                  width: MediaQuery.of(context).size.width * 0.12,
                  height: MediaQuery.of(context).size.height * 0.12,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.5),
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                          topRight: Radius.circular(30)))),
            ],
          ),
        ),
      ),
    );
  }
}
