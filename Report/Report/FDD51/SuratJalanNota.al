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
            column(PrintDateText; PrintDateText) { }
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
                    salesInvHeader: Record "Sales Invoice Header";
                    salesInvLine: Record "Sales Invoice Line";
                begin
                    Clear(Nomor_Invoice);
                    Clear(Kode_Customer);
                    Clear(Nama_Customer);
                    Clear(Alamat);
                    Clear(Nominal_Invoice);
                    Clear(TOP);

                    Nomor_Invoice := "Invoice No.";

                    if Nomor_Invoice <> '' then begin
                        if salesInvHeader.Get(Nomor_Invoice) then begin
                            Kode_Customer := salesInvHeader."Sell-to Customer No.";
                            Nama_Customer := salesInvHeader."Sell-to Customer Name";
                            Alamat := salesInvHeader."Ship-to Address";
                            if Alamat = '' then
                                Alamat := salesInvHeader."Bill-to Address";
                            TOP := salesInvHeader."Payment Terms Code";

                            salesInvLine.SetRange("Document No.", Nomor_Invoice);
                            if salesInvLine.FindSet() then begin
                                repeat
                                    Nominal_Invoice += salesInvLine."Amount Including VAT";
                                until salesInvLine.Next() = 0;
                            end;
                        end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                ShippingAgentServ: Record "Shipping Agent Services";
            begin
                PrintDateText := Format(Today, 0, '<Month Text> <Day,2>, <Year4>');

                Clear(Plat_Nomor);
                Clear(Nama_Driver);
                if ShippingAgentServ.FindFirst() then begin
                    Plat_Nomor := ShippingAgentServ."Plat Nomor";
                    Nama_Driver := ShippingAgentServ."Driver Name";
                end;
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
        PrintDateText: Text[100];
        Nomor_Invoice: Code[20];
        Kode_Customer: Code[20];
        Nama_Customer: Text[100];
        Alamat: Text[100];
        Nominal_Invoice: Decimal;
        TOP: Code[10];
}
