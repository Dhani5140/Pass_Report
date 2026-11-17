pageextension 52011 "BR Gen Cash Receipt Ext" extends "General Cash Receipt"
{
    actions
    {
        modify("Print TTBT")
        {
            trigger OnAfterAction()
            begin
                PrintTandaTerima();
            end;
        }
        addlast(Processing)
        {
            action(ReportPelunasanCashTransfer)
            {
                Caption = 'Report Pelunasan Cash & Transfer';
                ToolTip = 'Mencetak report pelunasan cash & transfer untuk dokumen ini.';
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AdvHeader: Record "Advance Header";
                begin
                    AdvHeader.Reset();
                    AdvHeader.SetRange("No.", Rec."No.");
                    Report.RunModal(Report::"Pelunasan Cash Transfer", true, false, AdvHeader);
                end;
            }
            action(PrintTandaTerima)
            {
                Caption = 'Print Tanda Terima';
                ToolTip = 'Mencetak Tanda Terima Bukti Tagih untuk dokumen ini.';
                ApplicationArea = All;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    PrintTandaTerima();
                end;
            }
        }
    }

    local procedure PrintTandaTerima()
    var
        AdvHeader: Record "Advance Header";
    begin
        AdvHeader.SetRange("No.", Rec."No.");
        Report.RunModal(Report::TandaTerimaBuktiTagih, true, false, AdvHeader);
    end;
}