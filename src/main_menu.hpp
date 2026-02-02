#ifndef main_menu
#define main_menu

extern "C" {
    #include <curses.h> 
}

#include <vector>
#include <string>
#include <memory>

#include "window.hpp"
#include "account.hpp"

namespace tcash_core {

    class MainMenu : public Window {
        // todo; make windows shared pointers
    public:
        std::vector<accounts> all_accounts;
        MainMenu();
        ~MainMenu();
        void CheckWinSizeChange();
        void RenderAccount();
        void RunEditTranProcess();
        void EnterKeyPressed();
        void SaveDataToXml();
        parts::column_row& dimensions();
        parts::cursor_coordinates& coordinates();
        const parts::column_row& dimensions() const;
        const parts::cursor_coordinates& coordinates() const;
    private:
        parts::column_row dimensions_;
        parts::cursor_coordinates coordinates_;
        void set_dimensions(parts::column_row& dims);
        void set_cursor_coordinates(parts::cursor_coordinates& coords);
        std::unique_ptr<helper::xml> xml_transactions_config_;
        std::vector<pugi::xml_node> transactions_;
        void set_transactions(std::vector<pugi::xml_node> transactions);
        void set_xml_transactions_config(std::unique_ptr<helper::xml> xml);
        helper::xml* xml_transactions_config();
        const std::vector<pugi::xml_node>& transactions() const;
        std::vector<pugi::xml_node>& transactions();
        parts::transaction ConvertTransactionToNode(
            parts::transaction, pugi::xml_node& tran);
        parts::transaction ConvertXmlNodeToTransaction(pugi::xml_node& tran);
        void SetXmlTransactions();
    }
}

#endif
