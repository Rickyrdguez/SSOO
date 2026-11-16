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

 // Para compilar use make y para comprobar lo hecho en la sesión de evaluación
 // use: ./copy pequeno.txt p2.txt && cat /tmp/copy_logfile 


// Archivo que contiene el main del programa copy

#include "copy.h"

/**
 * @brief Contiene todo el código de la aplicación. Cualquier excepción que se
 * escape de aquí la captura main().
 *
 * @param argc Número de argumentos de la línea de comandos
 * @param argv Argumentos de la línea de comandos
 * @return EXIT_SUCCESS si todo va bien, EXIT_FAILURE si hay algún error
 */
int protected_main(int argc, char* argv[]) {
    if (!check_args(argc, argv)) {
        return EXIT_FAILURE;
    }

    std::string src_path = argv[1];
    std::string dest_path = argv[2];

    if (is_directory(dest_path)) {
        std::filesystem::path dest{dest_path};
        dest /= std::filesystem::path{src_path}.filename();
        dest_path = dest.string();
    }

    if (is_same_file(src_path, dest_path)) {
        std::cerr << "copy: ORIGEN y DESTINO son el mismo archivo\n";
        return EXIT_FAILURE;
    }

    auto result = copy_file(src_path, dest_path);
    if (!result) {
        std::cerr << "copy: " << result.error().what() << '\n';
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}

/**
 * @brief Función principal. Llama a protected_main() dentro de un try para
 * capturar las excepciones inesperadas.
 */
int main(int argc, char* argv[]) {
    try {
        return protected_main(argc, argv);
    } catch (const std::system_error& e) {
        std::cerr << "copy: error inesperado (" << e.code().value()
                  << "): " << e.what() << '\n';
    } catch (const std::exception& e) {
        std::cerr << "copy: error inesperado: " << e.what() << '\n';
    }
    return EXIT_FAILURE;
}