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
            column(Nama_Cabang; Nama_Cabang) { }

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
                    whseShptLine: Record "Warehouse Shipment Line";
                    invKey: Text;
                begin
                    Clear(Nomor_Invoice);
                    Clear(Kode_Customer);
                    Clear(Nama_Customer);
                    Clear(Alamat);
                    Clear(Nominal_Invoice);
                    Clear(TOP);

                    invKey := "Invoice No.";
                    if invKey = '' then
                        invKey := 'SO:' + "Source No.";
                    if orderDict.ContainsKey(invKey) then
                        CurrReport.Skip();
                    orderDict.Add(invKey, true);

                    Nomor_Invoice := "Invoice No.";

                    if salesHeader.Get(salesHeader."Document Type"::Order, "Source No.") then begin
                        Kode_Customer := salesHeader."Sell-to Customer No.";
                        Nama_Customer := salesHeader."Sell-to Customer Name";
                        Alamat := salesHeader."Ship-to Address";
                        if Alamat = '' then
                            Alamat := salesHeader."Bill-to Address";
                        TOP := salesHeader."Payment Terms Code";
                    end;

                    whseShptLine.SetRange("No.", "No.");
                    whseShptLine.SetRange("Invoice No.", "Invoice No.");
                    if "Invoice No." = '' then
                        whseShptLine.SetRange("Source No.", "Source No.");
                    if whseShptLine.FindSet() then
                        repeat
                            Nominal_Invoice += LineAmountCalc.AmountInclVAT(whseShptLine, whseShptLine.Quantity);
                        until whseShptLine.Next() = 0;
                end;
            }

            trigger OnAfterGetRecord()
            var
                ShippingAgentServ: Record "Shipping Agent Services";
                Location: Record Location;
            begin
                Clear(Plat_Nomor);
                Clear(Nama_Driver);
                Clear(Nama_Cabang);
                Clear(orderDict);

                if ShippingAgentServ.Get("Shipping Agent Code", "Shipping Agent Service Code") then begin
                    Plat_Nomor := ShippingAgentServ."Plat Nomor";
                    Nama_Driver := ShippingAgentServ."Nama Driver";
                end;

                if Nama_Driver = '' then
                    Nama_Driver := "Nama Driver";

                if Location.Get("Location Code") then
                    Nama_Cabang := Location.Name;
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
        Nama_Cabang: Text[100];
        Nomor_Invoice: Code[35];
        Kode_Customer: Code[20];
        Nama_Customer: Text[100];
        Alamat: Text[100];
        Nominal_Invoice: Decimal;
        TOP: Code[10];
        orderDict: Dictionary of [Text, Boolean];
        LineAmountCalc: Codeunit "Whse. Shpt. Line Amount";
}
