import 'package:flutter/material.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pfg_app/src/localeProvider.dart';
import 'package:pfg_app/src/localization/l10.dart';

// Pantalla ajustes. El usuario puede borrar su perfil o cambiar de idioma la aplicación
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PantallaAjustesState createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  String _tamanioLetra = "Normal";

  @override
  void initState() {
    super.initState();
  }

  // Manejador Evento: Usuario pulsa botón 'Borrar Usuario'
  // Se muestra un mensaje al usuario para que ratifique su decisión y no borre la cuenta por un error en la pulsación del botón.
  void _asegurarBorradoUsuario() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColoresAplicacion.colorFondo,
          title: Text(AppLocalizations.of(context)!.confirmarBorrado,
              style: const TextStyle(
                  color: ColoresAplicacion.colorPrimario,
                  fontFamily: 'Inter',
                  fontSize: 20,
                  letterSpacing:
                      0 /*percentages not used in flutter. defaulting to zero*/,
                  fontWeight: FontWeight.bold,
                  height: 1)),
          content: Text(AppLocalizations.of(context)!.seguroBorrar,
              style: const TextStyle(
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
              child: Text(AppLocalizations.of(context)!.cancelar,
                  style:
                      const TextStyle(color: ColoresAplicacion.colorPrimario)),
            ),
            // Si pulsa el botón de aceptar, se borra el usuario del sistema
            TextButton(
              onPressed: () {
                // Aquí puedes realizar la acción de borrado
                Controlador().borrarUsuario(context);
              },
              child: Text(AppLocalizations.of(context)!.aceptar,
                  style:
                      const TextStyle(color: ColoresAplicacion.colorPrimario)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);

    final localesDisponibles = AppLocalizations.supportedLocales;
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Etiqueta: Selección de idioma
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Text(
                  AppLocalizations.of(context)!.seleccioneIdioma,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1),
                )),
            // Selector de idioma. Se despliegan todos los idiomas en los que está disponible la aplicación. Cambia el idioma de todos los botones y etiquetas de la aplicación.
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: DropdownButton<Locale>(
                  value: LocaleProvider().locale,
                  items: L10n.all.map<DropdownMenuItem<Locale>>((Locale value) {
                    return DropdownMenuItem(
                      child: Text(value.languageCode),
                      value: value,
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      provider.setLocale(value!);
                    });
                  },
                )),

            // Botón borrar usuario
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: _asegurarBorradoUsuario,
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
                    child: Center(
                        child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.25,
                              right: MediaQuery.of(context).size.width * 0.02),
                          child: Icon(Icons.delete,
                              color: ColoresAplicacion.colorPrimario, size: 25),
                        ),
                        Text(
                          AppLocalizations.of(context)!.borrarUsuario,
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
                ))
          ]),
    ));
  }
}
