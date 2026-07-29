pageextension 52000 "Warehouse Shipment" extends "Warehouse Shipment"
{
    actions
    {
        addlast(Reporting)
        {
            action(Print)
            {
                Caption = 'Print Surat jalan';
                trigger OnAction()
                begin
                    rec.SetRange("No.", Rec."No.");
                    Report.Run(52001, true, false, rec);
                end;
            }
        }
    }

}