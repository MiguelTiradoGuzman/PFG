# PFG - Aplicación móvil para recorridos turísticos guiados

Este repositorio contiene el software desarrollado para el Trabajo Final de Grado de Ingeniería Informática en la Universidad de Granada por el alumno Miguel Tirado Guzmán, dirigido por Carlos Ureña Almagro.

Con esta aplicación los usuarios pueden realizar rutas turísticas en las cuales se visitan diversos lugares de interés. La información de estos lugares puede ser obtenido vía imágenes, objetos 3D y audio.

Esta aplicación se ha construido con Flutter, obteniendo la información de mapas a través de Mapbox. Para la construcción del backend se ha utilizado Docker, sobre la que se construye una API con FastAPI y una base de datos MySQL.

# Configurar y lanzar el proyecto

## Dependencias previas

Para poder ejecutar este proyecto es necesario tener instalado una imagen Android en Android Studio así como el sdk de Flutter.

Al mismo tiempo, para la parte del servidor es necesario disponer de Docker.

## Configuración de la conexión de la aplicación al backend

Para que la aplicación se conecte con el servidor del backend se debe crear un archivo en pfg_app/lib/constants/network_const.dart

En ese archivo se debe añadir el siguiente código:

```dart
class NetworkConst {
  static const String baseUrl = 'https://TU_IP_PRIVADA';
  static const String baseUrlImagenes = 'http://TU_IP_PRIVADA:8080/imagenes';
  static const String baseUrlNoSSL = 'http://TU_IP_PRIVADA:8080';
}
```

## Configuración de Mapbox en Android

Estas son las indicaciones extraídas de la página oficial de Mapbox para instalar su dependencia en la aplicación. Disponible en: https://docs.mapbox.com/android/maps/guides/install/

### Configurar token secreto

Para evitar exponer tu token secreto, agrégalo como una variable de entorno:

