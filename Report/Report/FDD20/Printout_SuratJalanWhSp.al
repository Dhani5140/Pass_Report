report 52001 SuratJalanWhSp
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = SuratJalanWhSp;

    dataset
    {
        dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
        {
            RequestFilterFields = "No.";
            column(Nama_Driver; "Nama Driver") { }

            column(Shipment_Date; "Shipment Date") { }


            column(No_; "No.") { }
            dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
            {


                DataItemLink = "No." = field("No.");

                column(Invoice_No_; "Invoice No.") { }
                column(Destination_No_; "Destination No.") { }
                column(Cubage; Cubage) { }
                column(Total_Tonase; "Total Tonase") { }

                column(Total_Cubage; "Total Cubage") { }

                dataitem("Sales Header"; "Sales Header")
                {
                    DataItemLink = "No." = field("Source No.");
                    column(Salesperson_Code; "Salesperson Code") { }
                    column(Sell_to_Customer_Name; "Sell-to Customer Name") { }
                    column(Ship_to_Address; "Ship-to Address") { }

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
        layout(SuratJalanWhSp)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD20/SuratJalanWhSp.rdl';
        }
    }
}