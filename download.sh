#!/bin/bash
set -e

SCALES=("10m" "50m" "110m")
LAYERS=("admin_0_countries" "admin_1_states_provinces" "ne_10m_admin_0_boundary_lines_land")
EXTS=("shp" "shx" "dbf" "prj" "cpg")
BASE_URL="https://github.com/nvkelso/natural-earth-vector/raw/refs/heads/master"

max_retries=3

echo "🌍 Downloading Natural Earth shapefiles to /tmp/ne ..."

for scale in "${SCALES[@]}"; do
  for layer in "${LAYERS[@]}"; do
    LAYER_NAME="ne_${scale}_${layer}"
    OUTDIR="/tmp/ne/${scale}/${layer}"
    mkdir -p "$OUTDIR"
    printf "  • %s %s: " "$scale" "$layer"
    success=true
    for ext in "${EXTS[@]}"; do
      URL="${BASE_URL}/${scale}_cultural/${LAYER_NAME}.${ext}"
      OUTFILE="${OUTDIR}/${LAYER_NAME}.${ext}"
      attempt=1
      while true; do
        if curl -sSL -o "$OUTFILE" "$URL"; then
          break
        else
          rm -f "$OUTFILE"
          if (( attempt >= max_retries )); then
            printf "\n    ✗ Failed: %s\n" "$URL"
            success=false
            break
          fi
          attempt=$((attempt+1))
          sleep 2
        fi
      done
    done
    if $success; then
      printf "✅\n"
    else
      printf "⚠️\n"
    fi
  done
done

echo "🎉 All requested Natural Earth shapefiles processed in /tmp/ne" 