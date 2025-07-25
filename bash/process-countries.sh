#!/bin/bash
set -e
set -x

SCALES=("10m" "50m" "110m")

# Function to get all columns from a layer (excluding geometry)
get_all_columns() {
  local gpkg_file="$1"
  local layer_name="$2"
  
  # Get column list from ogrinfo, only actual columns with type specifications
  ogrinfo -so "$gpkg_file" "$layer_name" | \
    awk '/^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*: [A-Za-z]+ \(/ && !/^[[:space:]]*Geometry:/ {gsub(/:/, ""); gsub(/^[[:space:]]+/, ""); print $1}' | \
    grep -v "^$" | \
    tr '\n' ',' | \
    sed 's/,$//'
}

# Function to generate MIN() SQL for all columns
generate_min_sql() {
  local gpkg_file="$1"
  local layer_name="$2"
  local table_alias="$3"
  
  # Get all columns
  local columns=$(get_all_columns "$gpkg_file" "$layer_name")
  
  # Convert to MIN() format - use awk to handle the comma properly
  echo "$columns" | tr ',' '\n' | \
    awk -v table="$table_alias" '
      BEGIN { first = 1 }
      {
        if (first) {
          printf "  MIN(%s.%s) AS %s", table, $1, $1
          first = 0
        } else {
          printf ",\n  MIN(%s.%s) AS %s", table, $1, $1
        }
      }
    '
}

# Function to generate direct column selection SQL
generate_select_sql() {
  local gpkg_file="$1"
  local layer_name="$2"
  local table_alias="$3"
  
  # Get all columns
  local columns=$(get_all_columns "$gpkg_file" "$layer_name")
  
  # Convert to direct selection format - use awk to handle the comma properly
  echo "$columns" | tr ',' '\n' | \
    awk -v table="$table_alias" '
      BEGIN { first = 1 }
      {
        if (first) {
          printf "  %s.%s", table, $1
          first = 0
        } else {
          printf ",\n  %s.%s", table, $1
        }
      }
    '
}

# Function to get all non-geometry columns from a layer
get_non_geom_columns() {
  local gpkg_file="$1"
  local layer_name="$2"
  # Get column list from ogrinfo, only actual columns with type specifications, excluding geometry
  ogrinfo -so "$gpkg_file" "$layer_name" | \
    awk '/^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*: [A-Za-z]+ \(/ && !/^[[:space:]]*Geometry:/ && !/GEOMETRY/ {gsub(/:/, ""); gsub(/^[[:space:]]+/, ""); print $1}' | \
    grep -v "^$" | \
    tr '\n' ',' | \
    sed 's/,$//'
}

# === Extract Crimea geometry from 10m admin-1 provinces once ===
CRIMEA_GEOM_GPKG="/tmp/ne/crimea_geom.gpkg"
CRIMEA_GEOM_LAYER="crimea_geom"
CRIMEA_BBOX_WKT="/tmp/ne/crimea_bbox.wkt"
if [ ! -f "$CRIMEA_GEOM_GPKG" ]; then
  echo "[STEP] Extracting Crimea geometry from 10m admin-1 provinces..."
  ogr2ogr -f GPKG -a_srs EPSG:4326 -nln $CRIMEA_GEOM_LAYER "$CRIMEA_GEOM_GPKG" \
    /tmp/ne/10m/admin_1_states_provinces/ne_10m_admin_1_states_provinces.shp \
    -dialect sqlite -sql "SELECT * FROM ne_10m_admin_1_states_provinces WHERE adm1_code IN ('RUS-5482', 'RUS-283')"
  ogrinfo -al -so "$CRIMEA_GEOM_GPKG" $CRIMEA_GEOM_LAYER > /dev/null
fi
# Extract Crimea bounding box as WKT POLYGON (for 50m/110m)
echo "[STEP] Extracting Crimea bounding box as WKT..."
BBOX=$(ogrinfo -al -so "$CRIMEA_GEOM_GPKG" $CRIMEA_GEOM_LAYER | awk '/Extent: /{gsub(/[(),]/,""); print $2, $3, $5, $6}')
read MINX MINY MAXX MAXY <<< $BBOX
if (( $(echo "$MINX < 30 || $MINX > 40 || $MAXX < 30 || $MAXX > 40 || $MINY < 40 || $MINY > 50 || $MAXY < 40 || $MAXY > 50 || $MINX >= $MAXX || $MINY >= $MAXY" | bc -l) )); then
  echo "[ERROR] Crimea bbox coordinates look wrong or swapped: MINX=$MINX MINY=$MINY MAXX=$MAXX MAXY=$MAXY" >&2
  exit 1
