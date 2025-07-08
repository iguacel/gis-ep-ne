import json
from pathlib import Path
from qgis.core import (
    QgsApplication, QgsProject, QgsVectorLayer,
    QgsCoordinateReferenceSystem, QgsWkbTypes,
    QgsFillSymbol, QgsLineSymbol, QgsMarkerSymbol,
    QgsSingleSymbolRenderer
)

# Inicializar QGIS sin GUI
qgs = QgsApplication([b""], False)
qgs.setPrefixPath("/usr", True)  # ⚠️ Asegúrate de que esto va bien en tu entorno
qgs.initQgis()

BASE_DIR = Path(__file__).resolve().parent.parent
PRESETS_PATH = BASE_DIR / "data" / "presets.json"
ALIASES_PATH = BASE_DIR / "data" / "layer_aliases.json"
OUTPUT_FILE = BASE_DIR / "template.qgs"

with open(PRESETS_PATH, "r") as f:
    config = json.load(f)

with open(ALIASES_PATH, "r") as f:
    aliases = json.load(f)

scale = config["scale"]
layers = config["layers"]
geopkg_base = BASE_DIR / "OUTPUT" / "REDUX" / "geopackage" / scale

project = QgsProject.instance()
project.setCrs(QgsCoordinateReferenceSystem("EPSG:4326"))

for layer_cfg in layers:
    name = layer_cfg["name"]
    alias = layer_cfg["alias"]
    style = layer_cfg.get("style", {})

    if alias not in aliases:
        print(f"❌ Alias no encontrado: {alias}")
        continue

    filename = aliases[alias]["filename"] + ".gpkg"
    mode = aliases[alias]["mode"]
    layer_path = BASE_DIR / "OUTPUT" / mode / "geopackage" / scale / filename

    if not layer_path.exists():
        print(f"❌ No existe: {layer_path}")
        continue

    layer = QgsVectorLayer(str(layer_path), name, "ogr")
    if not layer.isValid():
        print(f"❌ Falló la carga de: {name}")
        continue

    print(f"✅ Añadiendo: {name}")
    geom_type = QgsWkbTypes.geometryType(layer.wkbType())

    fill_color = style.get("fill", "#eeeeee")
    stroke_color = style.get("stroke", "#111111")
    stroke_width = str(style.get("stroke_width", 0.26))
    fill_style = style.get("style", "solid")
    line_style = style.get("line_style", "solid")

    if geom_type == QgsWkbTypes.PolygonGeometry:
        symbol = QgsFillSymbol.createSimple({
            "color": fill_color,
            "outline_color": stroke_color,
            "outline_width": stroke_width,
            "style": fill_style,
            "outline_style": line_style
        })

    elif geom_type == QgsWkbTypes.LineGeometry:
        symbol = QgsLineSymbol.createSimple({
            "color": stroke_color,
            "width": stroke_width,
            "line_style": line_style
        })

    elif geom_type == QgsWkbTypes.PointGeometry:
        symbol = QgsMarkerSymbol.createSimple({
            "color": fill_color,
            "outline_color": stroke_color,
            "outline_style": line_style,
            "size": "3"
        })

    else:
        print(f"⚠️ Geometría no soportada: {name}")
        continue

    layer.setRenderer(QgsSingleSymbolRenderer(symbol))
    project.addMapLayer(layer)

# Guardar proyecto QGIS
project.write(str(OUTPUT_FILE))
print(f"\n✅ Proyecto generado en: {OUTPUT_FILE}")
qgs.exitQgis()
