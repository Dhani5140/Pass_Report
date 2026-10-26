pageextension 52000 "Warehouse Shipment" extends "Warehouse Shipment"
{
    actions
    {
        addlast(Reporting)
        {
            action(CetakSuratJalan)
            {
                Caption = 'Print Surat Jalan';
                Image = Print;
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                trigger OnAction()
                begin
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(52001, true, false, Rec);
                end;
            }
        }
    }
}
