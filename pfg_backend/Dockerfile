FROM python:3.12-rc-slim

WORKDIR /app

# Prevents Python from writing pyc files to disc (equivalent to python -B option)
ENV PYTHONDONTWRITEBYTECODE 1
# Prevents Python from buffering stdout and stderr (equivalent to python -u option)
ENV PYTHONUNBUFFERED 1

COPY requirements.txt .

RUN pip install --upgrade pip; pip install --no-cache-dir -r requirements.txt

RUN pip install fastapi-login