FROM qgis/qgis:latest
ENV QT_QPA_PLATFORM=offscreen

WORKDIR /app

# Copia todo el repo al contenedor
COPY . .

# Comando por defecto: ejecutar tu script
CMD ["python3", "python/generate_docker_qgs.py"]
