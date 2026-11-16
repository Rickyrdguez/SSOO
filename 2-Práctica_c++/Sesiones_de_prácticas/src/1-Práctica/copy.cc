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

 // Fichero que contiene la implementacion de las funciones del programa copy

#include "copy.h"

namespace {

// Tamaño del búfer de copia: 128 KiB
constexpr size_t kBufferSize = 128 * 1024;

/**
 * @brief Escribe todos los bytes indicados, repitiendo write() si escribe
 * menos de lo pedido
 *
 * @param fd Descriptor del archivo donde escribir
 * @param data Datos a escribir
 * @param size Número de bytes a escribir
 */
[[nodiscard]] std::expected<void, std::system_error> write_all(
    int fd, const char* data, size_t size) {
    size_t total_written = 0;
    while (total_written < size) {
        ssize_t written = write(fd, data + total_written, size - total_written);
        if (written == -1) {
            if (errno == EINTR) continue;  // Interrumpido por una señal
            return system_error_from_errno(
                "error al escribir en el archivo de destino");
        }
        total_written += static_cast<size_t>(written);
    }
    return {};
}

/**
 * @brief Copia todo el contenido de un descriptor a otro en bloques de 128 KiB
 *
 * @param src_fd Descriptor de origen (abierto para lectura)
 * @param dest_fd Descriptor de destino (abierto para escritura)
 */
[[nodiscard]] std::expected<void, std::system_error> copy_data(int src_fd,
                                                               int dest_fd) {
    std::array<char, kBufferSize> buffer;
    while (true) {
        ssize_t bytes_read = read(src_fd, buffer.data(), buffer.size());
        if (bytes_read == -1) {
            if (errno == EINTR) continue;  // Interrumpido por una señal
            return system_error_from_errno("error al leer el archivo de origen");
        }
        if (bytes_read == 0) {
            return {};  // Final del archivo
        }
        auto result =
            write_all(dest_fd, buffer.data(), static_cast<size_t>(bytes_read));
        if (!result) {
            return result;
        }
    }
}

// Modificación de la sesión 

/**
 * @brief Abre el archivo de registro en modo añadir: primero en /tmp y, solo si
 * falla, en el directorio HOME
 */
[[nodiscard]] std::expected<int, std::system_error> open_logfile() {
    constexpr int kFlags = O_WRONLY | O_CREAT | O_APPEND;
    int fd = open("/tmp/copy_logfile", kFlags, 0644);
    if (fd != -1) {
        return fd;
    }
    const char* home = std::getenv("HOME");
    if (home != nullptr) {
        std::string path = std::string{home} + "/copy_logfile";
        fd = open(path.c_str(), kFlags, 0644);
        if (fd != -1) {
            return fd;
        }
    }
    return system_error_from_errno("error al abrir el archivo de registro");
}

/**
 * @brief Añade al registro una línea con el archivo copiado y su tamaño
 *
 * @param src_path Ruta del archivo de origen
 * @param dest_path Ruta del archivo de destino (ya copiado)
 */
[[nodiscard]] std::expected<void, std::system_error> log_copy(
    const std::string& src_path, const std::string& dest_path) {
    struct stat st;
    if (stat(dest_path.c_str(), &st) == -1) {
        return system_error_from_errno(
            "error al consultar el tamaño del archivo de destino");
    }
    auto log_fd = open_logfile();
    if (!log_fd) {
        return std::unexpected(log_fd.error());
    }
    std::string line = src_path + " -> " + dest_path + " (" +
                       std::to_string(st.st_size) + " bytes)\n";
    auto result = write_all(*log_fd, line.data(), line.size());
    close(*log_fd);
    return result;
}

}  // namespace

/**
 * @brief Crea un std::unexpected con el errno actual. Hay que llamarla justo
 * después de que falle la llamada al sistema, antes de hacer cualquier otra.
 *
 * @param context Texto que describe qué se estaba haciendo
 */
std::unexpected<std::system_error> system_error_from_errno(
    std::string context) {
    return std::unexpected(
        std::system_error(errno, std::system_category(), std::move(context)));
}

/**
 * @brief Comprueba que se han indicado exactamente dos argumentos (ORIGEN y
 * DESTINO) además del nombre del programa. Si no, muestra el mensaje de uso.
 *
 * @param argc Número de argumentos (contando el nombre del programa)
 * @param argv Argumentos introducidos por la línea de comandos
 * @return true si los argumentos son correctos, false en caso contrario
 */
bool check_args(int argc, [[maybe_unused]] char* argv[]) {
    if (argc != 3) {
        std::cerr << "copy: se deben indicar los archivos ORIGEN y DESTINO\n";
        return false;
    }
    return true;
}

/**
 * @brief Comprueba si una ruta es un directorio usando stat()
 *
 * @param path Ruta a comprobar
 * @return true si es un directorio, false en cualquier otro caso
 */
bool is_directory(const std::string& path) {
    struct stat st;
    if (stat(path.c_str(), &st) == -1) {
        return false;
    }
    return S_ISDIR(st.st_mode);
}

/**
 * @brief Comprueba si dos rutas conducen al mismo archivo comparando el
 * dispositivo (st_dev) y el inodo (st_ino)
 *
 * @param src_path Ruta de origen
 * @param dest_path Ruta de destino
 * @return true si son el mismo archivo, false en caso contrario (o si alguno
 * no existe)
 */
bool is_same_file(const std::string& src_path, const std::string& dest_path) {
    struct stat src_st;
    struct stat dest_st;
    if (stat(src_path.c_str(), &src_st) == -1 ||
        stat(dest_path.c_str(), &dest_st) == -1) {
        return false;
    }
    return src_st.st_dev == dest_st.st_dev && src_st.st_ino == dest_st.st_ino;
}

/**
 * @brief Copia el contenido del archivo de origen en el de destino. Cierra
 * siempre los dos descriptores, tanto si la copia va bien como si falla.
 *
 * @param src_path Ruta del archivo de origen
 * @param dest_path Ruta del archivo de destino
 * @param dst_perms Permisos si hay que crear el archivo de destino
 */
std::expected<void, std::system_error> copy_file(const std::string& src_path,
                                                 const std::string& dest_path,
                                                 mode_t dst_perms) {
    int src_fd = open(src_path.c_str(), O_RDONLY);
    if (src_fd == -1) {
        return system_error_from_errno("error al abrir el archivo de origen");
    }

    int dest_fd =
        open(dest_path.c_str(), O_WRONLY | O_CREAT | O_TRUNC, dst_perms);
    if (dest_fd == -1) {
        auto error = system_error_from_errno("error al abrir el archivo de destino");
        close(src_fd);
        return error;
    }

    auto result = copy_data(src_fd, dest_fd);
    close(src_fd);

    if (close(dest_fd) == -1 && result) {
        return system_error_from_errno("error al cerrar el archivo de destino");
    }
    if (!result) {
        return result;
    }
    return log_copy(src_path, dest_path);
}