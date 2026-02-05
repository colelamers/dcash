
extern "C" {
    #include <curses.h> 
}
#include "window.hpp"
#include "log.hpp"

namespace tcash_core {
    helper::log& Window::LOG__ = helper::log::instance();
    
    void Window::SetupWindow(uint8_t flags) {
        // Setup curses
        initscr();
        cbreak();
        curs_set((flags & parts::kCursor) ? 1 : 0);
        if (flags & parts::kEcho){
            echo();
        }
        else{
            noecho();
        }
    }

    void Window::DestroyWindow() {
        endwin();
    }

    void Window::EnsureSelectionVisible() {
        // This decrements the view_start_ by 1 once we go beyond the
        // visible_rows_ "upward" (subtractive). 
        // Since the selected_index_ gets decremented immediately before this, 
        // we know it will also be decremented if it's beyond the threshold.
        if (selected_index() < view_start()) {
            set_view_start(selected_index());
        }
        // This increments the view_start_ by 1 once we go beyond the 
        // visibile_rows "downards" (additive). visible_rows_ is changed
        // whenever/if the window size is changed.
        else if (selected_index() >= view_start() + visible_rows()) {
            set_view_start(selected_index() - visible_rows() + 1);
        }
    }

    void Window::PageUpKey() {
        set_selected_index(selected_index() - visible_rows() - 1);
        if (selected_index() < 0) {
            set_selected_index(0);
        } 
        EnsureSelectionVisible();
    }

    void Window::PageDownKey() {
        set_selected_index(selected_index() + visible_rows() - 1);
        if (selected_index() >= renderable_rows()) {
            set_selected_index(renderable_rows() - 1);
        }
        EnsureSelectionVisible();
    }

    void Window::UpKey() {
        if (selected_index() > 0) {
            set_selected_index(selected_index() -1);
            EnsureSelectionVisible();
        }
    }

    void Window::DownKey() {
        if (selected_index() < renderable_rows() - 1) {
            set_selected_index(selected_index() + 1);
            EnsureSelectionVisible();
        }
    }

    void Window::NavigationSystem() {
        switch (input_key()) {
            case KEY_UP: 
                UpKey();
                break;
            case KEY_DOWN: 
                DownKey();
                break;
            case KEY_PPAGE: 
                PageUpKey();
                break;
            case KEY_NPAGE:
                PageDownKey();
                break;
            case KEY_HOME: // home key
                // todo; go left?
                break;
            case KEY_END: // end key
                // todo; go right
                break;
            // todo; add sorting functions here
        }
    }

    bool Window::QuitKeyCheck() {
        return input_key() == KEY_F(1); // todo; don't use f1 for quit
    }

    void Window::set_input_key() {
        // We use wgetch because: 
        // getch() == wgetch(stdscr)
        // 
        // If you are trying to operate a newly made window, getch() will 
        // override the screen with wgetch(stdscr) until you finish that call
        // as stdscr takes precedence and will block.
        input_key_ = wgetch(current_window().get());
    }

    int Window::view_start() {
        return view_start_;
    }
    
    int Window::selected_index(){
        return selected_index_;
    }

    int Window::visible_rows() {
        return visible_rows_;
    }
    
    int Window::top() {
        return top_;
    }
    
    int Window::renderable_rows() {
        return renderable_rows_;
    }
    
    int Window::input_key() {
        return input_key_;
    }
    
    void Window::set_view_start(const int num) {
        view_start_ = num;
    }
    
    void Window::set_selected_index(const int num) {
        selected_index_ = num;
    }
    
    void Window::set_visible_rows(const int num) {
        visible_rows_ = num;
    }

    void Window::set_top(const int num) {
        top_ = num;
    }
    
    void Window::set_renderable_rows(const int num) {
        renderable_rows_ = num;
    }

    std::unique_ptr<WINDOW, parts::WindowDeleter>&Window::current_window() {
        return current_window_;
    }

    void Window::set_current_window(
        std::unique_ptr<WINDOW, parts::WindowDeleter> c_win) {
        current_window_ = std::move(c_win);
    }
    
}
