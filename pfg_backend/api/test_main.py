import pytest
from fastapi.testclient import TestClient
import os
import sys

# Agrega el directorio raíz al sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from api.main import app  # Importa la instancia de la aplicación desde tu archivo principal
from main import hash_password
from main import obtener_rutas_desde_bd

@pytest.fixture
def test_client():
    return TestClient(app)

# def test_read_main(test_client):
#     response = test_client.get("/")
#     assert response.status_code == 200
#     assert response.json() == {"message": "Hello, World!"}

def test_login(test_client):
    # Simula un inicio de sesión válido
    response = test_client.post("/login", data={"username": "user1", "password": hash_password("password1")})
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_invalid_username_login(test_client):
    # Simula un inicio de sesión no válido por nombre de usuario erróneo
    response = test_client.post("/login", data={"username": "noExisteUsuario", "password": hash_password("password1")})
    assert response.status_code == 401

def test_invalid_password_login(test_client):
    # Simula un inicio de sesión no válido por contraseña errónea
    response = test_client.post("/login", data={"username": "user1", "password": hash_password("test")})
    assert response.status_code == 401

def test_obtener_rutas_authenticated(test_client):
    # Simula un inicio de sesión válido
    login_response = test_client.post("/login", data={"username": "user1", "password": hash_password("password1")})
    access_token = login_response.json()["access_token"]

    # Accede a la ruta de obtener rutas con el token de acceso
    response = test_client.get("/rutas", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "rutas" in response.json()

def test_obtener_rutas_unauthenticated(test_client):
    # Intenta acceder a la ruta de obtener rutas sin un token de acceso
    response = test_client.get("/rutas")
    assert response.status_code == 401

def test_obtener_rutas_desde_bd():
    # Puedes escribir pruebas unitarias para la función obtener_rutas_desde_bd
    # Simula una conexión a la base de datos o utiliza un mock para evitar la dependencia de la base de datos real
    # Asegúrate de ajustar esta prueba según la lógica específica de tu aplicación
    rutas = obtener_rutas_desde_bd()
    assert isinstance(rutas, list)
    # Realiza más comprobaciones según la estructura y la lógica de tus datos

