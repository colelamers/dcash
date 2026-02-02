#!/usr/bin/env rdmd
import std.stdio;
import std.file;
import std.process;
import std.algorithm;
import std.array;
import std.path;

void main() {
    auto testDir = "tests";
    auto includePaths = ["src", "src/helper"];
    string[] includeFlags;
    foreach (path; includePaths) {
        includeFlags ~= "-I" ~ path;
    }

    writeln("Searching for tests in /", testDir, "...");
    auto testFiles = dirEntries(testDir, SpanMode.depth)
        .filter!(f => f.name.endsWith(".d"))
        .array;
 
    int passed = 0;
    int failed = 0;

    foreach (file; testFiles) {
        writef("Running %s...\n", file.name);
        stdout.flush();

        auto cmd = ["rdmd"] ~ includeFlags ~ ["-main", "-unittest", file.name];
        auto result = execute(cmd);
        writeln(result.output);

        if (result.status == 0) {
            passed++;
        } else {
            writeln("\n--- Error in ", file.name, " ---");
            writeln(result.output);
            writeln("-------------------------------\n");
            failed++;
        }
    }

    writeln("--- Results ---");
    writefln("Total: %d | Passed: %d | Failed: %d", testFiles.length, passed, failed);
}
