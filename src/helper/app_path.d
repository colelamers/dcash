module helper.app_path;

import std.path;
import std.string;
import std.file;

string getProjectPath() {
    // Process:
    // project_root/src/sub_dir/file.cpp
    // project_root/src/sub_dir/
    // project_root/src/
    // project_root/
    return std.path.dirName(
        std.path.dirName(
            std.path.dirName(
                std.path.absolutePath(__FILE__))));
}

string getProjectName() {
    return std.path.baseName(getProjectPath());
}

string getFullyQualifiedDirPath(string defaultDir) {
    return std.path.buildPath(getProjectPath(), defaultDir);
}

void createFile(string fullyQualifiedFilePath) {
    string absPath = std.path.absolutePath(fullyQualifiedFilePath);
    string parentDir = std.path.dirName(absPath);

    if (!std.file.exists(parentDir)) {
        std.file.mkdirRecurse(parentDir);
    }

    if (!std.file.exists(absPath)) {
        std.file.write(absPath, "");
    }
}

bool verifyExists(string fullyQualifiedFilePath) {
    return std.file.exists(fullyQualifiedFilePath);
}

