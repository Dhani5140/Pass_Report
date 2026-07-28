report 52000 TandaTerimaBuktiTagih
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = TandaTerimaBuktiTagih;

    dataset
    {
        dataitem(Advance_Header; "Advance Header")
        {
            RequestFilterFields = "No.";
            column(No_; "No.") { }
            dataitem("Gen. Journal Line"; "Gen. Journal Line")
            {
                DataItemLink = "Document No." = field("No.");
                column(Account_No_; "Account No.") { }
                column(Posting_Date; "Posting Date") { }
                column(Amount; Amount) { }
                dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
                {
                    DataItemLink = "Document No." = field("Applies-to Doc. No.");
                    column(Document_No_; "Document No.") { }
                }
            }



        }
    }

    requestpage
    {

        layout
        {
            area(Content)
            {
                // group(GroupName)
                // {
                //     field(Name; SourceExpression)
                //     {

                //     }
                // }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }

    rendering
    {
        layout(TandaTerimaBuktiTagih)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD5/TandaTerimaBuktiTagih.rdl';
        }
    }
}