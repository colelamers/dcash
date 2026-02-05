module dcash.edit_account;

import dcash.parts;
import dcash.window;
import std.algorithm : move;
import std.conv : to;
import std.string : format;

/// EditAccount window for editing account fields
class EditAccount : Window {
private:
    EditColumnHeaders fieldNames;
    ColumnRow dimensions_;
    CursorCoordinates coordinates_;
    WINDOW* win; // current window

public:
    this(ref ColumnRow parentDims) {
        setupWindow(parts.kCursor);
        setDimensions(parentDims);
        setRenderableRows(AccountColumnHeaders.getHeaderStrings.length);

        // Create window: hardcoded height 10, width = columns - 4, start y/x
        win = newwin(10, dimensions().columns - 4,
                     dimensions().rows - 12, 2);
        keypad(win, true);
        box(win, 0, 0);

        setTop(3);
        setVisibleRows(dimensions().rows - top() - 1);
        setCurrentWindow(win);
    }

    ~this() {
        noecho();
        curs_set(0);
        if (win !is null) {
            werase(win);
            wrefresh(win);
            delwin(win);
        }
    }

    /// Handles input on a transaction
    void keyPressed(ref Transaction tran) {
        if (inputKey() == '\n') {
            curs_set(1);
            echo();

            char[128] buffer;
            int yStart = selectedIndex() + 3;
            int xStart = 18;

            // Clear line
            mvwhline(win, yStart, xStart, ' ', 64);
            mvwgetnstr(win, yStart, xStart, buffer.ptr, 64);

            auto headerEnum = cast(HeaderIndexes)selectedIndex();
            AccountColumnHeaders.setTransactionField(tran, headerEnum, buffer.ptr);

            noecho();
            curs_set(0);
        }
    }

    /// Render a transaction in the window
    void renderTransaction(ref Transaction tran) {
        werase(win);
        box(win, 0, 0);

        int fieldX = 4;
        int valueX = 18;

        mvwprintw(win, 1, fieldX, "FIELD");
        mvwprintw(win, 1, valueX, "VALUE");

        auto headers = AccountColumnHeaders.getHeaderMeta();

        foreach (i, col; headers) {
            int row = 3 + i;
            bool selected = (i == selectedIndex());

            if (selected) {
                wattron(win, A_REVERSE);
                mvwhline(win, row, 1, ' ', dimensions_.columns - 2);
            }

            mvwprintw(win, row, fieldX, "%s", col.title.ptr);
            string value = AccountColumnHeaders.getTransactionField(tran, col.index);
            mvwprintw(win, row, valueX, "%s", value.ptr);

            if (selected) {
                wattroff(win, A_REVERSE);
            }
        }

        wrefresh(win);
    }

    /// Accessors
    ref ColumnRow dimensions() { return dimensions_; }
    ref CursorCoordinates coordinates() { return coordinates_; }

private:
    void setDimensions(ref ColumnRow dims) {
        dimensions_ = move(dims);
    }

    void setCursorCoordinates(ref CursorCoordinates coords) {
        coordinates_ = move(coords);
    }
}

