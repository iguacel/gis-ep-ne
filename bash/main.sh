#!/bin/bash

# Colors with tput
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
RESET=$(tput sgr0)

log() {
  echo "${BLUE}${BOLD}🛠 $1...${RESET}"
}

success() {
  echo "${GREEN}✅ $1 completed successfully.${RESET}"
}

error() {
  echo "${RED}❌ Error during: $1${RESET}"
  exit 1
}

# Step 1: Download files
log "[Step 1/8] Running download.sh (download Natural Earth data)"
bash ./bash/download.sh && success "Download" || error "download"

echo
# Step 2: Process country geometries and export
log "[Step 2/8] Running process-countries.sh (process and export full country geometries)"
bash ./bash/process-countries.sh && success "Country geometry processing" || error "country geometry processing"

echo
# Step 3: Generate reduced version (key fields only)
log "[Step 3/8] Running redux-countries.sh (generate reduced country files with selected fields)"
bash ./bash/redux-countries.sh && success "Country redux" || error "country redux"

echo
# Step 4: Process boundary lines and export
log "[Step 4/8] Running process-boundaries-lines.sh (process and export full boundary lines)"
bash ./bash/process-boundaries-lines.sh && success "Boundary lines processing" || error "boundary lines processing"

echo
# Step 5: Generate reduced boundary lines version (key fields only)
log "[Step 5/8] Running redux-boundaries-lines.sh (generate reduced boundary lines with selected fields)"
bash ./bash/redux-boundaries-lines.sh && success "Boundary lines redux" || error "boundary lines redux"

echo
# Step 6: Convert base layers to GeoPackage
log "[Step 6/8] Running base-files.sh (convert Natural Earth base layers to GPKG)"
bash ./bash/base-files.sh && success "Base files conversion" || error "base files"

echo
# Step 7: Generate Spain provinces and CCAA
log "[Step 7/8] Running spain.sh (generate Spanish provinces and regions from Natural Earth)"
bash ./bash/spain.sh && success "Spain layers generated" || error "Spain generation"

echo
# Step 8: Generate layers_summary.json
log "[Step 8/8] Running generate-layers.sh (create JSON index of layers)"
bash ./bash/generate-layers.sh && success "Layer summary" || error "layer summary"

echo
echo "${GREEN}${BOLD}🎉 All done. Files updated successfully in OUTPUT and data folders.${RESET}"
