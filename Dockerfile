FROM python:3.11-slim

# Establece el directorio de trabajo
WORKDIR /app

# Copia el script de configuración en el contenedor
COPY install_dependencies.sh /app/install_dependencies.sh

# Dale permisos de ejecución al script
RUN chmod +x /app/install_dependencies.sh

# Ejecuta el script de configuración para instalar las dependencias del sistema
RUN /app/install_dependencies.sh

# Copia el archivo de requisitos y el código de la aplicación en el contenedor
COPY requirements.txt /app/requirements.txt
COPY . /app

# Instala las dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

RUN pip install gunicorn


# Expone el puerto que usará la aplicación
EXPOSE 8000

# Define el comando por defecto para ejecutar la aplicación
CMD ["gunicorn", "--worker-tmp-dir", "/dev/shm", "--config", "gunicorn_config.py", "api:app"]
