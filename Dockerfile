FROM python:3.11-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los scripts de configuración y darles permisos de ejecución
COPY setup.sh install_dependencies.sh /app/
RUN chmod +x /app/setup.sh /app/install_dependencies.sh

# Ejecutar el script de configuración para instalar las dependencias del sistema
RUN /app/setup.sh && /app/install_dependencies.sh

# Copiar el archivo de requisitos y el código de la aplicación en el contenedor
COPY requirements.txt /app/
COPY . /app/

# Instalar las dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# Expone el puerto que usará la aplicación
EXPOSE 8000

# Define el comando por defecto para ejecutar la aplicación
CMD ["gunicorn", "--worker-tmp-dir", "/dev/shm", "--config", "gunicorn_config.py", "api:app"]
