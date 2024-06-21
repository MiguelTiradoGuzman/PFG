# PFG - Aplicación móvil para recorridos turísticos guiados

Este repositorio contiene el software desarrollado para el Trabajo Final de Grado de Ingeniería Informática en la Universidad de Granada por el alumno Miguel Tirado Guzmán, dirigido por Carlos Ureña Almagro.

Con esta aplicación los usuarios pueden realizar rutas turísticas en las cuales se visitan diversos lugares de interés. La información de estos lugares puede ser obtenido vía imágenes, objetos 3D y audio.

Esta aplicación se ha construido con Flutter, obteniendo la información de mapas a través de Mapbox. Para la construcción del backend se ha utilizado Docker, sobre la que se construye una API con Fast-API y una base de datos MySQL.

# Configurar y lanzar el proyecto

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
