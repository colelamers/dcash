#include <array>
#include <iostream>
#include <map>

#include "tcash.hpp"
#include "account.hpp"
#include "parts.hpp"

static std::string get_date() {
    // todo; delete this function. i just used it for mocking
    auto now = std::chrono::system_clock::now();
    std::chrono::zoned_time local{std::chrono::current_zone(), now};
    std::chrono::year_month_day ymd{ floor<std::chrono::days>(local.get_local_time()) };
    return std::format("{:%Y-%m-%d}", ymd);
}

int main(int argc, char* argv[]) {
    // Setup Entities
    tcash_core::Account account;

    // todo; this is the account loop
    bool running = true;
    while (running) {
        account.CheckWinSizeChange();
        account.RenderAccount();
        account.set_input_key();
        if (account.QuitKeyCheck()) {
            account.SaveDataToXml();
            running = false; 
            break; 
        }
        account.NavigationSystem();
        account.KeyPressed();
    }
    return 0;
}
