from pydantic import BaseModel, Field

class Usuario (BaseModel):
    nombre: str
    email: str
    contrasenia: str
