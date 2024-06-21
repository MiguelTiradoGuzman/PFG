import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';

class TarjetaLugarInteres extends StatelessWidget {
  final RutaTuristica _ruta;
  final LugarInteres _lugarInteres;
  final List<File> _imgs;
  final Function(RutaTuristica, LugarInteres, List<File> imgs) onTapFuncion;
  final Function(RutaTuristica, LugarInteres) onTapFuncion2;
  const TarjetaLugarInteres(
      {required LugarInteres lugarInteres,
      required RutaTuristica ruta,
      required List<File> imgs,
      required this.onTapFuncion,
      required this.onTapFuncion2})
      : _imgs = imgs,
        _lugarInteres = lugarInteres,
        _ruta = ruta;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
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
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.height * 0.12,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                image: !_imgs.isEmpty
                    ? DecorationImage(
                        image: FileImage(_imgs.elementAt(0)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _lugarInteres.nombre,
                      style: const TextStyle(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        fontFamily: 'Inter',
                        fontSize: 20,
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                                left: MediaQuery.of(context).size.width * 0.0),
                            child: GestureDetector(
                                onTap: () =>
                                    onTapFuncion2(_ruta, _lugarInteres),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.height *
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
                                      child: Icon(Icons.delete,
                                          color: ColoresAplicacion.colorFondo,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.03),
                                    )))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
                onTap: () => onTapFuncion(_ruta, _lugarInteres, _imgs),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.height * 0.12,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: const Icon(Icons.edit,
                        color: ColoresAplicacion.colorLetrasPrincipal))),
          ],
        ),
      ),
    );
  }
}
