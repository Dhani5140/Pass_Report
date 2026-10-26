report 52008 SuratJalanNota
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = SuratJalanNota;

    dataset
    {
        dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
        {
            RequestFilterFields = "No.", "Location Code";

            column(No_; "No.") { }
            column(Location_Code; "Location Code") { }
            column(Posting_Date; "Posting Date") { }
            column(Plat_Nomor; Plat_Nomor) { }
            column(Nama_Driver; Nama_Driver) { }

            dataitem("Location"; "Location")
            {
                DataItemLink = Code = field("Location Code");

                column(Nama_Cabang; Name) { }
            }

            dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
            {
                DataItemLink = "No." = field("No.");

                column(Nomor_Invoice; Nomor_Invoice) { }
                column(Kode_Customer; Kode_Customer) { }
                column(Nama_Customer; Nama_Customer) { }
                column(Alamat; Alamat) { }
                column(Nominal_Invoice; Nominal_Invoice) { }
                column(TOP; TOP) { }

                trigger OnAfterGetRecord()
                var
                    salesHeader: Record "Sales Header";
                    salesLine: Record "Sales Line";
                begin
                    Clear(Nomor_Invoice);
                    Clear(Kode_Customer);
                    Clear(Nama_Customer);
                    Clear(Alamat);
                    Clear(Nominal_Invoice);
                    Clear(TOP);

                    Nomor_Invoice := "Invoice No.";

                    if salesHeader.Get(salesHeader."Document Type"::Order, "Source No.") then begin
                        Kode_Customer := salesHeader."Sell-to Customer No.";
                        Nama_Customer := salesHeader."Sell-to Customer Name";
                        Alamat := salesHeader."Ship-to Address";
                        if Alamat = '' then
                            Alamat := salesHeader."Bill-to Address";
                        TOP := salesHeader."Payment Terms Code";

                        salesLine.SetRange("Document Type", salesLine."Document Type"::Order);
                        salesLine.SetRange("Document No.", "Source No.");
                        if salesLine.FindSet() then begin
                            repeat
                                Nominal_Invoice += salesLine."Amount Including VAT";
                            until salesLine.Next() = 0;
                        end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                ShippingAgentServ: Record "Shipping Agent Services";
            begin
                Nama_Driver := "Nama Driver";

                Clear(Plat_Nomor);
                if ShippingAgentServ.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                    Plat_Nomor := ShippingAgentServ."Plat Nomor";
            end;
        }
    }

    rendering
    {
        layout(SuratJalanNota)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD51/SuratJalanNota.rdl';
        }
    }

    var
        Plat_Nomor: Text[100];
        Nama_Driver: Text[100];
        Nomor_Invoice: Code[20];
        Kode_Customer: Code[20];
        Nama_Customer: Text[100];
        Alamat: Text[100];
        Nominal_Invoice: Decimal;
        TOP: Code[10];
}
