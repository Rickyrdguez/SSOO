#!/bin/bash

# Ricardo Jesús Rodríguez Pérez

# --- VARIABLES ---
RUTA_PATH=$(echo $PATH | tr ":" " ")
DIRECTORIOS="$HOME $RUTA_PATH"
OPCION_D=0
DIRECT_OPCION_D=""
OPCION_U=0
USUARIO=""

# --- FUNCIONES ---

# Función manejo de errores
error_exit() {
  echo "$1" >&2
  exit 1
}

# Función uso del programa
usage() {
  echo "Programa que por defecto tiene como salida "
}

# Función que comprueba que lsof esté instalado
lsof_is_installed() {
  which lsof >/dev/null 2>/dev/null
}

# Función que ejecuta el lsof por defecto
salida_por_defecto() {
  for directorio in $DIRECTORIOS; do
    lsof +D "$directorio" 2>/dev/null | tail -n +2
  done
}

# Función que procesa la línea de comandos
procesado() {
  while [[ "$1" != "" ]]; do
    case "$1" in
      -h | --help )
        usage
        exit 0
      ;;
      -d )
        shift

        if [[ "$1" == "" || ! -d "$1" ]]; then
          error_exit "La opción -d debe de ir seguida de un directorio"
        fi

        OPCION_D=1
        DIRECT_OPCION_D="$1"

        shift
      ;;
      -u)
        shift 
        
        if [[ "$1" == "" || "$1" == -* ]]; then
          error_exit "La opción -u va seguida de usuario, consulte el manual con -h | --help"
        fi

        OPCION_U=1
        USUARIO="$1"
        shift
      ;;
      -*)
        error_exit "Opción desconocida, consulte el manual con -h | --help"
      ;;
      *)
        error_exit "Carácter no permitido, consulte el manual con -h | --help"
      ;;
    esac
  done
}

procesado "$@"

# Función que ejecuta el lsof pero para un usuario específico
salida_por_usuario() {
  for directorio in $DIRECTORIOS; do
    lsof -u "$1" -a +D "$directorio" 2>/dev/null | tail -n +2
  done
}

# Función que comprueba que el usuario exista
usuario_existe() {
  id "$1" >/dev/null 2>/dev/null
}

# --- COMPROBACIONES ---

# Comprobamos que lsof esté instalado
if ! lsof_is_installed; then
  error_exit "El comando lsof no está instalado"
fi

# Comprobamos que OPEN_FILES_FOLDER no esté vacñio y que sea un directorio
# Comprobamos tambien que no se haya activado la opción -d

if [[ "$OPEN_FILES_FOLDER" != "" ]]; then
  if [[ ! -d "$OPEN_FILES_FOLDER" ]]; then
    error_exit "El valor de OPEN_FILES_FOLDER no es un directorio"
  fi

  if [[ "$OPCION_D" == 1 ]]; then
    DIRECTORIOS="$DIRECT_OPCION_D $OPEN_FILES_FOLDER"
  else
    DIRECTORIOS="$OPEN_FILES_FOLDER"
  fi

elif [[ "$OPCION_D" == 1 ]]; then
  DIRECTORIOS="$DIRECT_OPCION_D"
fi


# Comprobamos que el usuario introducido exista
if [[ "$OPCION_U" == 1 ]]; then
  if ! usuario_existe "$USUARIO"; then
    error_exit "El usuario no existe"
  fi
fi

# --- LÓGICA DEL PROGRAMA ---
if [[ "$OPCION_U" == 0 ]]; then
  salida_por_defecto
else
  salida_por_usuario "$USUARIO"
fi