report 52006 InventoryStockss
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = inventoryStock;

    dataset
    {
        dataitem("Bin Content"; "Bin Content")
        {
            DataItemTableView = sorting("Location Code", "Bin Code", "Item No.");

            column(Location_Code; "Location Code")
            {
            }

            column(Brand; Brand)
            {
            }

            column(Bin_Code; "Bin Code")
            {
            }

            column(Item_No_; "Item No.")
            {
            }

            column(Item_Name; ItemName)
            {
            }

            column(Qty_Besar; QtyBesar)
            {
            }

            column(UOM_Besar; UOMBesar)
            {
            }

            column(Qty_Sedang; QtySedang)
            {
            }

            column(UOM_Sedang; UOMSedang)
            {
            }

            column(Qty_Pcs; QtyPcs)
            {
            }

            column(UOM_Pcs; UOMPcs)
            {
            }

            column(Qty_Base; QtyBase)
            {
            }

            column(Amount; Amount)
            {
            }

            trigger OnAfterGetRecord()
            var
                ItemRec: Record Item;
                VendorRec: Record Vendor;
                ItemUOM: Record "Item Unit of Measure";
                QtyPerUOM: Decimal;
            begin
                Clear(Brand);
                Clear(ItemName);

                Clear(QtyBesar);
                Clear(QtySedang);
                Clear(QtyPcs);
                Clear(QtyBase);

                Clear(UOMBesar);
                Clear(UOMSedang);
                Clear(UOMPcs);

                Clear(Amount);

                // Hitung Quantity dari Bin Content
                CalcFields(Quantity);

                // =====================================================
                // ITEM
                // =====================================================

                if not ItemRec.Get("Item No.") then
                    CurrReport.Skip();

                ItemName := ItemRec.Description;

                // =====================================================
                // BRAND = VENDOR / SUPPLIER
                // =====================================================

                if ItemRec."Vendor No." <> '' then begin
                    if VendorRec.Get(ItemRec."Vendor No.") then
                        Brand := VendorRec.Name;
                end;

                // =====================================================
                // BASE UOM
                // =====================================================

                UOMPcs := ItemRec."Base Unit of Measure";

                // =====================================================
                // UOM BESAR
                // =====================================================

                UOMBesar := ItemRec."Satuan Besar";

                if UOMBesar <> '' then begin
                    if ItemUOM.Get("Item No.", UOMBesar) then begin

                        QtyPerUOM := ItemUOM."Qty. per Unit of Measure";

                        if QtyPerUOM <> 0 then
                            QtyBesar :=
                                Quantity / QtyPerUOM;
                    end;
                end;

                // =====================================================
                // UOM SEDANG
                // =====================================================

                UOMSedang := ItemRec."Satuan Sedang";

                if UOMSedang <> '' then begin
                    if ItemUOM.Get("Item No.", UOMSedang) then begin

                        QtyPerUOM := ItemUOM."Qty. per Unit of Measure";

                        if QtyPerUOM <> 0 then
                            QtySedang :=
                                Quantity / QtyPerUOM;
                    end;
                end;

                // =====================================================
                // QTY PCS
                // =====================================================

                QtyPcs := Quantity;

                // =====================================================
                // QTY BASE
                // =====================================================

                QtyBase := Quantity;

                // =====================================================
                // AMOUNT
                // =====================================================

                Amount := Quantity * ItemRec."Unit Cost";
            end;
        }
    }

    rendering
    {
        layout(inventoryStock)
        {
            Type = RDLC;
            LayoutFile =
                './Report/FDD40/PrintOut_Report_Inventory_Stock.rdl';
        }
    }

    var
        QtyBesar: Decimal;
        QtySedang: Decimal;
        QtyPcs: Decimal;
        QtyBase: Decimal;

        UOMBesar: Code[20];
        UOMSedang: Code[20];
        UOMPcs: Code[20];

        Brand: Text[100];
        ItemName: Text[100];

        Amount: Decimal;
}