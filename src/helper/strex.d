module helper.strex;

static import std.stdio;
static import std.string;
static import std.algorithm;
static import std.conv;
static import std.math;
static import std.format;
static import std.typecons;
static import std.datetime;
static import std.uni;
static import std.exception;
static import std.array;
static import std.ascii;
static import std.range;

string toProper(const ref string s)
{
    if (std.range.empty(s)) {
        return "";
    }
    
    // Makes it entirely to lower, then capitalizes the first letter
    char[] buf = std.string.toLower(s).dup;
    buf[0] = std.ascii.toUpper(buf[0]);
    return std.exception.assumeUnique(buf);
}

/// Money helpers
long toLong(const ref string s)
{
    // Convert string to double and multiply by 100
    double val = std.conv.to!double(s);
    return cast(long) std.math.round(val * 100);
}

string convertLongToDecimalString(const ref long decimal)
{
    bool negative = decimal < 0;
    long absCents = std.math.abs(decimal);
    long dollars = absCents / 100;
    long remainder = absCents % 100;
    return std.format.format("%s%d.%02d", negative ? "-" : "", dollars, remainder);
}

// Converts a string as a decimal into a non-decimal number to ignore floating
// point and decimal oriented string conversion.
// @param s; 
// @ex; s = "1.23"
// @returns; 123
long convertDecimalStringToLong(const ref string s)
{
    if (s.length == 0) { 
        return 0;
    }
    
    long dotPos = std.string.indexOf(s, '.');
    if (dotPos == -1) {
        return std.conv.to!long(s) * 100;
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
        // todo; ~ causes allocation! remove to be able to eliminate GC
        while (centsPart.length < 2) {
            centsPart ~= "0"; 
        }
    }
    // todo; ~ causes allocation! remove to be able to eliminate GC
    dollarsPart ~= centsPart;
    return std.conv.to!long(dollarsPart);
//    return (dollars * 100) + cents;
}

/// Optional conversions
std.typecons.Nullable!int toInt(const ref string s)
{
    try
    {
        return std.typecons.Nullable!int(std.conv.to!int(s));
    }
    catch (Exception)
    {
        return std.typecons.Nullable!int.init;
    }
}

std.typecons.Nullable!double toDouble(const ref string s)
{
    try
    {
        return std.typecons.Nullable!double(std.conv.to!double(s));
    }
    catch (Exception)
    {
        return std.typecons.Nullable!double.init;
    }
}

std.typecons.Nullable!float toFloat(const ref string s)
{
    try
    {
        return std.typecons.Nullable!float(std.conv.to!float(s));
    }
    catch (Exception)
    {
        return std.typecons.Nullable!float.init;
    }
}

/// Date/time parsing and formatting
std.datetime.SysTime parseToSysTime(string dateStr, string fmt)
{
    try
    {
        return std.datetime.SysTime.fromSimpleString(dateStr);
    }
    catch (Exception)
    {
        return std.datetime.SysTime.min;
    }
}

string getYMD(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%Y%m%d");
    if (tp == std.datetime.SysTime.min) {
        return "INVALID DATE";
    }
    // todo; ~ causes allocation! remove to be able to eliminate GC
    return std.format.format("%04d%02d%02d", tp.year, tp.month, tp.day);
}

string getMDY(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%m%d%Y");
    if (tp == std.datetime.SysTime.min) {
        return "INVALID DATE";
    } 
    // todo; ~ causes allocation! remove to be able to eliminate GC
    return std.format.format("%02d%02d%04d", tp.month, tp.day, tp.year);
}

string getDMY(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%d%m%Y");
    if (tp == std.datetime.SysTime.min) { 
        return "INVALID DATE";
    }
    // todo; ~ causes allocation! remove to be able to eliminate GC
    return std.format.format("%02d%02d%04d", tp.day, tp.month, tp.year);
}

string getYMDHMS(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%Y-%m-%d %H:%M:%S");
    if (tp == std.datetime.SysTime.min) { 
        return "INVALID DATE";
    }
    // todo; std.format.format causes allocation! remove to be able to eliminate GC
    return std.format.format("%04d-%02d-%02d %02d:%02d:%02d",
        tp.year, tp.month, tp.day, tp.hour, tp.minute, tp.second);
}

string getFullUTC(string dateStr)
{
    auto tp = parseToSysTime(dateStr, "%Y-%m-%d %H:%M:%S");
    if (tp == std.datetime.SysTime.min) {
        return "INVALID DATE";
    }
    auto utc = tp.toUTC;
    // todo; ~ causes allocation! remove to be able to eliminate GC
    return std.format.format("%04d-%02d-%02d %02d:%02d:%02d UTC",
        utc.year, utc.month, utc.day, utc.hour, utc.minute, utc.second);
}
