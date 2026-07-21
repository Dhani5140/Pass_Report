report 52000 FakturPajak
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = FakturPajak;

    dataset
    {
        dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
        {
            column(No_; "No.")
            {

            }
        }
    }

    requestpage
    {
        // AboutTitle = 'Teaching tip title';
        // AboutText = 'Teaching tip content';
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
        layout(FakturPajak)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD22/FakturPajak.rdlc';
        }
    }
}