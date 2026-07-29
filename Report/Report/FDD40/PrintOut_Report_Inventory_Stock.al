report 52006 InventoryStockss
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
            column(Unit_of_Measure_Code; "Unit of Measure Code") { }

            dataitem("Item"; "Item")
            {
                DataItemLink = "No." = field("Item No.");

                column(No_; "No.") { }
                column(Description; Description) { }
                column(qtyBesar; qtyBesar) { }
                column(qtySedang; qtySedang) { }
                column(qtykecil; qtykecil) { }

                dataitem("Item Unit Of Measure"; "Item Unit of Measure")
                {
                    DataItemLink = "Item No." = field("No.");

                    column(Qty__per_Unit_of_Measure; "Qty. per Unit of Measure") { }
                }
            }

            dataitem("Default Dimension"; "Default Dimension")
            {
                column(Dimension_Value_Code; "Dimension Value Code") { }
            }

            trigger OnAfterGetRecord()
            var
                item: Record Item;
            begin
                Clear(qtyBesar);
                Clear(qtySedang);
                Clear(qtykecil);

                item.SetFilter("No.", '%1', "Warehouse Entry"."Item No.");
                if item.FindFirst() then begin
                    if item."Satuan Besar" = "Warehouse Entry"."Unit of Measure Code" then begin
                        qtyBesar := "Warehouse Entry"."Qty. per Unit of Measure";
                    end else if item."Satuan Sedang" = "Warehouse Entry"."Unit of Measure Code" then begin
                        qtySedang := "Warehouse Entry"."Qty. per Unit of Measure";
                    end else begin
                        qtykecil := "Warehouse Entry"."Qty. per Unit of Measure";
                    end;
                end;
            end;


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
        qtyBesar: Decimal;
        qtySedang: Decimal;
        qtykecil: Decimal;
}