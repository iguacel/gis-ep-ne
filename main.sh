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
log "[Step 1/5] Running download.sh (download Natural Earth data)"
bash download.sh && success "Download" || error "download"

echo
# Step 2: Process country geometries and export
log "[Step 2/5] Running process-countries.sh (process and export full country geometries)"
bash process-countries.sh && success "Country geometry processing" || error "country geometry processing"

echo
# Step 3: Generate reduced version (key fields only)
log "[Step 3/5] Running redux-countries.sh (generate reduced country files with selected fields)"
bash redux-countries.sh && success "Country redux" || error "country redux"

echo
# Step 4: Process boundary lines and export
log "[Step 4/5] Running process-boundaries-lines.sh (process and export full boundary lines)"
bash process-boundaries-lines.sh && success "Boundary lines processing" || error "boundary lines processing"

echo
# Step 5: Generate reduced boundary lines version (key fields only)
log "[Step 5/5] Running redux-boundaries-lines.sh (generate reduced boundary lines with selected fields)"
bash redux-boundaries-lines.sh && success "Boundary lines redux" || error "boundary lines redux"

echo

echo "${GREEN}${BOLD}🎉 All done. Files updated successfully in OUTPUT/FULL and OUTPUT/REDUX.${RESET}"
