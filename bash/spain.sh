#!/bin/bash
set -e

# Input shapefile (all associated files must be present)
INPUT="/tmp/ne/10m/admin_1_states_provinces/ne_10m_admin_1_states_provinces.shp"

# Output directories
OUTDIR="OUTPUT/BASE/geopackage/10m/"
mkdir -p "$OUTDIR"

# 1. Provinces: Filter sov_a3 = 'ESP', keep only specified fields
ogr2ogr \
  -f GPKG "$OUTDIR/ne_10m_spain-provinces.gpkg" \
  "$INPUT" \
  -where "sov_a3 = 'ESP'" \
  -select "name,region,region_cod,adm1_code,diss_me,iso_3166_2,iso_a2,code_hasc,provnum_ne,postal,woe_name,name_es,name_en,latitude,longitude"

# 2. CCAA: Dissolve by region, sov_a3 = 'ESP', keep only specified fields, output as MULTIPOLYGON
ogr2ogr \
  -f GPKG "$OUTDIR/ne_10m_spain-ccaa.gpkg" \
  "$INPUT" \
  -nlt MULTIPOLYGON \
  -dialect sqlite \
  -sql "SELECT region, region_cod, postal, type, type_en, ST_Union(geometry) AS geometry FROM ne_10m_admin_1_states_provinces WHERE sov_a3 = 'ESP' GROUP BY region, region_cod, postal, type, type_en"

echo "Done. Files written to $OUTDIR"
