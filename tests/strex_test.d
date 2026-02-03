module tests.strex_test;

import helper.strex;
import std.stdio;
import std.typecons;
import std.datetime;

struct Color {
    enum string reset  = "\033[0m";
    enum string red    = "\033[31m";
    enum string green  = "\033[32m";
    enum string yellow = "\033[33m";
    enum string blue   = "\033[34m";
    enum string cyan   = "\033[36m";
    enum string white  = "\033[1m";
}

void report(T)(string label, T value) {
    writef("  Checking %-40s | Value: %s%s%s\n", 
        label, Color.yellow, value, Color.reset);
}

void main() {
    writeln(Color.white, "========================================", Color.reset);
    writeln(Color.blue, "   STREX LIBRARY: FULL TEST SUITE", Color.reset);
    writeln(Color.white, "========================================", Color.reset);

    // 1. Case Manipulation
    writeln("\n[1] Case Manipulation");
    string prop = toProper("aLICE iN wONDERLAND");
    report("toProper(\"aLICE iN wONDERLAND\")", prop);
    assert(prop == "Alice in wonderland");
    assert(toProper("") == "");

    // 2. Money Helpers (String/Long conversion)
    writeln("\n[2] Money & Currency");
    
    long l1 = toLong("1.50");
    report("toLong(\"1.50\")", l1);
    assert(l1 == 150);

    string s1 = convertLongToDecimalString(-150);
    report("convertLongToDecimalString(-150)", s1);
    assert(s1 == "-1.50");

    long l2 = convertDecimalStringToLong("12.3");
    report("convertDecimalStringToLong(\"12.3\")", l2);
    assert(l2 == 1230);

    long l3 = convertDecimalStringToLong("0.999"); // Test truncation logic
    report("convertDecimalStringToLong(\"0.999\")", l3);
    assert(l3 == 99);

    // 3. Optional Conversions (Nullable)
    writeln("\n[3] Optional Conversions");
    
    auto nInt = toInt("100");
    report("toInt(\"100\")", nInt.get);
    assert(!nInt.isNull && nInt.get == 100);

    auto nBadInt = toInt("abc");
    report("toInt(\"abc\") isNull", nBadInt.isNull);
    assert(nBadInt.isNull);

    auto nDouble = toDouble("12.34");
    report("toDouble(\"12.34\")", nDouble.get);
    assert(!nDouble.isNull);

    auto nFloat = toFloat("1.2");
    report("toFloat(\"1.2\")", nFloat.get);
    assert(!nFloat.isNull);

    // 4. Date and Time (Using D's SimpleString format)
    // Note: SysTime.fromSimpleString expects "YYYY-Mon-DD HH:MM:SS"
    writeln("\n[4] Date & Time Formatting");
    
    string testDate = "2026-Jan-02 15:30:45";
    
    string ymd = getYMD(testDate);
    report("getYMD(\"2026-Jan-02...\")", ymd);
    assert(ymd == "20260102");

    string mdy = getMDY(testDate);
    report("getMDY(...)", mdy);
    assert(mdy == "01022026");

    string dmy = getDMY(testDate);
    report("getDMY(...)", dmy);
    assert(dmy == "02012026");

    string ymdhms = getYMDHMS(testDate);
    report("getYMDHMS(...)", ymdhms);
    assert(ymdhms == "2026-01-02 15:30:45");

    string utc = getFullUTC(testDate);
    report("getFullUTC(...)", utc);
    // Checking for "UTC" suffix
    assert(utc[$-3..$] == "UTC");

    string badDate = getYMD("not a date");
    report("getYMD(\"invalid\")", badDate);
    assert(badDate == "INVALID DATE");

    writeln("\n", Color.green, "PASSED: All implementation functions verified.", Color.reset);
    writeln(Color.white, "========================================", Color.reset);
}