fi
echo "POLYGON(($MINX $MINY, $MINX $MAXY, $MAXX $MAXY, $MAXX $MINY, $MINX $MINY))" > "$CRIMEA_BBOX_WKT"

CRIMEA_BBOX_GEOJSON="/tmp/ne/crimea_bbox.geojson"
WKT_BBOX=$(sed -E 's/^POLYGON\(\((.*)\)\)$/\1/' "$CRIMEA_BBOX_WKT")
IFS=',' read -r P1 P2 P3 P4 P5 <<< "$WKT_BBOX"
read MINX MINY <<< $(echo $P1)
read _ MAXY <<< $(echo $P2)
read MAXX _ <<< $(echo $P3)
read _ MINY2 <<< $(echo $P4)
if [[ "$MINY" != "$MINY2" ]]; then
  echo "[ERROR] BBOX Y values do not close: MINY=$MINY MINY2=$MINY2" >&2
  exit 1
fi
if [[ -z "$MINX" || -z "$MINY" || -z "$MAXX" || -z "$MAXY" ]]; then
  echo "[ERROR] One or more bbox variables are empty: MINX='$MINX' MINY='$MINY' MAXX='$MAXX' MAXY='$MAXY'" >&2
  echo "[ERROR] Crimea bbox WKT content: $(cat $CRIMEA_BBOX_WKT)" >&2
  exit 1
fi
cat > "$CRIMEA_BBOX_GEOJSON" <<EOF
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [$MINX, $MINY],
          [$MINX, $MAXY],
          [$MAXX, $MAXY],
          [$MAXX, $MINY],
          [$MINX, $MINY]
        ]]
      },
      "properties": {}
    }
  ]
}
EOF
if ! jq empty "$CRIMEA_BBOX_GEOJSON"; then
  echo "[ERROR] Crimea bbox GeoJSON is invalid JSON!" >&2
  cat "$CRIMEA_BBOX_GEOJSON" >&2
  exit 1
fi

for scale in 10m 50m 110m; do
  mkdir -p ./OUTPUT/FULL/tmp/$scale/
done

for scale in "${SCALES[@]}"; do
  echo "[STEP] Processing $scale..."
  INPUT_DIR="/tmp/ne/${scale}/admin_0_countries"
  ADMIN1_DIR="/tmp/ne/${scale}/admin_1_states_provinces"
  INPUT_SHAPE="$INPUT_DIR/ne_${scale}_admin_0_countries.shp"
  ADMIN1_SHAPE="$ADMIN1_DIR/ne_${scale}_admin_1_states_provinces.shp"
  OUTDIR_GPKG="./OUTPUT/FULL/geopackage/${scale}"
  OUTDIR_GEOJSON="./OUTPUT/FULL/geojson/${scale}"
  OUTDIR_SHP="./OUTPUT/FULL/shapefile/${scale}"
  TMPDIR="./OUTPUT/FULL/tmp/${scale}"
  mkdir -p "$OUTDIR_GPKG" "$OUTDIR_GEOJSON" "$OUTDIR_SHP" "$TMPDIR"

  if [ "$scale" = "110m" ]; then
    OGR_SRS_FLAGS="-a_srs EPSG:4326"
    OGR_SKIPFAIL="-skipfailures"
  else
    OGR_SRS_FLAGS="-t_srs EPSG:4326"
    OGR_SKIPFAIL=""
  fi

  INPUT_GPKG="$TMPDIR/ne_${scale}_admin_0_countries.gpkg"
  ADMIN1_GPKG="$TMPDIR/ne_${scale}_admin_1_states_provinces.gpkg"
  ogr2ogr -f GPKG -nlt MULTIPOLYGON $OGR_SRS_FLAGS "$INPUT_GPKG" "$INPUT_SHAPE"
  ogr2ogr -f GPKG -nlt MULTIPOLYGON $OGR_SRS_FLAGS "$ADMIN1_GPKG" "$ADMIN1_SHAPE"
  OUTBASE="ne_${scale}_admin_0_countries_el_pais"

  # 1. Merge Western Sahara and Morocco
  ogr2ogr -f GPKG -nlt MULTIPOLYGON $OGR_SRS_FLAGS "$TMPDIR/temp_morocco.gpkg" "$INPUT_GPKG" -nln temp_morocco -dialect sqlite -sql "
