#!/bin/bash

# --- VARIABLES ---
LISTA_USUARIOS=""

# --- FUNCIÓN DE MANEJO DE ERRORES Y DE USO DEL PROGRAMA ---

usage() {
  echo "Este programa tiene como salida los PIDs sin repeticion de los procesos del usuario $USER"
  echo 
  echo "Opciones válidas en el programa: "
  echo " [ -h | --help ]              - muestra la ayuda del programa"
  echo " [ -d directorio ]            - ejecuta el programa en un directorio específico, por defecto el actual"
  echo " [-u usuario(s) ]             - ejecuta el programa en una lista de usuarios, por defecto usa $USER"
}

error_usage() {
  echo "$1" >&2
  usage
  exit 1
}

error_exit() {
  echo "$1" >&2
  exit 1
}

# --- COMPROBAMOS QUE LSOF ESTÁ INSTALADO ---

lsof_is_installed() {
  which lsof > /dev/null 2> /dev/null
}

if ! lsof_is_installed; then
  error_exit "lsof No está instalado"
fi

# --- PROCESADO DE LA LÍNEA DE COMANDOS ---


while [[ "$1" != "" ]]; do
  case "$1" in
    -h | --help )
      usage
      exit 0
      shift
    ;;
    -d )
      shift
      if [[ "$1" == "" ]]; then
        error_exit "La opción -d debe de estar seguida por un directorio, consulte el manual en -h | --help"
      else
        OPEN_FILES_FOLDER="$1"
      fi
      shift
    ;;
    -u ) 
      shift
      if [[ "$1" == "" ]]; then
        error_exit "Luego del -u debe de haber mínimo un nombre, consulte el manual en -h | --help"
      fi

      while [[ "$1" != "" && "$1" != -* ]]; do
        LISTA_USUARIOS="$LISTA_USUARIOS $1"
        shift
      done
    ;;
    -*) 
      error_exit "Opción desconocida, consulte el manual del programa con -h | --help"
      shift
    ;;
    *) 
      error_exit "Caracter inválido, consulte el manual del programa con -h | --help"
      shift
      ;;
  esac
done

# --- SI LISTA DE USUARIOS ESTÁ VACÍA LE ASIGNAMOS $USER ---

if [[ -z "$LISTA_USUARIOS" ]]; then
  LISTA_USUARIOS="$USER"
else 
  LISTA_USUARIOS=$(echo $LISTA_USUARIOS | tr " " ",")
fi

# --- FUNCIONAMIENTO DEL PROGRAMA ---

if [[ ! -d $OPEN_FILES_FOLDER && $OPEN_FILES_FOLDER != "" ]]; then
    error_exit "La ruta introducida no existe"
fi

obtener_apertura() {
  if [[ $OPEN_FILES_FOLDER == "" ]]; then
    lsof -u $LISTA_USUARIOS 2>/dev/null
  else
    lsof -u $LISTA_USUARIOS -a +D $OPEN_FILES_FOLDER 2>/dev/null
  fi
}

obtener_columnas_ordenadas() {
  tail -n +2 | awk '{print $2}' | sort | uniq -c | sort -nr | awk '{print $2, $1}' 
}

obtener_apertura | obtener_columnas_ordenadas
