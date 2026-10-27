#!/bin/bash

# --- DECLARACION DE VARIABLES ---
MENSAJE="Hola"
NOMBRES=()

# --- FUNCIONES DE ERRORES Y DE AYUDA DEL PROGRAMA ---

usage() {
  echo "Programa que saluda"
  echo "Funcionamiento: $0 [-h | --help] [-n nombre(s)] [-m mensaje]"
  echo
  echo "Funciones:"
  echo "[-h | --help]         Selecciona la ayuda del programa"
  echo "[-n nombre(s)]        Introducir el nombre o los nombres, que quiera el usuario"
  echo "[-m mensaje]          Por si el usuario quiere introducir algún mensaje específico, por defecto se mostrará 'Hola, '"
}

error_usage() {
  echo "$1" >&2
  usage >&2
  exit 1
}

error_exit() {
  echo "$1" >&2
  exit 1
}

# --- PROCESAMIENTO DE LA LÍNEA DE COMANDOS ---

while [[ $1 != "" ]]; do
  case "$1" in
    -h | --help )
      usage
      exit 0
    ;;
    -n ) 
      shift
      while [[ -n "$1" && "$1" != -* ]]; do
        NOMBRES+=("$1")
        shift
      done
      continue
    ;;
    -m )
      shift
      if [[ -z "$1" || "$1" == -* ]]; then
        error_usage "Luego de -m va el mensaje a introducir entre comillas dobles, consulte el manual del programa con -h | --help"
      fi
      MENSAJE="$1"
    ;;
    -*)
      error_usage "Opción desconocida, consulte el manual del programa con -h | --help"
    ;;
    *)
      error_usage "Argumento no reconocido, consulte el manual del programa con -h | --help"
    ;;
  esac
  shift
done

# --- COMPROBACIONES ---

# Comprobar que se ha introducido algún nombre

if [[ "${#NOMBRES[@]}" -eq 0 ]]; then
  error_usage "Es necesario introducir mínimmo un nombre, puede consultar el manual con -h | --help"
fi

# --- FUNCIONAMIENTO DEL PROGRAMA ---

for n in "${NOMBRES[@]}"; do
  echo "$MENSAJE, $n"
done