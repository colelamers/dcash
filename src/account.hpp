#ifndef ACCOUNT_H
#define ACCOUNT_H

extern "C" {
    #include <curses.h> 
}

#include <vector>
#include <string>
#include <memory>

#include "parts.hpp"
#include "window.hpp"
#include "xml.hpp"

namespace tcash_core {
    class Account : public Window {
    public:
        Account();
        ~Account();
        void CheckWinSizeChange();
        void RenderAccount();
        void EditTran();
        void DeleteTran();
        void AddTran();
        void KeyPressed();
        void SaveDataToXml();
        void RenderHeaders();
        void DrawTransactionRow(int row, const pugi::xml_node& t);
        parts::ColumnRow& dimensions();
        parts::CursorCoordinates& coordinates();
        const parts::ColumnRow& dimensions() const;
        const parts::CursorCoordinates& coordinates() const;
        std::unique_ptr<helper::xml>& xml_transactions_config();
    private:
        parts::ColumnRow dimensions_;
        parts::CursorCoordinates coordinates_;
        std::unique_ptr<helper::xml> xml_transactions_config_;
        std::vector<pugi::xml_node> transactions_;
        void set_dimensions(parts::ColumnRow& dims);
        void set_cursor_coordinates(parts::CursorCoordinates& coords);
        void set_transactions(std::vector<pugi::xml_node> transactions);
        void set_xml_transactions_config(std::unique_ptr<helper::xml> xml);
        const std::vector<pugi::xml_node>& transactions() const;
        std::vector<pugi::xml_node>& transactions();
        void ConvertTransactionToNode(pugi::xml_node&, parts::Transaction&);
        void CreateNewTransactionNode(pugi::xml_node&, parts::Transaction&);
        void RunEditLoop(parts::Transaction& tran_item);
        parts::Transaction ConvertXmlNodeToTransaction(pugi::xml_node& tran);
        void SetXmlTransactions();
        void RefreshTransactionsXml();
    };
}
#endif
