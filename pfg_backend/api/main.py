
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
from fastapi.middleware.cors import CORSMiddleware


from datetime import timedelta
import hashlib

# Inicialización del host
app = FastAPI()

# Configurar el middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permitir solicitudes desde cualquier origen
    allow_credentials=True,
    allow_methods=["GET"],
    allow_headers=["*"],
)

# Inicialización del manejador de la base de datos
manejador_bd = ManejadorBD()
manejador_bd.conectarBD()

# Directorio donde se encuentran las imágenes
imagenes_dir = os.path.abspath("./api/api_mount")

# Prefijo que se agregará a la ruta de acceso pública
imagenes_prefix = "/imagenes"

# Montar el directorio de imágenes con el prefijo
app.mount(imagenes_prefix, StaticFiles(directory=imagenes_dir), name="imagenes")

# rutaParam: Ruta turística de la que crear la estructura de carpetas necesaria
# Crea una carpeta para la ruta y para cada uno de los lugares de interés
def crear_estructura_carpetas(rutaParam: RutaTuristica):
    # Ruta donde se almacenará la imagen del objeto ruta. Cambia espacios por _ y pasa el nombre a minúsculas
    ruta = os.path.join(os.getcwd(), "./api/api_mount/recursos/rutas/", rutaParam.nombre.replace(" ", "_"))

    # Si no existe dicha ruta, la crea
    if not os.path.exists(ruta):
        os.makedirs(ruta)
    
    # Creación para cada uno de los lugares de interés. Se cambian espacios por _
    for lugar in rutaParam.lugares:
        lugar_path = os.path.join(ruta, lugar.nombre.replace(" ", "_"))
        if not os.path.exists(lugar_path):
            os.makedirs(lugar_path)

# Elimina la estructura de carpetas de una ruta que llega por parámetro.
def eliminar_estructura_carpetas(rutaParam : RutaTuristica):
    ruta = os.path.join(os.getcwd(), "./api/api_mount/recursos/rutas/", rutaParam.nombre.replace(" ", "_"))
    # Sólo la borra si existe. Borra de forma recursiva para eliminar también carpetas de árboles.
    if os.path.exists(ruta):
        shutil.rmtree(ruta)

# Guarda la imagen asociada a una ruta turística.
def guardar_imagen_ruta(rutaParam: RutaTuristica, imagen_portada: UploadFile):

    # Eliminar la imagen de ruta existente si hay una
    ruta_imagen_antigua = rutaParam.ruta_imagen
    if ruta_imagen_antigua:
        ruta_imagen_completa = os.path.join(os.getcwd(), "api/api_mount", ruta_imagen_antigua)
        if os.path.exists(ruta_imagen_completa):
            os.remove(ruta_imagen_completa)
    # Crear la estructura de carpetas si aún no existe
    crear_estructura_carpetas(rutaParam)

    # Guardar la imagen de portada
    imagen_portada_path = os.path.join(os.getcwd(), f"./api/api_mount/recursos/rutas/{rutaParam.nombre.replace(' ', '_')}", imagen_portada.filename)
    with open(imagen_portada_path, "wb") as image_file:
        shutil.copyfileobj(imagen_portada.file, image_file)
    
    rutaParam.ruta_imagen = f"./recursos/rutas/{rutaParam.nombre.replace(' ', '_')}/{imagen_portada.filename}"
    
# Método para guardar una imagen de un lugar de interes perteneciente a una ruta turística determinada
def guardar_recurso_lugar(rutaParam: RutaTuristica, lugarInteres : str, archivo: UploadFile):
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

        # Contar el número de imágenes existentes en el lugar de interés
        num_imagenes = len(lugar_objetivo.fotos)

        # Construir el nuevo nombre de archivo con el prefijo numérico y el nombre del lugar
        nombre_archivo = f"{num_imagenes + 1}_{lugar.nombre.replace(' ', '-').lower()}.{archivo.filename.split('.')[-1]}"

        # Guardar la imagen
        lugar_path = os.path.join(os.getcwd(), f"./api/api_mount/recursos/rutas/{rutaParam.nombre.replace(' ', '_')}/{lugarInteres.replace(' ', '_')}")
        imagen_path = os.path.join(lugar_path, nombre_archivo)
        with open(imagen_path, "wb") as image_file:
                shutil.copyfileobj(archivo.file, image_file)
        # Agregar la ruta de la imagen al lugar de interés
        lugar_objetivo.fotos.append(f"./recursos/rutas/{rutaParam.nombre.replace(' ', '_')}/{lugarInteres.replace(' ', '_')}/{nombre_archivo}")
        return f"./recursos/rutas/{rutaParam.nombre.replace(' ', '_')}/{lugarInteres.replace(' ', '_')}/{nombre_archivo}" 
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
# Con default_expiry establecemos que los token de autenticación duran 24h antes de renovarse.
manager = LoginManager(SECRET_KEY, token_url=TOKEN_URL,default_expiry=timedelta(hours=24))

