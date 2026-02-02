#include <stdlib.h>
#include <vector>
#include <string>
#include <string.h>
#include <chrono>
#include <format>
// #include "log.hpp"

#include "account.hpp"
#include "edit_account.hpp"
#include "xml.hpp"
#include "strex.hpp"
#include "app_path.hpp"

namespace tcash_core { 
    Account::Account() : dimensions_{}, coordinates_{} {
        SetupWindow(parts::kCursor | parts::kEcho);
        // We get max of stdscr because we want this pegged to terminal size,
        // not according to the current window size
        getmaxyx(stdscr, dimensions().rows, dimensions().columns);
        current_window().reset(newwin(
            dimensions().rows, dimensions().columns, 
            coordinates().y, coordinates().x
        ));
        set_xml_transactions_config(std::make_unique<helper::xml>());
        SetXmlTransactions();
        RefreshTransactionsXml();
        keypad(current_window().get(), TRUE);
    }
    
    Account::~Account() {
        endwin();
    }

    // This is the refresh set to the list when a delete occurs
    void Account::RefreshTransactionsXml() {
        set_transactions(
            // todo; hardcoded values?
            xml_transactions_config()->children_by_path(
                { "account", "transactions" }, "tran")
        );
        set_renderable_rows(transactions().size());
        set_visible_rows(dimensions().rows - top() - 1);
        set_top(3); // todo; hardcoded 3 don't like that? can fix?
    }
    
    void Account::EditTran() {
        // todo; hardcoded values
        parts::Transaction txn = ConvertXmlNodeToTransaction(
            transactions()[selected_index()]);
        RunEditLoop(txn);
        // todo; is a return, why using as void?
        ConvertTransactionToNode(transactions()[selected_index()], txn);
    }

    void Account::RunEditLoop(parts::Transaction& tran_item) {
        EditAccount edit(dimensions());
        bool running = true;
        while (running) {
            edit.RenderTransaction(tran_item);
            edit.set_input_key();
            if (edit.QuitKeyCheck()) { 
                running = false; 
                break; 
            }
            edit.NavigationSystem();
            edit.KeyPressed(tran_item);
        }
    }

    void Account::AddTran() {
        pugi::xml_node tran_node = xml_transactions_config()->node_by_path(
            { "account", "transactions" }).append_child("tran");

        parts::Transaction txn;
        txn.uuid = helper::Uuid{}.GetUuid();
        txn.memo = "";
        txn.date = "";
        txn.credit = 0.00;
        txn.debit = 0.00;
        txn.reconciled = "n";
        txn.transfer = "";

        RunEditLoop(txn);
        CreateNewTransactionNode(tran_node, txn);
        SaveDataToXml();
        SetXmlTransactions();
        RefreshTransactionsXml();
    }

    void Account::DeleteTran() {
        /*
        NOTE: may need to implememnt this instead because it's significantly 
        faster than xPath
        pugi::xml_node child_to_delete;
        for (pugi::xml_node tran : root.children("tran")) {
            if (std::string(tran.attribute("uuid").value()) == "1234") {
                child_to_delete = tran;
                break;
            }
        }
        */
        parts::Transaction txn = ConvertXmlNodeToTransaction(
            transactions()[selected_index()]);
        pugi::xml_node del_node = xml_transactions_config()
            ->find_node_by_attribute("tran", "uuid", txn.uuid);

        if (del_node) {
            // Pugi requires to you move to the parent to delete a node below it
            del_node.parent().remove_child(del_node);
        }

        SaveDataToXml();
        SetXmlTransactions();
        RefreshTransactionsXml();

        // Now adjust selected_index safely
        if (selected_index() >= renderable_rows()) {
            set_selected_index(renderable_rows() - 1); // move highlight up
        }
        
        if (selected_index() < 0) {
            set_selected_index(0); // handle empty list
        }
    }

    void Account::KeyPressed() {
        switch(input_key()) {
            case '\n': // enter key
                EditTran();
                break;
            case KEY_DC: // del key
                DeleteTran();
                break;
            case KEY_IC: // ins key
                AddTran();
                break;
            case 27: // esc key
                // todo; change for edit tran
                break;
            default:
                break;
        }
    }

    void Account::RenderHeaders() {
        static const auto list = parts::AccountColumnHeaders::GetHeaderMeta();
        for (const auto& col : list) {
            mvwprintw(current_window().get(), 
                col.y, col.x, "%s", col.title.c_str());
        }
    }

    void Account::DrawTransactionRow(int row, const pugi::xml_node& t) {
        const auto& headers = parts::AccountColumnHeaders::GetHeaderMeta();
        for (const auto& col : headers) {
            std::string output;
            std::string corrected_key = helper::strex::tolower(col.title);
            switch (col.process) {
                case parts::ProcessType::kString:
                    output = t.attribute(corrected_key.c_str()).value();
                    break;
                case parts::ProcessType::kBoolYesNo:
                    output = t.attribute(
                        corrected_key.c_str()).as_bool() ? "y" : "n";
                    break;
                case parts::ProcessType::kMoney:
                    output = helper::strex::get_money_from_num(
                        t.attribute(corrected_key.c_str()).value());
                    break;
            }

            mvwprintw(current_window().get(), row, col.x, "%s", output.c_str());
        }
    }

