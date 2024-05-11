import 'package:flutter/material.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Pantalla de registro del usuario.
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PantallaRegistroState createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  // Controlador del campo de texto del correo del usuario
  final TextEditingController _correoControlador = TextEditingController();

  // Controlador del campo de contraseña del usuario
  final TextEditingController _contraseniaControlador = TextEditingController();

  // Controlador del campo de nombre de usuario
  final TextEditingController _usuarioControlador = TextEditingController();

  // Controlador del campo de repetición de contraseña
  final TextEditingController _contraseniaRepControlador =
      TextEditingController();

  // Error al comprobar la contraseña
  String _contrasenaErrorText = '';

  Future<void> _registrarUsuario() async {
    String correo = _correoControlador.text;
    String contrasena = _contraseniaControlador.text;
    String contrasenaRep = _contraseniaRepControlador.text;
    String nombreUsuario = _usuarioControlador.text;

    // Expresión regular para comprobar que el correo es válido
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    // Si no es un correo válido, se muestra error
    if (!emailRegex.hasMatch(correo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.correoInvalido,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width *
                            0.07, // Tamaño de fuente proporcional al ancho de la pantalla
                      ),
                    ),
                  ),
                ],
              )),
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
      return;
      // Si las contraseñas no coinciden, se muestra error
    } else if (contrasena != contrasenaRep) {
// Error al iniciar sesión, muestra un SnackBar con el mensaje de error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.contrasenaNoCoincide,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width *
                            0.07, // Tamaño de fuente proporcional al ancho de la pantalla
                      ),
                    ),
                  ),
                ],
              )),
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
      return;
      // Si la longitud de la contraseña es menos de 5 caracteres, se muestra error
    } else if (contrasena.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.contrasenaDemasiadoCorta,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width *
                            0.07, // Tamaño de fuente proporcional al ancho de la pantalla
                      ),
                    ),
                  ),
                ],
              )),
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
      return;
    } else {
      try {
        // Si no hay ningún fallo, se prueba a registrar el usuario
        await Controlador()
            .registrarUsuario(nombreUsuario, contrasena, correo, context);
        // Si se ha registrado correctamente, se inicia sesión
        await Controlador().iniciarSesion(correo, contrasena, context);
      } catch (e) {
        // Error al iniciar sesión, muestra un SnackBar con el mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.toString(),
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
  }

// Método para validar la longitud mínima de la contraseña
  void _validarContrasena(String value) {
    if (value.length < 5) {
      setState(() {
        _contrasenaErrorText = AppLocalizations.of(context)!.contrasenaTooShort;
      });
    } else {
      setState(() {
        _contrasenaErrorText = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Agregar un listener al controlador de la contraseña para validar dinámicamente
    // _contraseniaControlador.addListener(() {
    //   _validarContrasena(_contraseniaControlador.text);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Etiqueta bienvenidos
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Text(
                  AppLocalizations.of(context)!.bienvenido,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: ColoresAplicacion.colorLetrasPrincipal,
                      fontFamily: 'Inter',
                      fontSize: 40,
                      letterSpacing:
                          0 /*percentages not used in flutter. defaulting to zero*/,
                      fontWeight: FontWeight.bold,
                      height: 1),
                )),

            // Etiqueta correo electrónico
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Text(
                  AppLocalizations.of(context)!.correoElectronico,
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

            //Campo de texto de correo del usuario
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.15,
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
                                  color: ColoresAplicacion.colorLetrasPrincipal,
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1))),
                    ))),
            // Etiqueta nombre de usuario
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Text(
                  AppLocalizations.of(context)!.nombreDeUsuario,
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

            // Campo de texto del nombre de usuario
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.15,
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
                          controller: _usuarioControlador,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'NombreUsuario',
                              hintStyle: TextStyle(
                                  color: ColoresAplicacion.colorLetrasPrincipal,
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1))),
                    ))),

            // Campo de texto contraseña
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Text(
                  AppLocalizations.of(context)!.contrasena,
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
            // Campo de repetición de contraseña
            Column(
              children: [
                if (_contrasenaErrorText.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01,
                        left: MediaQuery.of(context).size.width * 0.04),
                    child: Text(
                      _contrasenaErrorText,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01,
                        left: MediaQuery.of(context).size.width * 0.05),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.15,
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
                            // onSubmitted: (_) {
                            //   FocusScope.of(context).nextFocus();
                            // },
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
                                    height: 1)),
                            // onChanged: (text) {
                            //   // Si la contraseña tiene menos de 5 caracteres se muestra error
                            //   setState(() {
                            //     if (text.length < 5) {
                            //       _contrasenaErrorText =
                            //           AppLocalizations.of(context)!
                            //               .contrasenaTooShort;
                            //     } else {
                            //       _contrasenaErrorText = '';
                            //     }
                            //   });
                            // },
                          ),
                        )))
              ],
            ),
            // Etiqueta repetir contraseña
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.03,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Text(
                  AppLocalizations.of(context)!.repetirContrasena,
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
            // Campo repetir contraseña
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.15,
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
                          controller: _contraseniaRepControlador,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '* * * * * * *',
                              hintStyle: TextStyle(
                                  color: ColoresAplicacion.colorLetrasPrincipal,
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1))),
                    ))),
            // Botón de registro de usuario
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1,
                  left: MediaQuery.of(context).size.width * 0.05),
              child: GestureDetector(
                  onTap: _registrarUsuario,
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.1,
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
                          child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.15,
                                right:
                                    MediaQuery.of(context).size.width * 0.02),
                            child: Icon(Icons.create,
                                color: ColoresAplicacion.colorFondo, size: 30),
                          ),
                          Text(
                            AppLocalizations.of(context)!.botonRegistrarme,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColoresAplicacion.colorFondo,
                                fontFamily: 'Inter',
                                fontSize: 30,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.bold,
                                height: 1),
                          )
                        ],
                      )))),
            ),
          ]),
    ));
  }
}
