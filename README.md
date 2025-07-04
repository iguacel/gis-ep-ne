![World Natural Earth II](images/World%20Natural%20Earth%20II.jpg)
<https://github.com/iguacel/gis-gdal-ne>

# EP Natural Earth

Procesamiento de archivos de Natural Earth con gdal

Carpeta en el drive
Drive/My Drive/EP NATURAL EARTH

Doc en google docs
<https://docs.google.com/document/d/1dFQIHUtnD8-tW3HSFGtwXeoIz9d_YFKppmUd7bNqGfc/edit?tab=t.0>

```
https://drive.google.com/open?id=1sWIhB5gMuiVcLAZEeVnxMiP8AcKNuQ7g&usp=drive_fs
```

Automatiza la descarga y modificación de capas de países del repositorio [Natural Earth](https://www.naturalearthdata.com/). Los scripts utilizados preservan los atributos originales y exportan los resultados en distintos niveles de detalle: 1:10m, 1:50m y 1:110m.

## Cambios en geometría

### Countries

#### 🟢 Crimea es Ucrania

- Se fusiona la geometría de Crimea (`ISO_A3 = 'RUS'` y `NAME = 'Crimea'`) con la de Ucrania (`ISO_A3 = 'UKR'`).

- Se elimina la parte correspondiente a Crimea de la geometría de Rusia.
  
#### 🟢 Marruecos + Sáhara Occidental

- Se fusiona la geometría de Marruecos (`ISO_A3 = 'MAR'`) con la del Sáhara Occidental (`ISO_A3 = 'ESH'`).

#### 🟢 Kazajistán + Baikonur

- Se fusiona la geometría del área de Baikonur (ciudad administrada por Rusia bajo arrendamiento) con la de Kazajistán (`ISO_A3 = 'KAZ'`).

### Boundaries lines

- Se eliminan las fronteras que aparecen detalladas arriba.

## 📁 Estructura de la carpeta OUTPUT

```
OUTPUT/
├── 📁 FULL/   # Archivos completos, con todos los atributos originales y geometrías procesadas
│   ├── geojson/      # Versiones GeoJSON por escala
│   ├── geopackage/   # Versiones GeoPackage por escala
│   ├── shapefile/    # Versiones Shapefile por escala
│   └── tmp/          # Archivos temporales intermedios
├── 📁 REDUX/  # Archivos reducidos, solo con los campos clave para países y fronteras
│   ├── geojson/      # Versiones GeoJSON reducidas
│   ├── geopackage/   # Versiones GeoPackage reducidas
│   └── shapefile/    # Versiones Shapefile reducidas
└── 📁 BASE/   # Capas base físicas (costa, océanos, graticules, etc.) en geopackage
    └── geopackage/   
```

- **FULL/**: Contiene los archivos completos, con todos los atributos y geometrías procesadas para cada escala (10m, 50m, 110m). Incluye subcarpetas para cada formato y archivos temporales.
- **REDUX/**: Contiene versiones simplificadas de los archivos, solo con los campos clave necesarios para visualización o análisis básico.
- **BASE/**: Incluye capas físicas base (costa, océanos, graticules, etc.) descargadas y convertidas a GeoPackage.

## Versión *REDUX*

Esta versión *redux* mantiene solo los campos clave para representar países y fronteras.

#### 🗺 `admin_0_countries` – Campos mantenidos

| Campo     | Descripción                                                              |
| --------- | ------------------------------------------------------------------------ |
| `ADMIN`   | Nombre oficial del país en inglés.                                       |
| `ISO_A2`  | Código ISO Alpha-2 (p. ej. "ES" para España).                            |
| `ISO_A3`  | Código ISO Alpha-3 del país (estándar internacional).                    |
| `UN_A3`   | Código numérico de 3 cifras de Naciones Unidas para el país.             |
| `NAME_EN` | Nombre del país en inglés (para etiquetas o propósitos internacionales). |
| `NAME_ES` | Nombre del país en español (útil para mapas en español).                 |
| `LABEL_X` | Coordenada X del punto ideal para etiquetar el país.                     |
| `LABEL_Y` | Coordenada Y del punto ideal para etiquetar el país.                     |

> 🔎 Se han eliminado más de 50 campos redundantes como nombres en múltiples idiomas, indicadores económicos, códigos alternativos, banderas, valores de exportación/importación, etc.

#### 🗺 `admin_0_boundary_lines_land` – Campos mantenidos

| Campo        | Descripción                                                                                                   |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| `NE_ID`      | ID único y estable de la línea de frontera. Permite trazabilidad entre resoluciones.                          |
| `FEATURECLA` | Clasificación de la frontera (p. ej. `"International boundary"`, `"Disputed boundary"`, `"Line of control"`). |
| `SCALERANK`  | Rango de importancia del límite (útil para simplificar en escalas pequeñas).                                  |

> 🔎 Se han eliminado campos vacíos o irrelevantes como `NAME`, `BRK_A3`, `FCLASS_*`, `MIN_ZOOM`, entre otros.

## Formatos de salida

Los shapefiles modificados se exportan en tres niveles de resolución:

- `ne_10m_admin_0_countries_fixed.*`
- `ne_50m_admin_0_countries_fixed.*`
- `ne_110m_admin_0_countries_fixed.*`

Además, se exportan versiones en GeoPackage (`.gpkg`), GeoJSON (`.geojson`) y TopoJSON (`.topojson`), compatibles con entornos web y GIS.

## Requisitos

- GDAL >= 3.0 (testeado en GDAL 3.11.0 "Eganville", released 2025/05/06)
- `curl`, `unzip`, `ogr2ogr`, `topojson`

## Uso

```bash
./main.sh
```

Guarda archivos temporales en:

```
tmp/ne
```

```
OUTPUT/FULL/tmp
```

Steps

```bash
./download.sh # Descarga y descomprime los shapefiles
./process-countries.sh # Aplica cambios geométricos
./redux-countries.sh # Elimina propiedades y guarda en la carpeta redux
./process-boundaries-lines.sh # Borra fronteras
./redux-boundaries-lines.sh # Elimina propiedades y guarda en la carpeta redux
```

## Base files

```bash
./base-files.sh
```

Este script descarga y convierte a geopackage algunas capas básicas. No se ejecuta desde main.sh
