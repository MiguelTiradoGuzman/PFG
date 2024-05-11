from http.client import HTTPException
import os
import importlib
from typing import List
from dotenv import load_dotenv
import mysql.connector
import hashlib
from api.modelo import lugarInteres, rutaTuristica, usuario
from functools import wraps


# Carga las variables de entorno desde el archivo .env
load_dotenv()
# Clase ManejadorBD. Es la clase encargada de realizar las conexiones con la BD.
# Es una abstracción de la base de datos.
class ManejadorBD:
    def __init__(self):
        # Obtención de las variables desde el archivo .env
        # Extrae el host del servidor de la BD.
        self.host = os.getenv("DB_HOST")
        # Extrae el nombre de usuario en el servidor.
        self.user = os.getenv("DB_USER")
        # Extrae la contraseña
        self.password = os.getenv("DB_PASSWORD")
        # Extrae el nombre de la BD
        self.database = os.getenv("DB_DATABASE")
        self.conexion = None
        self.cursor = None

    # Método para conectarse a la BD.
    def conectarBD(self):
        # Establece la conexión con el servidor
        self.conexion = mysql.connector.connect(
            host=self.host,
            user=self.user,
            password=self.password,
            database=self.database
        )
        # Obtiene un cursor
        self.cursor = self.conexion.cursor(dictionary=True)
    # Método para hacer un hashing de las contraseñas
    def hashContrasenia(self,contrasenia):
        # Convierte la contraseña a bytes.
        bytesContrasenia = contrasenia.encode('utf-8')

        # Calcula el hash SHA-256.
        hashContrasenia = hashlib.sha256(bytesContrasenia).hexdigest()

        return hashContrasenia
    
    # Método para cerrar la conexión con el servidor de la BD.
    # Cierra el cursor y la conexión.
    def cerrarConexionBD(self):
        if self.cursor:
            self.cursor.close()
        if self.conexion:
            self.conexion.close()

    # Método de extracción de objetos del tipo RutaTuristica desde los resultados
    # de un select hacia las rutas.
    def extraerRutas(self, rutasBD):
        rutas = []
        for rutaBD in rutasBD:
            # Para cada ruta, busca los lugares asociados
            self.cursor.execute("SELECT * FROM LugarInteres WHERE nombreRuta = %s", (rutaBD["nombre"],))
            lugaresBD = self.cursor.fetchall()
            lugares = []

            for lugarBD in lugaresBD:
                # Para cada lugar, busca las imágenes asociadas
                self.cursor.execute("SELECT lugarImagen FROM imagenLugar WHERE nombreLugar = %s", (lugarBD["nombre"],))
                imagenes_bd = self.cursor.fetchall()
                imagenes = [imagen_bd["lugarImagen"] for imagen_bd in imagenes_bd]

                # Crea instancia de LugarInteres y agrega a la lista de lugares
                lugar = lugarInteres.LugarInteres(
                    nombre=lugarBD["nombre"],
                    descripcion=lugarBD["descripcion"],
                    latitud=lugarBD["latitud"],
                    longitud=lugarBD["longitud"],
                    fotos=imagenes
                )
                lugares.append(lugar)
                
            # Obtención de la duración formateada
            duracionCompleta = str(rutaBD["duracion"])
            horas, minutos, segundos = duracionCompleta.split(":")
            duracionFormateada = f"{horas}:{minutos}"
            # Obtener la ruta de la imagen de portada
            img = ""
            autor = rutaBD["autor"]
            # Establecer el campo autor y la imagen de portada
            if(autor is None):
                autor=""
            if(rutaBD["imagenPortada"] is not None):
                img = rutaBD["imagenPortada"]
            # Aquí asumes que ruta_bd es un diccionario que contiene los datos de la ruta
            ruta = rutaTuristica.RutaTuristica(
                nombre=rutaBD["nombre"],
                descripcion=rutaBD["descripcion"],
                distancia=rutaBD["distancia"],
                duracion=duracionFormateada,
                ruta_imagen=img,
                lugares=lugares,
                autor = autor
            )
            # Meter en el vector de rutas la nueva creada.
            rutas.append(ruta)

        return rutas
    
    # Método para iniciar sesión
    def login(self, user: usuario):
        # Se busca el usuario con el mismo email y hash de la contraseña que le pasa por parámetro.
        query = "SELECT * FROM Usuario WHERE email = %s AND contrasenia=%s"
        self.cursor.execute(query,(user.email, self.hashContrasenia(user.contrasenia),))
        userDevolver = self.cursor.fetchone()
        # Si lo encuentra, le establece al usuario que llega por parámetro el nombre de usuario.
        if(userDevolver != None):
            user.nombre = userDevolver['nombreUsuario']
        # Si devuelve None es que no existe ninguna pareja con ese correo y contraseña
        return user
    
    # Registra un nuevo usuario en la BD
    def registrarUsuario(self, nuevoUsuario: usuario):
        # Verificar si ya existe un usuario con el mismo nombre de usuario
        if self.existeNombreUsuario(nuevoUsuario) :
            raise ValueError("El nombre de usuario ya está en uso")
        
        # Verificar si ya existe un usuario con el mismo correo electrónico

        if self.existeEmail(nuevoUsuario) :
            raise ValueError("El correo ya está en uso")

        # Hash de la contraseña antes de almacenarla en la base de datos
        hashContrasenia = self.hashContrasenia(nuevoUsuario.contrasenia)

        # Insertar el nuevo usuario en la base de datos
        query = "INSERT INTO Usuario (nombreUsuario, email, contrasenia) VALUES (%s, %s, %s)"
        values = (nuevoUsuario.nombre, nuevoUsuario.email, hashContrasenia)
        self.cursor.execute(query, values)
        self.conexion.commit()

        return {"message": "Usuario registrado exitosamente"}
    
    # Comprueba si existe un usuario en la BD por nombre
    # Recibe por parámetro el objeto usuario que se desea comprobar
    def existeNombreUsuario(self, user: usuario):
        # Consulta para comprobar si existe algún usuario con el mismo nombre de usuario.
        query = "SELECT * FROM Usuario WHERE nombreUsuario = %s"
        self.cursor.execute(query,(user.nombre,))
        
        user = self.cursor.fetchone()
        if(user == None):
            return False
        else:
            return True
    
    # Obtener usuario por nombre de usuario
    # Recibe por parámetro el nombre de usuario
    def obtenerUsuarioPorNombre(self, nombre):
        query = "SELECT * FROM Usuario WHERE nombreUsuario = %s"
        self.cursor.execute(query,(nombre,))
        userDevolver = self.cursor.fetchone()
        user = None
        if(userDevolver != None):
            # Si existe inicializa el objeto usuario a devolver sin la contraseña
            user = usuario.Usuario(email = userDevolver['email'], nombre=userDevolver['nombreUsuario'], contrasenia = "") 
        return user

    # Obtener usuario por el correo electrónico
    # Recibe el correo electrónico por parámetro.
    def obtenerUsuarioPorCorreo(self, correo):
        query = "SELECT * FROM Usuario WHERE email = %s"
        self.cursor.execute(query,(correo,))
        userDevolver = self.cursor.fetchone()
        user = None
        if(userDevolver != None):
            # Si existe el usuario inicializa una instancia de la clase Usuario
            user = usuario.Usuario(email = userDevolver['email'], nombre=userDevolver['nombreUsuario'], contrasenia = "") 
        return user
    
    # Comprobar si existe algun usuario con el mismo correo electronico
    def existeEmail(self, user: usuario):
        query = "SELECT * FROM Usuario WHERE email = %s"
        self.cursor.execute(query,(user.email,))
        user = self.cursor.fetchone()
        if(user == None):
            return False
        else:
            return True

    # Obtener la ruta especificada.
    # Recibe por parámetro el nombre de la ruta a obtener de la BD.
    def obtenerRuta(self, nombre):
        # Ejecuta la consulta para obtener todas las rutas
        self.cursor.execute("SELECT * FROM RutaTuristica WHERE nombre = %s",(nombre,) )
        # Obtiene los resultados
        ruta= self.cursor.fetchall()
        rutaDev=None
        # Extrae la ruta
        rutas = self.extraerRutas(ruta)
        if(len(rutas)!=0):
            # Sólo debe existir una, se devuelve la primera y única ruta del array
            rutaDev = rutas[0]
        return rutaDev
        

    # Obtener todas las rutas registradas en el sistema
    def obtenerRutas(self):
        # Ejecuta la consulta para obtener todas las rutas
        self.cursor.execute("SELECT * FROM RutaTuristica")

        # Obtiene los resultados
        rutasBD = self.cursor.fetchall()
        # Convierte los resultados de la base de datos a instancias de RutaTuristica
        rutas = []
        # Obtiene desde los resultados el array de rutas a devolver
        rutas = self.extraerRutas(rutasBD)
        return rutas
    
    # Elimina el usuario de la BD.
    # Obtiene por parámetro una instancia del usuario a borrar
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
            raise e
        
    # Inserta una nueva ruta turística en la BD.
    def insertarRuta(self, nueva_ruta: rutaTuristica.RutaTuristica):
        try:
            # Insertar la nueva ruta en la tabla RutaTuristica
            query_ruta = "INSERT INTO RutaTuristica (nombre, descripcion, distancia, duracion, autor) VALUES (%s, %s, %s, %s, %s)"
            values_ruta = (nueva_ruta.nombre, nueva_ruta.descripcion, nueva_ruta.distancia, nueva_ruta.duracion, nueva_ruta.autor)
            self.cursor.execute(query_ruta, values_ruta)

            # Insertar los lugares asociados a la ruta en la tabla LugarInteres
            for lugar in nueva_ruta.lugares:
                query_lugar = "INSERT INTO LugarInteres (nombre, descripcion, latitud, longitud, nombreRuta) VALUES (%s, %s, %s, %s, %s)"
                values_lugar = (lugar.nombre, lugar.descripcion, lugar.latitud, lugar.longitud, nueva_ruta.nombre)
                self.cursor.execute(query_lugar, values_lugar)

            # Confirmar los cambios en la base de datos
            self.conexion.commit()

            return {"message": "Ruta insertada correctamente"}
        
        except Exception as e:
            # En caso de error, se lanza una excepción HTTP con el detalle del error
            raise e
        
    # Borra una rutaTuristica del sistema
    def borrarRuta(self, ruta : rutaTuristica.RutaTuristica):
        try:
            # Consulta SQL para eliminar un usuario por su nombre de usuario
            query = "DELETE FROM RutaTuristica WHERE nombre = %s"
            
            # Ejecuta la consulta con el nombre de la ruta proporcionada
            self.cursor.execute(query, (ruta.nombre,))
            
            # Confirma los cambios en la base de datos
            self.conexion.commit()
            
            # Devuelve un mensaje de éxito
            return {"message": f"Ruta '{ruta.nombre}' eliminado correctamente"}
        
        except Exception as e:
            # En caso de error, se lanza una excepción HTTP con el detalle del error
            raise e 

    # Inserta una nueva imagen de una ruta en la BD
    def insertarImagenRuta(self, nueva_ruta: rutaTuristica.RutaTuristica):
        try:
            # Actualizar la imagen de la ruta turística
            self.cursor.execute(
                """
                UPDATE RutaTuristica
                SET imagenPortada = %s
                WHERE nombre = %s
                """,
                (nueva_ruta.ruta_imagen, nueva_ruta.nombre)
            )
            for lugar in nueva_ruta.lugares:
            # Insertar las imágenes asociadas al lugar en la tabla imagenLugar
                for foto in lugar.fotos:
                    query_imagen = "INSERT INTO imagenLugar (lugarImagen, nombreLugar) VALUES (%s, %s)"
                    values_imagen = (foto, lugar.nombre)
                    self.cursor.execute(query_imagen, values_imagen)

            # Confirmar los cambios en la base de datos
            self.conexion.commit()

        except Exception as e:
            # Si hay algún error, revertir cambios y lanzar una excepción
            self.conexion.rollback()
            raise e
        
    # Inserta una imagen de un lugar de interés en la BD
    def insertarimagenLugar(self, nuevo_lugar: str,ruta : str, dir_img : str):
        try:
            
            query_imagen = "INSERT INTO imagenLugar (lugarImagen, nombreLugar, nombreRuta) VALUES (%s, %s,%s)"
            values_imagen = (dir_img,nuevo_lugar,ruta )
            self.cursor.execute(query_imagen, values_imagen)

            # Confirmar los cambios en la base de datos
            self.conexion.commit()

        except Exception as e:
            # Si hay algún error, revertir cambios y lanzar una excepción
            self.conexion.rollback()
            raise e
        
    # Modificar la contraseña de un usuario en la BD
    def modificarUsuario(self, contrasenia : str, usuario : usuario.Usuario):
        try:
            # Hash de la nueva contraseña
            hashContrasenia = self.hashContrasenia(contrasenia)
            # Consulta SQL para actualizar la contraseña del usuario
            query = "UPDATE Usuario SET contrasenia = %s WHERE nombreUsuario = %s"
            
            # Ejecutar la consulta con la nueva contraseña y el nombre de usuario proporcionados
            self.cursor.execute(query, (hashContrasenia, usuario.nombre))
            
            # Confirmar los cambios en la base de datos
            self.conexion.commit()

            return {"message": f"Contraseña del usuario '{usuario.nombre}' modificada correctamente"}

        except Exception as e:
            # En caso de error, revertir cambios y lanzar una excepción
            print(e)
            self.conexion.rollback()
            raise e
        
    # Obtiene las rutas asociadas a un autor
    def obtenerRutasPorAutor(self, usuario: usuario.Usuario):
            # Ejecuta la consulta para obtener todas las rutas
            query = "SELECT * FROM RutaTuristica WHERE autor= %s"
            self.cursor.execute(query, ( usuario.email,))

            # Obtiene los resultados
            rutas_bd = self.cursor.fetchall()
            # Convierte los resultados de la base de datos a instancias de RutaTuristica
            rutas = []
            rutas = self.extraerRutas(rutas_bd)
            return rutas
    
    # Obtiene las rutas favoritas de un usuario
    def obtenerRutasFavoritas(self, usuario: usuario.Usuario):
                # Obtiene la conexión y el cursor desde la función de conexión
                # if(conexion == None or cursor == None):
                #     conexion, cursor = self.conectar_bd()

                # Ejecuta la consulta para obtener todas las rutas
                query = "SELECT rt.* FROM RutaTuristica rt JOIN usuariorutafavorita urf ON rt.nombre = urf.ruta WHERE urf.usuario = %s"
                self.cursor.execute(query, ( usuario.email,))

                # Obtiene los resultados
                rutas_bd = self.cursor.fetchall()
                # Convierte los resultados de la base de datos a instancias de RutaTuristica
                rutas = []
                rutas = self.extraerRutas(rutas_bd)
                return rutas

    # Marca una nueva ruta como favorita en la BD
    def marcarRutaFavorita(self,usuario : usuario.Usuario, ruta: str):
            try:
                
                query_favorito = "INSERT INTO usuariorutafavorita (usuario, ruta) VALUES (%s, %s)"
                values_imagen = (usuario.email,ruta)
                self.cursor.execute(query_favorito, values_imagen)

                # Confirmar los cambios en la base de datos
                self.conexion.commit()

            except Exception as e:
                # Si hay algún error, revertir cambios y lanzar una excepción
                self.conexion.rollback()
                raise e
    # Desmarca una ruta como favorita para un usuario
    def desmarcarRutaFavorita(self, usuario : usuario.Usuario ,ruta : str):
        try:
            # Consulta SQL para eliminar un usuario por su nombre de usuario
            query = "DELETE FROM usuariorutafavorita WHERE usuario = %s and ruta= %s"
            
            # Ejecuta la consulta con el nombre de la ruta proporcionada
            self.cursor.execute(query, (usuario.email, ruta))
            
            # Confirma los cambios en la base de datos
            self.conexion.commit()
            
            # Devuelve un mensaje de éxito
            return {"message": f"Favorito de  '{usuario.email}' en '{ruta}'eliminado correctamente"}
        
        except Exception as e:
            # En caso de error, se lanza una excepción HTTP con el detalle del error
            raise e 