module helper.strex;

import std.stdio;
import std.string;
import std.algorithm;
import std.conv;
import std.math;
import std.format;
import std.typecons;
import std.datetime;
import std.uni;
import std.exception;
import std.array;
import std.ascii : charUpper = toUpper;

string toProper(string s)
{
    if (s.empty) {
        return "";
    }
    
    // Makes it entirely to lower, then capitalizes the first letter
    char[] buf = s.toLower().dup;
    buf[0] = charUpper(buf[0]);
    return assumeUnique(buf);
}

/// Money helpers
long toLong(string s)
{
    // Convert string to double and multiply by 100
    double val = to!double(s);
    return cast(long) round(val * 100);
}

string convertLongToDecimalString(long cents)
{
    bool negative = cents < 0;
    long absCents = abs(cents);
    long dollars = absCents / 100;
    long remainder = absCents % 100;
    return format("%s%d.%02d", negative ? "-" : "", dollars, remainder);
}

// Converts a string as a decimal into a non-decimal number to ignore floating
// point and decimal oriented string conversion.
// @param s; 
// @ex; s = "1.23"
// @returns; 123
long convertDecimalStringToLong(string s)
{
    if (s.length == 0) { 
        return 0;
    }
    
    long dotPos = s.indexOf('.');
    if (dotPos == -1) {
        return to!long(s) * 100;
    }
    
    string dollarsPart = s[0 .. dotPos];
    string centsPart = s[dotPos + 1 .. $];

    // Normalize cents to 2 digits
    if (centsPart.length > 2) {
        centsPart = centsPart[0 .. 2];
    } 
    else {
        // Ensure we always result in 2 digits 
        // (e.g., "1" becomes "10", "" becomes "00")
        while (centsPart.length < 2) {
            centsPart ~= "0"; 
        }
    }
    
    dollarsPart ~= centsPart;
    return to!long(dollarsPart);
//    return (dollars * 100) + cents;
}

/// Optional conversions
Nullable!int toInt(string s)
{
    try
    {
        return Nullable!int(to!int(s));
    }
    catch (Exception)
    {
        return Nullable!int.init;
    }
}

Nullable!double toDouble(string s)
{
    try
    {
        return Nullable!double(to!double(s));
    }
    catch (Exception)
    {
        return Nullable!double.init;
    }
}

Nullable!float toFloat(string s)
{
    try
    {
        return Nullable!float(to!float(s));
    }
    catch (Exception)
    {
        return Nullable!float.init;
    }
}

/// Date/time parsing and formatting
SysTime parseToSysTime(string dateStr, string fmt)
{
    try
    {
        return SysTime.fromSimpleString(dateStr);
    }
    catch (Exception)
    {
        return SysTime.min;
    }
}

string getYMD(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%Y%m%d");
    if (tp == SysTime.min) {
        return "INVALID DATE";
    }
    return format("%04d%02d%02d", tp.year, tp.month, tp.day);
}

string getMDY(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%m%d%Y");
    if (tp == SysTime.min) {
        return "INVALID DATE";
    } 
    return format("%02d%02d%04d", tp.month, tp.day, tp.year);
}

string getDMY(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%d%m%Y");
    if (tp == SysTime.min) return "INVALID DATE";
    return format("%02d%02d%04d", tp.day, tp.month, tp.year);
}

string getYMDHMS(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%Y-%m-%d %H:%M:%S");
    if (tp == SysTime.min) return "INVALID DATE";
    return format("%04d-%02d-%02d %02d:%02d:%02d",
        tp.year, tp.month, tp.day, tp.hour, tp.minute, tp.second);
}

string getFullUTC(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%Y-%m-%d %H:%M:%S");
    if (tp == SysTime.min) return "INVALID DATE";
    auto utc = tp.toUTC;
    return format("%04d-%02d-%02d %02d:%02d:%02d UTC",
        utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second);
}
