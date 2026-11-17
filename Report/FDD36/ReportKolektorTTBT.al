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

                    InvoiceAmountValue := GetPostedSalesInvoiceAmount(PostedAdvanceLine."Applies-to Doc. No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(TTBTReturnValue);
                Clear(ReturnDateValue);
                Clear(ReturnDateText);
                Clear(BranchCodeValue);

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
    var
        PostedAdvLine: Record "Posted Advance Line";
    begin
        TTBTReturnValue := Format(PostedAdvanceHeader."TTBT Return");
        ReturnDateValue := PostedAdvanceHeader."Return Date";
        BranchCodeValue := PostedAdvanceHeader."Shortcut Dimension 2 Code";
        if BranchCodeValue = '' then begin
            PostedAdvLine.SetRange("Document No.", PostedAdvanceHeader."No.");
            PostedAdvLine.SetFilter("Shortcut Dimension 2 Code", '<>%1', '');
            if PostedAdvLine.FindFirst() then
                BranchCodeValue := PostedAdvLine."Shortcut Dimension 2 Code";
        end;

        if ReturnDateValue <> 0D then
            ReturnDateText := Format(ReturnDateValue, 0, '<Day,2>/<Month,2>/<Year4>')
        else
            ReturnDateText := '';
    end;
}