#ifndef APP_PATH_H
#define APP_PATH_H

#include <filesystem>
#include <string>

namespace helper::app_path {
    std::filesystem::path get_project_path();
    std::string get_project_name();
    std::filesystem::path get_fully_qualified_dir_path(const std::string& default_dir);
    void create_file(const std::string& fully_qualified_path);
    bool verify_exists(const std::string& fully_qualified_file_path);
}
#endif
