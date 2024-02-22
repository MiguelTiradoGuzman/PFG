import 'package:flutter/material.dart';
import 'package:pfg_app/modelo/lugarInteres.dart';
import 'package:pfg_app/constants/color.dart';

class ListaLugares extends StatelessWidget {
  final List<LugarInteres> lugares;
  ListaLugares({required this.lugares});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.045),
          child: Container(
            color: ColoresAplicacion.colorPrimario,
            width: MediaQuery.of(context).size.width * 0.05,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: List.generate(
                lugares.length,
                (index) => Container(
                      height: MediaQuery.of(context).size.height * 0.07,
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.02),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).size.width * 0.07,
                                  backgroundColor:
                                      ColoresAplicacion.colorPrimario,
                                  child: CircleAvatar(
                                    radius: MediaQuery.of(context).size.width *
                                        0.04,
                                    backgroundColor:
                                        ColoresAplicacion.colorFondo,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.03),
                            child: Text(
                              lugares[index].nombre,
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          )),
                        ],
                      ),
                    )),
          ),
        )
      ],
    );
  }
}
