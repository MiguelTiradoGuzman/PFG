import 'api.dart';
import '../modelo/usuario.dart';

class Controlador {
  static final Controlador _instance = Controlador._internal();
  Controlador._internal();
  factory Controlador() => _instance;

  final API _api = API();
  late Usuario _usuario;
  API get api => _api;

  set user(String username) {
    _usuario = Usuario(username: username);
  }

  Future<void> login(String username, String password) async {
    _api.login(username, password);
  }
}
