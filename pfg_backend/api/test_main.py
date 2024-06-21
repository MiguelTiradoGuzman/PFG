# from api.ManejadorBD import ManejadorBD
# import pytest
# from fastapi.testclient import TestClient
# import os
# import sys

# # Agrega el directorio raíz al sys.path
# sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# from api.main import app  # Importa la instancia de la aplicación desde tu archivo principal

# @pytest.fixture
# def test_client():
#     return TestClient(app)

# def test_login(test_client):
#     # Simula un inicio de sesión válido
#     response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
#     assert response.status_code == 200
#     assert "access_token" in response.json()

# def test_correo_invalido_login(test_client):
#     # Simula un inicio de sesión no válido por nombre de usuario erróneo
#     response = test_client.post("/login", data={"email": "noExisteUsuario", "password": "password1"})
#     assert response.status_code == 401

# def test_contrasenia_incorrecta_login(test_client):
#     # Simula un inicio de sesión no válido por contraseña errónea
#     response = test_client.post("/login", data={"email": "test@gmail.com", "password": "test"})
#     assert response.status_code == 401

# def test_contrasenia_correo_incorrectos_login(test_client):
#     # Simula un inicio de sesión no válido por contraseña y correo electrónico erróneos
#     response = test_client.post("/login", data={"email": "noExisteUsuario", "password": "test"})
#     assert response.status_code == 401

# def test_obtener_rutas_autentificado(test_client):
#     # Simula un inicio de sesión válido
#     login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
#     access_token = login_response.json()["access_token"]

#     # Accede a la ruta de obtener rutas con el token de acceso
#     response = test_client.get("/rutas", headers={"Authorization": f"Bearer {access_token}"})
#     assert response.status_code == 200
#     assert "rutas" in response.json()

# def test_obtener_rutas_sin_autentificar(test_client):
#     # Intenta acceder a la ruta de obtener rutas sin un token de acceso
#     response = test_client.get("/rutas")
#     assert response.status_code == 401

import pytest
from fastapi.testclient import TestClient
import os
import sys
from api.main import app
from api.modelo.lugarInteres import LugarInteres
from api.modelo.rutaTuristica import RutaTuristica
# Agrega el directorio raíz al sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

@pytest.fixture
def test_client():
    return TestClient(app)

# Endpoint: /login
def test_login(test_client):
    response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_correo_invalido_login(test_client):
    response = test_client.post("/login", data={"email": "noExisteUsuario", "password": "password1"})
    assert response.status_code == 401

def test_contrasenia_incorrecta_login(test_client):
    response = test_client.post("/login", data={"email": "test@gmail.com", "password": "test"})
    assert response.status_code == 401

def test_contrasenia_correo_incorrectos_login(test_client):
    response = test_client.post("/login", data={"email": "noExisteUsuario", "password": "test"})
    assert response.status_code == 401

