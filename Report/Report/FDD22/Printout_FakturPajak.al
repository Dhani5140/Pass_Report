report 52002 FakturPajak
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