#!/bin/bash

if [[ $1 == "" ]]; then 
  echo "ERROR: falta el argumento" >&2
  exit 1
fi

if [[ -d "$1" ]]; then
  echo "$1 es un directorio"

elif [[ -f "$1" ]]; then
  echo "$1 es un fichero con contenido"

elif [[ -e "$1" ]]; then
  echo "$1 existe pero esta vacio"

else 
  echo "$1 no existe"

fi