import json
from pathlib import Path
from qgis.core import (
    QgsApplication, QgsProject, QgsVectorLayer,
    QgsCoordinateReferenceSystem, QgsWkbTypes,
    QgsFillSymbol, QgsLineSymbol, QgsMarkerSymbol,
    QgsSingleSymbolRenderer
)

# 📁 Configuración de rutas base
BASE_DIR = Path(__file__).resolve().parent.parent
PRESETS_PATH = BASE_DIR / "data" / "presets.json"
ALIASES_PATH = BASE_DIR / "data" / "layer_aliases.json"
OUTPUT_FILE = BASE_DIR / "template.qgs"

# 🧠 Leer configuración y aliases
with open(PRESETS_PATH, "r") as f:
    config = json.load(f)

with open(ALIASES_PATH, "r") as f:
    aliases = json.load(f)

scale = config["scale"]
layers = config["layers"]

# 🚀 Inicializar QGIS sin GUI
QgsApplication.setPrefixPath("/Applications/QGIS.app/Contents/MacOS", True)
qgs = QgsApplication([], False)
qgs.initQgis()

project = QgsProject.instance()
project.setCrs(QgsCoordinateReferenceSystem("EPSG:4326"))

for layer_cfg in layers:
    name = layer_cfg["name"]
    alias = layer_cfg["alias"]
    style = layer_cfg.get("style", {})

    if alias not in aliases:
        print(f"❌ Alias no encontrado: {alias}")
        continue

    entry = aliases[alias]
    filename = entry["filename"] + ".gpkg"
    mode = entry["mode"]
    layer_path = BASE_DIR / "OUTPUT" / mode / "geopackage" / scale / filename

    if not layer_path.exists():
        print(f"❌ Archivo no encontrado: {layer_path}")
        continue

    layer = QgsVectorLayer(str(layer_path), name, "ogr")
    if not layer.isValid():
        print(f"❌ Falló la carga de: {name}")
        continue

    print(f"✅ Añadiendo: {name}")

    # 🎨 Estilo por tipo de geometría
    geom_type = QgsWkbTypes.geometryType(layer.wkbType())

    if geom_type == QgsWkbTypes.PolygonGeometry:
        symbol = QgsFillSymbol.createSimple({
            "color": style.get("fill", "#eeeeee"),
            "outline_color": style.get("stroke", "#111111"),
            "outline_width": str(style.get("stroke_width", 0.26)),
            "style": "solid"
        })
    elif geom_type == QgsWkbTypes.LineGeometry:
        symbol = QgsLineSymbol.createSimple({
            "color": style.get("stroke", "#111111"),
            "width": str(style.get("stroke_width", 0.26))
        })
    elif geom_type == QgsWkbTypes.PointGeometry:
        symbol = QgsMarkerSymbol.createSimple({
            "color": style.get("fill", "#eeeeee"),
            "outline_color": style.get("stroke", "#111111"),
            "size": "3"
        })
    else:
        print(f"⚠️ Geometría no soportada: {name}")
        continue

    layer.setRenderer(QgsSingleSymbolRenderer(symbol))
    project.addMapLayer(layer)

# 💾 Guardar proyecto
project.write(str(OUTPUT_FILE))
print(f"\n✅ Proyecto generado en: {OUTPUT_FILE}")

qgs.exitQgis()
