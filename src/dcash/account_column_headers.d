module dcash.account_column_headers;

import dcash.parts;
import helper.strex;
import std.array : array;
import std.conv : to;
import std.string : format;

/// AccountColumnHeaders: utility for getting/setting Transaction fields
struct AccountColumnHeaders {

    /// Get a specific part of a transaction
    static string getTransactionPart(ref Transaction t, HeaderIndexes index) {
        final switch (index) {
            case HeaderIndexes.kDate: return t.date;
            case HeaderIndexes.kMemo: return t.memo;
            case HeaderIndexes.kTransfer: return t.transfer;
            case HeaderIndexes.kReconciled: return t.reconciled ? "1" : "0";
            case HeaderIndexes.kDebit: return t.debit.to!string;
            case HeaderIndexes.kCredit: return t.credit.to!string;
            default: return "";
        }
    }

    /// Set a transaction field from a C-style buffer
    static void setTransactionField(ref Transaction t, HeaderIndexes index, char[] buffer) {
        string buf = buffer.idup; // copy buffer to string
        final switch (index) {
            case HeaderIndexes.kDate: t.date = buf; break;
            case HeaderIndexes.kMemo: t.memo = buf; break;
            case HeaderIndexes.kTransfer: t.transfer = buf; break;
            case HeaderIndexes.kReconciled: t.reconciled = (buf == "y"); break;
            case HeaderIndexes.kDebit: t.debit = convertMoneyToDecimal(buf); break;
            case HeaderIndexes.kCredit: t.credit = convertMoneyToDecimal(buf); break;
            default: break;
        }
    }

    /// Get transaction field as string (formatted)
    static string getTransactionField(const ref Transaction t, HeaderIndexes index) {
        final switch (index) {
            case HeaderIndexes.kDate: return t.date;
            case HeaderIndexes.kMemo: return t.memo;
            case HeaderIndexes.kTransfer: return t.transfer;
            case HeaderIndexes.kReconciled: return t.reconciled ? "y" : "n";
            case HeaderIndexes.kDebit: return convertDecimalToMoney(t.debit);
            case HeaderIndexes.kCredit: return convertDecimalToMoney(t.credit);
            default: return "";
        }
    }

    /// Return header strings
    static string[] getHeaderStrings() {
        static immutable string[] headers = ["DATE", "MEMO", "TRANSFER", "RECONCILED", "DEBIT", "CREDIT"];
        return headers;
    }

    /// Return header meta data
    static HeaderColumnMeta[] getHeaderMeta() {
        static immutable HeaderColumnMeta[] meta = [
            HeaderColumnMeta(1, 2, HeaderIndexes.kDate, getHeaderStrings()[cast(int)HeaderIndexes.kDate], ProcessType.kString),
            HeaderColumnMeta(1, 15, HeaderIndexes.kMemo, getHeaderStrings()[cast(int)HeaderIndexes.kMemo], ProcessType.kString),
            HeaderColumnMeta(1, 30, HeaderIndexes.kTransfer, getHeaderStrings()[cast(int)HeaderIndexes.kTransfer], ProcessType.kString),
            HeaderColumnMeta(1, 50, HeaderIndexes.kReconciled, getHeaderStrings()[cast(int)HeaderIndexes.kReconciled], ProcessType.kBoolYesNo),
            HeaderColumnMeta(1, 75, HeaderIndexes.kDebit, getHeaderStrings()[cast(int)HeaderIndexes.kDebit], ProcessType.kMoney),
            HeaderColumnMeta(1, 90, HeaderIndexes.kCredit, getHeaderStrings()[cast(int)HeaderIndexes.kCredit], ProcessType.kMoney)
        ];
        return meta;
    }
}

