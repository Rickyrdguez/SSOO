/**
 * Universidad de La Laguna
 * Escuela Superior de Ingeniería y Tecnología
 * Grado en Ingeniería Informática
 * Asignatura: Sistemas Operativos
 * Curso: 2º
 * Autor: Ricardo Jesús Rodríguez Pérez
 * Usuario: alu0101797557
 * Fecha: 15/11/2026
 */

 // Fichero que contiene la declaracion de las funciones del programa copy

#ifndef COPY_FILES_H_
#define COPY_FILES_H_

#include <fcntl.h>     // open(), O_RDONLY, O_WRONLY, O_CREAT, O_TRUNC
#include <sys/stat.h>  // stat(), S_ISDIR(), struct stat, mode_t
#include <unistd.h>    // read(), write(), close()

#include <array>   
#include <cerrno>        // errno, EINTR
#include <cstdlib>       // EXIT_SUCCESS, EXIT_FAILURE
#include <exception>     // std::exception
#include <expected>      // std::expected, std::unexpected
#include <filesystem>    // std::filesystem::path
#include <iostream>      // std::cerr
#include <string>        // std::string
#include <system_error>  // std::system_error, std::system_category()
#include <utility>       // std::move()

// Crea un std::unexpected con el errno actual y un texto de contexto
std::unexpected<std::system_error> system_error_from_errno(std::string context);

// Comprueba que se han indicado exactamente ORIGEN y DESTINO
bool check_args(int argc, char* argv[]);

// Comprueba si la ruta es un directorio
bool is_directory(const std::string& path);

// Comprueba si las dos rutas conducen al mismo archivo
bool is_same_file(const std::string& src_path, const std::string& dest_path);

// Copia el contenido de ORIGEN en DESTINO
// Lo modifico según la sesión de evaluación

/**
* el programa tiene que llevar un registro de los ficheros que ha copiado y su 
* tamaño. Este registro estará en el /tmp/copy_logfile ( o en el directorio 
* HOME/copy_logfile solo por si da error)
*/

[[nodiscard]] std::expected<void, std::system_error> copy_file(
    const std::string& src_path, const std::string& dest_path,
    mode_t dst_perms = 0644);

#endif  // COPY_FILES_H_