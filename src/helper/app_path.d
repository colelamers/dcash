module helper.app_path;

import std.path;
import std.string;
import std.file;

string getProjectPath() {
    return dirName(dirName(dirName(absolutePath(__FILE__))));
}

string getProjectName() {
    return baseName(getProjectPath());
}

string getFullyQualifiedDirPath(string defaultDir) {
    return buildPath(getProjectPath(), defaultDir);
}

void createFile(string fullyQualifiedFilePath) {
    string absPath = absolutePath(fullyQualifiedFilePath);
    string parentDir = dirName(absPath);

    if (!exists(parentDir)) {
        mkdirRecurse(parentDir);
    }

    if (!exists(absPath)) {
        write(absPath, "");
    }
}

bool verifyExists(string fullyQualifiedFilePath) {
    return exists(fullyQualifiedFilePath);
}

