report 52006 InventoryStockss
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = inventoryStockExcel;

    // 1. DATASET
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
                    DecimalPlaces = 0 : 2;
                }
                column(UOM_Besar; UOMBesar)
                {
                }
                column(Qty_Sedang; QtySedang)
                {
                    DecimalPlaces = 0 : 2;
                }
                column(UOM_Sedang; UOMSedang)
                {
                }
                column(Qty_Pcs; QtyPcs)
                {
                    DecimalPlaces = 0 : 2;
                }
                column(UOM_Pcs; UOMPcs)
                {
                }
                column(Qty_Base; QtyBase)
                {
                    DecimalPlaces = 0 : 2;
                }
                column(Amount; Amount)
                {
                    AutoFormatType = 1;
                }

                // ==================================================
                // FILTER TANGGAL
                // ==================================================
                trigger OnPreDataItem()
                begin
                    if EndingDate = 0D then
                        Error('Ending Date wajib diisi.');

                    if (StartingDate <> 0D) and (EndingDate < StartingDate) then
                        Error('Ending Date tidak boleh lebih kecil dari Starting Date.');

                    SetRange("Registering Date", 0D, EndingDate);
                end;

                // ==================================================
                // AFTER GET RECORD WAREHOUSE ENTRY
                // ==================================================
                trigger OnAfterGetRecord()
                var
                    WarehouseEntrySum: Record "Warehouse Entry";
                    WarehouseEntryLocTotal: Record "Warehouse Entry";
                    ValueEntry: Record "Value Entry";
                    CurrentKey: Text;
                    TotalLocQtyBase: Decimal;
                    TotalLocAmount: Decimal;
                begin
                    // Group Key: Location + Bin + Item
                    CurrentKey := "Location Code" + '|' + "Bin Code" + '|' + "Item No.";
                    if CurrentKey = LastKey then begin
                        CurrReport.Skip();
                        exit;
                    end;
                    LastKey := CurrentKey;

                    // Hitung Total Qty Base (Saldo per Bin sampai Ending Date)
                    WarehouseEntrySum.Reset();
                    WarehouseEntrySum.SetRange("Location Code", "Location Code");
                    WarehouseEntrySum.SetRange("Bin Code", "Bin Code");
                    WarehouseEntrySum.SetRange("Item No.", "Item No.");
                    WarehouseEntrySum.SetRange("Registering Date", 0D, EndingDate);
                    WarehouseEntrySum.CalcSums("Qty. (Base)");
                    QtyBase := WarehouseEntrySum."Qty. (Base)";

                    // Jika stok di Bin ini 0, lewati baris ini
                    if QtyBase = 0 then begin
                        CurrReport.Skip();
                        exit;
                    end;

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

                    // Konversi Qty per UOM
                    QtyBesar := GetQtyInUOM("Item No.", UOMBesar, QtyBase);
                    QtySedang := GetQtyInUOM("Item No.", UOMSedang, QtyBase);
                    QtyPcs := GetQtyInUOM("Item No.", UOMPcs, QtyBase);

                    // ==================================================
                    // Hitung Amount (Proporsional per Bin terhadap Lokasi)
                    // ==================================================
                    Amount := 0;
                    TotalLocQtyBase := 0;
                    TotalLocAmount := 0;

                    // 1. Total Stok Base seluruh Bin di Lokasi tersebut
                    WarehouseEntryLocTotal.Reset();
                    WarehouseEntryLocTotal.SetRange("Item No.", "Item No.");
                    WarehouseEntryLocTotal.SetRange("Location Code", "Location Code");
                    WarehouseEntryLocTotal.SetRange("Registering Date", 0D, EndingDate);
                    WarehouseEntryLocTotal.CalcSums("Qty. (Base)");
                    TotalLocQtyBase := WarehouseEntryLocTotal."Qty. (Base)";

                    // 2. Total Cost seluruh Lokasi dari Value Entry
                    ValueEntry.Reset();
                    ValueEntry.SetRange("Item No.", "Item No.");
                    ValueEntry.SetRange("Location Code", "Location Code");
                    ValueEntry.SetRange("Posting Date", 0D, EndingDate);
                    ValueEntry.CalcSums("Cost Amount (Actual)");
                    TotalLocAmount := ValueEntry."Cost Amount (Actual)";

                    // 3. Alokasikan cost ke Bin secara proporsional
                    if TotalLocQtyBase <> 0 then
                        Amount := Round((QtyBase / TotalLocQtyBase) * TotalLocAmount, 0.01)
                    else
                        Amount := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                LastKey := '';
            end;
        }
    }

    // 2. REQUESTPAGE
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

    // 3. RENDERING
    rendering
    {
        layout(inventoryStockExcel)
        {
            Type = Excel;
            LayoutFile = './Report/FDD40/Report_Inventory_Stock.xlsx';
        }
    }

    // 4. GLOBAL VARIABLES
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

    // 5. LOCAL PROCEDURES
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