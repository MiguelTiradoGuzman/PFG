import os
import importlib
from typing import List

from fastapi import FastAPI, Depends, HTTPException
from fastapi_login import LoginManager
from datetime import timedelta
import hashlib
app = FastAPI()

# Configuración de la clave secreta para el token de sesión
SECRET_KEY = "your-secret-key"
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
@app.post("/login")
async def login(username: str, password: str):
    user = fake_users_db.get(username)

    if user and user["password_hash"] == password:
        token = manager.create_access_token(data={"sub": username})
        return {"access_token": token, "token_type": "bearer"}
    raise HTTPException(status_code=401, detail="Invalid credentials")

# Ruta protegida que requiere inicio de sesión
@app.get("/protected")
def protected_route(user=Depends(manager)):
    return {"user": user}