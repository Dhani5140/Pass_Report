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
            column(Salesperson_Info; Salesperson_Info) { }
            column(Customer_No_Name; Customer_No_Name) { }
            column(Customer_Address; Customer_Address) { }
            column(Posting_Date; Posting_Date) { }
            column(Due_Date; Due_Date) { }
            column(Payment_Terms_Code; Payment_Terms_Code) { }
            column(No_Invoice; No_Invoice) { }
            column(PicklistNo; PicklistNo) { }
            column(No_Printed; No_Printed) { }
            column(UserFullName; UserFullName) { }
            column(DateTxt; DateTxt) { }
            column(Subtotal; Subtotal) { }
            column(Disc_Inv; Disc_Inv) { }
            column(DPP; DPP) { }
            column(PPN_Amt; PPN_Amt) { }
            column(Total; Total) { }

            dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
            {
                DataItemLink = "No." = field("No.");

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
                    salesLine: Record "Sales Line";
                begin
                    Clear(Kuantitas_Teks);
                    Clear(Unit_Price);
                    Clear(Potongan);
                    Clear(Jumlah_Rp);
                    Clear(Jumlah_Rp_Inc_VAT);
                    Clear(Line_Disc_Inv);

                    Kuantitas_Teks := Format("Qty. to Ship") + ' ' + "Unit of Measure Code";

                    if salesLine.Get(salesLine."Document Type"::Order,
                                      "Source No.", "Source Line No.") then begin
                        Unit_Price := salesLine."Unit Price";
                        Potongan := salesLine."Line Discount Amount";
                        Jumlah_Rp := salesLine.Amount;
                        Jumlah_Rp_Inc_VAT := salesLine."Amount Including VAT";
                        Line_Disc_Inv := salesLine."Inv. Discount Amount";
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                salesHeader: Record "Sales Header";
                salesPerson: Record "Salesperson/Purchaser";
                whseShptLine: Record "Warehouse Shipment Line";
                regWhseAct: Record "Registered Whse. Activity Line";
                salesLine: Record "Sales Line";
                vatSetup: Record "VAT Posting Setup";
            begin
                Clear(Company_Name);
                Clear(Company_Address);
                Clear(Company_Phone);
                Clear(Company_NPWP);
                Clear(Salesperson_Info);
                Clear(Customer_No_Name);
                Clear(Customer_Address);
                Clear(Posting_Date);
                Clear(Due_Date);
                Clear(Payment_Terms_Code);
                Clear(No_Invoice);
                Clear(PicklistNo);
                Clear(No_Printed);
                Clear(UserFullName);
                Clear(DateTxt);
                Clear(Subtotal);
                Clear(Disc_Inv);
                Clear(DPP);
                Clear(PPN_Amt);
                Clear(Total);

                Company_Name := 'PT. PANGAN SEJAHTERA SANTOSA';
                Company_Address := 'Jl. Pluit Karang Karya Timur Blok E No. 6, Penjaringan, Jakarta Utara, 14440';
                Company_Phone := '021-66679167';
                Company_NPWP := '82.599.753.6-041.000';

                UserFullName := UserId;
                DateTxt := Format(CurrentDateTime, 0, '<Day,2>-<Month Text>-<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>');

                No_Printed := 1;

                whseShptLine.SetRange("No.", "No.");
                whseShptLine.SetFilter("Source No.", '<>%1', '');
                if whseShptLine.FindFirst() then begin
                    if salesHeader.Get(salesHeader."Document Type"::Order, whseShptLine."Source No.") then begin
                        Posting_Date := salesHeader."Order Date";
                        Due_Date := salesHeader."Due Date";
                        Payment_Terms_Code := salesHeader."Payment Terms Code";
                        Customer_No_Name := salesHeader."Sell-to Customer No." + ' - ' + salesHeader."Bill-to Name";
                        Customer_Address := salesHeader."Bill-to Address";
                        if Customer_Address = '' then
                            Customer_Address := salesHeader."Sell-to Address";

                        Salesperson_Info := salesHeader."Salesperson Code";
                        if salesPerson.Get(salesHeader."Salesperson Code") then
                            Salesperson_Info := salesHeader."Salesperson Code" + ' - ' + salesPerson.Name;

                        No_Invoice := whseShptLine."Invoice No.";

                        salesLine.SetRange("Document Type", salesLine."Document Type"::Order);
                        salesLine.SetRange("Document No.", whseShptLine."Source No.");
                        salesLine.SetFilter("Amount", '<>%1', 0);
                        if salesLine.FindSet() then
                            repeat
                                Subtotal += salesLine."Line Amount";
                                Disc_Inv += salesLine."Inv. Discount Amount";
                            until salesLine.Next() = 0;

                        DPP := Subtotal - Disc_Inv;

                        if salesLine.FindFirst() then begin
                            if vatSetup.Get(salesLine."VAT Bus. Posting Group", salesLine."VAT Prod. Posting Group") then
                                PPN_Amt := DPP * vatSetup."VAT %" / 100;
                        end;

                        Total := DPP + PPN_Amt;
                    end;

                    regWhseAct.SetRange("Source No.", whseShptLine."Source No.");
                    if regWhseAct.FindFirst() then
                        PicklistNo := regWhseAct."No.";
                end;
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
        Company_Name: Text[100];
        Company_Address: Text[100];
        Company_Phone: Text[30];
        Company_NPWP: Text[20];
        Salesperson_Info: Text[100];
        Customer_No_Name: Text[100];
        Customer_Address: Text[100];
        Posting_Date: Date;
        Due_Date: Date;
        Payment_Terms_Code: Code[10];
        No_Invoice: Code[20];
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
}
