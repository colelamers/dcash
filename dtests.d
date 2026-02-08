#!/usr/bin/env rdmd
import std.stdio;
import std.file;
import std.process;
import std.algorithm;
import std.array;
import std.path;

void main() {
    // todo; add fully qualified imports
    // todo; move to tests folder
    // todo; rename to run.d
    auto testDir = "tests";
    auto includePaths = ["src", "src/helper"];
    string[] includeFlags;
    foreach (path; includePaths) {
        includeFlags ~= "-I" ~ path;
    }

    writeln("Searching for tests in /", testDir, "...");
    auto testFiles = std.file.dirEntries(testDir, SpanMode.depth)
        .filter!(f => f.name.endsWith(".d"))
        .array;
 
    int passed = 0;
    int failed = 0;

    foreach (file; testFiles) {
        std.stdio.writef("Running %s...\n", file.name);
        std.stdio.stdout.flush();

        auto cmd = ["rdmd"] ~ includeFlags ~ ["-main", "-unittest", file.name];
        auto result = execute(cmd);
        std.stdio.writeln(result.output);

        if (result.status == 0) {
            passed++;
        } 
        else {
            std.stdio.writeln("\n--- Error in ", file.name, " ---");
            std.stdio.writeln(result.output);
            std.stdio.writeln("-------------------------------\n");
            failed++;
        }
    }

    std.stdio.writeln("--- Results ---");
    std.stdio.writefln("Total: %d | Passed: %d | Failed: %d", testFiles.length, passed, failed);
}
