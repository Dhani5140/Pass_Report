pageextension 52011 "BR Gen Cash Receipt Ext" extends "General Cash Receipt"
{
    actions
    {
        addlast(Processing) // atau addlast(Reporting)
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
        }
    }
}