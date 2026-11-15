#!/bin/bash

# Ricardo Jesús Rodríguez Pérez         alu0101797557

# --- VARIABLES ---
LISTA_USUARIOS=""
LISTA_USABLE=""

# --- FUNCIONES ---

# Función manejo de errores
error_exit() {
  echo "$1" >&2
  exit 1
}

# Función ayuda del programa
usage() {
  echo "Programa que, por defecto, tiene como salida un primera columna de los PIDs de la variable '$USER' seguida de una segunda columna con el número de aperturas de archivo de ese proceso."
  echo "Por defecto, la segunda columna viene ordenada de forma descendente"
  echo
  echo  "Funciones del programa"
  echo " [ -h | --help ]            - Muestra la guía del programa"
  echo " [ -d directorio ]          - Trabaja sobre un directorio específico proporcionado quien ejecuta el programa"
  echo " [ -u usuario(s) ]          - Aplica el lsof sobre un usuario (o una lista de ellos) proporcionada por quien ejecuta el programa"
}

# Comprobar que lsof esté instalado
lsof_is_installed() {
  which lsof >/dev/null 2>/dev/null
}

# Encargado de obtener los PIDs
obtener_apertura() {
  if [[ -z $OPEN_FILES_FOLDER ]]; then
    lsof -u $LISTA_USABLE 2>/dev/null
  else 
    lsof -u $LISTA_USABLE -a +D "$OPEN_FILES_FOLDER" 2>/dev/null
  fi
}

# Obtiene y muestra las columnas ordenadas
ordenar_columnas() {
  awk '{print $2}' | tail -n +2 | sort | uniq -c
}

# Ordenar las columnas en función de la salida
ordenar_salida_programa() {
  awk '{print $2, $1}' | sort -k2 -nr
}

# Función que procesa la línea de comandos
procesado() {
  while [[ "$1" != "" ]]; do
    case $1 in
      -h | --help )
        usage
        exit 0
      ;;
      -d )
        shift 
        if [[ "$1" == "" ]]; then 
          error_exit "La opción debe de estar seguida por un directorio, consulte la guía del programa en -h | --help"
        else 
          OPEN_FILES_FOLDER="$1"
        fi
        shift
      ;;
      -u)
        shift 
      
        if [[ "$1" == "" ]]; then
          error_exit "La opción -u va seguida de usaurio(s), consulte la guía del programa con -h | --help"
        fi

        while [[ "$1" != "" && "$1" != -* ]]; do
          LISTA_USUARIOS="$LISTA_USUARIOS $1"
          shift
        done
      ;;
      -*)
        error_exit "Opción desconocida, consulte la guía del programa con -h | --help"
      ;;
      *)
        error_exit "Caracter no válido, consulte la guía del programa con -h | --help"
      ;;
    esac
  done
}

procesado "$@"


# Función que procesa $LISTA_USUARIOS y los transforma en una opción usable por lsof
transformar() {
  if [[ "$LISTA_USUARIOS" == "" ]]; then
    LISTA_USABLE="$USER"
  else
    LISTA_USABLE=$(echo $LISTA_USUARIOS | tr " " ",")
  fi
}

# --- COMPROBACIONES ---

if ! lsof_is_installed; then
  error_exit "El comando lsof no está instalado"
fi

# Comprobamos que OPEN_FILES_FOLDER sea un directorio
if [[ ! -d $OPEN_FILES_FOLDER && ! -z $OPEN_FILES_FOLDER ]]; then
  error_exit "$OPEN_FILES_FOLDER no es un directorio"
fi

# --- LÓGICA DEL PROGRAMA ---
transformar 

obtener_apertura | ordenar_columnas | ordenar_salida_programa 