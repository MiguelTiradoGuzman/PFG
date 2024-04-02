
import os
import importlib
import shutil
from typing import List
from dotenv import load_dotenv
import mysql.connector

from fastapi import Request, FastAPI, Depends, HTTPException, Form, UploadFile, File
from api.modelo.usuario import Usuario
from api.modelo.rutaTuristica import RutaTuristica
from api.modelo.lugarInteres import LugarInteres
from api.ManejadorBD import ManejadorBD

from fastapi.security import OAuth2PasswordRequestForm
from fastapi_login import LoginManager
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from typing import Annotated

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

def crear_estructura_carpetas(rutaParam: RutaTuristica):
    ruta = os.path.join(os.getcwd(), "./api/api_mount/recursos/rutas/", rutaParam.nombre.replace(" ", "_"))
    if not os.path.exists(ruta):
        os.makedirs(ruta)
    
    for lugar in rutaParam.lugares:
        lugar_path = os.path.join(ruta, lugar.nombre.replace(" ", "_"))
        if not os.path.exists(lugar_path):
            os.makedirs(lugar_path)

def guardar_imagen_ruta(rutaParam: RutaTuristica, imagen_portada: UploadFile):
    # Crear la estructura de carpetas si aún no existe
    crear_estructura_carpetas(rutaParam)

    # Guardar la imagen de portada
    imagen_portada_path = os.path.join(os.getcwd(), f"./api/api_mount/recursos/rutas/{rutaParam.nombre.replace(' ', '_')}", imagen_portada.filename)
    with open(imagen_portada_path, "wb") as image_file:
        shutil.copyfileobj(imagen_portada.file, image_file)
    
    rutaParam.ruta_imagen = f"./recursos/rutas/{rutaParam.nombre.replace(' ', '_')}/{imagen_portada.filename}"
    

def guardar_imagen_lugar(rutaParam: RutaTuristica, lugarInteres : str, imagen: UploadFile):
    # Buscar el lugar de interés entre los objetos de lugares de la ruta
    lugar_objetivo = None
    for lugar in rutaParam.lugares:
        if lugar.nombre == lugarInteres:
            lugar_objetivo = lugar
            break
    if(lugar_objetivo is not None):
        print("ENCUENTRO LUGAR")
        # Crear la estructura de carpetas si aún no existe
        crear_estructura_carpetas(rutaParam)

        # Guardar la imagen
        lugar_path = os.path.join(os.getcwd(), f"./api/api_mount/recursos/rutas/{rutaParam.nombre.replace(' ', '_')}/{lugarInteres.replace(' ', '_')}")
        imagen_path = os.path.join(lugar_path, imagen.filename)
        with open(imagen_path, "wb") as image_file:
                shutil.copyfileobj(imagen.file, image_file)
        lugar_objetivo.fotos.append(f"./recursos/rutas/{rutaParam.nombre.replace(' ', '_')}/{lugar_objetivo.nombre.replace(' ', '_')}/{imagen.filename}")
        return f"./recursos/rutas/{rutaParam.nombre.replace(' ', '_')}/{lugar_objetivo.nombre.replace(' ', '_')}/{imagen.filename}"; 
    else:
        print("NO ENCUENTRO LUGAR")

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

@app.get("/rutas")
def obtener_rutas(user=Depends(manager)):
    rutas_desde_bd = manejador_bd.obtenerRutas()
    return {"rutas":rutas_desde_bd}

@app.get("/ruta/{ruta}")
def obtener_ruta(ruta : str, user=Depends(manager)):
    rutaDev = manejador_bd.obtenerRuta(ruta)
    if(rutaDev is not None):
        return {"ruta":rutaDev}
    else:
        raise HTTPException(status_code=404, detail="Not found")

@app.post("/ruta/")
def insertar_ruta(ruta : RutaTuristica, user=Depends(manager)):
    rTest = manejador_bd.obtenerRuta(ruta.nombre)
    if(rTest is None):
        try:
            print(ruta)
            crear_estructura_carpetas(ruta)
            #guardar_imagenes(ruta, imagen_portada, imagenes)
            manejador_bd.insertarRuta(ruta)
            return {"message": "Ruta registrada exitosamente"}
        except ValueError as ve:
            raise HTTPException(status_code=401, detail="No se ha podido insertar")
    else:
        raise  HTTPException(status_code=409, detail="Ya existe la ruta")
# def insertar_ruta(ruta : RutaTuristica,imagenes: List[List[UploadFile]] = File(...), imagen_portada: UploadFile = File(...), user=Depends(manager)):
    
@app.post("/ruta/imagen")
def insertar_imagen_ruta(ruta :Annotated[str, Form()] , imagen_portada: UploadFile):
    r = manejador_bd.obtenerRuta(ruta)
    if(r is not None):
            try:
                guardar_imagen_ruta(r, imagen_portada)
                manejador_bd.insertarImagenRuta(r)
                return {"message": "Imagenes de ruta registradas exitosamente"}
            except ValueError as ve:
                raise HTTPException(status_code=401, detail="No se ha podido insertar")
    else:
        raise  HTTPException(status_code=409, detail="No existe la ruta de la cual guardar imagenes")
@app.post("/lugar/imagen")
def insertar_imagen_lugar(ruta :Annotated[str, Form()], lugar :Annotated[str, Form()] , imagen_lugar: UploadFile):
    r = manejador_bd.obtenerRuta(ruta)
    if(r is not None):
            try:
                dir_img = guardar_imagen_lugar(rutaParam=r,lugarInteres=lugar, imagen=imagen_lugar)
                print("------------IMAGEN LUGAR")
                print(dir_img)
                manejador_bd.insertarImagenLugar(lugar, dir_img)
                return {"message": "Imagenes de ruta registradas exitosamente"}
            except ValueError as ve:
                raise HTTPException(status_code=401, detail="No se ha podido insertar")
    else:
        raise  HTTPException(status_code=409, detail="No existe la ruta de la cual guardar imagenes")
    
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


# @app.post("/test-crear-carpetas")
# async def test_crear_carpetas():
#     ruta_nombre = "ruta_de_prueba"
#     lugares = ["lugar1", "lugar2", "lugar3"]
    
#     # Llamar a la función para crear la estructura de carpetas
#     crear_estructura_carpetas(ruta_nombre, lugares)
    
#     return {"message": f"Estructura de carpetas creada para la ruta '{ruta_nombre}' y los lugares: {lugares}"}