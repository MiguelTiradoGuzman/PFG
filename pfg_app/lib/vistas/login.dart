import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Pantalla de inicio de la aplicación. Se inicia sesión o se pasa a la pantalla de registro
class PaginaLogin extends StatefulWidget {
  const PaginaLogin({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaginaLoginState createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  // Controlador del campo de texto del correo electrónico
  final TextEditingController _correoControlador = TextEditingController();
  // Controlador del campo de texto de la contraseña
  final TextEditingController _contraseniaControlador = TextEditingController();

  // Función para manerjar la lógica para iniciar sesión
  Future<void> _iniciarSesion() async {
    String correo = _correoControlador.text;
    String contrasena = _contraseniaControlador.text;

    try {
      // Se hace llamada síncrona al iniciar sesión del controlador.
      await Controlador().iniciarSesion(correo, contrasena, context);
    } catch (e) {
      // Si salta algúna excepción durante el inicio de sesión, ya sea de HTTP o ajena
      // Error al iniciar sesión, muestra un SnackBar con el mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.errorInicioSesion,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width *
                          0.07, // Tamaño de fuente proporcional al ancho de la pantalla
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.cerrar,
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
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
            child: Stack(children: <Widget>[
              // Imagen de la Alhambra de fondo
              Positioned(
                  top: MediaQuery.of(context).size.height * -0.25,
                  // left: -1,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/alhambra.jpeg'),
                            fit: BoxFit.fitWidth),
                      ))),
              // Círculo en blanco de fondo
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.2,
                  left: 0,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: ColoresAplicacion.colorFondo,
                        borderRadius: BorderRadius.all(Radius.elliptical(
                            MediaQuery.of(context).size.width * 1.7,
                            MediaQuery.of(context).size.height)),
                      ))),
              // Icono de usuario
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.25,
                  left: MediaQuery.of(context).size.width * 0.3,
                  child: SvgPicture.asset(
                    'assets/images/user-circle.svg',
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.height,
                    semanticsLabel: 'User',
                    color: ColoresAplicacion.colorPrimario,
                  )),
              // Campo de texto del correo
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.50,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: Container(
                      width: 264,
                      height: 39,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        border: Border.all(
                          color: ColoresAplicacion.colorLetrasPrincipal,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.02),
                        child: TextField(
                            controller: _correoControlador,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'ejemplo@correo.ugr.es',
                                hintStyle: TextStyle(
                                    color:
                                        ColoresAplicacion.colorLetrasPrincipal,
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    height: 1))),
                      ))),
              // Etiqueta del correo electrónico
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.47,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: Text(
                    AppLocalizations.of(context)!.etiquetaCorreo,
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
              // Campo de texto de la contraseña
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.6,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: Container(
                      width: 264,
                      height: 39,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        border: Border.all(
                          color: ColoresAplicacion.colorLetrasPrincipal,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.02),
                        child: TextField(
                            controller: _contraseniaControlador,
                            obscureText: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: '* * * * * * *',
                                hintStyle: TextStyle(
                                    color:
                                        ColoresAplicacion.colorLetrasPrincipal,
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    height: 1))),
                      ))),
              // Etiqueta contraseña
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.57,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: Text(
                    AppLocalizations.of(context)!.contrasenia,
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
              // Botón de iniciar sesión. Su manejador es la función _iniciarSesion
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.67,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: GestureDetector(
                      onTap: _iniciarSesion,
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: MediaQuery.of(context).size.height * 0.07,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(65),
                              topRight: Radius.circular(65),
                              bottomLeft: Radius.circular(65),
                              bottomRight: Radius.circular(65),
                            ),
                            color: ColoresAplicacion.colorPrimario,
                          ),
                          child: Center(
                              child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.13,
                                    right: MediaQuery.of(context).size.width *
                                        0.01),
                                child: Icon(Icons.login,
                                    color: ColoresAplicacion.colorFondo,
                                    size: 30),
                              ),
                              Text(
                                AppLocalizations.of(context)!
                                    .botonIniciarSesion,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: ColoresAplicacion.colorFondo,
                                    fontFamily: 'Inter',
                                    fontSize: 20,
                                    letterSpacing:
                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                    fontWeight: FontWeight.bold,
                                    height: 1),
                              )
                            ],
                          ))))),
              // Botón para ir a la pantalla de registro.
              Positioned(
                  top: MediaQuery.of(context).size.height * 0.8,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: GestureDetector(
                    onTap: () {
                      Controlador().cargarPantallaRegistro(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
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
                                left: MediaQuery.of(context).size.width * 0.15,
                                right:
                                    MediaQuery.of(context).size.width * 0.01),
                            child: Icon(Icons.create,
                                color: ColoresAplicacion.colorPrimario,
                                size: 25),
                          ),
                          Text(
                            AppLocalizations.of(context)!.botonRegistrarme,
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                  )),
            ])));
  }
}
