from api.ManejadorBD import ManejadorBD
import pytest
from fastapi.testclient import TestClient
import os
import sys

# Agrega el directorio raíz al sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from api.main import app  # Importa la instancia de la aplicación desde tu archivo principal

@pytest.fixture
def test_client():
    return TestClient(app)

def test_login(test_client):
    # Simula un inicio de sesión válido
    response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_correo_invalido_login(test_client):
    # Simula un inicio de sesión no válido por nombre de usuario erróneo
    response = test_client.post("/login", data={"email": "noExisteUsuario", "password": "password1"})
    assert response.status_code == 401

def test_contrasenia_incorrecta_login(test_client):
    # Simula un inicio de sesión no válido por contraseña errónea
    response = test_client.post("/login", data={"email": "test@gmail.com", "password": "test"})
    assert response.status_code == 401

def test_contrasenia_correo_incorrectos_login(test_client):
    # Simula un inicio de sesión no válido por contraseña y correo electrónico erróneos
    response = test_client.post("/login", data={"email": "noExisteUsuario", "password": "test"})
    assert response.status_code == 401

def test_obtener_rutas_autentificado(test_client):
    # Simula un inicio de sesión válido
    login_response = test_client.post("/login", data={"email": "test@gmail.com", "password": "12345"})
    access_token = login_response.json()["access_token"]

    # Accede a la ruta de obtener rutas con el token de acceso
    response = test_client.get("/rutas", headers={"Authorization": f"Bearer {access_token}"})
    assert response.status_code == 200
    assert "rutas" in response.json()

def test_obtener_rutas_sin_autentificar(test_client):
    # Intenta acceder a la ruta de obtener rutas sin un token de acceso
    response = test_client.get("/rutas")
    assert response.status_code == 401

