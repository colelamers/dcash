module tcash_core.parts;

import std.stdio;
import std.string;
import std.conv;
import helper.strex;

extern (C):
    struct WINDOW;
    int delWin(WINDOW* win);


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

struct AccountColumnHeaders {

    static void SetTransactionField(
        ref Transaction t,
        HeaderIndexes index,
        string buffer
    ) {
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
                t.debit = helper.strex.convert_money_to_num(buffer);
                break;
            case HeaderIndexes.kCredit:
                t.credit = helper.strex.convert_money_to_num(buffer);
                break;
            default:
                break;
        }
    }

    static string GetTransactionField(
        const ref Transaction t,
        HeaderIndexes index
    ) {
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
                return helper.strex.convert_num_to_money(t.debit);
            case HeaderIndexes.kCredit:
                return helper.strex.convert_num_to_money(t.credit);
            default:
                return "";
        }
    }

    static const(string)[] GetHeaderStrings() {
        static immutable string[] headers = [
            "DATE", "MEMO", "TRANSFER", "RECONCILED", "DEBIT", "CREDIT"
        ];
        return headers;
    }

    static const(HeaderColumnMeta)[] GetHeaderMeta() {
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
    kCursor     = 0x01,
    kEcho       = 0x02,
    kBorder     = 0x04,
    kResizeable = 0x08,
    kColor      = 0x10,
    kMouse      = 0x20,
    kFullScr    = 0x40,
    kLogging    = 0x80
}

// assumes ncurses binding provides WINDOW and delwin
struct WindowDeleter {
    void opCall(WINDOW* w) nothrow {
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

