report 52005 PrintFaktur
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = PrintFaktur;

    dataset
    {
        dataitem("Warehouse Shipment Header"; "Warehouse Shipment Header")
        {
            RequestFilterFields = "No.", "Location Code";

            column(No_; "No.") { }
            column(Location_Code; "Location Code") { }
            column(Company_Name; Company_Name) { }
            column(Company_Address; Company_Address) { }
            column(Company_Phone; Company_Phone) { }
            column(Company_NPWP; Company_NPWP) { }
            column(Driver_Info; Driver_Info) { }
            column(No_Printed; No_Printed) { }
            column(UserFullName; UserFullName) { }
            column(DateTxt; DateTxt) { }

            dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
            {
                DataItemLink = "No." = field("No.");
                DataItemTableView = sorting("No.", "Line No.");

                column(No_Invoice; No_Invoice) { }
                column(Invoice_Key; LastInvoiceKey) { }
                column(Salesperson_Info; Salesperson_Info) { }
                column(External_Doc_No; External_Doc_No) { }
                column(Customer_No_Name; Customer_No_Name) { }
                column(Customer_Address; Customer_Address) { }
                column(Posting_Date; Posting_Date) { }
                column(Due_Date; Due_Date) { }
                column(Payment_Terms_Code; Payment_Terms_Code) { }
                column(PicklistNo; PicklistNo) { }
                column(Subtotal; Subtotal) { }
                column(Disc_Inv; Disc_Inv) { }
                column(DPP; DPP) { }
                column(PPN_Amt; PPN_Amt) { }
                column(Total; Total) { }
                column(No_Item; "Item No.") { }
                column(Description; Description) { }
                column(TotalQty; Kuantitas_Teks) { }
                column(Unit_Price; Unit_Price) { }
                column(Line_Discount_Amount; Potongan) { }
                column(AmountLine; Jumlah_Rp) { }
                column(LineAmount_Including_VAT; Jumlah_Rp_Inc_VAT) { }
                column(Inv_Discount_Amount; Line_Disc_Inv) { }

                trigger OnAfterGetRecord()
                var
                    VATPct: Decimal;
                begin
                    if InvoiceKey("Warehouse Shipment Line") <> LastInvoiceKey then
                        SetInvoiceInfo();

                    Kuantitas_Teks := Format("Qty. to Ship") + ' ' + "Unit of Measure Code";

                    LineAmountCalc.GetAmounts("Warehouse Shipment Line", "Qty. to Ship", Jumlah_Rp, Line_Disc_Inv, VATPct, Unit_Price, Potongan);
                    Jumlah_Rp_Inc_VAT := Round((Jumlah_Rp - Line_Disc_Inv) * (1 + VATPct / 100));
                end;

                trigger OnPreDataItem()
                begin
                    LastInvoiceKey := '';
                end;
            }

            trigger OnAfterGetRecord()
            var
                shippingAgentServ: Record "Shipping Agent Services";
                driverName: Text[100];
            begin
                Company_Name := 'PT. PANGAN SEJAHTERA SANTOSA';
                Company_Address := 'Jl. Pluit Karang Karya Timur Blok E No. 6, Penjaringan, Jakarta Utara, 14440';
                Company_Phone := '021-66679167';
                Company_NPWP := '82.599.753.6-041.000';

                UserFullName := UserId;
                DateTxt := Format(CurrentDateTime, 0, '<Day,2>-<Month Text>-<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>');

                No_Printed := 1;

                driverName := "Nama Driver";
                if shippingAgentServ.Get("Shipping Agent Code", "Shipping Agent Service Code") then
                    if shippingAgentServ."Nama Driver" <> '' then
                        driverName := shippingAgentServ."Nama Driver";

                Driver_Info := "Shipping Agent Service Code" + ' - ' + driverName;
            end;
        }
    }

    rendering
    {
        layout(PrintFaktur)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD22/PrintFaktur.rdl';
        }
    }

    var
        LineAmountCalc: Codeunit "Whse. Shpt. Line Amount";
        LastInvoiceKey: Text;
        Company_Name: Text[100];
        Company_Address: Text[100];
        Company_Phone: Text[30];
        Company_NPWP: Text[20];
        Salesperson_Info: Text[100];
        Driver_Info: Text[150];
        External_Doc_No: Code[35];
        Customer_No_Name: Text[100];
        Customer_Address: Text[100];
        Posting_Date: Date;
        Due_Date: Date;
        Payment_Terms_Code: Code[10];
        No_Invoice: Code[35];
        PicklistNo: Code[20];
        No_Printed: Integer;
        UserFullName: Text[50];
        DateTxt: Text[50];
        Kuantitas_Teks: Text[100];
        Unit_Price: Decimal;
        Potongan: Decimal;
        Jumlah_Rp: Decimal;
        Jumlah_Rp_Inc_VAT: Decimal;
        Line_Disc_Inv: Decimal;
        Subtotal: Decimal;
        Disc_Inv: Decimal;
        DPP: Decimal;
        PPN_Amt: Decimal;
        Total: Decimal;

    local procedure InvoiceKey(WhseLine: Record "Warehouse Shipment Line"): Text
    begin
        if WhseLine."Invoice No." <> '' then
            exit(WhseLine."Invoice No.");
        exit('SO:' + WhseLine."Source No.");
    end;

    local procedure SetInvoiceInfo()
    var
        salesHeader: Record "Sales Header";
        salesPerson: Record "Salesperson/Purchaser";
        regWhseAct: Record "Registered Whse. Activity Line";
        whseShptLine: Record "Warehouse Shipment Line";
        lineAmt: Decimal;
        invDisc: Decimal;
        vatPct: Decimal;
        unitPrice: Decimal;
        lineDisc: Decimal;
    begin
        LastInvoiceKey := InvoiceKey("Warehouse Shipment Line");
        Clear(Salesperson_Info);
        Clear(External_Doc_No);
        Clear(Customer_No_Name);
        Clear(Customer_Address);
        Clear(Posting_Date);
        Clear(Due_Date);
        Clear(Payment_Terms_Code);
        Clear(PicklistNo);
        Clear(Subtotal);
        Clear(Disc_Inv);
        Clear(DPP);
        Clear(PPN_Amt);
        Clear(Total);

        No_Invoice := "Warehouse Shipment Line"."Invoice No.";

        if salesHeader.Get(salesHeader."Document Type"::Order, "Warehouse Shipment Line"."Source No.") then begin
            Posting_Date := salesHeader."Order Date";
            Due_Date := salesHeader."Due Date";
            Payment_Terms_Code := salesHeader."Payment Terms Code";
            Customer_No_Name := salesHeader."Sell-to Customer No." + ' - ' + salesHeader."Bill-to Name";
            Customer_Address := salesHeader."Bill-to Address";
            if Customer_Address = '' then
                Customer_Address := salesHeader."Sell-to Address";
            External_Doc_No := salesHeader."External Document No.";
            Salesperson_Info := salesHeader."Salesperson Code";
            if salesPerson.Get(salesHeader."Salesperson Code") then
                Salesperson_Info := salesHeader."Salesperson Code" + ' - ' + salesPerson.Name;
        end;

        regWhseAct.SetRange("Source No.", "Warehouse Shipment Line"."Source No.");
        if regWhseAct.FindFirst() then
            PicklistNo := regWhseAct."No.";

        whseShptLine.SetRange("No.", "Warehouse Shipment Line"."No.");
        if "Warehouse Shipment Line"."Invoice No." <> '' then
            whseShptLine.SetRange("Invoice No.", "Warehouse Shipment Line"."Invoice No.")
        else begin
            whseShptLine.SetRange("Invoice No.", '');
            whseShptLine.SetRange("Source No.", "Warehouse Shipment Line"."Source No.");
        end;
        if whseShptLine.FindSet() then
            repeat
                if LineAmountCalc.GetAmounts(whseShptLine, whseShptLine."Qty. to Ship", lineAmt, invDisc, vatPct, unitPrice, lineDisc) then begin
                    Subtotal += lineAmt;
                    Disc_Inv += invDisc;
                    PPN_Amt += (lineAmt - invDisc) * vatPct / 100;
                end;
            until whseShptLine.Next() = 0;

        PPN_Amt := Round(PPN_Amt);
        DPP := Subtotal - Disc_Inv;
        Total := DPP + PPN_Amt;
    end;
}
