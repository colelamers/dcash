
#include <stdlib.h>
#include <vector>
#include <string>
#include <chrono>
#include <format>

#include "strex.hpp"
#include "log.hpp"
#include "edit_account.hpp"
#include "parts.hpp"

namespace tcash_core {
     EditAccount::EditAccount(parts::ColumnRow& parent_dims) {
        SetupWindow(parts::kCursor);
        set_dimensions(parent_dims);
        set_renderable_rows(parts::AccountColumnHeaders::GetHeaderStrings().size());
        // todo; hardcoded values bad?
        current_window().reset(
            newwin(10, dimensions().columns - 4, dimensions().rows - 12, 2));
        keypad(current_window().get(), TRUE);
        box(current_window().get(), 0, 0);
        set_top(3); // todo; hardcoded 3
        set_visible_rows(dimensions().rows - top() - 1);
    }

    EditAccount::~EditAccount() {
        // Destructor 
        noecho();
        curs_set(0);
        werase(current_window().get());
        wrefresh(current_window().get());
    }

    void EditAccount::KeyPressed(parts::Transaction& tran) {
        if (input_key() == '\n') { 
            curs_set(1);
            echo();
            std::unique_ptr<char[]> buffer = std::make_unique<char[]>(128);
            // Clear line from selected index text start point to end
            // todo; hardcoded values?
            mvwhline(current_window().get(), selected_index() + 3, 18, ' ', 64);
            mvwgetnstr(current_window().get(), selected_index() + 3, 18, 
                buffer.get(), 64);
            parts::HeaderIndexes header_enum = 
                static_cast<parts::HeaderIndexes>(selected_index());
            parts::AccountColumnHeaders::SetTransactionField(tran, header_enum,
                buffer);
            noecho();
            curs_set(0);
        }
    }

    void EditAccount::RenderTransaction(parts::Transaction& tran) {
        werase(current_window().get());
        box(current_window().get(), 0, 0);
        // todo; hardcoded values
        mvwprintw(current_window().get(), 1, 4, "FIELD");
        mvwprintw(current_window().get(), 1, 18, "VALUE");

        const auto& headers = parts::AccountColumnHeaders::GetHeaderMeta();

        for (size_t i = 0; i < headers.size(); ++i) {
            const auto& col = headers[i];
            int row = 3 + static_cast<int>(i);
            bool selected = (static_cast<int>(i) == selected_index());

            if (selected) {
                wattron(current_window().get(), A_REVERSE);
                mvwhline(current_window().get(), row, 1, ' ',
                    dimensions().columns - 2);
            }

            mvwprintw(current_window().get(), row, 4, "%s",col.title.c_str());
            std::string value = parts::AccountColumnHeaders::GetTransactionField(
                    tran, col.index );
            mvwprintw(current_window().get(), row, 18, "%s",value.c_str());

            if (selected) {
                wattroff(current_window().get(), A_REVERSE);
            }
        }

        wrefresh(current_window().get());
    }

    parts::ColumnRow& EditAccount::dimensions() {
        return dimensions_;
    }
    
    void  EditAccount::set_dimensions(const parts::ColumnRow& dims){
        dimensions_ = std::move(dims);
    }

    parts::CursorCoordinates& EditAccount::coordinates() {
        return coordinates_;
    }

    void  EditAccount::set_cursor_coordinates(
        const parts::CursorCoordinates& coords) {
        coordinates_ = std::move(coords);
    }

}
