report 52004 "Kas Besar Entry"
{
    Caption = 'Kas Besar Entry';
    ApplicationArea = All;
    DefaultRenderingLayout = KasBesarEntryRDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(GenJournalLine; "Gen. Journal Line")
        {
            DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");
            RequestFilterFields = "Journal Template Name", "Journal Batch Name", "Posting Date", "Payment Method Code", "Account No.", "Shortcut Dimension 1 Code";

            column(CompanyNameValue; CompanyName())
            {
            }
            column(ReportTitle; ReportTitleLbl)
            {
            }
            column(JournalTemplateName; GenJournalLine."Journal Template Name")
            {
            }
            column(JournalBatchName; GenJournalLine."Journal Batch Name")
            {
            }
            column(PostingDate; GenJournalLine."Posting Date")
            {
            }
            column(EntryType; GenJournalLine."Payment Method Code")
            {
            }
            column(EntryUser; EntryUserName)
            {
            }
            column(CustomerNo; CustomerNoValue)
            {
            }
            column(CustomerName; CustomerNameValue)
            {
            }
            column(BranchCode; GenJournalLine."Shortcut Dimension 1 Code")
            {
            }
            column(AccountDestination; AccountDestinationValue)
            {
            }
            column(AmountCredit; GenJournalLine.Amount)
            {
            }
            column(AmountBalance; AmountBalanceValue)
            {
            }

            trigger OnAfterGetRecord()
            begin
                if (GenJournalLine."Account No." = '') and
                   (GenJournalLine."Bal. Account No." = '') and
                   (GenJournalLine.Amount = 0)
                then begin
                    CurrReport.Skip();
                    exit;
                end;

                SetEntryUser();
                SetCustomerInformation();
                SetAccountDestinationAndBalance();
            end;
        }
    }

    rendering
    {
        layout(KasBesarEntryRDLC)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD27/KasBesarEntry.rdl';
            Caption = 'Kas Besar Entry';
            Summary = 'Print-out Kas Besar Entry dari General Journal.';
        }
    }

    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Customer: Record Customer;
        BankAccount: Record "Bank Account";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        GLAccount: Record "G/L Account";
        EntryUserName: Text[100];
        CustomerNoValue: Code[20];
        CustomerNameValue: Text[100];
        AccountDestinationValue: Code[20];
        AmountBalanceValue: Decimal;
        ReportTitleLbl: Label 'REPORT KAS BESAR ENTRY';

    local procedure SetEntryUser()
    begin
        Clear(EntryUserName);
        if GenJournalLine."Salespers./Purch. Code" = '' then
            exit;

        SalespersonPurchaser.Reset();
        if SalespersonPurchaser.Get(GenJournalLine."Salespers./Purch. Code") then
            EntryUserName := SalespersonPurchaser.Name;
    end;

    local procedure SetCustomerInformation()
    begin
        Clear(CustomerNoValue);
        Clear(CustomerNameValue);

        if GenJournalLine."Account Type" <> GenJournalLine."Account Type"::Customer then
            exit;

        CustomerNoValue := GenJournalLine."Account No.";
        Customer.Reset();
        if Customer.Get(CustomerNoValue) then
            CustomerNameValue := Customer.Name;
    end;

    local procedure SetAccountDestinationAndBalance()
    var
        DestinationGLAccountNo: Code[20];
    begin
        Clear(AccountDestinationValue);
        Clear(AmountBalanceValue);
        Clear(DestinationGLAccountNo);

        case GenJournalLine."Bal. Account Type" of
            GenJournalLine."Bal. Account Type"::"G/L Account":
                begin
                    AccountDestinationValue := GenJournalLine."Bal. Account No.";
                    DestinationGLAccountNo := GenJournalLine."Bal. Account No.";
                end;
            GenJournalLine."Bal. Account Type"::"Bank Account":
                begin
                    AccountDestinationValue := GenJournalLine."Bal. Account No.";
                    DestinationGLAccountNo := GetBankGLAccountNo(GenJournalLine."Bal. Account No.");
                end;
        end;

        if DestinationGLAccountNo = '' then
            exit;

        GLAccount.Reset();
        if GLAccount.Get(DestinationGLAccountNo) then begin
            GLAccount.CalcFields(Balance);
            AmountBalanceValue := GLAccount.Balance;
        end;
    end;

    local procedure GetBankGLAccountNo(BankAccountNo: Code[20]): Code[20]
    begin
        if BankAccountNo = '' then
            exit('');

        BankAccount.Reset();
        if not BankAccount.Get(BankAccountNo) then
            exit('');

        if BankAccount."Bank Acc. Posting Group" = '' then
            exit('');

        BankAccountPostingGroup.Reset();
        if not BankAccountPostingGroup.Get(BankAccount."Bank Acc. Posting Group") then
            exit('');

        exit(BankAccountPostingGroup."G/L Account No.");
    end;
}
