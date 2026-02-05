module main;

import dcash.account; // D module for Account

void main(string[] args) {
    // Setup Entities
    Account account = new Account();

    bool running = true;
    while (running) {
        account.checkWinSizeChange();
        account.renderAccount();
        account.setInputKey();

        if (account.quitKeyCheck()) {
            account.saveDataToXml();
            running = false;
            break;
        }

        account.navigationSystem();
        account.keyPressed();
    }
}

