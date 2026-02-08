module helper.app_path;

import std.path;
import std.string;
import std.file;

string 
getProjectPath() { // todo; change to projectRoot
    // Relative path where app_path is located
    return std.path.dirName(                        // project_root/
        std.path.dirName(                           // project_root/src/
            std.path.dirName(                       // project_root/src/sub_dir/
                std.path.absolutePath(__FILE__)))); // project_root/src/sub_dir/file.cpp
}

string
getProjectName() {
    return std.path.baseName(getProjectPath());
}

void
createFile(string fullyQualifiedFilePath) {
    string absPath = std.path.absolutePath(fullyQualifiedFilePath);
    string parentDir = std.path.dirName(absPath);

    // Add file if it doesn't exist
    if (!std.file.exists(parentDir)) {
        std.file.mkdirRecurse(parentDir);
    }

    if (!std.file.exists(absPath)) {
        // Add dummy file
        std.file.write(absPath, "");
    }
}

