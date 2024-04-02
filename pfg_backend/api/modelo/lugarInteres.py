from pydantic import BaseModel, Field
from typing import List, Optional
class LugarInteres(BaseModel):
    nombre: str
    descripcion: str
    latitud: float
    longitud: float
    fotos: Optional[List[str]]