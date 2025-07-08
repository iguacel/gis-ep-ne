# Crear qgs

## Local

```bash
PROJ_LIB=/Applications/QGIS.app/Contents/Resources/proj \
/Applications/QGIS.app/Contents/MacOS/bin/python3 python/generate_local_qgs.py

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

## Estilos de capa

🎨 Equivalentes en QGIS a lo que ves en el panel de simbología
Vamos a lo importante:

✅ Para rellenos (QgsFillSymbol.createSimple)

- "style": "no" → equivale a Fill style: No Brush

- "style": "solid" → Fill style: Solid

- "style": "bdiagonal" → Diagonal patterns, etc.

✅ Para líneas (QgsLineSymbol.createSimple)

- "line_style": "no" → Stroke style: No Line

- "line_style": "solid" → Stroke style: Solid Line

- "line_style": "dot" → Dotted

- "line_style": "dash" → Dashed

- "line_style": "dashdot" → Dash-Dot

⚠️ Nota: QgsLineSymbol.createSimple() espera "line_style" en lugar de "style"
