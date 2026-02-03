module dcash.parts;
import core.stdc.stdint;

// ---------------------------
// Data Structures
// ---------------------------

struct Transaction {
    string date;
    string uuid;
    int64_t credit;
    int64_t debit;
    string siblingAccountUuid;
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

// ---------------------------
// Enums
// ---------------------------

enum HeaderIndexes : int {
    kDate = 0,
    kMemo,
    kTransfer,
    kReconciled,
    kDebit,
    kCredit,
    kERROR_INDEX
}

enum ProcessType : int {
    kString,
    kBoolYesNo,
    kMoney
}

// ---------------------------
// Column / Viewport / Cursor
// ---------------------------

struct HeaderColumnMeta {
    int y = 0;        // row
    int x = 0;        // column
    HeaderIndexes index = HeaderIndexes.kERROR_INDEX;
    string title = "";
    ProcessType process = ProcessType.kString;
}

struct EditColumnHeaders {
    enum field = "FIELD";
    enum value = "VALUE";
}

struct Viewport {
    int top = 0;
    int visibleRows = 0;
}

struct ColumnRow {
    int rows = 0;    // "height"
    int columns = 0; // "width"
}

struct CursorCoordinates {
    int y = 0;
    int x = 0;
}

// ---------------------------
// Flags
// ---------------------------

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

// ---------------------------
// Ncurses window deleter
// ---------------------------

struct WindowDeleter {
    void opCall(void* w) const {
        import core.sys.posix.unistd : NULL;
        import ncurses : delwin;  // if using D ncurses bindings
        if (w !is null) {
            delwin(cast(void*) w);
        }
    }
}

// ---------------------------
// Cell representation
// ---------------------------

struct CellNcurses {
    int y = 0;
    int x = 0;
    string value = "";
    string formatter = "";
}

