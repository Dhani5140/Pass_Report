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

            dataitem("Location"; "Location")
            {
                DataItemLink = Code = field("Location Code");

                column(Address; Address) { }
            }

            dataitem("Warehouse Receipt Line"; "Warehouse Receipt Line")
            {
                DataItemLinkReference = "Warehouse Receipt Header";
                DataItemLink = "No." = field("No.");

                column(Source_No_; "Source No.") { }
                column(Item_No_; "Item No.") { }
                column(Description; Description) { }
                column(Unit_of_Measure_Code; "Unit of Measure Code") { }
                column(Qty; Quantity) { }
                column(QtyToReceive; "Qty. to Receive") { }
                column(Bin_Code; "Bin Code") { }
                column(No_Faktur_Penjualan; No_Faktur_Penjualan) { }
                column(Tanggal_Dokumen; Tanggal_Dokumen) { }
                column(No_Pelanggan; No_Pelanggan) { }
                column(Nama_Pelanggan; Nama_Pelanggan) { }
                column(Alamat_Pelanggan; Alamat_Pelanggan) { }
                column(Total_Nominal_Faktur; Total_Nominal_Faktur) { }

                trigger OnAfterGetRecord()
                var
                    salesReturLine: Record "Sales Line";
                    valueEntry: Record "Value Entry";
                    salesInvHeader: Record "Sales Invoice Header";
                    salesInvLine: Record "Sales Invoice Line";
                begin
                    Clear(No_Faktur_Penjualan);
                    Clear(Tanggal_Dokumen);
                    Clear(No_Pelanggan);
                    Clear(Nama_Pelanggan);
                    Clear(Alamat_Pelanggan);
                    Clear(Total_Nominal_Faktur);

                    if salesReturLine.Get(salesReturLine."Document Type"::"Return Order", "Source No.", "Source Line No.") then begin
                        if salesReturLine."Appl.-from Item Entry" <> 0 then begin
                            valueEntry.SetRange("Item Ledger Entry No.", salesReturLine."Appl.-from Item Entry");
                            valueEntry.SetRange("Document Type", valueEntry."Document Type"::"Sales Invoice");
                            if valueEntry.FindFirst() then
                                No_Faktur_Penjualan := valueEntry."Document No.";
                        end;
                    end;

                    if No_Faktur_Penjualan <> '' then begin
                        if salesInvHeader.Get(No_Faktur_Penjualan) then begin
                            Tanggal_Dokumen := salesInvHeader."Document Date";
                            No_Pelanggan := salesInvHeader."Sell-to Customer No.";
                            Nama_Pelanggan := salesInvHeader."Sell-to Customer Name";
                            Alamat_Pelanggan := salesInvHeader."Ship-to Address";
                            if Alamat_Pelanggan = '' then
                                Alamat_Pelanggan := salesInvHeader."Bill-to Address";

                            salesInvLine.SetRange("Document No.", No_Faktur_Penjualan);
                            if salesInvLine.FindSet() then begin
                                repeat
                                    Total_Nominal_Faktur += salesInvLine."Amount Including VAT";
                                until salesInvLine.Next() = 0;
                            end;
                        end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                LocationRec: Record Location;
            begin
                Clear(Alamat_Gudang);
                Clear(Nama_Cabang);
                if LocationRec.Get("Location Code") then begin
                    Alamat_Gudang := LocationRec.Address;
                    Nama_Cabang := LocationRec.Name;
                end;
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
        Plat_Nomor: Text[100];
        Nama_Supir: Text[100];
        PrintDateText: Text[100];
        Alamat_Gudang: Text[100];
        Nama_Cabang: Text[100];
        No_Faktur_Penjualan: Code[20];
        Tanggal_Dokumen: Date;
        No_Pelanggan: Code[20];
        Nama_Pelanggan: Text[100];
        Alamat_Pelanggan: Text[100];
        Total_Nominal_Faktur: Decimal;
}
