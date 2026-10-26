pageextension 52014 "Posted Purch. Receipt Ext" extends "Posted Purchase Receipt"
{
    actions
    {
        addlast(Reporting)
        {
            action(PrintGeneralReceipt)
            {
                Caption = 'Print Good Receipt Note';
                Image = Print;
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                ToolTip = 'Cetak Good Receipt Note untuk Posted Purchase Receipt yang sedang dibuka.';

                trigger OnAction()
                begin
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::"General Receipt", true, false, Rec);
                end;
            }
        }
    }
}