    void Account::RenderAccount() {
        // todo; structuralize this. can easily perform loops or something
        // of these items.
        werase(current_window().get());
        box(current_window().get(), 0, 0);
        RenderHeaders();

        for (int i = 0; i < visible_rows(); i++) {
            // i + view_start == selected_index
            int tx_index = view_start() + i;
            if (tx_index >= renderable_rows()) {
                break;
            }

            int row = top() + i;
            bool selected = (tx_index == selected_index());
            if (selected) {
                wattron(current_window().get(), A_REVERSE);
                mvwhline(current_window().get(), row, 1, ' ',
                    dimensions().columns - 2);
            }
            
            DrawTransactionRow(row, transactions()[tx_index]);

            // Turn off previous line attribute
            if (selected) {
                wattroff(current_window().get(), A_REVERSE);
            }
        }
        wrefresh(current_window().get());
    }

    void Account::CheckWinSizeChange() {
        int y, x;
        getmaxyx(stdscr, y, x);
        LOG__.trace_wf("xml");

        // If max y val of window size detected, reset dimensions
        if (y != dimensions().rows) {
            dimensions().rows = y;
            dimensions().columns = x;
            // dim.row - 2 + top + 1
            set_visible_rows(dimensions().rows - top() - 1); 
            EnsureSelectionVisible();
        }
    }

    parts::Transaction Account::ConvertXmlNodeToTransaction(
        pugi::xml_node& node) {
        parts::Transaction tran{};
        tran.memo = node.attribute("memo").value();
        tran.date = node.attribute("date").value();
        tran.uuid = node.attribute("uuid").value();
        tran.credit = helper::strex::convert_money_to_num(
            node.attribute("credit").value());
        tran.debit = helper::strex::convert_money_to_num(
            node.attribute("debit").value());
        tran.reconciled  = node.attribute("reconciled").as_bool();
        return tran;
    }

    void Account::ConvertTransactionToNode(pugi::xml_node& node, 
        parts::Transaction& tran) {
        // Only works with existing nodes, silently fails otherwise
        node.attribute("memo").set_value(tran.memo);
        node.attribute("date").set_value(tran.date);
        node.attribute("uuid").set_value(tran.uuid);
        node.attribute("credit").set_value(tran.credit);
        node.attribute("debit").set_value(tran.debit);
        node.attribute("reconciled").set_value(tran.reconciled);
    }

    void Account::CreateNewTransactionNode(pugi::xml_node& node, 
        parts::Transaction& tran) {
        // Only works with new nodes
        node.append_attribute("memo") = tran.memo.c_str();
        node.append_attribute("date") = tran.date.c_str();
        node.append_attribute("uuid") = tran.uuid.c_str();
        node.append_attribute("credit") = tran.credit;
        node.append_attribute("debit") = tran.debit;
        node.append_attribute("reconciled") = tran.reconciled;
    }

    void Account::SetXmlTransactions() {
        std::filesystem::path conf_path = std::filesystem::path(
            helper::app_path::get_fully_qualified_dir_path("confs"))
            / "savings_transactions.xml";
        xml_transactions_config()->load_from_file(conf_path.string());
    }

    void Account::SaveDataToXml() {
        xml_transactions_config()->write(
            xml_transactions_config()->get_full_path()
            / "savings_transactions.xml");
    }

    void Account::set_transactions(std::vector<pugi::xml_node> transactions) {
        transactions_ = std::move(transactions);
    }

    void Account::set_xml_transactions_config(
        std::unique_ptr<helper::xml> xml) {
        xml_transactions_config_ = std::move(xml);
    }

    std::unique_ptr<helper::xml>& Account::xml_transactions_config() {
        return xml_transactions_config_;
    }

    std::vector<pugi::xml_node>& Account::transactions() {
        return transactions_;
    }

    const std::vector<pugi::xml_node>& Account::transactions() const {
        return transactions_;
    }

    void Account::set_dimensions(parts::ColumnRow& dims){
        dimensions_ = dims;
    }

    void Account::set_cursor_coordinates(parts::CursorCoordinates& coords){
        coordinates_ = coords;
    }

    parts::ColumnRow& Account::dimensions() {
        return dimensions_;
    }

    const parts::ColumnRow& Account::dimensions() const {
        return dimensions_;
    }

    parts::CursorCoordinates& Account::coordinates() {
        return coordinates_;
    }

    const parts::CursorCoordinates& Account::coordinates() const {
        return coordinates_;
    }
}

