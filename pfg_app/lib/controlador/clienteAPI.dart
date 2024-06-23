import 'dart:convert';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pfg_app/constants/network_const.dart';
import 'package:pfg_app/modelo/rutaTuristica.dart';
import 'package:pfg_app/modelo/usuario.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

class ClienteAPI {
  // Se establece el patrón Singleton para la clase ClienteAPI
  static final ClienteAPI _instance = ClienteAPI._internal();
  factory ClienteAPI() => _instance;
  ClienteAPI._internal();

  // URL Base de la API
  String _baseUrl = NetworkConst.baseUrl;

  // Token de acceso del usuario. Inicialmente vacío al no haber iniciado sesión.
  String _token = '';

  // Método para obtener el token de sesión del usuario.
  String get token => _token;

  // Función para crear una lista de Rutas recibiéndolas desde un archivo en formato Json
  List<RutaTuristica> _rutasDesdeJson(Map<String, dynamic> rutasJson) {
    // Obtiene el vector de rutas en formato Json.
    List<dynamic> data = rutasJson['rutas'];

    // Por cada una de las rutas en formato Json crea un objeto del tipo RutaTuristica
    List<RutaTuristica> rutas = data.map((rutaJson) {
      return RutaTuristica.serializacion(rutaJson);
    }).toList();

    return rutas;
  }

  // Método para autenticarse en el sistema
  // Parámetros: correo electrónico del usuario y contraseña
  Future<Usuario> login(String correo, String contrasenia) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Creación del cuerpo de la petición HTTP
    var data = {'email': correo, 'password': contrasenia};

