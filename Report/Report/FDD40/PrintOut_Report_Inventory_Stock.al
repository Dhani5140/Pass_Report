report 52006 InventoryStockss
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = inventoryStock;

    dataset
    {
        // ==========================================================
        // ITEM
        // ==========================================================

        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");

            RequestFilterHeading = 'Filter: Item';

            RequestFilterFields =
                "No.",
                "Search Description",
                "Assembly BOM",
                "Inventory Posting Group",
                "Statistics Group",
                "Vendor No.";

            PrintOnlyIfDetail = true;

            // ======================================================
            // WAREHOUSE ENTRY
            // ======================================================

            dataitem("Warehouse Entry"; "Warehouse Entry")
            {
                DataItemLinkReference = Item;

                DataItemLink =
                    "Item No." = field("No.");

                DataItemTableView = sorting(
                    "Location Code",
                    "Bin Code",
                    "Item No.",
                    "Registering Date"
                );

                // ==================================================
                // COLUMNS
                // ==================================================

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

                // ==================================================
                // FILTER TANGGAL
                // ==================================================

                trigger OnPreDataItem()
                begin
                    // Starting Date dan Ending Date wajib diisi
                    if StartingDate = 0D then
                        Error('Starting Date wajib diisi.');

                    if EndingDate = 0D then
                        Error('Ending Date wajib diisi.');

                    if EndingDate < StartingDate then
                        Error(
                            'Ending Date tidak boleh lebih kecil dari Starting Date.'
                        );

                    SetRange(
                        "Registering Date",
                        StartingDate,
                        EndingDate
                    );
                end;

                // ==================================================
                // AFTER GET RECORD
                // ==================================================

                trigger OnAfterGetRecord()
                var
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

                    // ============================================
                    // GROUP KEY
                    // Location + Bin + Item
                    // ============================================

                    CurrentKey :=
                        "Location Code" + '|' +
                        "Bin Code" + '|' +
                        "Item No.";

                    if CurrentKey = LastKey then begin
                        CurrReport.Skip();
                        exit;
                    end;

                    LastKey := CurrentKey;

                    // ============================================
                    // ITEM INFORMATION
                    // Menggunakan parent Item
                    // ============================================

                    ItemName := Item.Description;

                    // ============================================
                    // BRAND
                    // Default Dimension
                    // Dimension Code = BRAND
                    // ============================================

                    DefaultDim.Reset();

                    DefaultDim.SetRange(
                        "Table ID",
                        Database::Item
                    );

                    DefaultDim.SetRange(
                        "No.",
                        Item."No."
                    );

                    DefaultDim.SetRange(
                        "Dimension Code",
                        'BRAND'
                    );

                    if DefaultDim.FindFirst() then begin
                        DefaultDim.CalcFields(
                            "Dimension Value Name"
                        );

                        Brand :=
                            DefaultDim."Dimension Value Name";
                    end;

                    // ============================================
                    // UOM ITEM
                    // ============================================

                    UOMBesar := Item."Satuan Besar";
                    UOMSedang := Item."Satuan Sedang";
                    UOMPcs := Item."Base Unit of Measure";

                    // ============================================
                    // TOTAL QTY BASE
                    // Location + Bin + Item
                    // ============================================

                    WarehouseEntrySum.Reset();

                    WarehouseEntrySum.CopyFilters(
                        "Warehouse Entry"
                    );

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
                            QtyBase +=
                                WarehouseEntrySum."Qty. (Base)";
                        until WarehouseEntrySum.Next() = 0;

                    // ============================================
                    // QTY BESAR
                    // ============================================

                    QtyBesar :=
                        GetQtyInUOM(
                            "Item No.",
                            UOMBesar,
                            QtyBase
                        );

                    // ============================================
                    // QTY SEDANG
                    // ============================================

                    QtySedang :=
                        GetQtyInUOM(
                            "Item No.",
                            UOMSedang,
                            QtyBase
                        );

                    // ============================================
                    // QTY PCS
                    // ============================================

                    QtyPcs :=
                        GetQtyInUOM(
                            "Item No.",
                            UOMPcs,
                            QtyBase
                        );

                    // ============================================
                    // AMOUNT
                    // Sementara menggunakan Item Ledger Entry
                    // ============================================

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
                        StartingDate,
                        EndingDate
                    );

                    if ItemLE.FindSet() then
                        repeat
                            ItemLE.CalcFields(
                                "Cost Amount (Actual)"
                            );

                            Amount +=
                                ItemLE."Cost Amount (Actual)";
                        until ItemLE.Next() = 0;
                end;
            }
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
    // RENDERING
    // ============================================================

    rendering
    {
        layout(inventoryStock)
        {
            Type = RDLC;

            LayoutFile =
                './Report/FDD40/PrintOut_Report_Inventory_Stock.rdl';
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

    // ============================================================
    // GET QTY UOM
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
        if UOMCode = '' then
            exit(0);

        if ItemUOM.Get(
            ItemNo,
            UOMCode
        ) then begin

            if ItemUOM."Qty. per Unit of Measure" <> 0 then begin

                QtyResult :=
                    BaseQty /
                    ItemUOM."Qty. per Unit of Measure";

                // Bulatkan menjadi bilangan bulat
                QtyResult :=
                    Round(
                        QtyResult,
                        1,
                        '='
                    );

                exit(QtyResult);
            end;
        end;

        exit(0);
    end;
}