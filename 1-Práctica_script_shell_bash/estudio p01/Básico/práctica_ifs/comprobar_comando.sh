#!/bin/bash

# Función de error y de uso

usage() {
  echo "Este programa comprueba si existe un comando instalado"
  echo "La entrada del programa es: ./comprobar_comando.sh <comando>"
}

error_usage() {
  echo "$1" >&2
  usage >&2
  exit 1
}

error() {
  echo "$1" >&2
  exit 1
}

# --- TRATAMIENTO DE ERRORES ---

if [[ $1 == "" ]]; then
  error_usage "Número de parámetros introducidos incorrrecto"
fi

# --- FUNCIONAMIENTO DEL PROGRAMA ---

if command -v "^$1" >/dev/null 2>&1; then