# Método para crear el hash de la contraseña antes de guardarla en la base de datos
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


# Definición de una función para obtener el usuario actual en función del token de sesión
@manager.user_loader()
def load_user(username: str):
    return manejador_bd.obtenerUsuarioPorNombre(username)

# Ruta para el inicio de sesión
# Petición POST. Recibe el email y la contraseña del usuario
@app.post("/login")
async def iniciar_sesion(email: str = Form(...), password: str = Form(...)):
    # Construye un usuario con el email y la contraseña proporcionada
    user = Usuario(email = email, nombre="", contrasenia = password)

    # Comprueba las credenciales con el manejador de la base de datos
    user = manejador_bd.login(user)

    # Si ha tenido éxito, el manejador de la base de datos debe haber rellenado todos los campos
    if user.nombre != '':
        # Creación de un token de acceso
        token = manager.create_access_token(data={"sub": user.nombre})
        # Se devuelve mensaje de respuesta con el token de acceso para futuros usos.
        return {"access_token": token, "token_type": "bearer", "user_info":user}
    # Si no se ha encontrado al usuario se devuelve error 401 (Unauthorized)
    else:
        raise HTTPException(status_code=401, detail="Credenciales inválidas")
    
# IMPORTANTE: Todos los endpoint tienen como parámetro user=Depends(manager).
# Esto carga el usuario desde el token de acceso. Si no es un token válido significa que
# el usuario no ha iniciado sesión y no tiene acceso al recurso.
# LoginManager se encarga de construir el objeto Usuario a partir del token pasado por parámetro.

# Petición GET. Obtener todas las rutas
@app.get("/rutas")
def obtener_rutas(user=Depends(manager)):
    # Se obtienen todas las rutas desde el manejador de la BD.
    rutas_desde_bd = manejador_bd.obtenerRutas()
    # Se devuelven en el cuerpo de la respuesta en formato JSON
    # Si no encuentra nada devuelve lista vacía.
    return {"rutas":rutas_desde_bd}

# Petición GET. Obtener todas las rutas que ha creado un usuario.
# Sólo es necesario pasar el token del usuario.  
@app.get("/usuario/me/rutas/creadas")
def obtener_rutas(user=Depends(manager)):
    # Obtiene de la BD las rutas creadas por un usuario.
    rutas_desde_bd = manejador_bd.obtenerRutasPorAutor(user)
    # Devolución del array de rutas en el cuerpo de la respuesta en formato JSON
    # Si no encuentra nada devuelve lista vacía.
    return {"rutas":rutas_desde_bd}

# Petición GET. Obtener las rutas favoritas de un usuario.
# Sólo es necesario pasar el token del usuario.
@app.get("/usuario/me/rutas/favoritas")
def obtener_rutas(user=Depends(manager)):
    # Obtiene de la BD las rutas favoritas de un usuario
    rutas_desde_bd = manejador_bd.obtenerRutasFavoritas(user)
    # Devolución del array de rutas en el cuerpo de la respuesta en formato JSON
    # Si no se encuentra nada se devuelve lista vacía
    return {"rutas":rutas_desde_bd}

# Petición POST. Marcar como favorita una ruta.
# Sólo es necesario pasar el token del usuario y el nombre de la ruta en la URL.
@app.post("/usuario/me/rutas/favoritas/{ruta}")
def marcar_favorita(ruta : str, user=Depends(manager)):

    try:
        # Registra en la BD la nueva ruta favorita del usuario
        manejador_bd.marcarRutaFavorita(user, ruta)
        return {"message": "Ruta favorita registrada exitosamente"}
        # Si ocurre algún error durante la inserción se devuelve 500 
    except ValueError as ve:
        raise HTTPException(status_code=500, detail=ve)

# Petición DELETE. desmarcar como favorita una ruta.
# Sólo es necesario pasar el token del usuario y el nombre de la ruta en la URL.
@app.delete("/usuario/me/rutas/favoritas/{ruta}")
def desmarcar_favorita(ruta : str, user=Depends(manager)):
    try:
        # Elimina de la BD la ruta como favorita para ese usuario.
        manejador_bd.desmarcarRutaFavorita(user, ruta)
        return {"message": "Ruta desmarcada como favorita exitosamente"}
        # Si ocurre algún error durante la inserción se devuelve 500 
    except ValueError as ve:
        raise HTTPException(status_code=500, detail=ve)

# Petición GET. Obtener una ruta específica.
# Sólo es necesario pasar el token del usuario y el nombre de la ruta.
@app.get("/ruta/{ruta}")
def obtener_ruta(ruta : str, user=Depends(manager)):

    rutaDev = manejador_bd.obtenerRuta(ruta)
    # Si ha encontrado la ruta en la BD
    if(rutaDev is not None):
        return {"ruta":rutaDev}
    # Si no se encuentra, se devuelve error 404.
    else:
        raise HTTPException(status_code=404, detail="Ruta no encontrada")
    
