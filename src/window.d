module dcash.window;

import dcash.parts;
import core.stdc.stdint;
import std.exception : enforce;
import std.algorithm : min, max;

// ---------------------------
// Curses C bindings
// ---------------------------
extern(C) {
    alias WINDOW = void;

    // Initialization / teardown
    //WINDOW* initscr();
    void initscr();
    void endwin();
    void cbreak();
    void nocbreak();
    void echo();
    void noecho();
    void curs_set(int visibility);
    void keypad(WINDOW* win, int bf);

    // Window operations
    WINDOW* newwin(int nlines, int ncols, int begin_y, int begin_x);
    void delwin(WINDOW* win);
    void werase(WINDOW* win);
    void box(WINDOW* win, int verch, int horch);
    void wrefresh(WINDOW* win);
    void mvwprintw(WINDOW* win, int y, int x, const(char)* fmt, ...);
    void mvwhline(WINDOW* win, int y, int x, int ch, int n);

    // Input
    void wgetch(WINDOW* win);

    // Standard screen
    WINDOW* stdscr;

    // Key constants
    enum KEY_UP = 65;     // values need to match your system's curses.h
    enum KEY_DOWN = 66;
    enum KEY_LEFT = 68;
    enum KEY_RIGHT = 67;
    enum KEY_HOME = 72;
    enum KEY_END = 70;
    enum KEY_NPAGE = 338;
    enum KEY_PPAGE = 339;
    enum KEY_IC = 331;
    enum KEY_DC = 330;
    enum KEY_F(int n) = 264 + n - 1; // KEY_F1 = 264 etc.
}



// ---------------------------
// Window Class
// ---------------------------

class Window {
public:
    this() {}
    ~this() { destroyWindow(); }

    void navigationSystem() {
        switch(inputKey()) {
            case KEY_UP: upKey(); break;
            case KEY_DOWN: downKey(); break;
            case KEY_PPAGE: pageUpKey(); break;
            case KEY_NPAGE: pageDownKey(); break;
            case KEY_HOME: break; // todo
            case KEY_END: break;  // todo
        }
    }

    bool quitKeyCheck() { return inputKey() == KEY_F(1); }

    void setInputKey() {
        enforce(currentWindow !is null, "Window not initialized");
        inputKey_ = wgetch(currentWindow);
    }

protected:
    void setupWindow(ubyte flags) {
        initscr();
        cbreak();
        curs_set((flags & parts.kCursor) != 0 ? 1 : 0);
        if ((flags & parts.kEcho) != 0)
            echo();
        else
            noecho();
    }

    void destroyWindow() {
        if (currentWindow !is null) {
            delwin(currentWindow);
            endwin();
            currentWindow = null;
        }
    }

    void ensureSelectionVisible() {
        if (selectedIndex < viewStart) {
            viewStart = selectedIndex;
        } else if (selectedIndex >= viewStart + visibleRows) {
            viewStart = selectedIndex - visibleRows + 1;
        }
    }

    // ---------------------------
    // Getters / Setters
    // ---------------------------
    int viewStartValue() { return viewStart; }
    int selectedIndexValue() { return selectedIndex; }
    int visibleRowsValue() { return visibleRows; }
    int topValue() { return top; }
    int renderableRowsValue() { return renderableRows; }
    int inputKeyValue() { return inputKey_; }

    void setViewStart(int n) { viewStart = n; }
    void setSelectedIndex(int n) { selectedIndex = n; }
    void setVisibleRows(int n) { visibleRows = n; }
    void setTop(int n) { top = n; }
    void setRenderableRows(int n) { renderableRows = n; }

    void setCurrentWindow(WINDOW* w) { currentWindow = w; }
    WINDOW* getCurrentWindow() { return currentWindow; }

private:
    WINDOW* currentWindow = null;

    int viewStart = 0;
    int selectedIndex = 0;
    int top = 0;
    int visibleRows = 0;
    int renderableRows = 0;
    int inputKey_;

    void pageUpKey() {
        selectedIndex -= visibleRows - 1;
        if (selectedIndex < 0) selectedIndex = 0;
        ensureSelectionVisible();
    }

    void pageDownKey() {
        selectedIndex += visibleRows - 1;
        if (selectedIndex >= renderableRows) selectedIndex = renderableRows - 1;
        ensureSelectionVisible();
    }

    void upKey() {
        if (selectedIndex > 0) {
            selectedIndex -= 1;
            ensureSelectionVisible();
        }
    }

    void downKey() {
        if (selectedIndex < renderableRows - 1) {
            selectedIndex += 1;
            ensureSelectionVisible();
        }
    }
}

