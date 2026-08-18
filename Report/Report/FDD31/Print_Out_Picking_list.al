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
            column(PrintDateTxt; PrintDateTxt) { }
            column(PrintTimeTxt; PrintTimeTxt) { }
            column(Plat_Nomor; Plat_Nomor) { }
            column(Driver_Name; Driver_Name) { }

            dataitem("Warehouse Activity Line"; "Warehouse Activity Line")
            {
                DataItemLink = "Activity Type" = field("Type"),
                               "No." = field("No.");

                column(Item_No_; "Item No.") { }
                column(Description; Description) { }
                column(Qty__to_Handle; "Qty. to Handle") { }
                column(qtyBesar; qtyBesar) { }
                column(qtySedang; qtySedang) { }
                column(qtykecil; qtykecil) { }

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

                trigger OnAfterGetRecord()
                var
                    item: Record Item;
                begin
                    Clear(qtyBesar);
                    Clear(qtySedang);
                    Clear(qtykecil);



                    item.SetFilter("No.", '%1', "Warehouse Activity Line"."Item No.");
                    if item.FindFirst() then begin
                        if item."Satuan Besar" = "Warehouse Activity Line"."Unit of Measure Code" then begin
                            qtyBesar := "Warehouse Activity Line"."Qty. to Handle";
                        end else if item."Satuan Sedang" = "Warehouse Activity Line"."Unit of Measure Code" then begin
                            qtySedang := "Warehouse Activity Line"."Qty. to Handle";
                        end else begin
                            qtykecil := "Warehouse Activity Line"."Qty. to Handle";
                        end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                ShippingAgentServ: Record "Shipping Agent Services";
            begin
                PrintDateTxt := Format(Today, 0, '<Month Text> <Day,2>, <Year4>');
                PrintTimeTxt := Format(Time, 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>');

                Clear(Plat_Nomor);
                Clear(Driver_Name);
                if ShippingAgentServ.FindFirst() then begin
                    Plat_Nomor := ShippingAgentServ."Plat Nomor";
                    Driver_Name := ShippingAgentServ."Driver Name";
                end;
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

    var
        qtyBesar: Decimal;
        qtySedang: Decimal;
        qtykecil: Decimal;
        PrintDateTxt: Text[50];
        PrintTimeTxt: Text[50];
        Plat_Nomor: Text[100];
        Driver_Name: Text[100];
}