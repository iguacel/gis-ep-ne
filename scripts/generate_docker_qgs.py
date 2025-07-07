import json
from pathlib import Path
from qgis.core import (
    QgsApplication, QgsProject, QgsVectorLayer,
    QgsCoordinateReferenceSystem, QgsWkbTypes,
    QgsFillSymbol, QgsLineSymbol, QgsMarkerSymbol,
    QgsSingleSymbolRenderer
)

# Inicializar QGIS sin GUI (versión Docker/Linux)
qgs = QgsApplication([b""], False)
qgs.setPrefixPath("/usr", True)
qgs.initQgis()

# Ruta base (dentro del contenedor)
BASE_DIR = Path(__file__).resolve().parent.parent
PRESETS_PATH = BASE_DIR / "presets.json"
OUTPUT_FILE = BASE_DIR / "template.qgs"

# Leer configuración desde presets.json
with open(PRESETS_PATH, "r") as f:
    config = json.load(f)

scale = config["scale"]
layers = config["layers"]
geopkg_base = BASE_DIR / "OUTPUT" / "REDUX" / "geopackage" / scale

# Crear proyecto QGIS
project = QgsProject.instance()
project.setCrs(QgsCoordinateReferenceSystem("EPSG:4326"))

# Cargar cada capa definida
for layer_cfg in layers:
    name = layer_cfg["name"]
    filename = layer_cfg["filename"]
    style = layer_cfg.get("style", {})

    layer_path = geopkg_base / filename
    if not layer_path.exists():
        print(f"❌ No existe: {layer_path}")
        continue

    layer = QgsVectorLayer(str(layer_path), name, "ogr")
    if not layer.isValid():
        print(f"❌ Falló la carga de: {name}")
        continue

    print(f"✅ Añadiendo: {name}")

    # Detectar tipo de geometría y aplicar estilo
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

# Guardar el proyecto .qgs en el directorio raíz
project.write(str(OUTPUT_FILE))
print(f"\n✅ Proyecto generado en: {OUTPUT_FILE}")

qgs.exitQgis()
