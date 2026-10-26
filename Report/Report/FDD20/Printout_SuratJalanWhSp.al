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
            column(TotalAmount; TotalAmount) { }

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
                column(InvoiceAmount; InvoiceAmount) { }

                trigger OnAfterGetRecord()
                begin
                    Clear(SODate);
                    Clear(CustName);
                    Clear(CustAddress);
                    Clear(SalespersonCode);
                    Clear(InvoiceAmount);

                    if salesHeader.Get(salesHeader."Document Type"::Order, "Source No.") then begin
                        SODate := salesHeader."Document Date";
                        CustName := salesHeader."Sell-to Customer Name";
                        CustAddress := salesHeader."Ship-to Address";
                        SalespersonCode := salesHeader."Salesperson Code";
                    end;

                    InvoiceAmount := CalcInvoiceAmount("No.", "Invoice No.", "Source No.");
                end;
            }

            trigger OnAfterGetRecord()
            var
                whseShptLine: Record "Warehouse Shipment Line";
                fakturDict: Dictionary of [Code[20], Boolean];
                outletDict: Dictionary of [Code[20], Boolean];
                spDict: Dictionary of [Code[20], Boolean];
                orderDict: Dictionary of [Code[20], Boolean];
            begin
                Clear(Plat_Nomor);
                Clear(Driver_Name);
                Clear(TotalSalesperson);
                Clear(TotalFaktur);
                Clear(TotalOutlet);
                Clear(fakturDict);
                Clear(outletDict);
                Clear(spDict);
                Clear(orderDict);
                Clear(TotalAmount);

                if shippingAgentServ.Get("Shipping Agent Code", "Shipping Agent Service Code") then begin
                    Plat_Nomor := shippingAgentServ."Plat Nomor";
                    Driver_Name := shippingAgentServ."Nama Driver";
                end;

                if Driver_Name = '' then
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

                        if whseShptLine."Source No." <> '' then
                            if not orderDict.ContainsKey(whseShptLine."Source No.") then begin
                                orderDict.Add(whseShptLine."Source No.", true);
                                TotalAmount += CalcOrderAmount(whseShptLine."Source No.");
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

    // Mengikuti perhitungan Total pada Print Faktur (report 52005): DPP + PPN
    local procedure CalcOrderAmount(OrderNo: Code[20]): Decimal
    var
        salesLine: Record "Sales Line";
        vatSetup: Record "VAT Posting Setup";
        Subtotal: Decimal;
        DiscInv: Decimal;
        DPP: Decimal;
        PPNAmt: Decimal;
    begin
        salesLine.SetRange("Document Type", salesLine."Document Type"::Order);
        salesLine.SetRange("Document No.", OrderNo);
        salesLine.SetFilter(Amount, '<>%1', 0);
        if not salesLine.FindSet() then
            exit(0);

        repeat
            Subtotal += salesLine."Line Amount";
            DiscInv += salesLine."Inv. Discount Amount";
        until salesLine.Next() = 0;

        DPP := Subtotal - DiscInv;

        if salesLine.FindFirst() then
            if vatSetup.Get(salesLine."VAT Bus. Posting Group", salesLine."VAT Prod. Posting Group") then
                PPNAmt := DPP * vatSetup."VAT %" / 100;

        exit(DPP + PPNAmt);
    end;

    // Total amount per faktur = jumlah total order (distinct) yang memiliki Invoice No. yang sama di shipment ini
    local procedure CalcInvoiceAmount(ShipmentNo: Code[20]; InvoiceNo: Code[20]; SourceNo: Code[20]): Decimal
    var
        whseShptLine: Record "Warehouse Shipment Line";
        orderDict: Dictionary of [Code[20], Boolean];
        Result: Decimal;
    begin
        if InvoiceNo = '' then
            exit(CalcOrderAmount(SourceNo));

        whseShptLine.SetRange("No.", ShipmentNo);
        whseShptLine.SetRange("Invoice No.", InvoiceNo);
        whseShptLine.SetFilter("Source No.", '<>%1', '');
        if whseShptLine.FindSet() then
            repeat
                if not orderDict.ContainsKey(whseShptLine."Source No.") then begin
                    orderDict.Add(whseShptLine."Source No.", true);
                    Result += CalcOrderAmount(whseShptLine."Source No.");
                end;
            until whseShptLine.Next() = 0;

        exit(Result);
    end;

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
        InvoiceAmount: Decimal;
        TotalAmount: Decimal;
        shippingAgentServ: Record "Shipping Agent Services";
        salesHeader: Record "Sales Header";
}
