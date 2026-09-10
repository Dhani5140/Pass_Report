report 52001 SuratJalanWhSp
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = SuratJalanWhSp;

    dataset
    {
        dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
        {
            RequestFilterFields = "Location Code";

            column(No_; "No.") { }
            column(Plat_Nomor; Plat_Nomor) { }
            column(Driver_Name; Driver_Name) { }
            column(TotalSalesperson; TotalSalesperson) { }
            column(TotalFaktur; TotalFaktur) { }
            column(TotalOutlet; TotalOutlet) { }
            column(DateTxt; DateTxt) { }
            column(TimeTxt; TimeTxt) { }

            dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
            {
                DataItemLink = "No." = field("No.");

                column(No_Faktur; "Invoice No.") { }
                column(SODate; SODate) { }
                column(CustCode; "Destination No.") { }
                column(CustName; CustName) { }
                column(CustAddress; CustAddress) { }
                column(Total_Cubage; "Total Cubage") { }
                column(Total_Tonase; "Total Tonase") { }
                column(SalespersonCode; SalespersonCode) { }

                trigger OnAfterGetRecord()
                begin
                    Clear(SODate);
                    Clear(CustName);
                    Clear(CustAddress);
                    Clear(SalespersonCode);

                    if salesHeader.Get(salesHeader."Document Type"::Order, "Source No.") then begin
                        SODate := salesHeader."Document Date";
                        CustName := salesHeader."Sell-to Customer Name";
                        CustAddress := salesHeader."Ship-to Address";
                        SalespersonCode := salesHeader."Salesperson Code";
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                whseShptLine: Record "Warehouse Shipment Line";
                fakturDict: Dictionary of [Code[20], Boolean];
                outletDict: Dictionary of [Code[20], Boolean];
                spDict: Dictionary of [Code[20], Boolean];
            begin
                Clear(Plat_Nomor);
                Clear(Driver_Name);
                Clear(TotalSalesperson);
                Clear(TotalFaktur);
                Clear(TotalOutlet);
                Clear(fakturDict);
                Clear(outletDict);
                Clear(spDict);

                if shippingAgentServ.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                    Plat_Nomor := shippingAgentServ."Plat Nomor";

                Driver_Name := "Nama Driver";

                DateTxt := Format(Today, 0, '<Day,2>-<Month Text>-<Year4>');
                TimeTxt := Format(Time, 0, '<Hours24,2>:<Minutes,2>:<Seconds,2>');

                whseShptLine.SetRange("No.", "No.");
                if whseShptLine.FindSet() then
                    repeat
                        if whseShptLine."Invoice No." <> '' then
                            if not fakturDict.ContainsKey(whseShptLine."Invoice No.") then begin
                                fakturDict.Add(whseShptLine."Invoice No.", true);
                                TotalFaktur += 1;
                            end;

                        if whseShptLine."Destination No." <> '' then
                            if not outletDict.ContainsKey(whseShptLine."Destination No.") then begin
                                outletDict.Add(whseShptLine."Destination No.", true);
                                TotalOutlet += 1;
                            end;

                        if salesHeader.Get(salesHeader."Document Type"::Order, whseShptLine."Source No.") then
                            if salesHeader."Salesperson Code" <> '' then
                                if not spDict.ContainsKey(salesHeader."Salesperson Code") then begin
                                    spDict.Add(salesHeader."Salesperson Code", true);
                                    TotalSalesperson += 1;
                                end;
                    until whseShptLine.Next() = 0;
            end;
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
                action(LayoutName)
                {
                }
            }
        }
    }

    rendering
    {
        layout(SuratJalanWhSp)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD20/SuratJalanWhSp.rdl';
        }
    }

    var
        Plat_Nomor: Code[20];
        Driver_Name: Text[100];
        TotalSalesperson: Integer;
        TotalFaktur: Integer;
        TotalOutlet: Integer;
        DateTxt: Text[30];
        TimeTxt: Text[30];
        SODate: Date;
        CustName: Text[100];
        CustAddress: Text[100];
        SalespersonCode: Code[20];
        shippingAgentServ: Record "Shipping Agent Services";
        salesHeader: Record "Sales Header";
}
