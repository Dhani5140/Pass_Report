pageextension 52000 "Warehouse Shipment" extends "Warehouse Shipment"
{
    actions
    {
        addafter("&Print")
        {
            action(CetakSuratJalan)
            {
                Caption = 'Print Surat Jalan';
                Image = Print;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(52001, true, false, Rec);
                end;
            }
        }
        addafter("&Print_Promoted")
        {
            actionref(CetakSuratJalan_Promoted; CetakSuratJalan) { }
        }
    }
}
