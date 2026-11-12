report 52006 InventoryStockss
{
    Caption = 'Inventory Stocks';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = inventoryStockExcel;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterHeading = 'Filter: Item';
            RequestFilterFields = "No.", "Search Description", "Assembly BOM", "Inventory Posting Group", "Statistics Group", "Vendor No.";
            PrintOnlyIfDetail = true;

            dataitem(BinContent; "Bin Content")
            {
                DataItemLinkReference = Item;
                DataItemLink = "Item No." = field("No.");
                DataItemTableView = sorting("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");
                RequestFilterFields = "Location Code", "Bin Code";

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

                trigger OnAfterGetRecord()
                var
                    BinContentLocTotal: Record "Bin Content";
                    ValueEntry: Record "Value Entry";
                    CurrentKey: Text;
                    TotalLocQtyBase: Decimal;
                    TotalLocAmount: Decimal;
                begin
                    // Group per kombinasi Location + Bin + Item agar tidak duplikat jika ada beberapa UOM di Bin yang sama
                    CurrentKey := "Location Code" + '|' + "Bin Code" + '|' + "Item No.";
                    if CurrentKey = LastKey then begin
                        CurrReport.Skip();
                        exit;
                    end;
                    LastKey := CurrentKey;

                    // Ambil Item Info & Satuan UOM
                    ItemName := Item.Description;
                    UOMBesar := Item."Satuan Besar";
                    UOMSedang := Item."Satuan Sedang";
                    UOMPcs := Item."Base Unit of Measure";

                    // Lookup langsung Quantity & Quantity (Base) dari tabel Bin Content
                    QtyBesar := GetBinContentQty("Location Code", "Bin Code", "Item No.", UOMBesar);
                    QtySedang := GetBinContentQty("Location Code", "Bin Code", "Item No.", UOMSedang);
                    QtyPcs := GetBinContentQty("Location Code", "Bin Code", "Item No.", UOMPcs);
                    QtyBase := GetTotalBinContentBaseQty("Location Code", "Bin Code", "Item No.");

                    // Lewati baris jika seluruh kuantitas di Bin ini 0
                    if (QtyBesar = 0) and (QtySedang = 0) and (QtyPcs = 0) and (QtyBase = 0) then begin
                        CurrReport.Skip();
                        exit;
                    end;

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

                    // Hitung Amount (Proporsional QtyBase Bin terhadap Total QtyBase di Lokasi dari Bin Content)
                    Amount := 0;
                    TotalLocQtyBase := 0;
                    TotalLocAmount := 0;

                    BinContentLocTotal.Reset();
                    BinContentLocTotal.SetRange("Location Code", "Location Code");
                    BinContentLocTotal.SetRange("Item No.", "Item No.");
                    if BinContentLocTotal.FindSet() then
                        repeat
                            BinContentLocTotal.CalcFields("Quantity (Base)");
                            TotalLocQtyBase += BinContentLocTotal."Quantity (Base)";
                        until BinContentLocTotal.Next() = 0;

                    ValueEntry.Reset();
                    ValueEntry.SetRange("Item No.", "Item No.");
                    ValueEntry.SetRange("Location Code", "Location Code");
                    if EndingDate <> 0D then
                        ValueEntry.SetRange("Posting Date", 0D, EndingDate);
                    ValueEntry.CalcSums("Cost Amount (Actual)");
                    TotalLocAmount := ValueEntry."Cost Amount (Actual)";

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

    rendering
    {
        layout(inventoryStockExcel)
        {
            Type = Excel;
            LayoutFile = './Report/FDD40/Report_Inventory_Stock.xlsx';
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
        DefaultDim: Record "Default Dimension";
        StartingDate: Date;
        EndingDate: Date;
        UseStockkeepingUnit: Boolean;

    // Lookup field Quantity dari Bin Content per UOM
    local procedure GetBinContentQty(LocCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]; UOMCode: Code[20]): Decimal
    var
        BinContentRec: Record "Bin Content";
        TotalQty: Decimal;
    begin
        if UOMCode = '' then
            exit(0);

        BinContentRec.Reset();
        BinContentRec.SetRange("Location Code", LocCode);
        BinContentRec.SetRange("Bin Code", BinCode);
        BinContentRec.SetRange("Item No.", ItemNo);
        BinContentRec.SetRange("Unit of Measure Code", UOMCode);
        if BinContentRec.FindSet() then
            repeat
                BinContentRec.CalcFields(Quantity);
                TotalQty += BinContentRec.Quantity;
            until BinContentRec.Next() = 0;

        exit(TotalQty);
    end;

    // Lookup total Quantity (Base) dari Bin Content untuk Bin & Item tersebut
    local procedure GetTotalBinContentBaseQty(LocCode: Code[10]; BinCode: Code[20]; ItemNo: Code[20]): Decimal
    var
        BinContentRec: Record "Bin Content";
        TotalBaseQty: Decimal;
    begin
        BinContentRec.Reset();
        BinContentRec.SetRange("Location Code", LocCode);
        BinContentRec.SetRange("Bin Code", BinCode);
        BinContentRec.SetRange("Item No.", ItemNo);
        if BinContentRec.FindSet() then
            repeat
                BinContentRec.CalcFields("Quantity (Base)");
                TotalBaseQty += BinContentRec."Quantity (Base)";
            until BinContentRec.Next() = 0;

        exit(TotalBaseQty);
    end;
}