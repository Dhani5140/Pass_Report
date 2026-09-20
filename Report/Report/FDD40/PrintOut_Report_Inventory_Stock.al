report 52006 InventoryStockss
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = inventoryStock;

    dataset
    {
        dataitem("Warehouse Entry"; "Warehouse Entry")
        {
            DataItemTableView = sorting(
                "Location Code",
                "Bin Code",
                "Item No.",
                "Registering Date"
            );

            RequestFilterFields =
                "Location Code",
                "Bin Code",
                "Item No.",
                "Registering Date";

            column(Location_Code; "Location Code")
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

            column(Brand; Brand)
            {
            }

            column(Qty_Base; QtyBase)
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

            column(Amount; Amount)
            {
            }

            trigger OnAfterGetRecord()
            var
                ItemRec: Record Item;
                VendorRec: Record Vendor;
                ItemLE: Record "Item Ledger Entry";
                WarehouseEntrySum: Record "Warehouse Entry";
                CurrentKey: Text;
            begin
                Clear(ItemName);
                Clear(Brand);
                Clear(QtyBase);
                Clear(QtyBesar);
                Clear(QtySedang);
                Clear(QtyPcs);
                Clear(Amount);
                Clear(UOMBesar);
                Clear(UOMSedang);
                Clear(UOMPcs);

                // ==========================================
                // GROUP KEY
                // Location + Bin + Item
                // ==========================================

                CurrentKey :=
                    "Location Code" + '|' +
                    "Bin Code" + '|' +
                    "Item No.";

                if CurrentKey = LastKey then begin
                    CurrReport.Skip();
                    exit;
                end;

                LastKey := CurrentKey;

                // ==========================================
                // ITEM
                // ==========================================

                if ItemRec.Get("Item No.") then begin

                    ItemName := ItemRec.Description;

                    // Sementara Brand masih menggunakan Vendor
                    // Nanti kita ubah ke Default Dimension

                    if ItemRec."Vendor No." <> '' then begin
                        if VendorRec.Get(ItemRec."Vendor No.") then
                            Brand := VendorRec.Name;
                    end;

                    // ==========================================
                    // UOM ITEM
                    // ==========================================

                    UOMBesar := ItemRec."Satuan Besar";
                    UOMSedang := ItemRec."Satuan Sedang";
                    UOMPcs := ItemRec."Base Unit of Measure";

                end;

                // ==========================================
                // TOTAL QTY BASE
                // Location + Bin + Item
                // ==========================================

                WarehouseEntrySum.Reset();

                WarehouseEntrySum.CopyFilters("Warehouse Entry");

                WarehouseEntrySum.SetRange(
                    "Location Code",
                    "Location Code"
                );

                WarehouseEntrySum.SetRange(
                    "Bin Code",
                    "Bin Code"
                );

                WarehouseEntrySum.SetRange(
                    "Item No.",
                    "Item No."
                );

                if WarehouseEntrySum.FindSet() then
                    repeat
                        QtyBase += WarehouseEntrySum."Qty. (Base)";
                    until WarehouseEntrySum.Next() = 0;

                // ==========================================
                // HITUNG QTY BERDASARKAN UOM
                // ==========================================

                QtyBesar := GetQtyInUOM(
                    "Item No.",
                    UOMBesar,
                    QtyBase
                );

                QtySedang := GetQtyInUOM(
                    "Item No.",
                    UOMSedang,
                    QtyBase
                );

                QtyPcs := GetQtyInUOM(
                    "Item No.",
                    UOMPcs,
                    QtyBase
                );

                // ==========================================
                // AMOUNT
                // Sementara tetap menggunakan
                // Item Ledger Entry
                // ==========================================

                ItemLE.Reset();

                ItemLE.SetRange(
                    "Item No.",
                    "Item No."
                );

                ItemLE.SetRange(
                    "Location Code",
                    "Location Code"
                );

                ItemLE.SetRange(
                    "Posting Date",
                    0D,
                    "Registering Date"
                );

                if ItemLE.FindSet() then
                    repeat
                        ItemLE.CalcFields("Cost Amount (Actual)");
                        Amount += ItemLE."Cost Amount (Actual)";
                    until ItemLE.Next() = 0;
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
        QtyBase: Decimal;
        QtyBesar: Decimal;
        QtySedang: Decimal;
        QtyPcs: Decimal;

        Amount: Decimal;

        UOMBesar: Code[20];
        UOMSedang: Code[20];
        UOMPcs: Code[10];

        Brand: Text[100];
        ItemName: Text[100];

        LastKey: Text;

    local procedure GetQtyInUOM(
        ItemNo: Code[20];
        UOMCode: Code[20];
        BaseQty: Decimal
    ): Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        if UOMCode = '' then
            exit(0);

        if ItemUOM.Get(ItemNo, UOMCode) then begin
            if ItemUOM."Qty. per Unit of Measure" <> 0 then
                exit(
                    BaseQty /
                    ItemUOM."Qty. per Unit of Measure"
                );
        end;

        exit(0);
    end;
}