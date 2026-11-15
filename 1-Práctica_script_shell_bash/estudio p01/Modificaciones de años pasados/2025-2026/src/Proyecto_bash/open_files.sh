#!/bin/bash

# Ricardo Jesús Rodríguez Pérez

# --- VARIABLES ---

# --- FUNCIONES ---

# Función de manejo de errores
error_exit() {
  echo "$1" >&2
  exit 1
}

# Función que  muestra el uso del programa 
usage() {
  echo "Programa que tiene como salida 4 columnas. En orden, cada una contiene:   USUARIO  UID  PID_ANTIGUO  N_ARCHIVOS"
  echo 
}

# Función que comprueba que lsof está instalado
lsof_is_installed() {
  which lsof >/dev/null 2>/dev/null
}

# Función que muestra la primera columna de la salida (usuarios conectados)
usuarios_conectados() {
  who | awk '{print $1}' | sort -u 
}

# Función que busca el UID 
buscar_uid() {
  id -u "$1"
}

# Función que busca el PID más antiguo
buscar_pid() {
  pgrep -o -u "$1"
}

# Función que muestra el número de archivos abiertos por el usuario del tipo REG
archivos_reg() {
  lsof -u "$1" | tail -n +2 | awk '{print $5}' | grep -E -e "REG" | wc -l
}

# --- COMPROBACIONES ---

# Comprobamos que lsof esté instalado y si no lo está salimos con error
if ! lsof_is_installed; then
  error_exit "El comando lsof, no está instalado"
fi

# --- LÓGICA DEL PROGRAMA ---