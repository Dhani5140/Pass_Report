pageextension 52004 "General Journal Kas Besar Ext" extends "General Journal"
{
    actions
    {
        addafter("Apply Entries")
        {
            action(ReportKasBesarEntry)
            {
                ApplicationArea = All;
                Caption = 'Report Kas Besar Entry';
                Image = Print;
                ToolTip = 'Membuka Report Kas Besar Entry untuk journal template dan journal batch yang sedang aktif.';

                trigger OnAction()
                var
                    GenJournalLine: Record "Gen. Journal Line";
                    JournalTemplateName: Code[10];
                    JournalBatchName: Code[10];
                begin
                    JournalTemplateName := Rec.GetRangeMax("Journal Template Name");
                    JournalBatchName := Rec.GetRangeMax("Journal Batch Name");

                    GenJournalLine.Reset();
                    GenJournalLine.SetRange("Journal Template Name", JournalTemplateName);
                    GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);

                    Report.RunModal(Report::"Kas Besar Entry", true, false, GenJournalLine);
                end;
            }
        }

        addlast(Category_Process)
        {
            actionref(ReportKasBesarEntry_Promoted; ReportKasBesarEntry)
            {
            }
        }
    }
}
