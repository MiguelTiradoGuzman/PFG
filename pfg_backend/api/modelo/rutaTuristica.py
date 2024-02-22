from pydantic import BaseModel, Field
from api.modelo.lugarInteres import LugarInteres
from typing import List


class RutaTuristica (BaseModel):
    nombre: str
    descripcion: str
    distancia: float
    duracion: str
    ruta_imagen: str
    lugares: List[LugarInteres]