# Petición DELETE. Borrar una ruta específica.
# Sólo es necesario pasar el token del usuario y el nombre de la ruta.
@app.delete("/ruta/{ruta}")
def borrar_ruta(ruta : str, user=Depends(manager)):
    rutaBorrar = manejador_bd.obtenerRuta(ruta.nombre)
    if(rutaBorrar is None):
        try:
            
            # También se borran todos sus datos almacenados
            eliminar_estructura_carpetas(rutaBorrar)
            manejador_bd.borrarRuta(rutaBorrar)
                # Se devuelve mensaje de éxito (Código 200)
            return {"message": "Ruta borrada correctamente"}
        except Exception as e:
            # En caso de error, se revierten los cambios y lanza una excepción
            raise HTTPException(status_code=500, detail=e)
    else:
        # Si no existe se devuelve código 404, NOT-FOUND.
        raise  HTTPException(status_code=404, detail="No existe ruta con ese nombre")

# Petición POST. Insertar una nueva ruta en el sistema.
# Recibe el token del usuario y la ruta en formato JSON.
@app.post("/ruta/")
def insertar_ruta(ruta : RutaTuristica, user=Depends(manager)):
    # Se intenta obtener la ruta para comprobar que no exista previamente.
    rutaInsertar = manejador_bd.obtenerRuta(ruta.nombre)
    if(rutaInsertar is None):
        try:
            ruta.autor = user.email
            # Si no existía se crea la estructura de carpetas y se inserta la información en la base de datos
            crear_estructura_carpetas(ruta)
            manejador_bd.insertarRuta(ruta)
            # Se devuelve mensaje de éxito (Código 200)
            return {"message": "Ruta registrada exitosamente"}
            # Si ocurre algún error durante la inserción se devuelve 500 
        except ValueError as ve:
            raise HTTPException(status_code=500, detail=ve)
    else:
        # Si ya existía se devuelve código 409, Conflicto.
        raise  HTTPException(status_code=409, detail="Ya existe la ruta")
    
# Petición PUT. Modificar una ruta del sistema.
# Recibe el token del usuario y la ruta ya modificada en formato JSON.
@app.put("/ruta/")
def modificar_ruta(ruta : RutaTuristica, user=Depends(manager)):
    # Intenta obtener la ruta desde la base de datos
    rutaModificar = manejador_bd.obtenerRuta(ruta.nombre)
    if(rutaModificar is not None):
        try:

            # Si existe se borra de la base de datos
            manejador_bd.borrarRuta(rutaModificar)
            # También se borran todos sus datos almacenados
            eliminar_estructura_carpetas(rutaModificar)
            # Se vuelve a crear su estructura de carpetas e inserta en la BD
            ruta.autor = user.email
            crear_estructura_carpetas(ruta)
            manejador_bd.insertarRuta(ruta)
            # Se devuelve mensaje de éxito (Código 200)
            return {"message": "Ruta modificada exitosamente"}
        # Si ocurre algún error durante la inserción se devuelve 500 
        except ValueError as ve:
            raise HTTPException(status_code=500, detail=ve)
    else:
        # Si ya existía se devuelve código 409, Conflicto.
        raise  HTTPException(status_code=409, detail="No existe la ruta")
# def insertar_ruta(ruta : RutaTuristica,imagenes: List[List[UploadFile]] = File(...), imagen_portada: UploadFile = File(...), user=Depends(manager)):

# Petición PUT. Modificar la contraseña de un usuario en el sistema
# Recibe el token del usuario y contraseña.
@app.put("/usuario/me")
def modificar_usuario(contrasenia : Annotated[str, Form()], user=Depends(manager)):
    try:
        nombre_usuario = user.nombre  # Acceder al nombre de usuario
        # Obtención del usuario
        usuario = manejador_bd.obtenerUsuarioPorNombre(nombre_usuario)
        # Modificar el usuario en la base de datos
        manejador_bd.modificarUsuario( contrasenia=contrasenia,usuario=usuario)
            # Se devuelve mensaje de éxito (Código 200)
        return {"message": "Contraseña modificada correctamente"}
    except Exception as e:
        # En caso de error, se revierten los cambios y lanza una excepción
        print(e)
        raise HTTPException(status_code=500, detail=e)
    
