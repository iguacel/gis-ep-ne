#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------
# download.sh — Descarga shapefiles de Natural Earth a /tmp/ne
# ----------------------------------------

SCALES=("10m" "50m" "110m")
LAYERS=("admin_0_countries" "admin_1_states_provinces" "admin_0_boundary_lines_land")
EXTS=("shp" "shx" "dbf" "prj" "cpg")
BASE_URL="https://github.com/nvkelso/natural-earth-vector/raw/refs/heads/master"

MAX_RETRIES=3
BASE_TMP_DIR="/tmp/ne"

echo "🌍 Downloading Natural Earth shapefiles to $BASE_TMP_DIR ..."

for scale in "${SCALES[@]}"; do
  for layer in "${LAYERS[@]}"; do
    LAYER_NAME="ne_${scale}_${layer}"
    OUTDIR="${BASE_TMP_DIR}/${scale}/${layer}"
    mkdir -p "$OUTDIR"

    printf "  • %s %s: " "$scale" "$layer"
    success=true

    for ext in "${EXTS[@]}"; do
      URL="${BASE_URL}/${scale}_cultural/${LAYER_NAME}.${ext}"
      OUTFILE="${OUTDIR}/${LAYER_NAME}.${ext}"
      attempt=1

      while true; do
        if curl -fsSL -o "$OUTFILE" "$URL"; then
          break
        else
          rm -f "$OUTFILE"
          if (( attempt >= MAX_RETRIES )); then
            printf "\n    ✗ Failed: %s\n" "$URL"
            success=false
            break
          fi
          attempt=$((attempt + 1))
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

echo "🎉 All requested Natural Earth shapefiles processed in $BASE_TMP_DIR"
