#!/bin/bash

# RICARDO JESÚS RODRÍGUEZ PÉREZ

# --- VARIABLES ---
USUARIOS=$(cut -d: -f1 /etc/passwd)
USA_FILTRO=0
FILTRO=""
USA_OPCION_E=0
ASCENDENTE=0
LISTA_USUARIOS_OPCION_U=""

# --- FUNCIONES ---

# FUnción que muestra el uso del programa 
usage() {
  echo "Programa que tiene como salida una primera columna con los usuarios y en una segunda el número de archivos que tiene abierto"
  echo "Por defecto, los usuarios son los almacenados en /etc/passwd y el orden de la segunda columna es descendente"
  echo 
  echo "Funciones específicas del programa:"
  echo " [ -h | --help ]        - Muestra la guía del programa"
  echo " [ -f filtro ]          - Esta opción muestra solo los archivos abiertos que acaban en dicho filtro"
  echo " [ -e ]                 - Función equivalente a la de -f pero usando la variable de entorno OPEN_FILES_REG"
  echo " [ -r ]                 - Función que cambia la salida de la segunda columna haciendo que pase a ser en orden ascendente"
  echo " [ -u usaurio(s) ]      - Puede añadir usuario(s) específico(s), por defecto el programa usa los almacenados en /etc/passwd"
  echo
  echo "IMPORTANTE: La opción -e y -f son incompatibles"
}

# Función manejo de errores
error_exit() {
  echo "$1" >&2
  exit 1
}

# Función lsof está instalado
lsof_is_installed() {
  which lsof >/dev/null 2>/dev/null
}

# Función contador de programas abierto
contador() {
  lsof -u $1 2>/dev/null | tail -n +2 | wc -l
}

# Función que elimina los números 0
elimina_cero() {
  awk '$2 > 0'
}

# Función que pone la salida en orden descendente
descendente() {
  sort -k2 -nr
}

# Función procesado de la línea de comandos
procesado() {
  while [[ "$1" != "" ]]; do
    case "$1" in
      -h | --help)
        usage
        exit 0
      ;;
      -f ) 
        shift
        if [[ "$1" == "" ]]; then
          error_exit "-f debe de estar seguido de un filtro, consulte la guía del programa con -h | --help"
        fi
        USA_FILTRO=1
        FILTRO="$1"
        shift
      ;;
      -e )
        USA_OPCION_E=1
        if [[ $OPEN_FILES_REG == "" ]]; then
          error_exit "OPEN_FILES_REG está vacío"
        fi
        shift
      ;;
      -r )
        ASCENDENTE=1
        shift
      ;;
      -u)
        shift 

        if [[ "$1" == "" || "$1" == -* ]]; then
          error_exit "La opción -u va seguida de usuario(s), consulte la guía con -h | --help)"
        fi

        while [[ "$1" != "" && "$1" != -* ]]; do
          LISTA_USUARIOS_OPCION_U="$LISTA_USUARIOS_OPCION_U $1"
          shift
        done

      ;;
      -* )
        error_exit "Opción desconocida, consulte la guía con -h | --help"
      ;;
      * )
        error_exit "Carácter no válido, consulte la guía con -h | --help"
      ;;
    esac
  done
}

procesado "$@"

# Función contador para la regex de -f
contador_regex() {
  lsof -u $1 2>/dev/null | tail -n +2 | grep -E -e "$FILTRO$" | wc -l
}

# Función contador para la opción -e
contador_open_files() {
  lsof -u "$1" 2>/dev/null | tail -n +2 | grep -E -e "$OPEN_FILES_REG$" | wc -l
}

# Función que muestra la segunda columna en orden ascendente
ascendente() {
  sort -k2 -n
}

# --- COMPROBACIONES ---

# ¿Está lsof instalado?
if ! lsof_is_installed; then
  error_exit "El comando 'lsof' no está instalado"
fi

# ¿Está el usuario intentando usar la opción -e y -f a la vez?
if [[ "$USA_FILTRO" == 1 && "$USA_OPCION_E" == 1 ]]; then
  error_exit "La opción -e y -f son incompatibles, consulte la guía del programa con -h | --help"
fi

# Comprobamos que lista de usuarios opcion u no esté vacío y si lo está le asignamos los usuarios de /etc/passwd
if [[ -z "$LISTA_USUARIOS_OPCION_U" ]]; then
  LISTA_USUARIOS_OPCION_U=$USUARIOS
fi

# --- LÓGICA DEL PROGRAMA ---

if [[ "$USA_FILTRO" == 1 && "$USA_OPCION_E" == 0 ]]; then

  if [[ "$ASCENDENTE" == 0 ]]; then 
    for user in $LISTA_USUARIOS_OPCION_U; do 
      echo "$user $(contador_regex $user)"
    done | descendente | elimina_cero

  else 

    for user in $LISTA_USUARIOS_OPCION_U; do 
      echo "$user $(contador_regex $user)"
    done | ascendente | elimina_cero

  fi

elif [[ "$USA_FILTRO" == 0 && "$USA_OPCION_E" == 1 ]]; then

  if [[ "$ASCENDENTE" == 0 ]]; then 
    for user in $LISTA_USUARIOS_OPCION_U; do
      echo "$user $(contador_open_files $user)"
    done | descendente | elimina_cero

  else

    for user in $LISTA_USUARIOS_OPCION_U; do
      echo "$user $(contador_open_files $user)"
    done | ascendente | elimina_cero
  fi

else 

   if [[ "$ASCENDENTE" == 0 ]]; then 
    for user in $LISTA_USUARIOS_OPCION_U; do
      echo "$user $(contador $user)"
    done | descendente | elimina_cero

  else

    for user in $LISTA_USUARIOS_OPCION_U; do
      echo "$user $(contador $user)"
    done | ascendente | elimina_cero
  fi 

fi