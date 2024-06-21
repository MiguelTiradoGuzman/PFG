import 'package:flutter/material.dart';
import 'package:pfg_app/constants/color.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:pfg_app/controlador/controlador.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MenuLateral extends StatelessWidget {
  // Pantalla que se muestra internamente
  final Widget body;
  // Título de la pantalla
  final String titulo;

  const MenuLateral({super.key, required this.body, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titulo,
          style: const TextStyle(
            color: ColoresAplicacion.colorLetrasPrincipal,
            fontFamily: 'Inter',
            fontSize: 28,
            letterSpacing: 0,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              size: 40,
              color: ColoresAplicacion.colorLetrasPrincipal,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: body,
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            color: ColoresAplicacion.colorPrimario,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: ListView(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 20),
                color: ColoresAplicacion.colorPrimario,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        size: 40,
                        color: ColoresAplicacion.colorFondo,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Cierra el Drawer
                      },
                    ),
                  ],
                ),
              ),
              FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.18,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: DrawerHeader(
                        decoration: const BoxDecoration(
                          color: ColoresAplicacion.colorFondo,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Cambia el CircleAvatar por un Icon temporalmente
                            const Icon(
                              Icons.person,
                              size: 75,
                              color: ColoresAplicacion.colorPrimario,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              Controlador().getUsuario().getNombreUsuario,
                              style: const TextStyle(
                                color: ColoresAplicacion.colorPrimario,
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              Padding(
                padding: EdgeInsets.only(top: 1.0),
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.inicio,
                      style: TextStyle(
                        color: ColoresAplicacion.colorFondo,
                        fontFamily: 'Inter',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      )),
                  leading: const Icon(
                    Icons.home,
                    size: 40,
                    color: ColoresAplicacion.colorFondo,
                  ),
                  onTap: () {
                    // Acciones cuando se presiona "Inicio"
                    Controlador()
                        .cargaPantallaInicial(context); // Cierra el Drawer
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 1.0),
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.miCuenta,
                      style: TextStyle(
                        color: ColoresAplicacion.colorFondo,
                        fontFamily: 'Inter',
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      )),
                  leading: const Icon(
                    Icons.person,
                    size: 40,
                    color: ColoresAplicacion.colorFondo,
                  ),
                  onTap: () {
                    // Acciones cuando se presiona "Mi Cuenta"
                    Controlador().cargarPantallaMiCuenta(context);
                  },
                ),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.ajustes,
                    style: TextStyle(
                      color: ColoresAplicacion.colorFondo,
                      fontFamily: 'Inter',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    )),
                leading: const Icon(
                  Icons.settings,
                  size: 40,
                  color: ColoresAplicacion.colorFondo,
                ),
                onTap: () {
                  Controlador().cargarPantallaAjustes(context);
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.anadirRuta,
                    style: TextStyle(
                      color: ColoresAplicacion.colorFondo,
                      fontFamily: 'Inter',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    )),
                leading: const Icon(
                  Icons.add_box,
                  size: 40,
                  color: ColoresAplicacion.colorFondo,
                ),
                onTap: () {
                  Controlador().cargarAniadirModificarRuta(context, null);
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.cerrarSesion,
                    style: TextStyle(
                      color: ColoresAplicacion.colorFondo,
                      fontFamily: 'Inter',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    )),
                leading: const Icon(
                  Icons.logout,
                  size: 40,
                  color: ColoresAplicacion.colorFondo,
                ),
                onTap: () {
                  Controlador().cerrarSesion(context); // Cierra el Drawer
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
