pageextension 52003 "Warehouse Shipment Ext" extends "Warehouse Shipment"
{
    actions
    {
        addlast(Reporting)
        {
            action(CetakFaktur)
            {
                Caption = 'Print Faktur';
                Image = Print;
                ApplicationArea = All;

                trigger OnAction()
                var
                    whseShptLine: Record "Warehouse Shipment Line";
                    sudahPick: Boolean;
                begin
                    sudahPick := true;

                    whseShptLine.SetRange("No.", Rec."No.");
                    if whseShptLine.FindSet() then
                        repeat
                            if whseShptLine."Qty. Picked (Base)" = 0 then
                                sudahPick := false;
                        until whseShptLine.Next() = 0;

                    if not sudahPick then
                        Error('et..et.....ett di pick dulu baru print boy');

                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(52005, true, false, Rec);
                end;
            }
        }
    }
}
