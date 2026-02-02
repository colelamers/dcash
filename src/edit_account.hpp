#ifndef EDIT_ACCOUNT_H
#define EDIT_ACCOUNT_H

extern "C" {
    #include <curses.h> 
}

#include <vector>
#include <string>

#include "parts.hpp"
#include "window.hpp"

// todo; needs a refactor according to style guides, private/protected
namespace tcash_core {
    class EditAccount : public Window {
    public:
        EditAccount(parts::ColumnRow& parent_dims);
        ~EditAccount();
        void RenderTransaction(parts::Transaction& tran);
        void KeyPressed(parts::Transaction& tran);
        void DrawTransactionRow(int row, int col, const parts::Transaction& t);
        parts::ColumnRow& dimensions();
        parts::CursorCoordinates& coordinates();
    private:
        parts::EditColumnHeaders field_names_;
        parts::ColumnRow dimensions_;
        parts::CursorCoordinates coordinates_;
        void set_dimensions(const parts::ColumnRow& dims);
        void set_cursor_coordinates(const parts::CursorCoordinates& coords);
    };

    

}

#endif
