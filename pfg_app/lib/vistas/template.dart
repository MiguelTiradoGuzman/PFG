import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../modelo/usuario.dart';

class TemplateApp extends StatelessWidget {
  final Widget body;
  final Usuario usuario;
  final String titulo;

  const TemplateApp(
      {super.key,
      required this.body,
      required this.usuario,
      required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Descubre Granada',
          style: TextStyle(
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
                              size: 80,
                              color: ColoresAplicacion.colorPrimario,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              usuario.getUsername,
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
                  title: const Text('Mi Cuenta',
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
                    Navigator.pop(context); // Cierra el Drawer
                  },
                ),
              ),
              ListTile(
                title: const Text('Ajustes',
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
                  // Acciones cuando se presiona "Ajustes"
                  Navigator.pop(context); // Cierra el Drawer
                },
              ),
              ListTile(
                title: const Text('Cerrar Menú',
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
                  Navigator.pop(context); // Cierra el Drawer
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}