report 52004 inventoryStock
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = inventoryStock;

    dataset
    {
        dataitem("Warehouse Entry"; "Warehouse Entry")
        {
            column(Location_Code; "Location Code") { }
            column(Bin_Code; "Bin Code") { }
            column(Item_No_; "Item No.") { }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = field("Item No.");

                column(Description; Description) { }
                column(Global_Dimension_2_Code; "Global Dimension 2 Code") { }
                column(Satuan_Besar; "Satuan Besar") { }
                column(Satuan_Sedang; "Satuan Sedang") { }
                dataitem("Item Unit of Measure"; "Item Unit of Measure")
                {
                    DataItemLink = "Item No." = field("No.");
                    column(Qty__per_Unit_of_Measure; "Qty. per Unit of Measure") { }
                }
            }

            dataitem("Default Dimension"; "Default Dimension")
            {
                column(Dimension_Value_Name; "Dimension Value Name") { }
                column(Dimension_Value_Code; "Dimension Value Code") { }
            }
        }

    }



    rendering
    {
        layout(inventoryStock)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD40/PrintOut_Report_Inventory_Stock.rdl';
        }
    }

    var
        myInt: Integer;
}