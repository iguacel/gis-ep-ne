#!/bin/bash
# Genera un JSON con los nombres de capas por escala y modo en OUTPUT/*/geopackage/*

OUTPUT_DIR="./OUTPUT"
RESULT="data/layers_summary.json"

echo "📦 Generando $RESULT..."

mkdir -p "$(dirname "$RESULT")"

echo "{" > "$RESULT"

modes=(BASE FULL REDUX)
scales=(10m 50m 110m)

for i in "${!modes[@]}"; do
  mode="${modes[$i]}"
  echo "  \"$mode\": {" >> "$RESULT"

  for j in "${!scales[@]}"; do
    scale="${scales[$j]}"
    path="$OUTPUT_DIR/$mode/geopackage/$scale"
    echo -n "    \"$scale\": [" >> "$RESULT"

    files=()
    if [ -d "$path" ]; then
      while IFS= read -r -d '' file; do
        base=$(basename "$file" .gpkg)
        files+=("\"$base\"")
      done < <(find "$path" -maxdepth 1 -name "*.gpkg" -print0)
    fi

    IFS=,; echo -n "${files[*]}" >> "$RESULT"; unset IFS

    if [ "$j" -lt $((${#scales[@]} - 1)) ]; then
      echo "]," >> "$RESULT"
    else
      echo "]" >> "$RESULT"
    fi
  done

  if [ "$i" -lt $((${#modes[@]} - 1)) ]; then
    echo "  }," >> "$RESULT"
  else
    echo "  }" >> "$RESULT"
  fi
done

echo "}" >> "$RESULT"

echo "✅ Resumen guardado correctamente en $RESULT"
