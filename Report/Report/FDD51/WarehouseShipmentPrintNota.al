pageextension 52005 "Warehouse Shipment Print Nota" extends "Warehouse Shipment"
{
    actions
    {
        addlast(Reporting)
        {
            action(CetakSuratJalanNota)
            {
                Caption = 'Print Surat Jalan Nota';
                Image = Print;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::SuratJalanNota, true, false, Rec);
                end;
            }
        }
    }
}
