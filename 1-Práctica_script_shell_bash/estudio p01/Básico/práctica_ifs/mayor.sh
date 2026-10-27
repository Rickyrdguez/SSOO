#!/bin/bash

# Manejo de caso de errores

# Número de parámetros incorrectos

if [[ $# -ne 2 ]]; then
  echo "El programa $0 usa <./mayor.sh> <primer_numero> <segundo_numero>" >&2
  exit 1
fi

# Introduce algo que no sea un número

if [[ ! $1 =~ ^[0-9]+$ ||  ! $2 =~ ^[0-9]+$ ]]; then 
  echo "El programa solo usa números enteros positivos" >&2
  exit 1
fi


if [[ $1 -gt $2 ]]; then 
  echo "$1 es mayor que $2"
  
elif [[ $1 -lt $2 ]]; then
  echo "$1 es menor que $2"

else
  echo "$1 es igual a $2"
fi
