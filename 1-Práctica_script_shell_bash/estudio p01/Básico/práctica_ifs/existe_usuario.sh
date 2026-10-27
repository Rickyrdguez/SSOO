#!/bin/bash

# ---- TRATAMIENTO DE ERRORES ----

# Creamos la funcion de manejo de errores y de uso del programa

usage() {
  echo "Uso: $0 <nombre_usuario>"
  echo "Comprueba que exista el usuario introducido y además de ver si está conectado."
}

error_usage() {
  echo "$1" >&2
  usage >&2
  exit 1
}

# No introduce datos

if [[ $1 == "" ]]; then
  error_usage "No se han introducido los datos suficientes"
fi


# --- FUNCIONAMIENTO DEL PROGRAMA ---

if grep -q "^$1:" /etc/passwd; then
  echo "Existe"

  if who | grep -q "^$1 "; then
  echo "Está conectado"
  else 
  echo "No está conectado"
  fi

else
  error_usage "El usuario '$1' no existe"
fi