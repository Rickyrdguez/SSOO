#!/bin/bash

VERBOSE=0
DIR="."
EXT=""

# --- FUNCIÓN DE MANEJO DE ERRORES Y DE USO ---

usage() {
  echo "El uso del programa es: $0 [-h | --help] [-v] [-d directorio] [-e extensión]"
  echo "Programa que cuenta los ficheros de un directorio"
  echo
  echo "Con [-h | --help]       consulta la guía del programa"
  echo "Con [-v]                muestra el nombre de cada fichero"
  echo "Con [-d directorio]     Directorio a mirar (por defecto, el actual)"
  echo " Con [-e extensión]     Cuenta los directorios que hay con esa extensión (por defecgto, cuenta todos)"
}

error_usage () {
  echo "$1" >&2
  usage >&2
  exit 1
}

error_exit() {
  echo "$1" >&2
  exit 1
}


# --- PROCESADO DE LA LÍNEA DE COMANDOS ---

while [[ $1 != "" ]]; do
  case "$1" in
    -h | --help )
      usage
      exit 0
    ;;
    -v )
      VERBOSE=1
    ;;
    -d )
      shift
      DIR="$1"
    ;;
    -e )
      shift
      if [[ -z "$1" || "$1" == -* ]]; then
        error_usage "Falta la extensión tras -e"
      fi
      EXT="$1"
    ;;
    -* )
      error_usage "Opción no reconocida"
    ;;
    *)
      error_usage "Argumento no reconocido"
    ;;
  esac
  shift
done

# --- COMPROBAR EL DIRECTORIO (ya con su valor final) ---

if [[ ! -e "$DIR" ]]; then
  error_exit "El directorio '$DIR' no existe"
elif [[ ! -d "$DIR" ]]; then
  error_exit "'$DIR' no es un directorio"
fi

# --- PROGRAMA PRINCIPAL ---

CONTADOR=0

for files in "$DIR"/*; do
  if [[ -f "$files" ]]; then
    if [[ -z "$EXT" || "$files" == *."$EXT" ]]; then
      CONTADOR=$((CONTADOR + 1))
      if [[ $VERBOSE -eq 1 ]]; then
        echo "$files"
      fi
    fi
  fi
done

echo "El directorio cuenta con $CONTADOR elementos"