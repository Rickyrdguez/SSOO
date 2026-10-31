#!/bin/bash

# RICARDO JESÚS RODRÍGUEZ PÉREZ

# --- VARIABLES ---
LISTA_USUARIOS=$(cut -d: -f1 /etc/passwd)
SE_USA_REGEX=0
REGEX=""
SE_USA_E=0
OPCION_R=0
LISTA_USUARIOS_OPCION_U=""
LISTA_USABLE=""

# --- FUNCIONES ---

# Función de uso de programa
usage () {
  echo "Este programa muestra por pantalla dos columnas"
  echo "La primera está formada por los usuarios extraidos en /etc/passwd y en la segunda el número de de aperturas de archivo del usuario correspondiente."
  echo
  echo "Opciones específicas del programa: "
  echo " [ -h | --help ]          - Muestra la ayuda del programa"
  echo " [ -f filtro ]            - Usa una regex para filtrar los programas acabados en dicho filtro"
  echo " [ -e ]                   - Accede a la variable de entorno 'OPEN_FILES_REG' y ese valor lo usa como filtro"
  echo " [ -r ]                   - Cambia el orden de ordenamiento a ascendente"
  echo " [ -u usuario(s) ]        - Con la opción -u usuario(s) el programa solo se ejecutará con el(los) usuario(s) introducidos"
  echo
  echo "IMPORTANTE: La opción -e y -f filtro SON INCOMPATIBLES"
}

# Función de manejo de errores
error_exit() {
  echo "$1" >&2
  exit 1
}


# Función que comprueba que lsof está en el path
esta_en_path() {
  which lsof >/dev/null 2>/dev/null 
}

# Función contador
contador() {
  lsof -u $1 2>/dev/null | tail -n +2 | wc -l
}

# Función que ordena de mayor a menor
ordena() {
  sort -k2 -nr
}

# Función contador de regex
contador_regex() {
  lsof -u $1 2>/dev/null | tail -n +2 | grep -E -e "$REGEX$" | wc -l
}

# Función contador con OPEN_FILES_REG
contador_open_files_reg() {
  lsof -u $1 2>/dev/null | tail -n +2 | grep -E "$OPEN_FILES_REG$" | wc -l
}

# Función llamada con -r que ordena de menor a mayor
ordena_ascendente() {
  sort -k2 -n
}

# Función que elimina los 0  para no mostrarlos
elimina_cero() {
  awk '$2 > 0'
}

# FUNCIÓN PROCESADO DE LA LINEA DE COMANDOS
procesa() {
  while [[ "$1" != "" ]]; do
    case "$1" in
      -h | --help)
        usage
        exit 0
      ;;
      -f )
        SE_USA_REGEX=1
        shift
        if [[ "$1" == "" ]]; then
          error_exit "La función -f debe estar seguida por un filtro, consulte la guía del programa con -h | --help"
        fi  
        REGEX="$1"
        shift
      ;;
      -e)
        SE_USA_E=1
        if [[ $OPEN_FILES_REG == "" ]]; then
          error_exit "OPEN_FILES_REG está vacío"
        fi
        shift
      ;;
      -r)
        OPCION_R=1
        shift
      ;;
      -u)
        shift 

        if [[ "$1" == "" || "$1" == -* ]]; then 
          error_exit "La opción -u va seguida de nombre(s) de usuario, consulte el manual el -h | --help"
        fi

        while [[ "$1" != "" && "$1" != -* ]]; do
          LISTA_USUARIOS_OPCION_U="$LISTA_USUARIOS_OPCION_U $1"
          shift
        done
      ;;
      -*)
        error_exit "Opción desconocida, consulte el manual en -h | --help"
        shif
      ;;
      *)
        error_exit "El carácter introducido no es procesado por el programa, consulte el manual en -h | --help"
        shift
      ;;
    esac
  done
}

procesa "$@"

# Analizamos el caso en el que el usuario use las opciones -e y -f 
if [[ "$SE_USA_REGEX" == 1 && "$SE_USA_E" == 1 ]]; then
  error_exit "La opción -e y -f son incompatibles"
fi

# --- COMPROBACIONES ---

# Comprobamos que lsof está en el path
if ! esta_en_path; then
  error_exit "El comando lsof no está en el path"
fi

# Comprobamos que la lista de usuarios opción u no esté vacía y si lo está le aplicamos los usuarios de LISTA_USUARIOS

if [[ -z "$LISTA_USUARIOS_OPCION_U" ]]; then
  LISTA_USUARIOS_OPCION_U=$LISTA_USUARIOS
fi

# --- LÓGICA DEL PROGRAMA ---

if [[ "$SE_USA_REGEX" == 0 && "$SE_USA_E" == 0 ]]; then

  if [[ "$OPCION_R" == 0 ]]; then
    for usuario in $LISTA_USUARIOS_OPCION_U; do
      echo "$usuario $(contador $usuario)"
    done | ordena | elimina_cero
  else 
    for usuario in $LISTA_USUARIOS_OPCION_U; do
      echo "$usuario $(contador $usuario)"
    done | ordena_ascendente | elimina_cero
  fi

elif [[ "$SE_USA_REGEX" == 1 && "$SE_USA_E" == 0 ]]; then

  if [[ "$OPCION_R" == 0 ]]; then
    for usuario in $LISTA_USUARIOS_OPCION_U; do
      echo "$usuario $(contador_regex $usuario)"
    done | ordena | elimina_cero
  else
    for usuario in $LISTA_USUARIOS_OPCION_U; do
      echo "$usuario $(contador_regex $usuario)"
    done | ordena_ascendente | elimina_cero
  fi

elif [[ "$SE_USA_REGEX" == 0 && "$SE_USA_E" == 1 ]]; then

  if [[ "$OPCION_R" == 0 ]]; then
    for usuario in $LISTA_USUARIOS_OPCION_U; do
      echo "$usuario $(contador_open_files_reg $usuario)"
    done | ordena | elimina_cero
  else 
    for usuario in $LISTA_USUARIOS_OPCION_U; do
      echo "$usuario $(contador_open_files_reg $usuario)"
    done | ordena_ascendente | elimina_cero
  fi

fi