1. Encuentra o crea un archivo `gradle.properties` en la carpeta de usuario de Gradle. La carpeta está ubicada en `«USER_HOME»/.gradle`. Una vez que hayas encontrado o creado el archivo, su ruta debería ser `«USER_HOME»/.gradle/gradle.properties`. Más detalles sobre las propiedades de Gradle en la [documentación oficial de Gradle](https://docs.gradle.org/current/userguide/build_environment.html#sec:gradle_configuration_properties).
2. Agrega tu token secreto en tu archivo `gradle.properties`:

   ```properties
   MAPBOX_DOWNLOADS_TOKEN=TU_TOKEN_SECRETO_MAPBOX_ACCESS_TOKEN
   ```

### Configurar tu token público

El SDK soporta múltiples formas de proporcionar un token de acceso: a través de recursos de la aplicación o configurándolo en tiempo de ejecución.

#### Recursos

Una forma de proporcionar tu token público al SDK de Mapbox es agregándolo como un recurso de cadena de Android.

Para hacerlo, crea un nuevo archivo de recursos de cadena en tu módulo de la aplicación (por ejemplo, `app/src/main/res/values/developer-config.xml`) con tu token público de la API de Mapbox:

    ```xml
    <?xml version="1.0" encoding="utf-8"?>
    <resources xmlns:tools="http://schemas.android.com/tools">
        <string name="mapbox_access_token" translatable="false" tools:ignore="UnusedResources">TU_TOKEN_PÚBLICO_MAPBOX_ACCESS_TOKEN</string>
    </resources>
    ```

En este caso, si deseas rotar un token de acceso, necesitarás volver a lanzar tu aplicación. Para obtener más información sobre la rotación de tokens de acceso, consulta la [página de Información de Tokens de Acceso](https://docs.mapbox.com/help/glossary/access-token/).

### Configurar permisos

Si planeas mostrar la ubicación del usuario en el mapa u obtener la información de la ubicación del usuario, necesitarás agregar el permiso `ACCESS_COARSE_LOCATION` en el archivo `AndroidManifest.xml` de tu aplicación. También necesitas agregar el permiso `ACCESS_FINE_LOCATION` si necesitas acceso a la ubicación precisa. Puedes verificar si el usuario ha concedido el permiso de ubicación y solicitar permisos si el usuario no los ha concedido aún utilizando el `PermissionsManager`.

```xml
<manifest ... >
  <!-- Incluye siempre este permiso -->
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

  <!-- Incluye solo si tu aplicación se beneficia del acceso a ubicación precisa. -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
</manifest>
```

## Configuración del Backend

### Configuración de Claves de Encriptación para HTTPS

Para que la aplicación funcione correctamente con HTTPS, es necesario crear claves de encriptación en la carpeta `/pfg_backend/certs/`. Estas claves deben tener los siguientes nombres y extensiones:

- `localhost.crt`
- `localhost.csr`
- `localhost.key`

#### Pasos para crear las claves

1. Crear la carpeta `/pfg_backend/certs/`.
2. Ejecutar los comandos necesarios para generar las claves.

   ```sh
   # Generar la clave privada
   openssl genpkey -algorithm RSA -out localhost.key

   # Crear una solicitud de firma de certificado (CSR)
   openssl req -new -key localhost.key -out localhost.csr

   # Crear el certificado
   openssl x509 -req -days 365 -in localhost.csr -signkey localhost.key -out localhost.crt
   ```

### Configuración del reverse proxy

En el archivo /pfg_backend/nginx.conf se debe alterar la siguiente línea para que reenvíe las peticiones al servidor de la API:

```
proxy_pass http://TU_IP:8080;
```

### Configuración de la Base de datos

Una vez se ha levantado el servicio de MySQL se debe crear un usuario y la base de datos llamada 'pfg' y ejecutar los siguientes comandos para crear la estructura de la base de datos:

```sql
    CREATE TABLE `Usuario` (
            `email` varchar(50) NOT NULL,
            `nombreUsuario` varchar(50) NOT NULL,
            `contrasenia` varchar(100) NOT NULL,
            PRIMARY KEY (`email`),
            UNIQUE KEY `uq_nombreUsuario` (`nombreUsuario`)
        );

    CREATE TABLE `RutaTuristica` (
            `nombre` varchar(50) NOT NULL,
            `descripcion` text NOT NULL,
            `distancia` float NOT NULL,
            `duracion` time NOT NULL,
            `imagenPortada` varchar(500) DEFAULT NULL,
            `autor` varchar(50) DEFAULT NULL,
            PRIMARY KEY (`nombre`),
            KEY `fk_usuario_email` (`autor`),
            CONSTRAINT `fk_usuario_email` FOREIGN KEY (`autor`) REFERENCES `Usuario` (`email`) ON DELETE SET NULL
        );

    CREATE TABLE `LugarInteres` (
            `nombre` varchar(50) NOT NULL,
            `nombreRuta` varchar(50) NOT NULL,
            `longitud` float NOT NULL,
            `latitud` float NOT NULL,
            `descripcion` text NOT NULL,
            PRIMARY KEY (`nombre`,`nombreRuta`),
            KEY `lugarinteres_ibfk_1` (`nombreRuta`),
            CONSTRAINT `lugarinteres_ibfk_1` FOREIGN KEY (`nombreRuta`) REFERENCES `RutaTuristica` (`nombre`) ON DELETE CASCADE
        );

    CREATE TABLE `ImagenLugar` (
            `lugarImagen` varchar(500) NOT NULL,
            `nombreLugar` varchar(50) NOT NULL,
            `nombreRuta` varchar(50) NOT NULL,
            PRIMARY KEY (`lugarImagen`,`nombreLugar`, `nombreRuta`),
            KEY `FK_nombreRuta` (`nombreRuta`),
            KEY `FK_nombreLugar` (`nombreLugar`),
            CONSTRAINT FK_nombreLugar_nombreRuta FOREIGN KEY (`nombre`,`nombreRuta`) REFERENCES LugarInteres (`nombreLugar`,`nombreRuta`) ON DELETE CASCADE
        );

    CREATE TABLE `UsuarioRutaFavorita` (
            `usuario` varchar(50) NOT NULL,
            `ruta` varchar(50) NOT NULL,
            PRIMARY KEY (`usuario`,`ruta`),
            KEY `fk_usuariorutafavorita_ruta` (`ruta`),
            CONSTRAINT `usuariorutafavorita_ibfk_1` FOREIGN KEY (`usuario`) REFERENCES `Usuario` (`email`),
            CONSTRAINT `usuariorutafavorita_ibfk_2` FOREIGN KEY (`ruta`) REFERENCES `RutaTuristica` (`nombre`)
          );
```

### Configuración de las variables de entorno

Por último, se debe crear un archivo .env en la carpeta /pfg_backend con las siguientes variables:

```
# MySQL Configuration
MYSQL_ROOT_PASSWORD=tuContraseniaBD
MYSQL_DATABASE=pfg
MYSQL_USER=tuUsuarioBD
MYSQL_PASSWORD=tuContraseniaUsuarioBD

# Configuracion API
DB_HOST=mysql
DB_PORT=3306
DB_USER=tuUsuarioBD
DB_PASSWORD=tuContraseniaUsuarioBD
DB_DATABASE=pfg
API_SECRET_KEY=tuClaveSecretaAPI
```
