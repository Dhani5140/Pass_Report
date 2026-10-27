pageextension 52006 "Report Settlement Harian" extends "Posted Gen. Cash Receipt List"
{
    actions
    {
        addlast(Processing)
        {
            action(ReportSettlementHarian)
            {
                Caption = 'Report Settlement Harian';
                Image = Report;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Report.Run(52009);
                end;
            }
        }
    }
}