# Endpoint: /rutas
def test_obtener_rutas_autentificado(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    response = test_client.get("/rutas", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "rutas" in response.json()

def test_obtener_rutas_sin_autentificar(test_client):
    response = test_client.get("/rutas")
    assert response.status_code == 401

# Endpoint: /usuario/me/rutas/creadas
def test_obtener_rutas_creadas(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    response = test_client.get("/usuario/me/rutas/creadas", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "rutas" in response.json()

# Endpoint: /usuario/me/rutas/favoritas
def test_obtener_rutas_favoritas(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    response = test_client.get("/usuario/me/rutas/favoritas", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "rutas" in response.json()

# Endpoint: /ruta/ (POST)
def test_insertar_ruta(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    lugar = LugarInteres(
                    nombre="n1",
                    descripcion="Una desc",
                    latitud=1.00,
                    longitud=1.00,
                    fotos=[]
                )
    lugar2 = LugarInteres(
                    nombre="n2",
                    descripcion="Una desc",
                    latitud=2.00,
                    longitud=1.00,
                    fotos=[]
                )
    lugares = []
    lugares.append(lugar)
    lugares.append(lugar2)
    nueva_ruta = RutaTuristica(
                nombre="ruta_test",
                descripcion="Una descripción",
                distancia=3.00,
                duracion="3:00",
                ruta_imagen="",
                lugares=lugares,
                autor = "test@gmail.com"
            )
    response = test_client.post("/ruta/", json=nueva_ruta.dict(), headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "message" in response.json()
# Endpoint: /ruta/{ruta} (GET)
def test_obtener_ruta(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    response = test_client.get("/ruta/ruta_test", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "ruta" in response.json()

# Endpoint: /usuario/me/rutas/favoritas/{ruta} (POST)
def test_marcar_favorita(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    response = test_client.post("/usuario/me/rutas/favoritas/ruta_test", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "message" in response.json()

# Endpoint: /usuario/me/rutas/favoritas/{ruta} (DELETE)
def test_desmarcar_favorita(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    response = test_client.delete("/usuario/me/rutas/favoritas/ruta_test", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "message" in response.json()

# Endpoint: /ruta/ (PUT)
def test_modificar_ruta(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    lugar = LugarInteres(
                    nombre="n1",
                    descripcion="Una desc",
                    latitud=1.00,
                    longitud=1.00,
                    fotos=[]
                )
    lugar2 = LugarInteres(
                    nombre="n2",
                    descripcion="Una desc",
                    latitud=2.00,
                    longitud=1.00,
                    fotos=[]
                )
    lugares = []
    lugares.append(lugar)
    lugares.append(lugar2)
    ruta_modificada = RutaTuristica(
                nombre="ruta_test",
                descripcion="Una descripción",
                distancia=3.00,
                duracion="3:00",
                ruta_imagen="",
                lugares=lugares,
                autor = "test@gmail.com"
            )
    response = test_client.put("/ruta/", json=ruta_modificada.dict(), headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "message" in response.json()

# Endpoint: /ruta/{ruta} (DELETE)
def test_borrar_ruta(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    response = test_client.delete("/ruta/ruta_test", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "message" in response.json()

# Endpoint: /usuario/me (PUT)
# def test_modificar_usuario(test_client):
#     login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
#     access_token = login_response.json()["access_token"]
#     response = test_client.put("/usuario/me", data={"contrasenia": "nueva_password"}, headers={"Authorization": f"Bearer {access_token}"})
#     assert response.status_code == 200
#     assert "message" in response.json()

# # Endpoint: /ruta/imagen (POST)
# def test_insertar_imagen_ruta(test_client):
#     login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
#     access_token = login_response.json()["access_token"]
#     ruta = "ruta_test"
#     with open("test_image.jpg", "rb") as image:
#         response = test_client.post(
#             "/ruta/imagen", 
#             headers={"Authorization": f"Bearer {access_token}"}, 
#             data={"ruta": ruta}, 
#             files={"imagen_portada": ("test_image.jpg", image, "image/jpeg")}
#         )
#     assert response.status_code == 200
#     assert "message" in response.json()

# Endpoint: /lugar/imagen (POST)
# def test_insertar_imagen_lugar(test_client):
#     login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
#     access_token = login_response.json()["access_token"]
#     ruta = "ruta_test"
#     lugar = "lugar_test"
#     with open("test_image.jpg", "rb") as image:
#         response = test_client.post(
#             "/lugar/imagen", 
#             headers={"Authorization": f"Bearer {access_token}"}, 
#             data={"ruta": ruta, "lugar": lugar}, 
#             files={"imagen_lugar": ("test_image.jpg", image, "image/jpeg")}
#         )
#     assert response.status_code == 200
#     assert "message" in response.json()

# Endpoint: /signin (POST)
def test_registro(test_client):
    response = test_client.post("/signin", data={"nombreUsuario": "nuevo_usuario", "correo": "nuevo@gmail.com", "password": "nuevo_password"})
    assert response.status_code == 200
    assert "message" in response.json()

# Endpoint: /logout (POST)
def test_logout(test_client):
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]
    response = test_client.post("/logout", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "message" in response.json()

#Endpoint: /usuario/me (DELETE)
def test_borrar_usuario(test_client):
    login_response = test_client.post("/login", data={"email": "nuevo@gmail.com", "password": "nuevo_password"})
    access_token = login_response.json()["access_token"]
    response = test_client.delete("/usuario/me", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "message" in response.json()
