import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

double tamTitulos = 23;

// Pantalla Mi Cuenta. El usuario puede observar su información personal en el sistema, modificar la contraseña, acceder a sus rutas favoritas y acceder a sus rutas creadas para modificarlas.
class MiCuenta extends StatefulWidget {
  const MiCuenta();

  @override
  // ignore: library_private_types_in_public_api
  _MiCuentaState createState() => _MiCuentaState();
}

class _MiCuentaState extends State<MiCuenta> {
  // Controlador del campo de texto de modificación de la contraseña
  final TextEditingController _controladorContrasenia = TextEditingController();
  // Controlador del campo de texto de repetición de la contraseña
  final TextEditingController _controladorRepeticionContrasenia =
      TextEditingController();
  // Contraseña antigua
  String _contraseniaAntigua = '';
  // Mensaje de error
  String _contraseniaErrorText = '';

// Método para validar la longitud mínima de la contraseña
  void _validarContrasena(String value) {
    if (value.length < 5) {
      setState(() {
        // Si es demasiado corta se rellena la variable de error.
        _contraseniaErrorText =
            AppLocalizations.of(context)!.contrasenaTooShort;
      });
    } else {
      setState(() {
        // Si se ha solucionado este problema, se vacía dicha variable
        _contraseniaErrorText = '';
      });
    }
  }

