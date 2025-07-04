#!/bin/bash
set -e

# Fields to keep
FIELDS="ADMIN,ISO_A2,ISO_A3,UN_A3,NAME_EN,NAME_ES,LABEL_X,LABEL_Y"
SCALES=("10m" "50m" "110m")
FORMATS=("geopackage" "geojson" "shapefile")

for scale in "${SCALES[@]}"; do
  for format in "${FORMATS[@]}"; do
    INDIR="./OUTPUT/FULL/${format}/${scale}"
    OUTDIR="./OUTPUT/REDUX/${format}/${scale}"
    mkdir -p "$OUTDIR"
    INBASE="ne_${scale}_admin_0_countries_el_pais"
    OUTBASE="${INBASE}_redux"

    if [ "$format" = "geopackage" ]; then
      INFILE="$INDIR/${INBASE}.gpkg"
      OUTFILE="$OUTDIR/${OUTBASE}.gpkg"
      if [ -f "$INFILE" ]; then
        ogr2ogr -f GPKG -select $FIELDS "$OUTFILE" "$INFILE" "$INBASE"
      fi
    elif [ "$format" = "geojson" ]; then
      INFILE="$INDIR/${INBASE}.geojson"
      OUTFILE="$OUTDIR/${OUTBASE}.geojson"
      if [ -f "$INFILE" ]; then
        ogr2ogr -f GeoJSON -select $FIELDS "$OUTFILE" "$INFILE"
      fi
    elif [ "$format" = "shapefile" ]; then
      INDIR_SHAPE="$INDIR/${INBASE}_shp"
      OUTDIR_SHAPE="$OUTDIR/${OUTBASE}_shp"
      if [ -d "$INDIR_SHAPE" ]; then
        ogr2ogr -f "ESRI Shapefile" -select $FIELDS "$OUTDIR_SHAPE" "$INDIR_SHAPE"
      fi
    fi
  done
  echo "[DONE] $scale redux export complete."
done

echo "[ALL DONE] All scales exported to OUTPUT/REDUX." 