import os
import importlib
from typing import List
from dotenv import load_dotenv
import mysql.connector
import hashlib
from api.modelo import lugarInteres, rutaTuristica, usuario


# Carga las variables de entorno desde el archivo .env
load_dotenv()

class ManejadorBD:
    def __init__(self):
        self.host = os.getenv("DB_HOST")
        self.user = os.getenv("DB_USER")
        self.password = os.getenv("DB_PASSWORD")
        self.database = os.getenv("DB_DATABASE")
        self.conexion = None
        self.cursor = None

    def conectar_bd(self):
        print(self.host)
        self.conexion = mysql.connector.connect(
            host=self.host,
            user=self.user,
            password=self.password,
            database=self.database
        )
        self.cursor = self.conexion.cursor(dictionary=True)

    def hash_password(self,password):
        # Convierte la contraseña a bytes.
        password_bytes = password.encode('utf-8')

        # Calcula el hash SHA-256.
        hashed_password = hashlib.sha256(password_bytes).hexdigest()

        return hashed_password
    
    def cerrar_conexion_bd(self):
        if self.cursor:
            self.cursor.close()
        if self.conexion:
            self.conexion.close()

    def login(self, user: usuario):
        query = "SELECT * FROM Usuario WHERE email = %s AND contrasenia=%s"
        self.cursor.execute(query,(user.email, self.hash_password(user.contrasenia),))
        userDevolver = self.cursor.fetchone()
        print(userDevolver)
        if(userDevolver != None):
            user.nombre = userDevolver['nombreUsuario']
        return user
    
    def registrar_usuario(self, nuevo_usuario: usuario):
        # Verificar si ya existe un usuario con el mismo nombre de usuario o correo electrónico
        if self.existeNombreUsuario(nuevo_usuario) or self.existeEmail(nuevo_usuario):
            raise ValueError("El nombre de usuario o correo electrónico ya están en uso")

        # Hash de la contraseña antes de almacenarla en la base de datos
        hashed_password = self.hash_password(nuevo_usuario.contrasenia)

        # Insertar el nuevo usuario en la base de datos
        query = "INSERT INTO Usuario (nombreUsuario, email, contrasenia) VALUES (%s, %s, %s)"
        values = (nuevo_usuario.nombre, nuevo_usuario.email, hashed_password)
        self.cursor.execute(query, values)
        self.conexion.commit()

        return {"message": "Usuario registrado exitosamente"}
    
    def existeNombreUsuario(self, user: usuario):
        query = "SELECT * FROM Usuario WHERE nombreUsuario = %s"
        print("Antes execute")
        self.cursor.execute(query,(user.nombre,))
        print("Tras execute")
        user = self.cursor.fetchone()
        if(user == None):
            return False
        else:
            return True
        
    def obtenerUsuario(self, nombre):
        query = "SELECT * FROM Usuario WHERE nombreUsuario = %s"
        self.cursor.execute(query,(nombre,))
        userDevolver = self.cursor.fetchone()
        print(userDevolver)
        user = None
        if(userDevolver != None):
            user = usuario.Usuario(email = userDevolver['email'], nombre=userDevolver['nombreUsuario'], contrasenia = "") 
        return user
        
    def existeEmail(self, user: usuario):
        query = "SELECT * FROM Usuario WHERE email = %s"
        self.cursor.execute(query,(user.email,))
        user = self.cursor.fetchone()
        if(user == None):
            return False
        else:
            return True

    def obtenerRutas(self):
        # Obtiene la conexión y el cursor desde la función de conexión
        # if(conexion == None or cursor == None):
        #     conexion, cursor = self.conectar_bd()

        # Ejecuta la consulta para obtener todas las rutas
        self.cursor.execute("SELECT * FROM RutaTuristica")

        # Obtiene los resultados
        rutas_bd = self.cursor.fetchall()
        # Convierte los resultados de la base de datos a instancias de RutaTuristica
        rutas = []
        for ruta_bd in rutas_bd:
            # Para cada ruta, busca los lugares asociados
            self.cursor.execute("SELECT * FROM LugarInteres WHERE nombreRuta = %s", (ruta_bd["nombre"],))
            lugares_bd = self.cursor.fetchall()
            lugares = []

            for lugar_bd in lugares_bd:
                # Para cada lugar, busca las imágenes asociadas
                self.cursor.execute("SELECT lugarImagen FROM ImagenLugar WHERE nombreLugar = %s", (lugar_bd["nombre"],))
                imagenes_bd = self.cursor.fetchall()
                imagenes = [imagen_bd["lugarImagen"] for imagen_bd in imagenes_bd]

                # Crea instancia de LugarInteres y agrega a la lista de lugares
                lugar = lugarInteres.LugarInteres(
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
            ruta = rutaTuristica.RutaTuristica(
                nombre=ruta_bd["nombre"],
                descripcion=ruta_bd["descripcion"],
                distancia=ruta_bd["distancia"],
                duracion=duracionFormateada,
                ruta_imagen=ruta_bd["imagenPortada"],
                lugares=lugares
            )
            rutas.append(ruta)

        return rutas
    def eliminarUsuario(self, usuario: usuario.Usuario):
        try:
            # Consulta SQL para eliminar un usuario por su nombre de usuario
            query = "DELETE FROM Usuario WHERE nombreUsuario = %s"
            
            # Ejecuta la consulta con el nombre de usuario proporcionado
            self.cursor.execute(query, (usuario.nombre,))
            
            # Confirma los cambios en la base de datos
            self.conexion.commit()
            
            # Devuelve un mensaje de éxito
            return {"message": f"Usuario '{usuario.nombre}' eliminado correctamente"}
        
        except Exception as e:
            # En caso de error, se lanza una excepción HTTP con el detalle del error
            raise HTTPException(status_code=500, detail=str(e))
