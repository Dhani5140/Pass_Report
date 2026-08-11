tableextension 52000 "Warehouse Receipt Header Ext" extends "Warehouse Receipt Header"
{
    fields
    {
        field(52000; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CekDokumenRetur();
            end;
        }
        field(52001; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CekDokumenRetur();
            end;
        }
    }

    local procedure CekDokumenRetur()
    var
        whseRcptLine: Record "Warehouse Receipt Line";
    begin
        whseRcptLine.SetRange("No.", Rec."No.");
        whseRcptLine.SetRange("Source Document", whseRcptLine."Source Document"::"Sales Return Order");
        if whseRcptLine.IsEmpty() then
            Error('No return orders');
    end;
}
