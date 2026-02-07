module dcash.parts;

static import std.stdio;
static import std.string;
static import std.conv;
static import helper.strex;

extern (C):
    struct WINDOW;
    int delwin(WINDOW* win);

struct Transaction {
    string date;
    string uuid;
    long credit;
    long debit;
    string sibling_account_uuid;
    string transfer;
    string memo;
    bool reconciled;
}

struct Account {
    string uuid;
    string description;
    string type;
    string name;
    bool placeholder;
    bool hidden;
}

enum HeaderIndexes {
    kDate = 0,
    kMemo,
    kTransfer,
    kReconciled,
    kDebit,
    kCredit,
    kERROR_INDEX
}

enum ProcessType {
    kString,
    kBoolYesNo,
    kMoney
}

struct HeaderColumnMeta {
    int y = 0; // row
    int x = 0; // column
    HeaderIndexes index = HeaderIndexes.kERROR_INDEX;
    string title = "";
    ProcessType process = ProcessType.kString;
}


struct EditColumnHeaders {
    const string field = "FIELD";
    const string value = "VALUE";
}

struct Viewport {
    int top = 0;
    int visible_rows = 0;
}

struct ColumnRow {
    int rows = 0;    // height
    int columns = 0; // width
}

struct CursorCoordinates {
    int y = 0;
    int x = 0;
}

enum AppFlags : ubyte {
    kCursor     = 0x01, // 0000 0001, 001
    kEcho       = 0x02, // 0000 0010, 002
    kBorder     = 0x04, // 0000 0100, 004
    kResizeable = 0x08, // 0000 1000, 008
    kColor      = 0x10, // 0001 0000, 016
    kMouse      = 0x20, // 0010 0000, 032
    kFullScr    = 0x40, // 0100 0000, 064
    kLogging    = 0x80  // 1000 0000, 128
}

// assumes ncurses binding provides WINDOW and delwin
struct WindowDeleter {
    void opCall(WINDOW* w) {
        if (w !is null) {
            delwin(w);
        }
    }
}

struct CellNcurses {
    int y = 0;
    int x = 0;
    string value = "";
    string formatter = "";
}

struct AccountColumnHeaders {
    static void 
    SetTransactionField(ref Transaction t, HeaderIndexes index, string buffer) {
        final switch (index) {
            case HeaderIndexes.kDate:
                t.date = buffer;
                break;
            case HeaderIndexes.kMemo:
                t.memo = buffer;
                break;
            case HeaderIndexes.kTransfer:
                t.transfer = buffer;
                break;
            case HeaderIndexes.kReconciled:
                t.reconciled = (buffer == "y");
                break;
            case HeaderIndexes.kDebit:
                t.debit = helper.strex.toLong(buffer);
                break;
            case HeaderIndexes.kCredit:
                t.credit = helper.strex.toLong(buffer);
                break;
           case HeaderIndexes.kERROR_INDEX:
                break;
        }
    }

    static string 
    GetTransactionField(const ref Transaction t, HeaderIndexes index) {
        final switch (index) {
            case HeaderIndexes.kDate:
                return t.date;
            case HeaderIndexes.kMemo:
                return t.memo;
            case HeaderIndexes.kTransfer:
                return t.transfer;
            case HeaderIndexes.kReconciled:
                return t.reconciled ? "y" : "n";
            case HeaderIndexes.kDebit:
                return helper.strex.convertLongToDecimalString(t.debit);
            case HeaderIndexes.kCredit:
                return helper.strex.convertLongToDecimalString(t.credit);
           case HeaderIndexes.kERROR_INDEX:
                return "ERROR_INDEX_OCCURRED";
        }
    }

    static const(string)[] 
    GetHeaderStrings() {
        static immutable string[] headers = [
            "DATE", "MEMO", "TRANSFER", "RECONCILED", "DEBIT", "CREDIT"
        ];
        return headers;
    }

    static const(HeaderColumnMeta)[] 
    GetHeaderMeta() {
        static immutable HeaderColumnMeta[] meta = [
            HeaderColumnMeta(
                1,
                2,
                HeaderIndexes.kDate,
                GetHeaderStrings()[cast(int)HeaderIndexes.kDate],
                ProcessType.kString
            ),
            HeaderColumnMeta(
                1,
                15,
                HeaderIndexes.kMemo,
                GetHeaderStrings()[cast(int)HeaderIndexes.kMemo],
                ProcessType.kString
            ),
            HeaderColumnMeta(
                1,
                30,
                HeaderIndexes.kTransfer,
                GetHeaderStrings()[cast(int)HeaderIndexes.kTransfer],
                ProcessType.kString
            ),
            HeaderColumnMeta(
                1,
                50,
                HeaderIndexes.kReconciled,
                GetHeaderStrings()[cast(int)HeaderIndexes.kReconciled],
                ProcessType.kBoolYesNo
            ),
            HeaderColumnMeta(
                1,
                75,
                HeaderIndexes.kDebit,
                GetHeaderStrings()[cast(int)HeaderIndexes.kDebit],
                ProcessType.kMoney
            ),
            HeaderColumnMeta(
                1,
                90,
                HeaderIndexes.kCredit,
                GetHeaderStrings()[cast(int)HeaderIndexes.kCredit],
                ProcessType.kMoney
            )
        ];
        return meta;
    }
}

