pageextension 52001 "Whse Pick Ext" extends "Warehouse Pick"
{
    actions
    {
        addlast(Reporting)
        {
            action(CetakPickingList)
            {
                Caption = 'Print Picking List';
                Image = Print;
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(52003, true, false, Rec);
                end;
            }
        }
    }
}
