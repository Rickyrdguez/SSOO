#!/bin/bash

# Ricardo Jesús Rodríguez Pérez

# --- VARIABLES ---
USUARIOS=$(cut -d: -f1 /etc/passwd)
USA_FILTRO=0
FILTRO=""
OPCION_E=0
FILTRO_OPCION_E=""
OPCION_R=0
LISTA_USUARIOS=""

# --- FUNCIONES ---

# Función error
error_exit() {
  echo "$1" >&2
  exit 1
}

# Función que muestra la guía del programa 
usage(){
  echo "Programa que tiene como salida 2 columnas, la primera formada por los usuarios, por defecto los extraídos de /etc/passwd"
  echo "y como segunda columna el número de aperturas de archivo del usuario correspondiente"
  echo
  echo "Funciones útiles del programa"
  echo " [ -h | --help ]          - Consulta la guía del programa"
  echo " [ -f filtro ]            - Añade un filtro para contar solo los archivos acabado en eso"
  echo " [ -e ]                   - Accede al valor de la variable OPEN_FILES_REG y lo usa como filtro"
  echo " [ -r ]                   - Cambia el orden de la salida ordenando de menor a mayor"
  echo " [ -u usuario(s) ]        - Añade la cantidad de usuarios que quiera y se ejecuta el programa sobre ellos"
  echo
  echo "IMPORTANTE: las opciones -e y -f son incompatibles"
}

# Funcion que comprueba que lsof está instalado
lsof_is_installed() {
  which lsof >/dev/null 2>/dev/null
}

# Función contar las aperturas de archivo
contador() {
  lsof -u $1 2>/dev/null | tail -n +2 | wc -l
}

# Función que ordena de forma descendiente
ordenar_descendiente() {
  uniq | sort -k2 -nr
}

# Elimina los 0
elimina_cero() {
  awk '$2 > 0'
}


# Función contador de los acabados por el filtro dado por el usuario
contador_regex() {
  lsof -u $1 2>/dev/null | tail -n +2 | grep -E -e "($FILTRO)$" | wc -l
}

# Funcion contador usando el contenido de OPEN_FILES_REG
contador_open_files_reg() {
  lsof -u $1 2>/dev/null | tail -n +2 | grep -E -e "($OPEN_FILES_REG)$" | wc -l
}

# Función que ordena de forma ascendente
ordena_ascendente() {
  uniq | sort -k2 -n
}

# Función que procesa la línea de comandos
procesa() {
  while [[ "$1" != "" ]]; do
    case "$1" in
      -h | --help)
        usage
        exit 0
      ;;
      -f )
      shift 

      if [[ "$1" == "" || "$1" == -* ]]; then
        error_exit "La opción -f va seguida de un filtro, consulte el manual del programa con -h | --help"
      fi

      USA_FILTRO=1

      FILTRO="$1"
      shift
      ;;
      -e)

      if [[ "$OPEN_FILES_REG" == "" ]]; then
        error_exit "Open files reg está vacío o no es un directorio, consulte el manual con -h | --help"
      fi
    
      OPCION_E=1
      FILTRO_OPCION_E="$OPEN_FILES_REG"

      shift
      ;;
      -r)
        OPCION_R=1
        shift
      ;;
      -u)
        shift

        if [[ "$1" == "" || "$1" == -* ]]; then
          error_exit "La opción -u debe de estar seguida de usuario(s), consulte la guía del programa con -h | --help)"
        fi

        while [[ "$1" != "" && "$1" != -* ]]; do
          LISTA_USUARIOS="$LISTA_USUARIOS $1"
          shift
        done

      ;;
      -*)
        error_exit "Función desconocida, consulte la guía del porgrama con -h | --help"
      ;;
      *)
        error_exit "Carácter desconocido por el programa, consulte la guía del mismo con -h | --help"
      ;;
    esac
  done
}

procesa "$@"

# --- COMPROBACIONES ---

if ! lsof_is_installed; then
  error_exit "El comando lsof no está instalado"
fi


# Comprobamos que no se haya activado la opción -e y -f
if [[ "$USA_FILTRO" == 1 && "$OPCION_E" == 1 ]]; then
  error_exit "La opción -e y -f de este programa son incompatibles, consulte la guía con -h | --help"
fi

# Comprobamos que la LISTA_USUARIOS no esté vacía y si lo estuviera, volcamos ahí los datos de USUARIOS

if [[ -z $LISTA_USUARIOS ]]; then
  LISTA_USUARIOS="$USUARIOS"
fi

# --- PROGRAMA PRINCIPAL ---

if [[ "$USA_FILTRO" == 1 && "$OPCION_E" == 0 ]]; then

  if [[ "$OPCION_R" == 0 ]]; then
    for user in $LISTA_USUARIOS; do
      echo "$user $(contador_regex $user)"
    done | ordenar_descendiente | elimina_cero
  else 
    for user in $LISTA_USUARIOS; do
      echo "$user $(contador_regex $user)"
    done | ordena_ascendente | elimina_cero
  fi

elif [[ "$USA_FILTRO" == 0 && "$OPCION_E" == 1 ]]; then

  if [[ "$OPCION_R" == 0 ]]; then
    for user in $LISTA_USUARIOS; do
      echo "$user $(contador_open_files_reg $user)"
    done | ordenar_descendiente | elimina_cero
  else
    for user in $LISTA_USUARIOS; do
      echo "$user $(contar_open_files_reg $user)"
    done | ordena_ascendente | elimina_cero
  fi

else

  if [[ "$OPCION_R" == 0 ]]; then
    for user in $LISTA_USUARIOS; do
      echo "$user $(contador $user)"
    done | ordenar_descendiente | elimina_cero
  else
    for user in $LISTA_USUARIOS; do
      echo "$user $(contador $user)"
    done | ordena_ascendente | elimina_cero
  fi

fi