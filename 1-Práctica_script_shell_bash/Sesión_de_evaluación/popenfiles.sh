#!/bin/bash

# Ricardo Jesús Rodríguez Pérez

# --- VARIABLES ---
VALORES_PID=$(ps | tail -n +2 | awk '{print $1}' | tr "\n" ",")
USA_OPCION_D=0
DIRECTORIO=""
ORDENA=0
MODO_F=0


# --- FUNCIONES ---

# Funcion encargada del manejo de errores
error_exit() {
  echo "$1" >&2
  exit 1
}

# Funcion encargada de mostrar la ayuda del programa 
usage() {
	echo "Uso del programa: ./popenfiles [-h] [ [-d dir] [-f] ]"
}

# Funcion que comprueba que lsof esta instalado
lsof_is_installed() {
	which lsof >/dev/null 2>/dev/null
}

# Funcion que ejecuta la salida por defecto del programa
salida_del_programa() {
	if [[ "$USA_OPCION_D" == 0 && "$ORDENA" == 0 ]]; then
		lsof -p $VALORES_PID
	elif [[ "$USA_OPCION_D" == 0 && "$ORDENA" == 1 ]]; then
		lsof -p $VALORES_PID | orden_alfabetico
	elif [[ "$USA_OPCION_D" == 1 && "$ORDENA" == 0 ]]; then
		lsof -p "$VALORES_PID" -a +d "$DIRECTORIO"
	else
		lsof -p "$VALORES_PID" -a +d "$DIRECTORIO" | orden_alfabetico
	fi
}

# Funcion de procesado de la linea de comandos
procesa() {
	while [[ "$1" != "" ]]; do
		case "$1" in
			-h | --help)
				usage
				exit 0
			;;
			-d)
				shift

				if [[ "$1" == "" ]]; then 
					error_exit "La opción -d va seguida de un directorio, consulte la guía del programa con -h | --help"
				fi

				USA_OPCION_D=1
				DIRECTORIO="$1"
				shift
			;;
			-sc)
				ORDENA=1
				shift
			;;
			-f)
				shift
				;;
			-F)
				shift 
				MODO_F=1
				shift
			;;
			-*) 
				error_exit "Función del programa desconocida, consulte la guía con -h | --help"
			;;
			*)
				error_exit "Carácter no soportado por el programa, consulte la guía con -h | --help"
			;;
		esac
	done
}

procesa "$@"


# Funcion que ordena la columna COMMAND por orden alfabetico
orden_alfabetico() {
	tail -n +2 | sort -k1
}

# Creamos la funcion get_mod_time
get_mod_time() {
	stat -c "%y" "$1" >/dev/null 2>/dev/null
}

# Funcion encargada de la salida de -F


# --- COMPROBACIONES ---

# Comprobamos que lsof esta instalado llamando a lsof_is_installed
if ! lsof_is_installed; then
	error_exit "El comando lsof no esta en el path"
fi

# Comprobamos que la variable de entorno OPEN_FILES_COMM no esta vacia y si no lo esta, añdiremos el contenido a VALORES_PID para aplicarle el lsof
if [[ "$OPEN_FILES_COMM" != "" ]]; then
	PID_OPEN_FILES=$(ps ax -o pid,comm | grep -E -e $OPEN_FILES_COMM | tr "\n" "," | awk '{print $1}')
	VALORES_PID="$VALORES_PID,$PID_OPEN_FILES"
fi


# Comprobamos que el directorio proporcionado por la opcion -d no este vacio y sea un directorio
# Si es un directorio, entonces buscaremos su ruta absoluta para usarla
if [[ "$USA_OPCION_D" == 1 ]]; then
	if [[ "$DIRECTORIO" == "" || ! -d "$DIRECTORIO" ]]; then
		error_exit "El directorio proporcionado por la opción -d está vacío o no es un directorio"
	else
		DIRECTORIO=$(realpath "$DIRECTORIO")
	fi
fi


# --- PROGRAMA PRINCIPAL ---

if [[ "$MODO_F" == 0 ]]; then
	salida_del_programa
elif [[ "$MODO_F" == 1 ]]; then
	salida_del_programa | while read -r linea; do

		INICIO=$(echo "$linea" | cut -c1-2)
		RUTA=$(echo "$linea" | cut -c2-)

		if [[ "$INICIO" == "n/" ]]; then
			echo "$linea"
			echo "y$(get_mod_time "$RUTA")"
		fi
	done
fi