    // Realizar la solicitud POST con el correo y contraseña en el cuerpo de la petición
    // Hacia la URL /login
    try {
      Response response = await dio.post(
        '$_baseUrl/login',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: FormData.fromMap(data),
      );
      // Una vez recibida la respuesta, se cierra la petición
      dio.close();

      // Si el código de respuesta es 200 OK, se procesa la respuesta
      if (response.statusCode == 200) {
        // Se construye el objeto usuario desde los datos obtenidos
        Usuario usuario = Usuario.serializacion(response.data['user_info']);

        // Se establece el token de sesión del usuario para usarlo en futuras peticiones.
        _token = response.data['access_token']!;

        // Se devuelve el usuario construido.
        return usuario;
      } else {
        throw ('Inicio de sesión fallido. Verifica tus credenciales.');
        // Si nos devuelve otro código, como 404 NOT-FOUND se devuelve un usuario vacío
        //return Usuario(nombreUsuario: "not-found", correo: "not-found");
      }
    } catch (e) {
      // Si hay algún error durante el paso de mensajes se lanza una excepción.
      throw ('Error: $e');
    }
  }

  // Método para registrar un nuevo usuario en el sistema
  Future<void> registrarUsuario(
      String nombreUsuario, String contrasenia, String correo) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Construcción del cuerpo de la petición HTTP con la información del nuevo usuario
    var data = {
      'nombreUsuario': nombreUsuario,
      'password': contrasenia,
      'correo': correo
    };

    // Realizar la solicitud POST con la información del usuario.
    // Hacia la URL /signin
    try {
      Response response = await dio.post(
        '$_baseUrl/signin',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: FormData.fromMap(data),
      );

      // Si la respuesta tiene código 409 Conflict es porque puede existir otro usuario con el mismo nombre o correo electrónico.
      if (response.statusCode == 409) {
        throw (response.data['detail']);
      }

      // Se cierra la conexión del cliente
      dio.close();
    } catch (e) {
      throw ('Error: $e');
    }
  }

  // Método para obtener todas las rutas del sistema
  Future<List<RutaTuristica>> getRutas() async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }
    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud GET hacia la URL /rutas.
    try {
      Response response = await dio.get(
        '$_baseUrl/rutas',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      // Si la respuesta es exitosa, procesa las rutas.
      if (response.statusCode == 200) {
        dio.close();
        return _rutasDesdeJson(response.data);
      } else {
        // Ha habido un error al obtener las rutas
        dio.close();
        throw Exception('Error al obtener las rutas: ${response.statusCode}');
      }
    } catch (e) {
      // Hay algún error durante el paso de mensajes ajeno al protocolo.
      throw ('Error: $e');
    }
  }

  // Método para obtener una ruta específica por el nombre de la ruta.
  Future<RutaTuristica?> getRuta(String nombreRuta) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud GET a la URL /ruta/nombreDeLaRuta.
    try {
      Response response = await dio.get(
        '$_baseUrl/ruta/$nombreRuta',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Si la respuesta tiene código 200 OK, se construye la ruta a devolver
      if (response.statusCode == 200) {
        RutaTuristica ruta = RutaTuristica.serializacion(response.data['ruta']);
        dio.close();
        return ruta;
        // Si no se ha encontrado (Código 404 en protocolo HTTP) se devuelve null.
      } else if (response.statusCode == 404) {
        dio.close();
        return null;
      } else {
        // Si no, es que hay algún error en el cliente o en el servidor.
        throw Exception('Error al obtener las ruta: ${response.statusCode}');
      }
    } catch (e) {
      // Si hay algún error en el paso de mensajes ajeno al protocolo HTTP
      throw ('Error: $e');
    }
  }

  // Método para insertar una nueva Ruta en el sistema. Debe llegar un objeto del tipo ruta así como la imagen de portada y la matriz con las imágenes de los lugares de interés que componen la ruta.
  void insertarRuta(
      RutaTuristica ruta, List<List<File>> recursos, File imagenPortada) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }

    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // // Crear un string en formato Json con los datos de la ruta.
    String rutaJson = jsonEncode(ruta.deserializacion());

    // Realizar la solicitud POST a la URL /ruta/.
    try {
      Response response = await dio.post(
        '$_baseUrl/ruta/',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: rutaJson,
      );

      // Si no se devuelve éxito en la inserción de la ruta se muestra el error.
      if (response.statusCode != 200) {
        throw Exception('Error al insertar la ruta: ${response.statusCode}');
      }
    } catch (e) {
      // Si hay algún error en el paso de mensajes ajeno al protocolo HTTP
      throw ('Error: $e');
    }

    // Obtener el nombre de la ruta
    String nombreRuta = ruta.nombre;
    FormData formData = FormData();

    // Crear FormData para enviar imágenes junto con el nombre de la ruta
    formData.fields.add(MapEntry('ruta', nombreRuta));

    // Agregar la imagen de portada al FormData
    formData.files.add(MapEntry(
      'imagen_portada',
      await MultipartFile.fromFile(imagenPortada.path),
    ));

    // Realizar la solicitud POST para enviar la imagen
    Response responseImagenes = await dio.post(
      '$_baseUrl/ruta/imagen?ruta=$nombreRuta',
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
      // Se añade la imagen en el cuerpo de la petición HTTP.
      data: formData,
    );

    // Si hay algún error en la inserción de la imagen
    if (responseImagenes.statusCode != 200) {
      throw Exception(
          'Error al insertar la imagen de la ruta: ${responseImagenes.statusCode}');
    }

    // Se envían todas las imágenes asociadas a cada lugar de interés.
    for (var i = 0; i < ruta.lugares.length; i++) {
      // Agregar todas las imágenes al FormData
      for (var j = 0; j < recursos.elementAt(i).length; j++) {
        // Construcción del FormData
        formData = FormData();
        formData.fields.add(MapEntry('ruta', nombreRuta));
        // Se añade el nombre del lugar de interés
        formData.fields
            .add(MapEntry('lugar', ruta.lugares.elementAt(i).nombre));
        // Se añade la imagen
        formData.files.add(MapEntry(
          'imagen_lugar',
          await MultipartFile.fromFile(recursos.elementAt(i).elementAt(j).path),
        ));
        // Realizar la solicitud POST para enviar las imágenes
        Response responseImagenes = await dio.post(
          '$_baseUrl/lugar/imagen',
          options: Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
          data: formData,
        );
        // Si hay algún error ajeno en la inserción de la imagen
        if (responseImagenes.statusCode != 200) {
          throw Exception(
              'Error al insertar la imagen del lugar: ${responseImagenes.statusCode}');
        }
      }
    }
  }

  // Método para modificar una ruta en el sistema. Se reciben los mismos parámetros que en el método para insertar una nueva ruta en el sistema.
  void modificarRuta(
      RutaTuristica ruta, List<List<File>> recursos, File imagenPortada) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }
    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // // Crear un string en formato Json con los datos de la ruta.
    String rutaJson = jsonEncode(ruta.deserializacion());

    print("-----------  ORDEN DE ENVÍO -------------");
    print(ruta.lugares);

    // Realizar la solicitud PUT para modificar la ruta.
    try {
      Response response = await dio.put(
        '$_baseUrl/ruta/',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: rutaJson,
      );
      // Hay algún problema en la modificación de la ruta
      if (response.statusCode != 200) {
        throw Exception('Error al insertar la ruta: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error: $e');
    }

    // Obtener el nombre de la ruta
    String nombreRuta = ruta.nombre;
    FormData formData = FormData();

    // Crear FormData para enviar imágenes junto con el nombre de la ruta
    formData.fields.add(MapEntry('ruta', nombreRuta));

    // Agregar la imagen de portada al FormData
    formData.files.add(MapEntry(
      'imagen_portada',
      await MultipartFile.fromFile(imagenPortada.path),
    ));
    // Realizar la solicitud POST para enviar la imagen
    Response responseImagenes = await dio.post(
      '$_baseUrl/ruta/imagen?ruta=$nombreRuta',
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
      // Se añade la imagen al cuerpo de la petición HTTP
      data: formData,
    );

    // Error en la inserción de la imagen
    if (responseImagenes.statusCode != 200) {
      throw Exception(
          'Error al insertar la imagen de la ruta: ${responseImagenes.statusCode}');
    }

    // Insertar de nuevo las imágenes de los lugares de interés
    for (var i = 0; i < ruta.lugares.length; i++) {
      // Agregar todas las imágenes al FormData
      for (var j = 0; j < recursos.elementAt(i).length; j++) {
        formData = FormData();
        // Añadir el nombre de la ruta en el cuerpo de la petición
        formData.fields.add(MapEntry('ruta', nombreRuta));

        // Añadir el nombre del lugar en el cuerpo de la petición
        formData.fields
            .add(MapEntry('lugar', ruta.lugares.elementAt(i).nombre));

        // Añadir el binario de la imagen en la petición HTTP
        formData.files.add(MapEntry(
          'imagen_lugar',
          await MultipartFile.fromFile(recursos.elementAt(i).elementAt(j).path),
        ));
        // Realizar la solicitud POST para enviar las imágenes
        Response responseImagenes = await dio.post(
          '$_baseUrl/lugar/imagen',
          options: Options(
            headers: {'Content-Type': 'multipart/form-data'},
          ),
          data: formData,
        );

        // Si hay algún problema en la inserción de la imagen se lanza excepción
        if (responseImagenes.statusCode != 200) {
          throw Exception(
              'Error al insertar la imagen del lugar: ${responseImagenes.statusCode}');
        }
      }
    }
  }

  // Método para cerrar sesión en el sistema
  Future<void> cerrarSesion() async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }
    // Configurar el encabezado de autorización con el token.
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud POST a la URL /logout. Con el token se identifica al usuario
    try {
      Response response = await dio.post(
        '$_baseUrl/logout',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Destruir el token de identificación del usuario en el sistema
      _token = '';

      // Cerrar petición
      dio.close();
    } catch (e) {
      throw ('Error: $e');
    }
  }

  // Método para borrar un usuario del sistema
  Future<void> borrarUsuario() async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }
    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud DELETE al servidor. Se identifica al usuario por el token
    try {
      Response response = await dio.delete(
        '$_baseUrl/usuario/me',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Se destruye el token de acceso del usuario
      _token = '';
      // Manejo de la respuesta del servidor
      if (response.statusCode == 200) {
        dio.close();
        return response.data;
      } else {
        throw Exception('Error al cerrar sesión: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error: $e');
    }
  }

  // Método para obtener un archivo desde una URL de la API.
  Future<File?> fileDesdeURLImagen(String url) async {
    try {
      // Se obtiene la imagen de la api mediante una petición del paquete http.
      final http.Response responseData = await http.get(Uri.parse(url));

      // Se procesa la imagen construyendo el binario devuelto a una variable del tipo File.
      if (responseData.statusCode == 200) {
        Uint8List uint8list = responseData.bodyBytes;
        // Se crea un directorio temporal donde guardar ese File
        var tempDir = await getTemporaryDirectory();
        String fileName = url.split('/').last;
        String filePath = path.join(tempDir.path, fileName);
        // Se crea el File con los bytes recibidos en la respuesta de la petición HTTP
        File file = await File(filePath).writeAsBytes(uint8list);
        return file;
      } else {
        // Si hay algún error se devuelve null.
        print(
            'Error al cargar imagen, código de estado: ${responseData.statusCode}');
        return null;
      }
      // Manejo de errores en el paso de mensajes
    } catch (e) {
      print('Error al descargar la imagen: $e');
      return null;
    }
  }

  // Método para modificar la contraseña de un usuario en el sistema
  Future<void> modificarContrasenia(String contrasenia) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Se pasa la contraseña en el cuerpo de la petición
    var data = {'contrasenia': contrasenia};

    dio.options.headers['Authorization'] = 'Bearer $_token';
    // Realizar la solicitud PUT al ser una modificación, en la URL /usuario/me
    try {
      Response response = await dio.put(
        '$_baseUrl/usuario/me',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        // Se mete la nueva contraseña en el cuerpo
        data: FormData.fromMap(data),
      );
      // Se cierra el cliente.
      dio.close();
    } catch (e) {
      throw ('Error: $e');
    }
  }

  // Método para obtener las rutas favoritas del usuario que está usando la aplicación
  Future<List<RutaTuristica>> getRutasFavoritas() async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }
    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud GET
    //No es necesario pasar el usuario ya que la API sabe qué usuario le contacta por el token. Por tanto, debe haber iniciado sesión previamente.
    try {
      Response response = await dio.get(
        '$_baseUrl/usuario/me/rutas/favoritas',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Se procesa la respuesta del servidor
      if (response.statusCode == 200) {
        dio.close();
        return _rutasDesdeJson(response.data);
      } else {
        throw Exception('Error al obtener las rutas: ${response.statusCode}');
      }
      // Manejo de errores en el paso de mensajes
    } catch (e) {
      throw ('Error: $e');
    }
  }

  // Método para obtener las rutas que el usuario ha creado
  Future<List<RutaTuristica>> getMisRutas() async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };

    // Verificar si el token está presente
    if (_token.isEmpty) {
      throw Exception("No se ha iniciado sesión. Primero realiza el login.");
    }
    // Configurar el encabezado de autorización con el token
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud GET
    // No es necesario pasar el usuario ya que la API sabe qué usuario le contacta por el token
    try {
      Response response = await dio.get(
        '$_baseUrl/usuario/me/rutas/creadas',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Procesamiento de la respuesta del servidor
      if (response.statusCode == 200) {
        dio.close();
        return _rutasDesdeJson(response.data);
        // Manejo de errores
      } else {
        throw Exception('Error al obtener las rutas: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error: $e');
    }
  }

  // Método para marcar como favorita una ruta.
  Future<void> marcarFavorita(RutaTuristica ruta) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
    String nombreRuta = ruta.nombre;
    dio.options.headers['Authorization'] = 'Bearer $_token';
    // Realizar la solicitud POST. El servidor reconoce qué usuario la ha marcado como favorita a través del token.
    try {
      Response response = await dio.post(
        '$_baseUrl/usuario/me/rutas/favoritas/$nombreRuta',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Si responde con conflicto por estar marcada como favorita
      if (response.statusCode == 409) {
        throw (response.data['detail']);
      }
      // Cerrar el cliente.
      dio.close();
    } catch (e) {
      // Manejo de errores.
      throw ('Error: $e');
    }
  }

  // Desmarcar como favorita una ruta
  Future<void> desmarcarFavorita(RutaTuristica ruta) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) => true))
      ..interceptors.add(LogInterceptor(responseBody: true));

    //IMPORTANTE: Se desactivan ciertas opciones para poder usar certificados SSL autofirmados
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
    String nombreRuta = ruta.nombre;
    dio.options.headers['Authorization'] = 'Bearer $_token';

    // Realizar la solicitud DELETE. Para borrar el favorito del usuario actual a la ruta.
    try {
      Response response = await dio.delete(
        '$_baseUrl/usuario/me/rutas/favoritas/$nombreRuta',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 409) {
        throw (response.data['detail']);
      }

      // Cierra el cliente.
      dio.close();
    } catch (e) {
      // Manejo de errores.
      throw ('Error: $e');
    }
  }
}
