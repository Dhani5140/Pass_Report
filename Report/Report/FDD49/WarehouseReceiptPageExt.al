pageextension 52002 "Warehouse Receipt Page Ext" extends "Warehouse Receipt"
{
    layout
    {
        addafter(General)
        {
            group("Return Shipping Agent")
            {
                Caption = 'Return Shipping Agent';
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
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
                Image = Print;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.SetRange("No.", Rec."No.");
                    Report.Run(Report::SuratJalanRetur, true, false, Rec);
                end;
            }
        }
    }
}
