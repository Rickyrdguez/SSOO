#!/bin/bash

# Ricardo Jesús Rodríguez Pérez

# --- VARIABLES ---
LISTA_USUARIOS=""
LISTA_USABLE=""

# --- FUNCIÓN DE USO Y DE MANEJO DE ERRORES ---

usage() {
  echo "Este programa tiene como salida los PIDs sin repeticion de los procesos del usuario $USER"
  echo 
  echo "Opciones válidas en el programa: "
  echo " [ -h | --help ]              - muestra la ayuda del programa"
  echo " [ -d directorio ]            - ejecuta el programa en un directorio específico, por defecto el actual"
  echo " [-u usuario(s) ]             - ejecuta el programa en una lista de usuarios, por defecto usa $USER"
}

error_exit() {
  echo "$1" >&2
  exit 1
}

# --- PROCESADO DE LA LÍNEA DE COMANDOS ---

procesado() {

  while [[ "$1" != "" ]]; do
    case "$1" in
      -h | --help) 
        usage
        exit 0
        shift
      ;;
      -d )
        shift 
        if [[ "$1" == "" ]]; then
          error_exit "Luego de la opción -d tiene que poner el nombre del directorio"
        elif [[ ! -d "$1" ]]; then 
          error_exit "El directorio no existe"
        else
          OPEN_FILES_FOLDER="$1"
        fi
        shift
      ;;
      -u )
        shift 
        if [[ "$1" == "" || "$1" == -* ]]; then
          error_exit "La opción -u debe estar seguida de usuario(s)"
        fi

        while [[ "$1" != "" && "$1" != -* ]]; do
          LISTA_USUARIOS="$LISTA_USUARIOS $1"
          shift
        done
      ;;
      -*)
        error_exit "Función desconocida, consulte el manual con -h | --help"
      ;;
      *)
        error_exit "Carácter no válido"
      ;;  
    esac
  done 
}

procesado "$@"

# --- COMPROBAMOS QUE LSOF ESTÉ INSTALADO ---

lsof_is_installed() {
  which lsof >/dev/null 2>/dev/null
}

if ! lsof_is_installed; then
  error_exit "lsof no está instalado"
fi

# --- COMPROBAMOS QUE LISTA_USUARIOS ESTÉ VACÍO Y SI LO ESTÁ ASINGAMOS $USER ---

if [[ -z "$LISTA_USUARIOS" ]]; then
  LISTA_USUARIOS=$USER
else 
  LISTA_USABLE=$(echo $LISTA_USUARIOS | tr " " ",")
fi

# --- FUNCIONAMIENTO DEL PROGRAMA ---

if [[ ! -d $OPEN_FILES_FOLDER && "$OPEN_FILES_FOLDER" != "" ]]; then 
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
  tail -n +2 | awk '{print $2}' | sort  | uniq -c | sort -nr | awk '{print $2, $1}'
}

obtener_apertura | obtener_columnas_ordenadas