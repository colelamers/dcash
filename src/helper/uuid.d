module helper.uuid;

import std.random : Random, uniform;
import std.array : array;
import std.string : toStringz;
import std.conv : to;

/// Thread-safe UUID v4 generator
class Uuid {
private:
    string uuid_;

public:
    this() {
        uuid_ = generateUuidV4();
    }

    string getUuid() const {
        return uuid_;
    }

private:
    /// Convert 0-15 into a hex char
    char hexDigit(int val) {
        return val < 10 ? cast(char)('0' + val) : cast(char)('a' + val - 10);
    }

    /// Fill buffer with random hex digits
    void fillBuffer(ref Random rnd, ref char[] buf, ref int pos, int count) {
        foreach (_; 0 .. count) {
            buf[pos++] = hexDigit(uniform(0, 16, rnd));
        }
    }

    /// Generate UUID v4
    string generateUuidV4() {
        char[36] buf;
        int pos = 0;

        // Create a local random generator
        auto rnd = Random(uniform(0, int.max));

        // Sections 8-4-4-4-12
        fillBuffer(rnd, buf[], pos, 8);
        buf[pos++] = '-';
        fillBuffer(rnd, buf[], pos, 4);
        buf[pos++] = '-';
        buf[pos++] = '4'; // version 4
        fillBuffer(rnd, buf[], pos, 3);
        buf[pos++] = '-';
        buf[pos++] = hexDigit(uniform(8, 12, rnd)); // variant
        fillBuffer(rnd, buf[], pos, 3);
        buf[pos++] = '-';
        fillBuffer(rnd, buf[], pos, 12);

        return buf.to!string;
    }
}

