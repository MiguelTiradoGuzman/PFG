import os
import importlib
from typing import List
from dotenv import load_dotenv
import mysql.connector

from fastapi import Request, FastAPI, Depends, HTTPException, Form
from api.modelo.usuario import Usuario
from api.modelo.rutaTuristica import RutaTuristica
from api.modelo.lugarInteres import LugarInteres

from fastapi.security import OAuth2PasswordRequestForm
from fastapi_login import LoginManager
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder



from datetime import timedelta
import hashlib
app = FastAPI()

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
manager = LoginManager(SECRET_KEY, token_url=TOKEN_URL,default_expiry=timedelta(hours=12))

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
    return fake_users_db.get(username)

# Ruta para el inicio de sesión

# async def login(data: OAuth2PasswordRequestForm = Depends()):
#     username = data.username
#     password = data.password
@app.post("/login")
async def login(username: str = Form(...), password: str = Form(...)):

    user = fake_users_db.get(username)

    if user and user["password_hash"] == password:
        user_info = {key: value for key, value in user.items() if key != "password_hash"}
        token = manager.create_access_token(data={"sub": username})
        print(user_info)
        return {"access_token": token, "token_type": "bearer", "user_info":user_info}
    raise HTTPException(status_code=401, detail="Invalid credentials")

# Ruta protegida que requiere inicio de sesión
@app.get("/protected")
def protected_route(user=Depends(manager)):
    return {"user": user}

def obtener_rutas_desde_bd():
    # Obtiene la conexión y el cursor desde la función de conexión
    conexion, cursor = conectar_bd()

    # Ejecuta la consulta para obtener todas las rutas
    cursor.execute("SELECT * FROM RutaTuristica")

    # Obtiene los resultados
    rutas_bd = cursor.fetchall()
    # Convierte los resultados de la base de datos a instancias de RutaTuristica
    rutas = []
    for ruta_bd in rutas_bd:
        # Para cada ruta, busca los lugares asociados
        cursor.execute("SELECT * FROM LugarInteres WHERE nombreRuta = %s", (ruta_bd["nombre"],))
        lugares_bd = cursor.fetchall()
        lugares = []

        for lugar_bd in lugares_bd:
            # Para cada lugar, busca las imágenes asociadas
            cursor.execute("SELECT lugarImagen FROM ImagenLugar WHERE nombreLugar = %s", (lugar_bd["nombre"],))
            imagenes_bd = cursor.fetchall()
            imagenes = [imagen_bd["lugarImagen"] for imagen_bd in imagenes_bd]

            # Crea instancia de LugarInteres y agrega a la lista de lugares
            lugar = LugarInteres(
                nombre=lugar_bd["nombre"],
                descripcion=lugar_bd["descripcion"],
                latitud=lugar_bd["latitud"],
                longitud=lugar_bd["longitud"],
                fotos=imagenes
            )
            lugares.append(lugar)

        duracionCompleta = str(ruta_bd["duracion"])
        horas, minutos, segundos = duracionCompleta.split(":")
        duracionFormateada = f"{horas}:{minutos}"
        # Aquí asumes que ruta_bd es un diccionario que contiene los datos de la ruta
        # Puedes adaptar esto según la estructura real de tus datos
        ruta = RutaTuristica(
            nombre=ruta_bd["nombre"],
            descripcion=ruta_bd["descripcion"],
            distancia=ruta_bd["distancia"],
            duracion=duracionFormateada,
            ruta_imagen=ruta_bd["imagenPortada"],
            lugares=lugares
        )
        rutas.append(ruta)
    # Cierra tanto el cursor como la conexión
    cursor.close()
    conexion.close()

    return rutas

# Ahora, en tu ruta FastAPI, puedes llamar a esta función y devolver las rutas
@app.get("/rutas")
def obtener_rutas():
    rutas_desde_bd = obtener_rutas_desde_bd()
    return {"rutas":rutas_desde_bd}