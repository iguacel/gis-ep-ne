#!/bin/bash
set -e

SCALES=("10m" "50m" "110m")
# NE_IDs to remove per country
MOROCCO_ID=1746705351
UKRAINE_ID=1746708787
BAIKONUR_ID=1746708621 # Only in 10m

for scale in "${SCALES[@]}"; do
  INDIR="/tmp/ne/${scale}/admin_0_boundary_lines_land"
  INBASE="ne_${scale}_admin_0_boundary_lines_land"
  INFILE_SHAPE="$INDIR/${INBASE}.shp"

  OUTDIR_GPKG="./OUTPUT/FULL/geopackage/${scale}"
  OUTDIR_GEOJSON="./OUTPUT/FULL/geojson/${scale}"
  OUTDIR_SHP="./OUTPUT/FULL/shapefile/${scale}"
  mkdir -p "$OUTDIR_GPKG" "$OUTDIR_GEOJSON" "$OUTDIR_SHP"
  OUTBASE="${INBASE}_el_pais"

  # Determine correct field name (NE_ID or ne_id)
  if ogrinfo -so "$INFILE_SHAPE" "$INBASE" 2>/dev/null | grep -q "NE_ID"; then
    ID_FIELD="NE_ID"
  elif ogrinfo -so "$INFILE_SHAPE" "$INBASE" 2>/dev/null | grep -q "ne_id"; then
    ID_FIELD="ne_id"
  else
    echo "[WARN] No NE_ID/ne_id field found for $scale, skipping."
    continue
  fi

  # Compose SQL filter
  FILTER_IDS="$MOROCCO_ID,$UKRAINE_ID"
  if [ "$scale" = "10m" ]; then
    FILTER_IDS="$FILTER_IDS,$BAIKONUR_ID"
  fi

  # GPKG
  OUTFILE_GPKG="$OUTDIR_GPKG/${OUTBASE}.gpkg"
  ogr2ogr -f GPKG "$OUTFILE_GPKG" "$INFILE_SHAPE" \
    -nln "$OUTBASE" \
    -dialect sqlite \
    -sql "SELECT * FROM $INBASE WHERE $ID_FIELD NOT IN ($FILTER_IDS)"

  # GeoJSON
  OUTFILE_GEOJSON="$OUTDIR_GEOJSON/${OUTBASE}.geojson"
  ogr2ogr -f GeoJSON "$OUTFILE_GEOJSON" "$OUTFILE_GPKG" "$OUTBASE"

  # Shapefile
  OUTDIR_SHP_FINAL="$OUTDIR_SHP/${OUTBASE}_shp"
  ogr2ogr -f "ESRI Shapefile" "$OUTDIR_SHP_FINAL" "$OUTFILE_GPKG" "$OUTBASE"

  echo "[DONE] $scale boundary lines processed."
done

echo "[ALL DONE] All boundary lines processed and saved in OUTPUT/FULL/{format}/{scale}/"
