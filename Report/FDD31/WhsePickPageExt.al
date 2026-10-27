pageextension 52001 "Whse Pick Ext" extends "Warehouse Pick"
{
    actions
    {
        addafter("&Print")
        {
            action(CetakPickingList)
            {
                Caption = 'Print Picking List';
                Image = Print;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(52003, true, false, Rec);
                end;
            }
        }
        addfirst(Category_Category4)
        {
            actionref(CetakPickingList_Promoted; CetakPickingList) { }
        }
        addafter("&Print_Promoted")
        {
            actionref(CetakPickingList_Process; CetakPickingList) { }
        }
    }
}
