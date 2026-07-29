report 52003 PickingList
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = PickingList;

    dataset
    {
        dataitem("Warehouse Activity Header"; "Warehouse Activity Header")
        {
            RequestFilterFields = "No.";

            column(Location_Code; "Location Code") { }
            column(Warehouse_Shipment_No_; "Warehouse Shipment No.") { }
            column(No_; "No.") { }

            dataitem("Shipping Agent Services"; "Shipping Agent Services")
            {

                column(Plat_Nomor; "Plat Nomor") { }
                column(Driver_Name; "Driver Name") { }
            }

            dataitem("Warehouse Activity Line"; "Warehouse Activity Line")
            {
                DataItemLink = "Activity Type" = field("Type"),
                               "No." = field("No.");

                column(Item_No_; "Item No.") { }
                column(Description; Description) { }
                column(Qty__to_Handle; "Qty. to Handle") { }

                dataitem("Item"; "Item")
                {
                    DataItemLink = "No." = field("Item No.");

                    column(Satuan_Besar; "Satuan Besar") { }
                    column(Satuan_Sedang; "Satuan Sedang") { }
                    column(Base_Unit_of_Measure; "Base Unit of Measure") { }

                    dataitem("Item Unit Of Measure"; "Item Unit of Measure")
                    {
                        DataItemLink = "Item No." = field("No.");

                        column(Qty__per_Unit_of_Measure; "Qty. per Unit of Measure") { }
                    }
                }
            }

            trigger OnAfterGetRecord(

            )
            begin

            end;
        }
    }

    rendering
    {
        layout(PickingList)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD31/PickingList.rdl';
        }
    }
}