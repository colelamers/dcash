module dcash.account;

import std.stdio;
import std.string;
import std.array;
import std.conv;
import core.sync.mutex;
import std.file;
import std.path;

import helper.xml;
import dcash.window;
import dcash.parts : HeaderIndexes, ColumnRow, CursorCoordinates;
import dcash.edit_account;

class Account : Window {
private:
    ColumnRow dimensions_;
    CursorCoordinates coordinates_;
    Xml xmlConfig_;
    Node[] transactions_;
    int selectedIndex_;
    int top_;
    int visibleRows_;

public:
    this() {
        dimensions_ = ColumnRow.init;
        coordinates_ = CursorCoordinates.init;

        // Initialize curses window
        setupWindow(cast(int)HeaderIndexes.kCursor | cast(int)HeaderIndexes.kEcho);
        int rows, cols;
        getmaxyx(stdscr, rows, cols);
        dimensions_.rows = rows;
        dimensions_.columns = cols;

        // Initialize XML
        xmlConfig_ = new Xml();
        setXmlTransactions();
        refreshTransactionsXml();

        keypad(currentWindow(), true);
    }

    ~this() {
        endwin();
    }

    void editTran() {
        auto txn = convertXmlNodeToTransaction(transactions_[selectedIndex_]);
        runEditLoop(txn);
        convertTransactionToNode(transactions_[selectedIndex_], txn);
    }

    void addTran() {
        auto tranNode = xmlConfig_.nodeByPath(["account", "transactions"]).appendChild("tran");

        Transaction txn;
        txn.uuid = helper.Uuid.getUuid();
        txn.memo = "";
        txn.date = "";
        txn.credit = 0.0;
        txn.debit = 0.0;
        txn.reconciled = false;
        txn.transfer = "";

        runEditLoop(txn);
        createNewTransactionNode(tranNode, txn);
        saveDataToXml();
        setXmlTransactions();
        refreshTransactionsXml();
    }

    void deleteTran() {
        auto txn = convertXmlNodeToTransaction(transactions_[selectedIndex_]);
        auto delNode = xmlConfig_.findNodeByAttribute("tran", "uuid", txn.uuid);

        if (delNode.exists()) {
            delNode.node.parent.removeChild(delNode.node);
        }

        saveDataToXml();
        setXmlTransactions();
        refreshTransactionsXml();

        // Adjust selection safely
        if (selectedIndex_ >= transactions_.length) {
            selectedIndex_ = transactions_.length - 1;
        }

        if (selectedIndex_ < 0) {
            selectedIndex_ = 0;
        }
    }

    void keyPressed(int key) {
        final switch (key) {
            case '\n': editTran(); break;
            case KEY_DC: deleteTran(); break;
            case KEY_IC: addTran(); break;
            case 27: break; // ESC
            default: break;
        }
    }

    void renderHeaders() {
        foreach(col; AccountColumnHeaders.getHeaderMeta()) {
            mvwprintw(currentWindow(), col.y, col.x, col.title);
        }
    }

    void drawTransactionRow(int row, Node t) {
        foreach(col; AccountColumnHeaders.getHeaderMeta()) {
            string output;
            string key = toLower(col.title);

            final switch (col.process) {
                case ProcessType.kString: 
                    output = t.attributes().get(key, "");
                    break;
                case ProcessType.kBoolYesNo: 
                    output = (t.attributes().get(key, "n") == "true") ? "y" : "n";
                    break;
                case ProcessType.kMoney:
                    output = helper.strex.getMoneyFromDecimal(t.attributes().get(key, "0"));
                    break;
            }
            mvwprintw(currentWindow(), row, col.x, output);
        }
    }

    void renderAccount() {
        werase(currentWindow());
        box(currentWindow(), 0, 0);
        renderHeaders();

        foreach(i; 0 .. visibleRows_) {
            int txIndex = top_ + i;
            if (txIndex >= transactions_.length) { 
                break;
            }
            
            bool selected = txIndex == selectedIndex_;
            if (selected) {
                wattron(currentWindow(), A_REVERSE);
            }

            drawTransactionRow(top_ + i, transactions_[txIndex]);

            if (selected) {
                wattroff(currentWindow(), A_REVERSE);
            }
        }
        wrefresh(currentWindow());
    }

    void checkWinSizeChange() {
        int y, x;
        getmaxyx(stdscr, y, x);

        if (y != dimensions_.rows) {
            dimensions_.rows = y;
            dimensions_.columns = x;
            visibleRows_ = dimensions_.rows - top_ - 1;
            ensureSelectionVisible();
        }
    }

    void saveDataToXml() {
        xmlConfig_.write(path("savings_transactions.xml"));
    }

private:
    Node[] transactions() { 
        return transactions_; 
    }

    void setXmlTransactions() {
        xmlConfig_.loadFromFile(path("savings_transactions.xml"));
    }
}

