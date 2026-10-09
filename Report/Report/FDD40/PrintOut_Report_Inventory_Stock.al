report 52006 InventoryStockss
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = inventoryStockExcel;

    dataset
    {
        // ==========================================================
        // ITEM
        // ==========================================================
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterHeading = 'Filter: Item';
            RequestFilterFields = "No.", "Search Description", "Assembly BOM", "Inventory Posting Group", "Statistics Group", "Vendor No.";
            PrintOnlyIfDetail = true;

            // ======================================================
            // WAREHOUSE ENTRY
            // ======================================================
            dataitem("Warehouse Entry"; "Warehouse Entry")
            {
                DataItemLinkReference = Item;
                DataItemLink = "Item No." = field("No.");
                DataItemTableView = sorting("Location Code", "Bin Code", "Item No.", "Registering Date");

                // ==================================================
                // COLUMNS (Sesuai urutan header layout Excel)
                // ==================================================
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

                // ==================================================
                // FILTER TANGGAL
                // ==================================================
                trigger OnPreDataItem()
                begin
                    if StartingDate = 0D then
                        Error('Starting Date wajib diisi.');

                    if EndingDate = 0D then
                        Error('Ending Date wajib diisi.');

                    if EndingDate < StartingDate then
                        Error('Ending Date tidak boleh lebih kecil dari Starting Date.');

                    SetRange("Registering Date", StartingDate, EndingDate);
                end;

                // ==================================================
                // AFTER GET RECORD WAREHOUSE ENTRY
                // ==================================================
                trigger OnAfterGetRecord()
                var
                    WarehouseEntrySum: Record "Warehouse Entry";
                    ValueEntry: Record "Value Entry";
                    CurrentKey: Text;
                begin
                    // Group Key: Location + Bin + Item
                    CurrentKey := "Location Code" + '|' + "Bin Code" + '|' + "Item No.";
                    if CurrentKey = LastKey then begin
                        CurrReport.Skip();
                        exit;
                    end;
                    LastKey := CurrentKey;

                    // Mengambil Item Info & Satuan UOM
                    ItemName := Item.Description;
                    UOMBesar := Item."Satuan Besar";
                    UOMSedang := Item."Satuan Sedang";
                    UOMPcs := Item."Base Unit of Measure";

                    // Mengambil Dimensi Brand
                    Brand := '';
                    DefaultDim.Reset();
                    DefaultDim.SetRange("Table ID", Database::Item);
                    DefaultDim.SetRange("No.", Item."No.");
                    DefaultDim.SetRange("Dimension Code", 'BRAND');
                    if DefaultDim.FindFirst() then begin
                        DefaultDim.CalcFields("Dimension Value Name");
                        Brand := DefaultDim."Dimension Value Name";
                    end;

                    // Hitung Total Qty Base
                    QtyBase := 0;
                    WarehouseEntrySum.Reset();
                    WarehouseEntrySum.SetRange("Location Code", "Location Code");
                    WarehouseEntrySum.SetRange("Bin Code", "Bin Code");
                    WarehouseEntrySum.SetRange("Item No.", "Item No.");
                    WarehouseEntrySum.SetRange("Registering Date", StartingDate, EndingDate);
                    WarehouseEntrySum.CalcSums("Qty. (Base)");
                    QtyBase := WarehouseEntrySum."Qty. (Base)";

                    // Konversi Qty per UOM
                    QtyBesar := GetQtyInUOM("Item No.", UOMBesar, QtyBase);
                    QtySedang := GetQtyInUOM("Item No.", UOMSedang, QtyBase);
                    QtyPcs := GetQtyInUOM("Item No.", UOMPcs, QtyBase);

                    // Hitung Amount melalui Value Entry (field normal, mendukung CalcSums)
                    Amount := 0;
                    ValueEntry.Reset();
                    ValueEntry.SetRange("Item No.", "Item No.");
                    ValueEntry.SetRange("Location Code", "Location Code");
                    ValueEntry.SetRange("Posting Date", StartingDate, EndingDate);
                    ValueEntry.CalcSums("Cost Amount (Actual)");
                    Amount := ValueEntry."Cost Amount (Actual)";
                end;
            }

            trigger OnAfterGetRecord()
            begin
                LastKey := '';
            end;
        }
    }

    // ============================================================
    // REQUEST PAGE
    // ============================================================
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(UseSKUField; UseStockkeepingUnit)
                    {
                        ApplicationArea = All;
                        Caption = 'Use Stockkeeping Unit';
                    }
                }
                group(DateFilter)
                {
                    Caption = 'Date';

                    field(StartingDateField; StartingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Starting Date';
                    }
                    field(EndingDateField; EndingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Ending Date';
                    }
                }
            }
        }
    }

    // ============================================================
    // RENDERING EXCEL
    // ============================================================
    rendering
    {
        layout(inventoryStockExcel)
        {
            Type = Excel;
            LayoutFile = './Report/FDD40/Report_Inventory_Stock.xlsx';
        }
    }

    // ============================================================
    // VARIABLES
    // ============================================================
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
        DefaultDim: Record "Default Dimension";
        StartingDate: Date;
        EndingDate: Date;
        UseStockkeepingUnit: Boolean;

    // ============================================================
    // LOCAL PROCEDURE: GET QTY UOM
    // ============================================================
    local procedure GetQtyInUOM(
        ItemNo: Code[20];
        UOMCode: Code[20];
        BaseQty: Decimal
    ): Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
        QtyResult: Decimal;
    begin
        if (UOMCode = '') or (BaseQty = 0) then
            exit(0);

        if ItemUOM.Get(ItemNo, UOMCode) then begin
            if ItemUOM."Qty. per Unit of Measure" <> 0 then begin
                QtyResult := BaseQty / ItemUOM."Qty. per Unit of Measure";
                exit(Round(QtyResult, 1, '='));
            end;
        end;

        exit(0);
    end;
}