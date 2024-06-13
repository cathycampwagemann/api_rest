FROM python:3.11-slim

# Establece el directorio de trabajo
WORKDIR /app

# Actualiza la lista de paquetes e instala las dependencias del sistema necesarias
RUN mkdir -p /var/lib/apt/lists/partial && chmod 755 /var/lib/apt/lists/partial && \
    apt-get update && apt-get install -y libgl1-mesa-glx && \
    chmod 700 /var/lib/apt/lists/partial

# Copia el archivo de requisitos y el código de la aplicación en el contenedor
COPY requirements.txt /app/requirements.txt
COPY . /app

# Instala las dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Instala gunicorn
RUN pip install gunicorn

# Expone el puerto que usará la aplicación
EXPOSE 8000

# Define el comando por defecto para ejecutar la aplicación
CMD ["gunicorn", "--worker-tmp-dir", "/dev/shm", "--config", "gunicorn_config.py", "api:app"]