SELECT * FROM ne_${scale}_admin_0_countries WHERE NAME IN ('Morocco', 'W. Sahara');
"
  
  # Generate MIN() SQL for Morocco merge
  MOROCCO_MIN_SQL=$(generate_min_sql "$TMPDIR/temp_morocco.gpkg" "temp_morocco" "temp_morocco")
  
  ogr2ogr -f GPKG -nlt MULTIPOLYGON $OGR_SRS_FLAGS "$TMPDIR/fused_morocco.gpkg" "$TMPDIR/temp_morocco.gpkg" -nln fused_morocco -dialect sqlite -sql "
SELECT 
  'Morocco' AS NAME,
  'Morocco' AS ADMIN,
$MOROCCO_MIN_SQL,
  ST_Union(geom) AS geom 
FROM temp_morocco;
"

  # 2. Merge Baikonur and Kazakhstan
  ogr2ogr -f GPKG -nlt MULTIPOLYGON $OGR_SRS_FLAGS "$TMPDIR/temp_kazakhstan.gpkg" "$INPUT_GPKG" -nln temp_kazakhstan -dialect sqlite -sql "
SELECT * FROM ne_${scale}_admin_0_countries WHERE NAME IN ('Kazakhstan', 'Baikonur');
"
  # Merge, keeping Kazakhstan's properties (except geometry)
  KAZAKHSTAN_NON_GEOM_COLS=$(get_non_geom_columns "$TMPDIR/temp_kazakhstan.gpkg" "temp_kazakhstan")
  GEOM_FIELD=$(ogrinfo -so "$TMPDIR/temp_kazakhstan.gpkg" "temp_kazakhstan" 2>/dev/null | grep -E 'Geometry Column' | awk -F= '{print $2}' | xargs)
  if [ -z "$GEOM_FIELD" ]; then
    GEOM_FIELD="GEOMETRY"
  fi
  ogr2ogr -f GPKG -nlt MULTIPOLYGON $OGR_SRS_FLAGS "$TMPDIR/fused_kazakhstan.gpkg" "$TMPDIR/temp_kazakhstan.gpkg" -nln fused_kazakhstan -dialect sqlite -sql "
SELECT 
  $KAZAKHSTAN_NON_GEOM_COLS,
  (SELECT ST_Union($GEOM_FIELD) FROM temp_kazakhstan) AS $GEOM_FIELD
FROM temp_kazakhstan
WHERE NAME = 'Kazakhstan';
"

  # 3. Extract Crimea
  mkdir -p "$TMPDIR"
  if [ "$scale" = "10m" ]; then
    ogr2ogr -f GPKG -nlt MULTIPOLYGON $OGR_SRS_FLAGS "$TMPDIR/temp_crimea.gpkg" "$ADMIN1_GPKG" -nln crimea -dialect sqlite -sql "
SELECT * FROM ne_${scale}_admin_1_states_provinces WHERE adm1_code IN ('RUS-5482', 'RUS-283');
"
    ogrinfo -al -so "$TMPDIR/temp_crimea.gpkg" crimea > /dev/null
  else
    ogr2ogr -f GPKG -nln temp_crimea_bbox $OGR_SRS_FLAGS -makevalid "$TMPDIR/temp_crimea.gpkg" "$CRIMEA_BBOX_GEOJSON"
    ogrinfo -al -so "$TMPDIR/temp_crimea.gpkg" temp_crimea_bbox > /dev/null
  fi

  # 4. Create GPKG with Ukraine + Crimea
  ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/ukraine_and_crimea.gpkg" "$INPUT_GPKG" -nln ukraine -dialect sqlite -sql "
SELECT * FROM ne_${scale}_admin_0_countries WHERE NAME = 'Ukraine';
"
  
  # Generate direct selection SQL for Ukraine
  UKRAINE_SELECT_SQL=$(generate_select_sql "$TMPDIR/ukraine_and_crimea.gpkg" "ukraine" "ukraine")
  
  if [ "$scale" = "10m" ]; then
    ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/ukraine_and_crimea.gpkg" "$TMPDIR/temp_crimea.gpkg" -update -nln crimea
    ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/ukraine_plus_crimea.gpkg" "$TMPDIR/ukraine_and_crimea.gpkg" -nln ukraine_plus_crimea -dialect sqlite -sql "
SELECT
$UKRAINE_SELECT_SQL,
  ST_Union(geom, (SELECT ST_Union(geom) FROM crimea)) AS geom
FROM ukraine;
"
    if [ ! -f "$TMPDIR/ukraine_plus_crimea.gpkg" ]; then
      echo "[ERROR] Failed to create $TMPDIR/ukraine_plus_crimea.gpkg for $scale" >&2
      echo "[ERROR] Available layers in $TMPDIR/ukraine_and_crimea.gpkg:" >&2
      ogrinfo "$TMPDIR/ukraine_and_crimea.gpkg"
      exit 1
    fi
  else
    ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid -t_srs EPSG:4326 "$TMPDIR/ukraine_and_crimea.gpkg" "$INPUT_GPKG" -nln russia -dialect sqlite -sql "
