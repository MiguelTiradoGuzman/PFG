from pydantic import BaseModel, Field
from api.modelo.lugarInteres import LugarInteres
from typing import List, Optional


class RutaTuristica (BaseModel):
    nombre: str
    descripcion: str
    distancia: float
    duracion: str
    ruta_imagen: Optional[str]
    lugares: List[LugarInteres]