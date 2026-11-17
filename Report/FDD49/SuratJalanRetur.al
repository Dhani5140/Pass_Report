report 52007 SuratJalanRetur
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = SuratJalanRetur;

    dataset
    {
        dataitem("Warehouse Receipt Header"; "Warehouse Receipt Header")
        {
            RequestFilterFields = "No.", "Location Code";

            column(No_; "No.") { }
            column(PrintDateText; PrintDateText) { }
            column(Plat_Nomor; Plat_Nomor) { }
            column(Nama_Supir; Nama_Supir) { }
            column(Alamat_Gudang; Alamat_Gudang) { }
            column(Nama_Cabang; Nama_Cabang) { }
            column(Location_Code; "Location Code") { }
            column(No_Faktur_Penjualan; No_Faktur_Penjualan) { }
            column(No_Pelanggan; No_Pelanggan) { }
            column(Nama_Pelanggan; Nama_Pelanggan) { }
            column(Alamat_Pelanggan; Alamat_Pelanggan) { }

            dataitem("Warehouse Receipt Line"; "Warehouse Receipt Line")
            {
                DataItemLinkReference = "Warehouse Receipt Header";
                DataItemLink = "No." = field("No.");

                column(Source_No_; "Source No.") { }
                column(Item_No_; "Item No.") { }
                column(Description; Description) { }

                dataitem(PutAwayLine; Integer)
                {
                    DataItemTableView = sorting(Number);

                    column(Unit_of_Measure_Code; PutAwayUOM) { }
                    column(Qty; RequestQty) { }
                    column(QtyToReceive; PutAwayQty) { }
                    column(Bin_Code; PutAwayBin) { }

                    trigger OnPreDataItem()
                    begin
                        PutAwayStaging.Reset();
                        PutAwayStaging.SetCurrentKey("Document No.", "Whse. Recpt. Line No.");
                        PutAwayStaging.SetRange("Document No.", "Warehouse Receipt Line"."No.");
                        PutAwayStaging.SetRange("Whse. Recpt. Line No.", "Warehouse Receipt Line"."Line No.");
                        PutAwayStaging.SetFilter("Qty. to Receive", '<>0');
                        PutAwayCount := PutAwayStaging.Count();
                        if PutAwayCount = 0 then
                            SetRange(Number, 1)
                        else
                            SetRange(Number, 1, PutAwayCount);
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        RequestQty := 0;
                        if Number = 1 then
                            RequestQty := "Warehouse Receipt Line".Quantity;

                        if PutAwayCount = 0 then begin
                            PutAwayUOM := "Warehouse Receipt Line"."Unit of Measure Code";
                            PutAwayQty := "Warehouse Receipt Line"."Qty. to Receive";
                            PutAwayBin := "Warehouse Receipt Line"."Bin Code";
                            exit;
                        end;

                        if Number = 1 then
                            PutAwayStaging.FindSet()
                        else
                            PutAwayStaging.Next();

                        PutAwayUOM := PutAwayStaging."Unit of Measure Code";
                        PutAwayQty := PutAwayStaging."Qty. to Receive";
                        PutAwayBin := PutAwayStaging."Bin Code 2";
                    end;
                }
            }

            trigger OnAfterGetRecord()
            var
                LocationRec: Record Location;
                ShippingAgentServ: Record "Shipping Agent Services";
            begin
                Clear(Alamat_Gudang);
                Clear(Nama_Cabang);
                Clear(Plat_Nomor);
                Clear(Nama_Supir);

                PrintDateText := Format(Today, 0, '<Day,2>/<Month,2>/<Year,2>');

                if LocationRec.Get("Location Code") then begin
                    Alamat_Gudang := LocationRec.Address;
                    Nama_Cabang := LocationRec.Name;
                end;

                if ShippingAgentServ.Get("Shipping Agent Code", "Shipping Agent Service Code") then begin
                    Plat_Nomor := ShippingAgentServ."Plat Nomor";
                    Nama_Supir := ShippingAgentServ."Nama Driver";
                end;

                SetCustomerAndInvoice();
            end;
        }
    }

    rendering
    {
        layout(SuratJalanRetur)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD49/SuratJalanRetur.rdl';
        }
    }

    var
        PutAwayStaging: Record "Whse. Splt PWay Line Staging";
        PutAwayCount: Integer;
        PutAwayUOM: Code[10];
        PutAwayQty: Decimal;
        PutAwayBin: Code[20];
        RequestQty: Decimal;
        Plat_Nomor: Text[100];
        Nama_Supir: Text[100];
        PrintDateText: Text[30];
        Alamat_Gudang: Text[100];
        Nama_Cabang: Text[100];
        No_Faktur_Penjualan: Code[20];
        No_Pelanggan: Code[20];
        Nama_Pelanggan: Text[100];
        Alamat_Pelanggan: Text[100];

    local procedure SetCustomerAndInvoice()
    var
        whseRcptLine: Record "Warehouse Receipt Line";
        returnHeader: Record "Sales Header";
        returnLine: Record "Sales Line";
        valueEntry: Record "Value Entry";
    begin
        Clear(No_Faktur_Penjualan);
        Clear(No_Pelanggan);
        Clear(Nama_Pelanggan);
        Clear(Alamat_Pelanggan);

        whseRcptLine.SetRange("No.", "Warehouse Receipt Header"."No.");
        whseRcptLine.SetRange("Source Document", whseRcptLine."Source Document"::"Sales Return Order");
        if not whseRcptLine.FindSet() then
            exit;

        if returnHeader.Get(returnHeader."Document Type"::"Return Order", whseRcptLine."Source No.") then begin
            No_Pelanggan := returnHeader."Sell-to Customer No.";
            Nama_Pelanggan := returnHeader."Sell-to Customer Name";
            Alamat_Pelanggan := returnHeader."Sell-to Address";
        end;

        repeat
            if returnLine.Get(returnLine."Document Type"::"Return Order", whseRcptLine."Source No.", whseRcptLine."Source Line No.") then
                if returnLine."Appl.-from Item Entry" <> 0 then begin
                    valueEntry.SetRange("Item Ledger Entry No.", returnLine."Appl.-from Item Entry");
                    valueEntry.SetRange("Document Type", valueEntry."Document Type"::"Sales Invoice");
                    if valueEntry.FindFirst() then
                        No_Faktur_Penjualan := valueEntry."Document No.";
                end;
        until (No_Faktur_Penjualan <> '') or (whseRcptLine.Next() = 0);
    end;
}