SELECT * FROM ne_${scale}_admin_0_countries WHERE NAME = 'Russia';
" -update
    ogr2ogr -f GPKG -nlt POLYGON -makevalid -t_srs EPSG:4326 "$TMPDIR/ukraine_and_crimea.gpkg" "$TMPDIR/temp_crimea.gpkg" -nln temp_crimea_bbox -update
    ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/ukraine_plus_crimea.gpkg" "$TMPDIR/ukraine_and_crimea.gpkg" -nln ukraine_plus_crimea -dialect sqlite -sql "
WITH bbox AS (SELECT geom FROM temp_crimea_bbox),
     russia_geom AS (SELECT geom FROM russia),
     crimea_piece AS (SELECT ST_Union(ST_Intersection(russia_geom.geom, bbox.geom)) AS geom FROM russia_geom, bbox)
SELECT
$UKRAINE_SELECT_SQL,
  ST_Union(geom, (SELECT geom FROM crimea_piece)) AS geom
FROM ukraine;
"
  fi

  # 5. Remove modified countries
  ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/temp_rest.gpkg" "$INPUT_GPKG" -nln temp_rest -dialect sqlite -sql "
SELECT * FROM ne_${scale}_admin_0_countries
WHERE NAME NOT IN ('Morocco', 'W. Sahara', 'Kazakhstan', 'Baikonur', 'Russia', 'Ukraine');
"

  # 6. Remove Crimea from Russia
  ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/russia_and_crimea.gpkg" "$INPUT_GPKG" -nln russia -dialect sqlite -sql "
SELECT * FROM ne_${scale}_admin_0_countries WHERE NAME = 'Russia';
"
  
  # Generate direct selection SQL for Russia
  RUSSIA_SELECT_SQL=$(generate_select_sql "$TMPDIR/russia_and_crimea.gpkg" "russia" "russia")
  
  if [ "$scale" = "10m" ]; then
    ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/russia_and_crimea.gpkg" "$TMPDIR/temp_crimea.gpkg" -update -nln crimea
    ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/russia_crimea_removed.gpkg" "$TMPDIR/russia_and_crimea.gpkg" -nln russia_clean -dialect sqlite -sql "
SELECT
$RUSSIA_SELECT_SQL,
  ST_Difference(geom, (SELECT ST_Union(geom) FROM crimea)) AS geom
FROM russia;
"
  else
    ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/russia_and_crimea.gpkg" "$TMPDIR/temp_crimea.gpkg" -update -nln temp_crimea_bbox
    ogr2ogr -f GPKG -nlt MULTIPOLYGON -makevalid $OGR_SRS_FLAGS "$TMPDIR/russia_crimea_removed.gpkg" "$TMPDIR/russia_and_crimea.gpkg" -nln russia_clean -dialect sqlite -sql "
SELECT
$RUSSIA_SELECT_SQL,
  ST_Difference(geom, (SELECT ST_Union(geom) FROM temp_crimea_bbox)) AS geom
FROM russia;
"
  fi

  # 7. Merge all into final GPKG
  FINAL_GPKG="$OUTDIR_GPKG/${OUTBASE}.gpkg"
  ogrmerge.py \
    -f GPKG \
    -single \
    -nln ${OUTBASE} \
    -o "$FINAL_GPKG" \
    -overwrite_ds \
    $OGR_SKIPFAIL \
    "$TMPDIR/temp_rest.gpkg" \
    "$TMPDIR/russia_crimea_removed.gpkg" \
    "$TMPDIR/fused_morocco.gpkg" \
    "$TMPDIR/fused_kazakhstan.gpkg" \
    "$TMPDIR/ukraine_plus_crimea.gpkg"

  # 8. Export to GeoJSON
  ogr2ogr -f GeoJSON -t_srs EPSG:4326 $OGR_SKIPFAIL "$OUTDIR_GEOJSON/${OUTBASE}.geojson" "$FINAL_GPKG" ${OUTBASE}

  # 9. Export to Shapefile
  ogr2ogr -f "ESRI Shapefile" -lco ENCODING=UTF-8 -nlt MULTIPOLYGON -t_srs EPSG:4326 $OGR_SKIPFAIL "$OUTDIR_SHP/${OUTBASE}_shp" "$FINAL_GPKG" ${OUTBASE}

  echo "[DONE] $scale processed: $FINAL_GPKG"
done

echo "[ALL DONE] All scales processed successfully."