#!/bin/bash
# source ./init.sh

# Añadir la carpeta bash/ al PATH solo en esta sesión
export PATH="$PWD/bash:$PATH"

echo "✅ PATH actualizado temporalmente. Ahora puedes usar scripts como:"
echo "   • process-countries.sh"
echo "   • download.sh"
echo "   • base-files.sh"
echo
echo "ℹ️ Esto solo afecta a esta terminal. Si abres una nueva, vuelve a ejecutar ./init.sh"
