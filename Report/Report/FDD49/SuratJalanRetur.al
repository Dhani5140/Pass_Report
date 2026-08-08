report 52004 SuratJalanRetur
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
                    BarisReturPenjualan: Record "Sales Line";
                    LogTransaksi: Record "Value Entry";
                    HeaderFakturPenjualan: Record "Sales Invoice Header";
                    BarisFakturPenjualan: Record "Sales Invoice Line";
                begin
                    Clear(No_Faktur_Penjualan);
                    Clear(Tanggal_Dokumen);
                    Clear(No_Pelanggan);
                    Clear(Nama_Pelanggan);
                    Clear(Alamat_Pelanggan);
                    Clear(Total_Nominal_Faktur);

                    // Mencari Faktur asli daritransaksi retur (Value Entry)
                    if BarisReturPenjualan.Get(BarisReturPenjualan."Document Type"::"Return Order", "Source No.", "Source Line No.") then begin
                        if BarisReturPenjualan."Appl.-from Item Entry" <> 0 then begin
                            LogTransaksi.SetRange("Item Ledger Entry No.", BarisReturPenjualan."Appl.-from Item Entry");
                            LogTransaksi.SetRange("Document Type", LogTransaksi."Document Type"::"Sales Invoice");
                            if LogTransaksi.FindFirst() then
                                No_Faktur_Penjualan := LogTransaksi."Document No.";
                        end;
                    end;

                    // Mengambil detail customer & total nominal faktur dari Sales Invoice Header
                    if No_Faktur_Penjualan <> '' then begin
                        if HeaderFakturPenjualan.Get(No_Faktur_Penjualan) then begin
                            Tanggal_Dokumen := HeaderFakturPenjualan."Document Date";
                            No_Pelanggan := HeaderFakturPenjualan."Sell-to Customer No.";
                            Nama_Pelanggan := HeaderFakturPenjualan."Sell-to Customer Name";
                            Alamat_Pelanggan := HeaderFakturPenjualan."Ship-to Address";
                            if Alamat_Pelanggan = '' then
                                Alamat_Pelanggan := HeaderFakturPenjualan."Bill-to Address";

                            BarisFakturPenjualan.SetRange("Document No.", No_Faktur_Penjualan);
                            if BarisFakturPenjualan.FindSet() then begin
                                repeat
                                    Total_Nominal_Faktur += BarisFakturPenjualan."Amount Including VAT";
                                until BarisFakturPenjualan.Next() = 0;
                            end;
                        end;
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
            }
        }

        actions
        {
            area(processing)
            {
            }
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