# Petición POST. Insertar una nueva imagen a una ruta
# Recibe el token del usuario, nombre de la ruta e imagen.
@app.post("/ruta/imagen")
def insertar_imagen_ruta(ruta :Annotated[str, Form()] , imagen_portada: UploadFile, user=Depends(manager)):
    # Obtiene la ruta desde la BD
    r = manejador_bd.obtenerRuta(ruta)
    if(r is not None):
            try:
                # Si la encuentra, guarda la imagen en su directorio
                guardar_imagen_ruta(r, imagen_portada)
                # Registra en la BD la dirección de la imagen de la ruta.
                manejador_bd.insertarImagenRuta(r)
                return {"message": "Imagenes de ruta registradas exitosamente"}
            except ValueError as ve:
                raise HTTPException(status_code=401, detail="No se ha podido insertar")
    else:
        raise  HTTPException(status_code=409, detail="No existe la ruta de la cual guardar imagenes")

# Petición POST. Insertar una imagen de un lugar de interés.
# Recibe el nombre de la ruta a la que pertenece, el nombre del lugar y la imagen.
@app.post("/lugar/imagen")
def insertar_imagen_lugar(ruta :Annotated[str, Form()], lugar :Annotated[str, Form()] , imagen_lugar: UploadFile):
    # Obtiene la ruta desde la BD
    r = manejador_bd.obtenerRuta(ruta)
    if(r is not None):
            try:
                # Guarda la imagen dentro del directorio perteneciente al lugar de interés.
                dir_img = guardar_recurso_lugar(rutaParam=r,lugarInteres=lugar, archivo=imagen_lugar)
                # Registra en la BD la ruta de la nueva imagen para dicho lugar de interés
                manejador_bd.insertarImagenLugar(lugar,ruta, dir_img)
                return {"message": "Imagenes de ruta registradas exitosamente"}
            except ValueError as ve:
                raise HTTPException(status_code=401, detail="No se ha podido insertar")
    else:
        raise  HTTPException(status_code=409, detail="No existe la ruta de la cual guardar imagenes")

# Petición POST. Crear un nuevo usuario.
# Recibe por parámetro el nombre de usuario, correo electrónico y la contraseña.
@app.post("/signin")
async def registro(nombreUsuario: str = Form(...), correo: str = Form(...), password: str = Form(...)):
    try:
        # Creación de un objeto del tipo Usuario.
        nuevo_usuario = Usuario(nombre=nombreUsuario, email=correo, contrasenia=password)
        # Registrar en la BD al nuevo usuario
        manejador_bd.registrarUsuario(nuevo_usuario)
        return {"message": "Usuario registrado exitosamente"}
    except ValueError as ve:
        # Error si existe un error por la existencia de algún usuario con el mismo nombre o correo.
        raise HTTPException(status_code=409, detail=str(ve))
    except Exception as e:
        # Excepción si el servidor dejó de funcionar inesperadamente.
        raise HTTPException(status_code=500, detail=str(e))
    

# Petición POST. Cerrar sesión del usuario.
# Sólo debe recibir el tóken de sesión.
@app.post("/logout")
async def cerrar_sesion(user=Depends(manager)):
    #Establecer el la fecha de expiración del token en el pasado para que se destruya
    manager._token_expiry = manager.default_expiry
    return {"message": "Logout exitoso"}

# Petición DELETE. Eliminar un usuario del sistema.
# Sólo es necesario recibir el tóken de sesión.
@app.delete("/usuario/me")
async def borrar_usuario(user=Depends(manager)):
    # Eliminar el token de sesión
    manager._token_expiry = manager.default_expiry
    # Eliminar al usuario de la BD
    mensaje = manejador_bd.eliminarUsuario(user)
    return mensaje

# # Petición POST. Subir un archivo a la carpeta de un lugar de interés.
# # Recibe el nombre de la ruta y el nombre del lugar como parámetros en la URL, y la imagen a subir.
# @app.post("/ruta/{ruta}/{lugar}/recurso")
# async def subir_archivo_lugar(ruta: str, lugar: str, archivo: UploadFile):
#     # Obtener la ruta turística desde la base de datos
#     ruta_turistica = manejador_bd.obtenerRuta(ruta)
#     if ruta_turistica is None:
#         raise HTTPException(status_code=404, detail="La ruta turística no existe")
    
#     # Intentar encontrar el lugar de interés dentro de la ruta
#     lugar_interes = next((l for l in ruta_turistica.lugares if l.nombre == lugar), None)
#     if lugar_interes is None:
#         raise HTTPException(status_code=404, detail=f"El lugar de interés '{lugar}' no existe en la ruta '{ruta}'")
    
#     try:
#         # Guardar el archivo en la carpeta del lugar de interés
#         dir_archivo = guardar_recurso_lugar(ruta_turistica, lugar_interes, archivo)
        
#         # Registrar la ruta del archivo en la base de datos
#         manejador_bd.insertarArchivoLugar(lugar_interes, dir_archivo)
        
#         return {"message": f"Archivo subido exitosamente al lugar de interés '{lugar}' de la ruta '{ruta}'"}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))