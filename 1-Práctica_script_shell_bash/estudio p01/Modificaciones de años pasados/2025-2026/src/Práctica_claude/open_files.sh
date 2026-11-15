#!/bin/bash

# Ricardo Jesús Rodríguez Pérez

# --- VARIABLES ---
EXISTE_OPEN_FILES_TYPE=0

# --- FUNCIONES ---

# Función del manejo de errores
error_exit() {
  echo "$1" >&2
  exit 1
}

# Función de uso del programa
usage() {
  echo "Programa cuya salida son 2 columnas, la primera contiene los nombres de comando que salen en lsof de los procesos del usuario (sin repeticiones)"
  echo "En la segunda columna sale el número total de aperturas de archivo de ese comando. La salida está ordenada por esta segunda columna de forma descendente"
  echo
}

# Función que comprueba que lsof esté instalado
lsof_is_installed() {
  which lsof >/dev/null 2>/dev/null
}

# Función que muestra la primera columna de la salida
salida_primera_columna() {
  lsof -u "$USER" | tail -n +2  
}

# Función que muestra la salida de la segunda columna sin OPEN_FILES_TYPE
salida_segunda_columna() {
  awk '{print $1}' | sort | uniq -c | sort -nr | awk '{print $2 " " $1}'
}

# Función que muestra la salida de la segunda columna con OPEN_FILES_TYPE
salida_open_files_type() {
  grep -E -e "($OPEN_FILES_TYPE)$" | awk '{print $1}' | sort | uniq -c | sort -nr | awk '{print $2 " " $1}'
}

# Función que muestra la salida del programa que cuenta el filtro que se encuentra en la varibale de entorno OPEN_FILES_FOLDER
salida_open_files() {
  lsof -u "$USER" +D "$OPEN_FILES_TYPE" | tail -n +2 | awk '{print $1}' | sort | uniq -c | sort -nr | awk '{print $2 " " $1}'
}

# Función de procesado de la línea de comandos
procesado() {
  while [[ "$1" != "" ]]; do
    case "$1" in
      -h | --help) 
        usage
        exit 0
      ;;

    esac
  done
}

procesado "$@"

# --- COMPROBACIONES ---

if ! lsof_is_installed; then
  error_exit "El comando lsof no está instalado"
fi

if [[ $OPEN_FILES_TYPE == "" ]]; then
  EXISTE_OPEN_FILES_TYPE=1
fi

# --- LÓGICA DEL PROGRAMA ---

if [[ "$EXISTE_OPEN_FILES_TYPE" == 0 ]]; then
  salida_primera_columna | salida_segunda_columna
else
  salida_primera_columna | salida_open_files_type
fi