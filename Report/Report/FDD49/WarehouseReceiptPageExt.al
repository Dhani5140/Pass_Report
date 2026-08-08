pageextension 52002 "Warehouse Receipt Page Ext" extends "Warehouse Receipt"
{
    layout
    {
        // ini untuj menambahkan field shipping agent dan shipping agent codenya di warehouse receipt page sebagai tambahan field untuk sales return order
        addafter(General)
        {
            group("Return Shipping Agent") // buat 2 field baru dibawah general tab
            {
                Caption = 'Return Shipping Agent';
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All; // dicoba pakai all dulu karena belum tahu apakah bisa difilter
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        addlast(Reporting)
        {
            action(CetakSuratJalanRetur)
            {
                Caption = 'Print Surat Jalan Retur';
                Image = Print; // tambahkan button extra untuk print surat jalan return di bagian action
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(52001, true, false, Rec);
                end;
            }
        }
    }
}