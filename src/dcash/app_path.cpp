#include <filesystem>
#include <fstream>
#include <string>
#include "app_path.hpp"

namespace helper::app_path {
    // todo; this is not safe if this ever moves because of __FILE__
    // so if it ever moves, you need to revise the code
    // Returns project name, assuming root of project is name
    std::filesystem::path 
    get_project_path() {
        // Process:
        // project_root/src/sub_dir/file.cpp
        // project_root/src/sub_dir/
        // project_root/src/
        // project_root/
        return std::filesystem::absolute(__FILE__)
            .parent_path().parent_path().parent_path();
    }

    std::string 
    get_project_name(){
        return app_path::get_project_path().filename().string();
    }

    // Assumes default_dir is a subdir of the project path. It does NOT
    // assume it is an immediate child, but is treated as such, so there is
    // some flexibility.
    std::filesystem::path 
    get_fully_qualified_dir_path(const std::string& default_dir) {
        // project_root/config
        return app_path::get_project_path() / default_dir;
    }

    void 
    create_file(const std::string& fully_qualified_file_path) {
        std::filesystem::path file_path = std::filesystem::absolute(fully_qualified_file_path);

        // Create folder if it doesn't exist
        if (!std::filesystem::is_directory(file_path.parent_path())) {
            std::filesystem::create_directories(file_path.parent_path());
        }

        // Create the file if it doesn't exist
        if (!std::filesystem::exists(file_path)) {
            std::ofstream ofs(file_path);
        }
    }

    bool 
    verify_exists(const std::string& fully_qualified_file_path) {
        std::filesystem::path file_path(fully_qualified_file_path);
        return std::filesystem::exists(file_path);
    }
}