  // Manejador del evento: Usuario pulsa el botón modiciar contraseña
  void _mostrarMenuEditarContrasenia(BuildContext context) {
    // Muestra diálogo para que el usuario introduzca la antigua contraseña
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 4),
          // Etiqueta: Introduzca su antigua contraseña
          title:
              Text(AppLocalizations.of(context)!.introducirAntiguaContrasena),
          content: SizedBox(
            // Ajusta el tamaño del contenido del diálogo
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: TextFormField(
              initialValue: '',
              onChanged: (value) {
                setState(() {
                  _contraseniaAntigua = value;
                });
              },
              decoration: const InputDecoration(
                hintText: '* * * * * *',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text(AppLocalizations.of(context)!.cancelar),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                manejarContrasenia();
              },
              child: Text(AppLocalizations.of(context)!.guardar),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Agregar un listener al controlador de la contraseña para validar dinámicamente
    _controladorContrasenia.addListener(() {
      _validarContrasena(_controladorContrasenia.text);
    });
  }

  // Manejador de evento: Usuario pulsa botón guardar en menú de diálogo.
  void manejarContrasenia() {
    // Contraseña nueva
    String contrasena = _controladorContrasenia.text;
    // Repetición de la nueva contraseña
    String contrasenaRep = _controladorRepeticionContrasenia.text;
    if (contrasena != contrasenaRep) {
      // Las contraseñas no son similares, muestra un SnackBar con el mensaje de error
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
      // Las contraseñas son demasiado cortas, muestra el mensaje de error por pantalla
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
      //Registra la nueva contraseña en el sistema
      Controlador()
          .modificarContrasenia(contrasena, _contraseniaAntigua, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Imagen de icono de usuario
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.3),
                child: SvgPicture.asset(
                  'assets/images/user-circle.svg',
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.height,
                  semanticsLabel: 'User',
                  color: ColoresAplicacion.colorPrimario,
                )),
            // Etiqueta: Datos personales
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01,
                    left: MediaQuery.of(context).size.width * 0.0),
                child: ExpansionTile(
                  title: Text(
                    AppLocalizations.of(context)!.datosPersonales,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: ColoresAplicacion.colorLetrasPrincipal,
                        fontFamily: 'Inter',
                        fontSize: tamTitulos,
                        letterSpacing:
                            0 /*percentages not used in flutter. defaulting to zero*/,
                        fontWeight: FontWeight.bold,
                        height: 1),
                  ),
                  children: [
                    // Padding(
                    //     padding: EdgeInsets.only(
                    //         top: MediaQuery.of(context).size.height * 0.01,
                    //         left: MediaQuery.of(context).size.width * 0.05),
                    //     child: GestureDetector(
                    //       onTap: () {},
                    //       child: Container(
                    //         width: MediaQuery.of(context).size.width * 0.7,
                    //         height: MediaQuery.of(context).size.height * 0.05,
                    //         decoration: BoxDecoration(
                    //           borderRadius: const BorderRadius.only(
                    //             topLeft: Radius.circular(65),
                    //             topRight: Radius.circular(65),
                    //             bottomLeft: Radius.circular(65),
                    //             bottomRight: Radius.circular(65),
                    //           ),
                    //           color: ColoresAplicacion.colorFondo,
                    //           border: Border.all(
                    //             color: ColoresAplicacion.colorPrimario,
                    //             width: 2,
                    //           ),
                    //         ),
                    //         child: Center(
                    //             child: Text(
                    //           AppLocalizations.of(context)!.modificarImagen,
                    //           textAlign: TextAlign.center,
                    //           style: const TextStyle(
                    //               color: ColoresAplicacion.colorPrimario,
                    //               fontFamily: 'Inter',
                    //               fontSize: 20,
                    //               letterSpacing:
                    //                   0 /*percentages not used in flutter. defaulting to zero*/,
                    //               fontWeight: FontWeight.bold,
                    //               height: 1),
                    //         )),
                    //       ),
                    //     )),
                    // Etiqueta: Correo electrónico
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02,
                            left: MediaQuery.of(context).size.width * 0.05),
                        child: Text(
                          AppLocalizations.of(context)!.etiquetaCorreo,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: ColoresAplicacion.colorLetrasPrincipal,
                              fontFamily: 'Inter',
                              fontSize: tamTitulos,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        )),
                    // Muestra el correo electrónico del usuario
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.width * 0.05),
                      child: Text(
                        Controlador().getUsuario().getCorreo,
                        style: const TextStyle(
                          color: ColoresAplicacion.colorLetrasPrincipal,
                          fontFamily: 'Inter',
                          fontSize: 20,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                          height: 1,
                        ),
                      ),
                    ),
                    // Etiqueta: Nombre de usuario
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.03,
                            left: MediaQuery.of(context).size.width * 0.05),
                        child: Text(
                          AppLocalizations.of(context)!.nombreDeUsuario,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: ColoresAplicacion.colorLetrasPrincipal,
                              fontFamily: 'Inter',
                              fontSize: tamTitulos,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        )),
                    // Muestra el nombre de usuario
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.width * 0.05),
                      child: Text(
                        Controlador().getUsuario().getNombreUsuario,
                        style: const TextStyle(
                          color: ColoresAplicacion.colorLetrasPrincipal,
                          fontFamily: 'Inter',
                          fontSize: 20,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                          height: 1,
                        ),
                      ),
                    ),
                    // Botón para abrir el menú de edición de contraseña
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.01,
                            left: MediaQuery.of(context).size.width * 0.01),
                        child: ExpansionTile(
                          title: Text(
                            AppLocalizations.of(context)!.modificarContrasenia,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: ColoresAplicacion.colorLetrasPrincipal,
                                fontFamily: 'Inter',
                                fontSize: tamTitulos,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.bold,
                                height: 1),
                          ),
                          children: [
                            Column(
                              children: [
                                if (_contraseniaErrorText.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.04),
                                    child: Text(
                                      _contraseniaErrorText,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.01),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          border: Border.all(
                                            color: ColoresAplicacion
                                                .colorLetrasPrincipal,
                                            width: 2,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          child: TextField(
                                            controller: _controladorContrasenia,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '* * * * * * *',
                                                hintStyle: TextStyle(
                                                    color: ColoresAplicacion
                                                        .colorLetrasPrincipal,
                                                    fontFamily: 'Inter',
                                                    fontSize: 15,
                                                    letterSpacing: 0,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height: 1)),
                                            onChanged: (text) {
                                              setState(() {
                                                if (text.length < 5) {
                                                  _contraseniaErrorText =
                                                      AppLocalizations.of(
                                                              context)!
                                                          .contrasenaTooShort;
                                                } else {
                                                  _contraseniaErrorText = '';
                                                }
                                              });
                                            },
                                          ),
                                        )))
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .repetirContrasenia,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: ColoresAplicacion
                                          .colorLetrasPrincipal,
                                      fontFamily: 'Inter',
                                      fontSize: tamTitulos,
                                      letterSpacing:
                                          0 /*percentages not used in flutter. defaulting to zero*/,
                                      fontWeight: FontWeight.bold,
                                      height: 1),
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        0.01,
                                    left: MediaQuery.of(context).size.width *
                                        0.01),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.width *
                                        0.15,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      border: Border.all(
                                        color: ColoresAplicacion
                                            .colorLetrasPrincipal,
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.02),
                                      child: TextField(
                                          controller:
                                              _controladorRepeticionContrasenia,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: '* * * * * * *',
                                              hintStyle: TextStyle(
                                                  color: ColoresAplicacion
                                                      .colorLetrasPrincipal,
                                                  fontFamily: 'Inter',
                                                  fontSize: 15,
                                                  letterSpacing: 0,
                                                  fontWeight: FontWeight.normal,
                                                  height: 1))),
                                    ))),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        0.01,
                                    left: MediaQuery.of(context).size.width * 0,
                                    bottom: MediaQuery.of(context).size.height *
                                        0.01),
                                child: GestureDetector(
                                  onTap: () {
                                    _mostrarMenuEditarContrasenia(context);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(65),
                                        topRight: Radius.circular(65),
                                        bottomLeft: Radius.circular(65),
                                        bottomRight: Radius.circular(65),
                                      ),
                                      color: ColoresAplicacion.colorPrimario,
                                      border: Border.all(
                                        color: ColoresAplicacion.colorPrimario,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                        child: Text(
                                      AppLocalizations.of(context)!
                                          .modificarContrasenia,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: ColoresAplicacion.colorFondo,
                                          fontFamily: 'Inter',
                                          fontSize: 20,
                                          letterSpacing:
                                              0 /*percentages not used in flutter. defaulting to zero*/,
                                          fontWeight: FontWeight.bold,
                                          height: 1),
                                    )),
                                  ),
                                )),
                          ],
                        )),
                  ],
                )),
            // Botón Mis rutas favoritas
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: () {
                    Controlador().cargaSelectorFavoritas(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color: ColoresAplicacion.colorPrimario,
                      border: Border.all(
                        color: ColoresAplicacion.colorFondo,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                              right: MediaQuery.of(context).size.width * 0.06),
                          child: Icon(Icons.favorite,
                              color: ColoresAplicacion.colorFondo),
                        ),
                        Center(
                            child: Text(
                          AppLocalizations.of(context)!.misRutasFavoritas,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: ColoresAplicacion.colorFondo,
                              fontFamily: 'Inter',
                              fontSize: 20,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        ))
                      ],
                    ),
                  ),
                )),
            // Botón Mis Rutas Creadas
            Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: GestureDetector(
                  onTap: () {
                    Controlador().cargarSelectorModificarRutas(
                        context, Controlador().getUsuario());
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color: ColoresAplicacion.colorFondo,
                      border: Border.all(
                        color: ColoresAplicacion.colorPrimario,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                              right: MediaQuery.of(context).size.width * 0.06),
                          child: Icon(Icons.settings,
                              color: ColoresAplicacion.colorPrimario),
                        ),
                        Center(
                            child: Text(
                          AppLocalizations.of(context)!.modificarRutas,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: ColoresAplicacion.colorPrimario,
                              fontFamily: 'Inter',
                              fontSize: 20,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.bold,
                              height: 1),
                        ))
                      ],
                    ),
                  ),
                ))
          ]),
    ));
  }
}
