# Usa una imagen base de Python
FROM python:3.11-slim

# Establece el directorio de trabajo
WORKDIR /app

# Instala las dependencias del sistema
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Crea y activa el entorno virtual e instala las dependencias en él
RUN python3 -m venv venv && \
    /bin/bash -c "source venv/bin/activate && pip install --no-cache-dir -r requirements.txt && pip install gdown"

# Copia el resto de los archivos de la aplicación en el contenedor
COPY api.py .
COPY modelo.py .
COPY gunicorn_config.py .
COPY requirements.txt .
COPY index.html ./templates

# Descarga el modelo desde Google Drive
RUN /bin/bash -c "source venv/bin/activate && gdown https://drive.google.com/uc?id=1Ed9g2Rj_k7CPF8ClBalaYfDhfbNlsuTC -O mejor_modelo.pth"

# Establece el comando de inicio para ejecutar la aplicación Flask con Gunicorn
CMD ["gunicorn", "-c", "gunicorn_config.py", "api:app"]
