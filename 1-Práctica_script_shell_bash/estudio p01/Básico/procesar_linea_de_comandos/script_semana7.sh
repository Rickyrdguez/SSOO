#!/bin/bash

# ENUNCIADO: Un cript que me devuelva el procentaje de memoria consumida por los procesos que tiene abierto los ficheros 
# de "/tmp". Con el parámetro "-d" puedo cambiar el directorio de búsqueda. Implementa además un "-h"

DIR=/tmp

# --- FUNCIÓN DE AYUDA Y ERROR ---

usage() {
  echo "Programa que, por defecto, muestra los ficheros que más memoria consumen en la fichero /tmp"
  echo "Si desea cambiar de fichero use: ./$0 -d fichero"
}

error_exit() {
  echo "$1" >&2
  exit 1
}

# --- PROCESAR LINEA DE COMANDOS ---

if [[ $# != 0 ]]; then
  if [[ $1 == "-h" ]]; then
    usage
    exit 0
  elif [[ $1 == "-d" ]]; then
    [[ -n $2 ]] || error_exit "La opción -d requiere un directorio"
    DIR=$2
  else
    error_exit "Opción incorrecta, consulte el uso del programa con $0 -h"
  fi
fi

# --- COMPROBACIONES --- 

# el directorio introducido es correcto

directory_exist() {
  [[ -d "$1" ]]
}

if ! directory_exist $DIR; then
  error_exit "El directorio no existe"
fi

# lsof está instalado

lsof_is_installed() {
  type lsof > /dev/null 2> /dev/null
}

if ! lsof_is_installed; then
  error_exit "lsof No está instalado"
fi

# --- EJECUCIÓN DEL PROGRAMA --- 


# La verdad es que esta parte no la sabría hacer sin ayuda de la IA así que lo subo así y me pongo a estudiar más