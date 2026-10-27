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

                // Format tanggal agar hanya menampilkan hari/bulan/tahun tanpa jam
                column(Date; Format(PostedAdvanceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')) { }
                column(TTBTNo; PostedAdvanceHeader."No.") { }
                column(InvoiceNo; PostedAdvanceLine."Applies-to Doc. No.") { }
                column(InvoiceAmount; InvoiceAmountValue) { }
                column(CollectedAmount; PostedAdvanceLine."Amount (LCY)") { }

                // Gunakan "Salesman" sesuai dokumen FDD
                column(TTBTCollector; PostedAdvanceHeader."Salesman") { }

                // Jika field TTBT Return dan Return Date belum ada di tabel, gunakan string/date kosong:
                column(TTBTReturn; TTBTReturnValue) { }
                column(ReturnDate; Format(ReturnDateValue, 0, '<Day,2>/<Month,2>/<Year4>')) { }

                column(BranchCode; PostedAdvanceHeader."Shortcut Dimension 1 Code") { }

                trigger OnAfterGetRecord()
                begin
                    InvoiceAmountValue := GetInvoiceRemainingAmount(PostedAdvanceLine."Applies-to Doc. No.");
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
        TTBTReturnValue: Code[20];
        ReturnDateValue: Date;

    local procedure GetInvoiceRemainingAmount(DocNo: Code[20]): Decimal
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if DocNo = '' then
            exit(0);

        if SalesInvoiceHeader.Get(DocNo) then begin
            SalesInvoiceHeader.CalcFields("Remaining Amount");
            exit(SalesInvoiceHeader."Remaining Amount");
        end;

        exit(0);
    end;
}