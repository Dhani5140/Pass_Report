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
            column(Company_Address; Company_Address) { }
            column(Company_Phone; Company_Phone) { }
            column(Company_NPWP; Company_NPWP) { }
            column(Salesman_Code; Salesman_Code) { }
            column(Salesman_Name; Salesman_Name) { }
            column(Picking_List_No; Picking_List_No) { }
            column(Order_Date; Order_Date) { }
            column(Due_Date; Due_Date) { }
            column(Payment_Terms; Payment_Terms) { }
            column(Customer_No; Customer_No) { }
            column(Customer_Name; Customer_Name) { }
            column(Customer_Address; Customer_Address) { }
            column(Print_DateTime; Print_DateTime) { }
            column(SPV_Finance; SPV_Finance) { }
            column(Invoice_No_; Invoice_No_) { }
            column(Subtotal; Subtotal) { }
            column(Disc_Inv; Disc_Inv) { }
            column(DPP; DPP) { }
            column(PPN_Pct; PPN_Pct) { }
            column(PPN_Amt; PPN_Amt) { }
            column(Total; Total) { }

            dataitem("Warehouse Shipment Line"; "Warehouse Shipment Line")
            {
                DataItemLink = "No." = field("No.");

                column(Item_No_; "Item No.") { }
                column(Description; Description) { }
                column(Qty_Picked_Base; "Qty. Picked (Base)") { }
                column(Kuantitas_Teks; Kuantitas_Teks) { }
                column(Hrg_Jual; Hrg_Jual) { }
                column(Potongan; Potongan) { }
                column(Jumlah_Rp; Jumlah_Rp) { }

                trigger OnAfterGetRecord()
                var
                    item: Record Item;
                    itemUoM: Record "Item Unit of Measure";
                    salesLine: Record "Sales Line";
                    qtyPerBesar: Decimal;
                    qtyPerSedang: Decimal;
                    sisaQty: Decimal;
                    jmlBesar: Integer;
                    jmlSedang: Integer;
                    jmlKecil: Integer;
                begin
                    Clear(Kuantitas_Teks);
                    Clear(Hrg_Jual);
                    Clear(Potongan);
                    Clear(Jumlah_Rp);

                    if salesLine.Get(salesLine."Document Type"::Order,
                                      "Source No.", "Source Line No.") then begin
                        Hrg_Jual := salesLine."Unit Price";
                        Potongan := salesLine."Line Discount Amount";
                        Jumlah_Rp := salesLine.Amount;
                    end;

                    if item.Get("Item No.") then begin
                        if item."Satuan Besar" <> '' then begin
                            if itemUoM.Get("Item No.", item."Satuan Besar") then
                                qtyPerBesar := itemUoM."Qty. per Unit of Measure";
                        end;

                        if item."Satuan Sedang" <> '' then begin
                            if itemUoM.Get("Item No.", item."Satuan Sedang") then
                                qtyPerSedang := itemUoM."Qty. per Unit of Measure";
                        end;

                        sisaQty := "Qty. Picked (Base)";

                        if qtyPerBesar > 0 then begin
                            jmlBesar := Round(sisaQty / qtyPerBesar, 1, '<');
                            sisaQty := sisaQty - (jmlBesar * qtyPerBesar);
                        end;

                        if qtyPerSedang > 0 then begin
                            jmlSedang := Round(sisaQty / qtyPerSedang, 1, '<');
                            sisaQty := sisaQty - (jmlSedang * qtyPerSedang);
                        end;

                        jmlKecil := Round(sisaQty, 1);

                        if jmlBesar > 0 then
                            Kuantitas_Teks := Format(jmlBesar) + ' ' + item."Satuan Besar";

                        if jmlSedang > 0 then begin
                            if Kuantitas_Teks <> '' then
                                Kuantitas_Teks += ' ';
                            Kuantitas_Teks += Format(jmlSedang) + ' ' + item."Satuan Sedang";
                        end;

                        if jmlKecil > 0 then begin
                            if Kuantitas_Teks <> '' then
                                Kuantitas_Teks += ' ';
                            Kuantitas_Teks += Format(jmlKecil) + ' ' + item."Base Unit of Measure";
                        end;

                        if Kuantitas_Teks = '' then
                            Kuantitas_Teks := Format("Qty. Picked (Base)") + ' ' + "Unit of Measure Code";

                    end else begin
                        Kuantitas_Teks := Format("Qty. Picked (Base)") + ' ' + "Unit of Measure Code";
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                companyInfo: Record "Company Information";
                salesHeader: Record "Sales Header";
                salesPerson: Record "Salesperson/Purchaser";
                whseShptLine: Record "Warehouse Shipment Line";
                regWhseAct: Record "Registered Whse. Activity Line";
                salesLine: Record "Sales Line";
                vatSetup: Record "VAT Posting Setup";
            begin
                Clear(Company_Address);
                Clear(Company_Phone);
                Clear(Company_NPWP);
                Clear(Salesman_Code);
                Clear(Salesman_Name);
                Clear(Picking_List_No);
                Clear(Order_Date);
                Clear(Due_Date);
                Clear(Payment_Terms);
                Clear(Customer_No);
                Clear(Customer_Name);
                Clear(Customer_Address);
                Clear(Print_DateTime);
                Clear(SPV_Finance);
                Clear(Invoice_No_);
                Clear(Subtotal);
                Clear(Disc_Inv);
                Clear(DPP);
                Clear(PPN_Pct);
                Clear(PPN_Amt);
                Clear(Total);

                companyInfo.Get();
                Company_Address := companyInfo.Address;
                Company_Phone := companyInfo."Phone No.";
                Company_NPWP := companyInfo."VAT Registration No.";

                whseShptLine.SetRange("No.", "No.");
                whseShptLine.SetFilter("Source No.", '<>%1', '');
                if whseShptLine.FindFirst() then begin
                    if salesHeader.Get(salesHeader."Document Type"::Order, whseShptLine."Source No.") then begin
                        Order_Date := salesHeader."Order Date";
                        Due_Date := salesHeader."Due Date";
                        Payment_Terms := salesHeader."Payment Terms Code";
                        Customer_No := salesHeader."Sell-to Customer No.";
                        Customer_Name := salesHeader."Bill-to Name";
                        Customer_Address := salesHeader."Bill-to Address";
                        Salesman_Code := salesHeader."Salesperson Code";
                        if salesPerson.Get(Salesman_Code) then
                            Salesman_Name := salesPerson.Name;

                        salesLine.SetRange("Document Type", salesLine."Document Type"::Order);
                        salesLine.SetRange("Document No.", whseShptLine."Source No.");
                        salesLine.SetFilter("Amount", '<>%1', 0);
                        if salesLine.FindSet() then
                            repeat
                                Subtotal += salesLine."Line Amount";
                                Disc_Inv += salesLine."Line Discount Amount";
                            until salesLine.Next() = 0;

                        DPP := Subtotal - Disc_Inv;

                        if salesLine.FindFirst() then begin
                            if vatSetup.Get(salesLine."VAT Bus. Posting Group", salesLine."VAT Prod. Posting Group") then
                                PPN_Pct := vatSetup."VAT %";
                        end;

                        PPN_Amt := DPP * PPN_Pct / 100;
                        Total := DPP + PPN_Amt;
                    end;

                    regWhseAct.SetRange("Source No.", whseShptLine."Source No.");
                    if regWhseAct.FindFirst() then
                        Picking_List_No := regWhseAct."No.";
                end;

                SPV_Finance := UserId;
                Print_DateTime := Format(CurrentDateTime, 0, '<Day,2>-<Month Text>-<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>');
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
        Company_Address: Text[100];
        Company_Phone: Text[30];
        Company_NPWP: Text[20];
        Salesman_Code: Code[20];
        Salesman_Name: Text[50];
        Picking_List_No: Code[20];
        Invoice_No_: Code[20];
        Order_Date: Date;
        Due_Date: Date;
        Payment_Terms: Code[10];
        Customer_No: Code[20];
        Customer_Name: Text[100];
        Customer_Address: Text[100];
        Print_DateTime: Text[50];
        SPV_Finance: Text[50];
        Kuantitas_Teks: Text[100];
        Hrg_Jual: Decimal;
        Potongan: Decimal;
        Jumlah_Rp: Decimal;
        Subtotal: Decimal;
        Disc_Inv: Decimal;
        DPP: Decimal;
        PPN_Pct: Decimal;
        PPN_Amt: Decimal;
        Total: Decimal;
}
