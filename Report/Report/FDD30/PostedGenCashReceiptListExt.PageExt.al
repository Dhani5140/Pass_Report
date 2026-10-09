pageextension 52013 "PostedGenCashReceiptListExt" extends "Posted Gen. Cash Receipt List"
{
    actions
    {
        addlast(Processing)
        {
            action(ReportKolektorTTBT)
            {
                ApplicationArea = All;
                Caption = 'Report Kolektor TTBT';
                ToolTip = 'Cetak Report Kolektor TTBT.';
                Image = PrintReport;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Report.Run(Report::"Report Kolektor TTBT");
                end;
            }
        }
    }
}