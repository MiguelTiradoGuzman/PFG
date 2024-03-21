import os
import importlib
from typing import List
from dotenv import load_dotenv
import mysql.connector

from fastapi import Request, FastAPI, Depends, HTTPException, Form
from api.modelo.usuario import Usuario
from api.modelo.rutaTuristica import RutaTuristica
from api.modelo.lugarInteres import LugarInteres
from api.ManejadorBD import ManejadorBD

from fastapi.security import OAuth2PasswordRequestForm
from fastapi_login import LoginManager
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder



from datetime import timedelta
import hashlib

app = FastAPI()

manejador_bd = ManejadorBD()
manejador_bd.conectar_bd()

# Directorio donde se encuentran las imágenes
imagenes_dir = os.path.abspath("./api/api_mount")

# Prefijo que se agregará a la ruta de acceso pública
imagenes_prefix = "/imagenes"

# Montar el directorio de imágenes con el prefijo
app.mount(imagenes_prefix, StaticFiles(directory=imagenes_dir), name="imagenes")


# Carga las variables de entorno desde el archivo .env
load_dotenv()

def conectar_bd():
    # Obtiene las variables de entorno para la conexión a la base de datos
    host = os.getenv("DB_HOST")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    database = os.getenv("DB_DATABASE")

    # Configura la conexión a la base de datos MySQL
    conexion = mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=database
    )

    # Crea y devuelve tanto la conexión como el cursor para ejecutar consultas SQL
    cursor = conexion.cursor(dictionary=True)
    return conexion, cursor

# Configuración de la clave secreta para el token de sesión
SECRET_KEY = os.getenv("API_SECRET_KEY").encode('utf-8')
# Configuración del token de acceso y el esquema de token
TOKEN_URL = "./"

# Configuración del LoginManager
manager = LoginManager(SECRET_KEY, token_url=TOKEN_URL,default_expiry=timedelta(hours=24))

def hash_password(password):
    # Convierte la contraseña a bytes.
    password_bytes = password.encode('utf-8')

    # Calcula el hash SHA-256.
    hashed_password = hashlib.sha256(password_bytes).hexdigest()

    return hashed_password

# Base de datos de usuarios de ejemplo (debes implementar tu propio sistema de usuarios)
fake_users_db = {
    "user1": {
        "username": "user1",
        "password_hash": hash_password("password1"),
        #"password_hash": "password1",
    },
    "user2": {
        "username": "user2",
        "password_hash": hash_password("password2"),
    },
}


# Definir una función para obtener el usuario actual en función del token de sesión
@manager.user_loader()
def load_user(username: str):
    return manejador_bd.obtenerUsuario(username)

# Ruta para el inicio de sesión
@app.post("/login")
async def login(email: str = Form(...), password: str = Form(...)):

    user = Usuario(email = email, nombre="", contrasenia = password)

    user = manejador_bd.login(user)

    if user.nombre != '':
        token = manager.create_access_token(data={"sub": user.nombre})
        print(user)
        print(token)
        return {"access_token": token, "token_type": "bearer", "user_info":user}
        
    else:
        raise HTTPException(status_code=401, detail="Invalid credentials")

# Ruta protegida que requiere inicio de sesión
@app.get("/protected")
def protected_route(user=Depends(manager)):
    return {"user": user}

@app.get("/rutas")
def obtener_rutas(user=Depends(manager)):
    rutas_desde_bd = manejador_bd.obtenerRutas()
    return {"rutas":rutas_desde_bd}

@app.post("/signin")
async def registro(username: str = Form(...), correo: str = Form(...), password: str = Form(...)):
    try:
        nuevo_usuario = Usuario(nombre=username, email=correo, contrasenia=password)
        print(nuevo_usuario)
        manejador_bd.registrar_usuario(nuevo_usuario)
        return {"message": "Usuario registrado exitosamente"}
    except ValueError as ve:
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/logout")
async def cerrar_sesion(user=Depends(manager)):
    #Establecer el la fecha de expiración del token en el pasado para que se destruya
    manager._token_expiry = manager.default_expiry
    return {"message": "Logout exitoso"}

@app.post("/delete/usuario/me")
async def borrar_usuario(user=Depends(manager)):
    mensaje = manejador_bd.eliminarUsuario(user)
    return mensaje