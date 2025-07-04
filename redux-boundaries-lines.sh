#!/bin/bash
set -e

FIELDS="FEATURECLA,SCALERANK"
SCALES=("10m" "50m" "110m")
FORMATS=("geopackage" "geojson" "shapefile")

for scale in "${SCALES[@]}"; do
  for format in "${FORMATS[@]}"; do
    INDIR="./OUTPUT/FULL/${format}/${scale}"
    OUTDIR="./OUTPUT/REDUX/${format}/${scale}"
    mkdir -p "$OUTDIR"
    INBASE="ne_${scale}_admin_0_boundary_lines_land_el_pais"
    OUTBASE="${INBASE}_redux"

    if [ "$format" = "geopackage" ]; then
      INFILE="$INDIR/${INBASE}.gpkg"
      OUTFILE="$OUTDIR/${OUTBASE}.gpkg"
      if [ -f "$INFILE" ]; then
        FIELD_NAME=$(ogrinfo -so "$INFILE" "$INBASE" 2>/dev/null | grep -Eo 'NE_ID|ne_id' | head -1)
        if [ "$FIELD_NAME" = "ne_id" ]; then
          ogr2ogr -f GPKG "$OUTFILE" "$INFILE" "$INBASE" \
            -dialect sqlite \
            -sql "SELECT CAST(ne_id AS INTEGER) AS NE_ID, $FIELDS FROM $INBASE"
        elif [ "$FIELD_NAME" = "NE_ID" ]; then
          ogr2ogr -f GPKG -select NE_ID,$FIELDS "$OUTFILE" "$INFILE" "$INBASE"
        fi
      fi
    elif [ "$format" = "geojson" ]; then
      INFILE="$INDIR/${INBASE}.geojson"
      OUTFILE="$OUTDIR/${OUTBASE}.geojson"
      if [ -f "$INFILE" ]; then
        FIELD_NAME=$(ogrinfo -so "$INFILE" "$INBASE" 2>/dev/null | grep -Eo 'NE_ID|ne_id' | head -1)
        if [ "$FIELD_NAME" = "ne_id" ]; then
          ogr2ogr -f GeoJSON "$OUTFILE" "$INFILE" -dialect sqlite \
            -sql "SELECT CAST(ne_id AS INTEGER) AS NE_ID, $FIELDS FROM \"$INBASE\""
        elif [ "$FIELD_NAME" = "NE_ID" ]; then
          ogr2ogr -f GeoJSON -select NE_ID,$FIELDS "$OUTFILE" "$INFILE"
        fi
      fi
    elif [ "$format" = "shapefile" ]; then
      INDIR_SHAPE="$INDIR/${INBASE}_shp"
      OUTDIR_SHAPE="$OUTDIR/${OUTBASE}_shp"
      if [ -d "$INDIR_SHAPE" ]; then
        FIELD_NAME=$(ogrinfo -so "$INDIR_SHAPE" "$INBASE" 2>/dev/null | grep -Eo 'NE_ID|ne_id' | head -1)
        if [ "$FIELD_NAME" = "ne_id" ]; then
          ogr2ogr -f "ESRI Shapefile" "$OUTDIR_SHAPE" "$INDIR_SHAPE" \
            -dialect sqlite \
            -sql "SELECT CAST(ne_id AS INTEGER) AS NE_ID, $FIELDS FROM $INBASE"
        elif [ "$FIELD_NAME" = "NE_ID" ]; then
          ogr2ogr -f "ESRI Shapefile" -select NE_ID,$FIELDS "$OUTDIR_SHAPE" "$INDIR_SHAPE"
        fi
      fi
    fi
  done
  echo "[DONE] $scale redux boundary lines export complete."
done

echo "[ALL DONE] All boundary lines exported to OUTPUT/REDUX."
