report 52000 TandaTerimaBuktiTagih
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = TandaTerimaBuktiTagih;

    dataset
    {
        dataitem(Advance_Header; "Advance Header")
        {
            RequestFilterFields = "No.";
            column(No_; "No.") { }

            column(Employee_Name; "Employee Name") { }
            column(Employee_No_; "Employee No.") { }

            column(Salesman; Salesman) { }
            dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
            {
                DataItemLink = "Code" = field(Salesman);
                column(Sales_Name; Name) { }
            }

            dataitem("Gen. Journal Line"; "Gen. Journal Line")
            {
                DataItemLink = "Document No." = field("No.");

                // Ganti Account No. menjadi CustomerFullName agar nama toko ikut muncul
                column(Account_No_; CustomerFullName) { }

                // Ganti Posting Date menjadi format teks tanpa jam
                column(Posting_Date; PostingDateText) { }


                // Pakai Abs() agar nominal tidak minus
                column(Amount; SisaFaktur) { }

                dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
                {
                    DataItemLink = "Document No." = field("Applies-to Doc. No.");

                    // Beri alias agar tidak bentrok dengan No_ milik header
                    column(Document_No_; "Document No.") { }
                }

                // Tambahkan trigger ini di dalam Gen. Journal Line
                trigger OnAfterGetRecord()
                var
                    Cust: Record Customer;
                begin
                    // Ambil nama customer
                    CustomerFullName := "Account No.";
                    if Cust.Get("Account No.") then
                        CustomerFullName := StrSubstNo('%1 - %2', "Account No.", Cust.Name);

                    // Hilangkan jam dari tanggal
                    if "Posting Date" <> 0D then
                        PostingDateText := Format("Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')
                    else
                        PostingDateText := '';

                    // Buat nilai amount selalu positif
                    SisaFaktur := Abs(Amount);
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content) { }
        }

        actions
        {
            area(processing) { }
        }
    }

    rendering
    {
        layout(TandaTerimaBuktiTagih)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD5/TandaTerimaBuktiTagih.rdl';
        }
    }

    // Tambahkan 3 variabel penampung ini di bawah
    var
        CustomerFullName: Text;
        PostingDateText: Text[30];
        SisaFaktur: Decimal;
        SalesName: Text;
}

pageextension 52010 GeneralCashReceiptExt extends "General Cash Receipt"
{
    actions
    {
        addafter(Release)
        {
            action(PrintTandaTerima)
            {
                Caption = 'Print Tanda Terima';
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    AdvanceHdr: Record "Advance Header";
                begin
                    AdvanceHdr.Reset();
                    AdvanceHdr.SetRange("No.", Rec."No.");
                    Report.Run(Report::TandaTerimaBuktiTagih, true, false, AdvanceHdr);
                end;
            }
        }
    }
}