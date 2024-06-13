import torch
from flask import Flask, render_template, request, jsonify
from modelo import CustomDenseNet, procesar_imagen, predecir_neumonia
from flask_caching import Cache
from werkzeug.utils import secure_filename
import gdown
import os
import cv2

app = Flask(__name__)
cache = Cache(app, config={'CACHE_TYPE': 'redis', 'CACHE_REDIS_URL': 'redis://localhost:159.203.79.121:6379/0'})

# URL del archivo en Google Drive
url = 'https://drive.google.com/uc?id=1Ed9g2Rj_k7CPF8ClBalaYfDhfbNlsuTC'

# Descargar el archivo y guardarlo localmente
output = 'mejor_modelo.pth'
gdown.download(url, output, quiet=False)

# Cargar el modelo y moverlo al dispositivo adecuado (CPU o GPU)
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
modelo = CustomDenseNet(num_classes=2)
modelo.load_state_dict(torch.load(output, map_location=device))
modelo.to(device)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
carpeta_principal_imagenes = os.path.join(BASE_DIR, 'carpeta_temporal')

# Si la carpeta temporal no existe, se crea
if not os.path.exists(carpeta_principal_imagenes):
    os.makedirs(carpeta_principal_imagenes)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':  
        if 'file' not in request.files:
            return jsonify({"error": "No se indicó el nombre del archivo"}), 400
    file = request.files['file']
    # Verifica si se seleccionó un archivo
    if file.filename == '':
        return jsonify({"error": "No se seleccionó ningún archivo"}), 400

    # Guarda el archivo en la carpeta temporal
    filename = secure_filename(file.filename)
    file_path = os.path.join(carpeta_principal_imagenes, filename)
    file.save(file_path)

    return jsonify({"message": "Archivo cargado exitosamente"}), 200
    
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({"error": "No se indico el nombre del arhivo"}), 400

    file = request.files['file']
    # Verifica si se seleccionó un archivo
    if file.filename == '':
        return jsonify({"error": "No se seleccionó ningún archivo"}), 400

    # Guarda el archivo en la carpeta temporal
    filename = secure_filename(file.filename)
    temp_image_path = os.path.join(carpeta_principal_imagenes, filename)
    file.save(temp_image_path)
    print(f"Imagen guardada temporalmente en: {temp_image_path}")

    imagen = cv2.imread(temp_image_path)
    if imagen is None:
        return jsonify({"error": f"No se pudo leer la imagen en la ruta: {temp_image_path}"}), 400

    imagen_tensor = procesar_imagen(temp_image_path,carpeta_principal_imagenes)
    if imagen_tensor is None:
        return jsonify({"error": "Error al procesar la imagen"}), 500

    imagen_tensor = imagen_tensor.to(device)

    prediccion = predecir_neumonia(modelo, imagen_tensor)

    if prediccion == 1:
        result = "La imagen muestra signos de neumonía."
    else:
        result = "La imagen no muestra signos de neumonía."

    return jsonify({"respuesta": result})

if __name__ == '__main__':
    app.run(debug=True)
