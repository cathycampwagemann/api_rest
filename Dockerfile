# Usa una imagen base de Python
FROM python:3.11-slim

# Establece el directorio de trabajo
WORKDIR /app

# Instala las dependencias del sistema
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copia el archivo requirements.txt en el contenedor
COPY requirements.txt .

# Instala las dependencias necesarias para crear un entorno virtual
RUN apt-get update && apt-get install -y python3-venv

# Crea y activa el entorno virtual
RUN python3 -m venv venv
RUN /bin/bash -c "source venv/bin/activate"

# Instala las dependencias en el entorno virtual
RUN pip install --no-cache-dir -r requirements.txt

# Instala gdown para descargar archivos de Google Drive
RUN pip install gdown

# Copia el resto de los archivos de la aplicación en el contenedor
COPY api.py .
COPY modelo.py .
COPY gunicorn_config.py .
COPY templates index.html .

# Descarga el modelo desde Google Drive
RUN gdown https://drive.google.com/uc?id=1Ed9g2Rj_k7CPF8ClBalaYfDhfbNlsuTC -O mejor_modelo.pth

# Establece el comando de inicio para ejecutar la aplicación Flask con Gunicorn
CMD ["gunicorn", "-c", "gunicorn_config.py", "api:app"]
