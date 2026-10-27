#!/bin/bash

# --- PARÁMETROS ---
ORDENAR=0
LIMITE=""
GRUPOS=()
USAR_GRUPOS=0

# --- FUNCIONES DE AYUDA Y MANEJO DE ERRORES ---

usage() {
  echo "Uso: $0 [-h | --help] [-s] [-l N] [-g grupo ...]"
  echo "Lista los usuarios del sistema con su UID y su shell."
  echo
  echo "Opciones:"
  echo "  -h, --help      Muestra esta ayuda y termina"
  echo "  -s              Ordena por UID, de mayor a menor (por defecto, alfabético)"
  echo "  -l N            Muestra solo los N primeros usuarios (N entero mayor que 0)"
  echo "  -g grupo ...    Muestra solo los usuarios de alguno de esos grupos"
  echo
  echo "Variable de entorno:"
  echo "  USERS_SHELL     Si está definida, muestra solo los usuarios con esa shell"
}

error_usage() {
  echo "$1" >&2
  usage >&2
  exit 1
}

error_exit() {
  echo "$1" >&2
  exit 1
}

# --- PROCESADO DE LÍNEA DE COMANDOS ---

while [[ "$1" != "" ]]; do
  case "$1" in
    -h | --help) 
      usage
      exit 0
    ;;
    -s) 
      ORDENAR=1
    ;;
    -l) 
      shift
      if [[ ! "$1" =~ ^[0-9]+$ || "$1" -eq 0 ]]; then
        error_usage "Solo números enteros >= 1, consulte el manual del programa con [-h | --help]"
      fi
      LIMITE="$1"
    ;; 
    -g)
    shift 
    USAR_GRUPOS=1
    while [[ -n "$1" && "$1" != -* ]]; do
      GRUPOS+=("$1")
      shift
    done
    continue
    ;;
    -*) 
      error_usage "Opción no encontrada, consulte el manual del programa con [-h | --help]"
    ;;
    *) 
      error_usage "Carácter invalida, consulte el manual del programa con [-h | --help]"
    ;;
  esac
  shift
done

# --- COMBROBACIONES ---

# ¿Está getent descargado?

if ! command -v getent >/dev/null 2>&1; then
  error_exit "El comando getent no está descargado"
fi

# ¿Existe $USERS_SHELL?

if [[ -n "$USERS_SHELL" && ! -e "$USERS_SHELL" ]]; then
  error_exit "La shell '$USERS_SHELL' no existe"
fi

# ¿Nos indican que usemos el grupo pero este está vacío?

if [[ $USAR_GRUPOS -eq 1 && ${#GRUPOS[@]} -eq 0 ]]; then
  error_usage "Falta la lista de grupos tras -g"
fi

# --- FUNCIONAMIENTO DEL PROGRAMA ---

{
  echo "USUARIO UID SHELL"

  if [[ $ORDENAR -eq 1 ]]; then
    cut -d: -f1,3,7 /etc/passwd | tr ':' ' ' | sort -k2 -n -r
  else
    cut -d: -f1,3,7 /etc/passwd | tr ':' ' ' | sort

  fi
} | column -t