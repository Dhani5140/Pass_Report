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
            dataitem(PostedAdvanceLine; "Posted Advance Line")
            {
                DataItemLink = "Document No." = field("No.");

                column(Date; PostedAdvanceHeader."Posting Date") { }
                column(TTBTNo; PostedAdvanceHeader."No.") { }
                column(InvoiceNo; PostedAdvanceLine."Applies-to Doc. No.") { }
                column(InvoiceAmount; InvoiceAmountValue) { }
                column(CollectedAmount; PostedAdvanceHeader."Collected Amount") { }
                // column(TTBTCollector; PostedAdvanceHeader."Salesman Code") { }
                // column(TTBTReturn; PostedAdvanceHeader."TTBT Return Code") { }
                column(ReturnDate; PostedAdvanceHeader."Return Date") { }
                column(BranchCode; PostedAdvanceHeader."Shortcut Dimension 1 Code") { }

                trigger OnAfterGetRecord()
                begin
                    InvoiceAmountValue := GetInvoiceAmount(PostedAdvanceLine."Applies-to Doc. No.");
                end;
            }

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
                group(Filter)
                {
                    Caption = 'Filter';
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
        CustomerLedgerEntry: Record "Cust. Ledger Entry";

    local procedure GetInvoiceAmount(DocNo: Code[20]): Decimal
    begin
        if DocNo = '' then
            exit(0);

        CustomerLedgerEntry.Reset();
        CustomerLedgerEntry.SetRange("Document No.", DocNo);
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        if CustomerLedgerEntry.FindFirst() then
            exit(Abs(CustomerLedgerEntry.Amount));

        exit(0);
    end;
}
