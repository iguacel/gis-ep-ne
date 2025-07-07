# Crear qgs

## Local

```bash
PROJ_LIB=/Applications/QGIS.app/Contents/Resources/proj \
/Applications/QGIS.app/Contents/MacOS/bin/python3 scripts/generate_local_qgs.py

```

## Docker

1. Compilar docker

```bash
docker build -t qgis-generator .

```

2. Modificar Dockfile

3. Ejecutar

```bash
docker run --rm -v $(pwd):/app qgis-generator

```
