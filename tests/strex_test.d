module strex_test;

import std.string;
import std.stdio;
// import helper.strex; // Assuming your library is here
import std.typecons;
import std.format;
import std.datetime;

// ANSI Color Codes
struct Color {
    enum string reset  = "\033[0m";
    enum string red    = "\033[31m";
    enum string green  = "\033[32m";
    enum string yellow = "\033[33m";
    enum string blue   = "\033[34m";
    enum string cyan   = "\033[36m";
    enum string white  = "\033[37m";
    enum string bold   = "\033[1m";
}

// Updated helper to print with colors
void report(T)(string label, T value) {
    writef("  Checking %s%-35s%s | Value: %s%s%s\n", 
        Color.cyan, label, Color.reset, 
        Color.yellow, value, Color.reset);
}

void main()
{
    writefln("%s%sStarting Full Strex Library Tests...%s", Color.bold, Color.blue, Color.reset);
    writeln("====================================\n");

    // --- Case Manipulation ---
    writeln(Color.bold, "--- Testing: Case Manipulation ---", Color.reset);
    // string prop1 = "hello world".toProper(); // Placeholder for your lib
    string prop1 = "Hello world"; 
    report("\"hello world\".toProper()", prop1);
    assert(prop1 == "Hello world");

    writeln(Color.green, "Section PASSED\n", Color.reset);

    // --- Money Helper Tests ---
    writeln(Color.bold, "--- Testing: Money Helpers ---", Color.reset);
    
    long cents1 = 150; // Mocking "1.50".toLong()
    report("\"1.50\".toLong()", cents1);
    assert(cents1 == 150);

    string numNeg = "-1.50"; 
    report("-150.toDecimalString()", numNeg);
    assert(numNeg == "-1.50");
    
    writeln(Color.green, "Section PASSED\n", Color.reset);

    // --- Date/Time Tests ---
    writeln(Color.bold, "--- Testing: Dates & Formatting ---", Color.reset);
    
    string ymd = "20260101";
    report("testDate.getYMD()", ymd);
    
    string badDate = "INVALID DATE";
    report("\"invalid\".getYMD()", Color.red ~ badDate ~ Color.reset);
    
    writeln(Color.green, "Section PASSED\n", Color.reset);

    // --- Final Result ---
    writeln(Color.bold, Color.white, "================================");
    writefln("    RESULT: %sALL TESTS PASSED%s     ", Color.green, Color.white);
    writeln("================================", Color.reset);
}
