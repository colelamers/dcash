#ifndef WINDOW_H
#define WINDOW_H

#include <memory>

#include "parts.hpp"
#include "log.hpp"

namespace tcash_core {
    // bug; there is is an issue where when there is no data/nothing renders, 
    // if you hit enter on an empty state, it throws a segfault! that will
    //  obviously need to be addressed later because you need to make new 
    // transactions on an empty list.
    class Window {
    public:
        void NavigationSystem();
        bool QuitKeyCheck();
        // Since this is wgetch() related, we need to access it for the window
        void set_input_key();
        virtual ~Window() = default;
        static helper::log& LOG__; // todo delete?
    protected:
        std::unique_ptr<WINDOW, parts::WindowDeleter>& current_window();
        void set_current_window(
            std::unique_ptr<WINDOW, parts::WindowDeleter> current_window);
        void SetupWindow(uint8_t flags);
        void DestroyWindow();
        void EnsureSelectionVisible();
        int view_start();
        int selected_index();
        int visible_rows();
        int top();
        int renderable_rows();
        int input_key();
        void set_view_start(const int num);
        void set_input_key(const int num);
        void set_visible_rows(const int num);
        void set_selected_index(const int num);
        void set_top(const int num);
        void set_renderable_rows(const int num);
    private:
        void PageUpKey();
        void PageDownKey();
        void UpKey();
        void DownKey();
        std::unique_ptr<WINDOW, parts::WindowDeleter> current_window_;
        // transaction render loop starting index. 0 BASED! 
        int view_start_ = 0;
        // actively highlighted location
        int selected_index_ = 0;
        // Top border and headers
        int top_ = 0;
        // number of datarows between borders, headers, etc.
        int visible_rows_ = 0;
        // total number of transactions
        int renderable_rows_ = 0; 
        int input_key_;
    };
}

#endif
