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

    writeln("\n[1] Case Manipulation");
    string prop = helper.strex.toProper("aLICE iN wONDERLAND");
    report("toProper(\"aLICE iN wONDERLAND\")", prop);
    assert(prop == "Alice in wonderland");
    writeln(Color.green, "PASSED", Color.reset);
    assert(helper.strex.toProper("") == "");
    writeln(Color.green, "PASSED", Color.reset);

    writeln("\n[2] Money & Currency");
    
    long l1 = helper.strex.toLong("1.50");
    report("toLong(\"1.50\")", l1);
    assert(l1 == 150);
    writeln(Color.green, "PASSED", Color.reset);

    string s1 = helper.strex.convertLongToDecimalString(-150);
    report("convertLongToDecimalString(-150)", s1);
    assert(s1 == "-1.50");
    writeln(Color.green, "PASSED", Color.reset);

    long l2 = helper.strex.convertDecimalStringToLong("12.3");
    report("convertDecimalStringToLong(\"12.3\")", l2);
    assert(l2 == 1230);
    writeln(Color.green, "PASSED", Color.reset);

    long l3 = helper.strex.convertDecimalStringToLong("0.999");
    report("convertDecimalStringToLong(\"0.999\")", l3);
    assert(l3 == 99);
    writeln(Color.green, "PASSED", Color.reset);

    writeln("\n[3] Optional Conversions");
    
    auto nInt = helper.strex.toInt("100");
    report("toInt(\"100\")", nInt.get);
    assert(!nInt.isNull && nInt.get == 100);
    writeln(Color.green, "PASSED", Color.reset);

    auto nBadInt = helper.strex.toInt("abc");
    report("toInt(\"abc\") isNull", nBadInt.isNull);
    assert(nBadInt.isNull);
    writeln(Color.green, "PASSED", Color.reset);

    auto nDouble = helper.strex.toDouble("12.34");
    report("toDouble(\"12.34\")", nDouble.get);
    assert(!nDouble.isNull);
    writeln(Color.green, "PASSED", Color.reset);

    auto nFloat = helper.strex.toFloat("1.2");
    report("toFloat(\"1.2\")", nFloat.get);
    assert(!nFloat.isNull);
    writeln(Color.green, "PASSED", Color.reset);

    writeln("\n[4] Date & Time Formatting");
    string testDate = "2026-Jan-02 15:30:45";
    
    string ymd = helper.strex.getYMD(testDate);
    report("getYMD(\"2026-Jan-02...\")", ymd);
    assert(ymd == "20260102");
    writeln(Color.green, "PASSED", Color.reset);

    string mdy = helper.strex.getMDY(testDate);
    report("getMDY(...)", mdy);
    assert(mdy == "01022026");
    writeln(Color.green, "PASSED", Color.reset);

    string dmy = helper.strex.getDMY(testDate);
    report("getDMY(...)", dmy);
    assert(dmy == "02012026");
    writeln(Color.green, "PASSED", Color.reset);

    string ymdhms = helper.strex.getYMDHMS(testDate);
    report("getYMDHMS(...)", ymdhms);
    assert(ymdhms == "2026-01-02 15:30:45");
    writeln(Color.green, "PASSED", Color.reset);

    string utc = helper.strex.getFullUTC(testDate);
    report("getFullUTC(...)", utc);
    // Checking for "UTC" suffix
    assert(utc[$-3..$] == "UTC");
    writeln(Color.green, "PASSED", Color.reset);

    string badDate = helper.strex.getYMD("not a date");
    report("getYMD(\"invalid\")", badDate);
    assert(badDate == "INVALID DATE");
    writeln(Color.green, "PASSED", Color.reset);
    writeln(Color.white, "========================================", Color.reset);
}
