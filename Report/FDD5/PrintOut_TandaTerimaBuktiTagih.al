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
                // 1. Filter hanya baris Customer agar baris balancing/kosong tidak ikut tercetak
                DataItemTableView = where("Account Type" = const(Customer));

                column(Account_No_; CustomerFullName) { }
                column(Posting_Date; PostingDateText) { }
                column(Amount; SisaFaktur) { }
                column(Document_No_; InvoiceDocNo) { }

                trigger OnAfterGetRecord()
                var
                    Cust: Record Customer;
                    CustLedgEntry: Record "Cust. Ledger Entry";
                begin
                    // 2. Skip jika baris tidak memiliki nomor faktur (mencegah row kosong)
                    if "Applies-to Doc. No." = '' then
                        CurrReport.Skip();

                    // 3. Ambil data Posted Sales Invoice dari Cust. Ledger Entries (Document Type = Invoice saja)
                    CustLedgEntry.Reset();
                    CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
                    CustLedgEntry.SetRange("Document No.", "Applies-to Doc. No.");
                    CustLedgEntry.SetRange("Customer No.", "Account No.");
                    if CustLedgEntry.FindFirst() then begin
                        InvoiceDocNo := CustLedgEntry."Document No.";P
                        if CustLedgEntry."Posting Date" <> 0D then
                            PostingDateText := Format(CustLedgEntry."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')
                        else
                            PostingDateText := '';
                    end else
                        // Skip jika dokumen yang di-apply bukan tipe Invoice
                        CurrReport.Skip();

                    // 4. Ambil nama customer
                    CustomerFullName := "Account No.";
                    if Cust.Get("Account No.") then
                        CustomerFullName := StrSubstNo('%1 - %2', "Account No.", Cust.Name);

                    // 5. Pastikan nilai sisa faktur selalu positif
                    // Catatan: Pastikan field ini sesuai dengan kolom Sisa Faktur di General Cash Rcpt. Subform
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

    var
        CustomerFullName: Text;
        PostingDateText: Text[30];
        InvoiceDocNo: Code[20];
        SisaFaktur: Decimal;
}