# Etapa 1: Instalación de dependencias del sistema
FROM python:3.11-slim AS base
WORKDIR /app

# Crea el directorio necesario para apt
RUN mkdir -p /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists/partial && \
    apt-get update && \
    apt-get install -y libgl1-mesa-glx && \
    chmod 700 /var/lib/apt/lists/partial

# Etapa 2: Instalación de dependencias de la aplicación
FROM base AS dependencies
COPY requirements.txt /app/requirements.txt
RUN python3 -m venv myenv && \
    . myenv/bin/activate && \
    pip install --no-cache-dir -r requirements.txt

# Etapa 3: Copia del código de la aplicación
FROM dependencies AS build
COPY . /app

# Etapa 4: Configuración final
FROM build AS final
# Instala gunicorn
RUN . myenv/bin/activate && \
    pip install gunicorn

# Expone el puerto que usará la aplicación
EXPOSE 8000

# Define el comando por defecto para ejecutar la aplicación
CMD ["gunicorn", "--worker-tmp-dir", "/dev/shm", "--config", "gunicorn_config.py", "api:app"]

