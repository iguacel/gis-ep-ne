#!/bin/bash
set -e

SCALES=("10m" "50m" "110m")
EXTS=("shp" "shx" "dbf" "prj" "cpg")
BASE_URL="https://github.com/nvkelso/natural-earth-vector/raw/refs/heads/master"
max_retries=3

# Color codes for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Base physical layers to download
LAYERS=("coastline:physical" "land:physical" "ocean:physical" "lakes:physical" "graticules_10:physical/graticules_all" "graticules_30:physical/graticules_all" "wgs84_bounding_box:physical/graticules_all")

echo -e "${BLUE}🌍 Downloading Natural Earth base physical files to /tmp/ne ...${NC}"

for scale in "${SCALES[@]}"; do
  echo -e "${CYAN}📁 Processing scale: ${scale}${NC}"
  
  for layer_info in "${LAYERS[@]}"; do
    layer_name="${layer_info%%:*}"
    category="${layer_info##*:}"
    LAYER_NAME="ne_${scale}_${layer_name}"
    OUTDIR="/tmp/ne/${scale}/${category}/${layer_name}"
    mkdir -p "$OUTDIR"
    
    printf "  ${YELLOW}• %s: ${NC}" "$layer_name"
    success=true
    
    for ext in "${EXTS[@]}"; do
      # Handle graticules directory structure
      if [[ "$category" == *"graticules_all"* ]]; then
        URL="${BASE_URL}/${scale}_physical/ne_${scale}_graticules_all/${LAYER_NAME}.${ext}"
      else
        URL="${BASE_URL}/${scale}_${category}/${LAYER_NAME}.${ext}"
      fi
      OUTFILE="${OUTDIR}/${LAYER_NAME}.${ext}"
      attempt=1
      
      while true; do
        if curl -sSL -o "$OUTFILE" "$URL"; then
          break
        else
          rm -f "$OUTFILE"
          if (( attempt >= max_retries )); then
            printf "\n    ${RED}✗ Failed: %s${NC}\n" "$URL"
            success=false
            break
          fi
          attempt=$((attempt+1))
          sleep 2
        fi
      done
    done
    
    if $success; then
      printf "${GREEN}✅${NC}\n"
    else
      printf "${RED}⚠️${NC}\n"
    fi
  done
done

echo -e "${GREEN}🎉 All base physical files downloaded to /tmp/ne${NC}"

echo -e "${BLUE}🔄 Converting to geopackage format...${NC}"

# Create output directory structure
mkdir -p "./OUTPUT/BASE/geopackage"

for scale in "${SCALES[@]}"; do
  echo -e "${CYAN}📁 Converting scale: ${scale}${NC}"
  
  OUTDIR_GPKG="./OUTPUT/BASE/geopackage/${scale}"
  mkdir -p "$OUTDIR_GPKG"
  
  for layer_info in "${LAYERS[@]}"; do
    layer_name="${layer_info%%:*}"
    category="${layer_info##*:}"
    LAYER_NAME="ne_${scale}_${layer_name}"
    INDIR="/tmp/ne/${scale}/${category}/${layer_name}"
    INFILE_SHAPE="$INDIR/${LAYER_NAME}.shp"
    OUTFILE_GPKG="$OUTDIR_GPKG/${LAYER_NAME}.gpkg"
    
    if [ -f "$INFILE_SHAPE" ]; then
      printf "  ${YELLOW}• Converting %s: ${NC}" "$layer_name"
      
      if ogr2ogr -f GPKG "$OUTFILE_GPKG" "$INFILE_SHAPE" -nln "$LAYER_NAME" 2>/dev/null; then
        printf "${GREEN}✅${NC}\n"
      else
        printf "${RED}❌${NC}\n"
      fi
    else
      printf "  ${RED}• Skipping %s: file not found${NC}\n" "$layer_name"
    fi
  done
done

echo -e "${GREEN}🎉 All base files converted to geopackage format in OUTPUT/BASE/geopackage/${NC}"
