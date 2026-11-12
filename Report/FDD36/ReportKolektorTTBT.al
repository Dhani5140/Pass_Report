report 52011 "Report Kolektor TTBT"
{
    Caption = 'Report Kolektor TTBT';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = KolektorTTBT;

    dataset
    {
        dataitem(PostedAdvanceHeader; "Posted Advance Header")
        {
            RequestFilterFields = "No.";

            dataitem(PostedAdvanceLine; "Posted Advance Line")
            {
                DataItemLink = "Document No." = field("No.");

                column(Date; Format(PostedAdvanceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')) { }
                column(TTBTNo; PostedAdvanceHeader."No.") { }
                column(InvoiceNo; PostedAdvanceLine."Applies-to Doc. No.") { }
                column(InvoiceAmount; InvoiceAmountValue) { }
                column(CollectedAmount; Abs(PostedAdvanceLine."Amount (LCY)")) { }
                column(TTBTCollector; PostedAdvanceHeader."Salesman") { }
                column(TTBTReturn; TTBTReturnValue) { }
                column(ReturnDate; ReturnDateText) { }
                column(BranchCode; BranchCodeValue) { }

                trigger OnAfterGetRecord()
                begin
                    Clear(InvoiceAmountValue);

                    // 1. Ambil Invoice Amount (Amount Including VAT) dari Posted Sales Invoice
                    InvoiceAmountValue := GetPostedSalesInvoiceAmount(PostedAdvanceLine."Applies-to Doc. No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(TTBTReturnValue);
                Clear(ReturnDateValue);
                Clear(ReturnDateText);
                Clear(BranchCodeValue);

                // 3. Ambil TTBT Return, Return Date, dan Branch Code dari Posted Gen. Cash Receipt Header
                GetPostedGCRInfo();
            end;

            trigger OnPreDataItem()
            begin
                if (StartingDate <> 0D) or (EndingDate <> 0D) then begin
                    if StartingDate = 0D then
                        StartingDate := EndingDate;
                    if EndingDate = 0D then
                        EndingDate := StartingDate;
                    SetRange("Posting Date", StartingDate, EndingDate);
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(StartingDate; StartingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Starting Date';
                    }
                    field(EndingDate; EndingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Ending Date';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if StartingDate = 0D then
                StartingDate := WorkDate();
            if EndingDate = 0D then
                EndingDate := WorkDate();
        end;
    }

    rendering
    {
        layout(KolektorTTBT)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD36/KolektorTTBT.rdl';
        }
    }

    var
        StartingDate: Date;
        EndingDate: Date;
        InvoiceAmountValue: Decimal;
        TTBTReturnValue: Text[50];
        ReturnDateValue: Date;
        ReturnDateText: Text[20];
        BranchCodeValue: Code[20];

    local procedure GetPostedSalesInvoiceAmount(DocNo: Code[20]): Decimal
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if DocNo = '' then
            exit(0);

        if SalesInvoiceHeader.Get(DocNo) then begin
            SalesInvoiceHeader.CalcFields("Amount Including VAT");
            exit(SalesInvoiceHeader."Amount Including VAT");
        end;

        exit(0);
    end;

    local procedure GetPostedGCRInfo()
    begin
        // Jika "Posted Advance Header" adalah tabel Posted Gen. Cash Receipt Header itu sendiri:
        // Sesuaikan nama field dengan struktur tabel "Posted Advance Header" (misal via Inspect Page Ctrl+Alt+F1)
        TTBTReturnValue := Format(PostedAdvanceHeader."TTBT Return"); // atau field Return status/no di header
        ReturnDateValue := PostedAdvanceHeader."Return Date";
        BranchCodeValue := PostedAdvanceHeader."Shortcut Dimension 1 Code"; // cek apakah Cabang ada di Dim 1 atau Dim 2

        if ReturnDateValue <> 0D then
            ReturnDateText := Format(ReturnDateValue, 0, '<Day,2>/<Month,2>/<Year4>')
        else
            ReturnDateText := '';
    end;
}