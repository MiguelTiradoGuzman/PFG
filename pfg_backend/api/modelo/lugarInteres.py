from pydantic import BaseModel, Field
from typing import List
class LugarInteres(BaseModel):
    nombre: str
    descripcion: str
    latitud: float
    longitud: float
    fotos: List[str]