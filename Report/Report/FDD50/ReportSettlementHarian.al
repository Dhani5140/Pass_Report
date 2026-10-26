report 52009 "Report Settlement Harian"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = ReportSettlementHarian;

    dataset
    {
        dataitem(CompanyInfo; "Company Information")
        {
            column(Company_Name; Company_Name) { }
            column(Company_Address; Company_Address) { }
            column(ReportDateTxt; ReportDateTxt) { }
            column(JmlFakturPeng; JmlFakturPeng) { }
            column(QtyBesarPeng; QtyBesarPeng) { }
            column(ValuePeng; ValuePeng) { }
            column(JmlFakturRetur; JmlFakturRetur) { }
            column(QtyBesarRetur; QtyBesarRetur) { }
            column(ValueRetur; ValueRetur) { }
            column(JmlFakturTolak; JmlFakturTolak) { }
            column(QtyBesarTolak; QtyBesarTolak) { }
            column(ValueTolak; ValueTolak) { }
            column(JmlFakturOmset; JmlFakturOmset) { }
            column(QtyBesarOmset; QtyBesarOmset) { }
            column(ValueOmset; ValueOmset) { }
            column(JmlFakturCash; JmlFakturCash) { }
            column(QtyBesarCash; QtyBesarCash) { }
            column(ValueCash; ValueCash) { }
            column(JmlFakturTRF; JmlFakturTRF) { }
            column(QtyBesarTRF; QtyBesarTRF) { }
            column(ValueTRF; ValueTRF) { }
            column(JmlFakturRetur2; JmlFakturRetur2) { }
            column(QtyBesarRetur2; QtyBesarRetur2) { }
            column(ValueRetur2; ValueRetur2) { }
            column(JmlFakturTOP; JmlFakturTOP) { }
            column(QtyBesarTOP; QtyBesarTOP) { }
            column(ValueTOP; ValueTOP) { }
            column(JmlFakturTotal; JmlFakturTotal) { }
            column(QtyBesarTotal; QtyBesarTotal) { }
            column(ValueTotal; ValueTotal) { }
            column(JmlTbtTTBT; JmlTbtTTBT) { }
            column(ValueTbtTTBT; ValueTbtTTBT) { }
            column(JmlTbtCash; JmlTbtCash) { }
            column(ValueTbtCash; ValueTbtCash) { }
            column(JmlTbtTRF; JmlTbtTRF) { }
            column(ValueTbtTRF; ValueTbtTRF) { }
            column(JmlTbtBalik; JmlTbtBalik) { }
            column(ValueTbtBalik; ValueTbtBalik) { }
            column(JmlTbtTotal; JmlTbtTotal) { }
            column(ValueTbtTotal; ValueTbtTotal) { }

            trigger OnAfterGetRecord()
            begin
                Company_Name := 'PT. PANGAN SEJAHTERA SANTOSA';
                Company_Address := 'Jl. Pluit Karang Karya Timur Blok E No. 6, Penjaringan, Jakarta Utara, 14440';

                if PostingDate = 0D then
                    PostingDate := Today;

                ReportDateTxt := Format(PostingDate, 0, '<Day,2>/<Month,2>/<Year4>');

                Clear(invoiceDict);
                Clear(cashInvDict);
                Clear(trfInvDict);
                Clear(tbtCashDict);
                Clear(tbtTrfDict);
                Clear(tbtBalikDict);

                HitungPengiriman();
                HitungRetur();
                HitungTolakan();
                HitungCashTransfer();
                HitungTOP();
                HitungTTBT();

                JmlFakturOmset := JmlFakturPeng + JmlFakturRetur + JmlFakturTolak;
                QtyBesarOmset := QtyBesarPeng - QtyBesarRetur - QtyBesarTolak;
                ValueOmset := ValuePeng - ValueRetur - ValueTolak;

                JmlFakturTotal := JmlFakturOmset;
                QtyBesarTotal := QtyBesarOmset;
                ValueTotal := ValueOmset;

                JmlTbtTotal := JmlTbtTTBT;
                ValueTbtTotal := ValueTbtTTBT;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Group)
                {
                    field(PostingDate; PostingDate)
                    {
                        Caption = 'Posting Date';
                    }
                }
            }
        }
        actions
        {
            area(processing)
            {
                action(LayoutName)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    rendering
    {
        layout(ReportSettlementHarian)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD50/ReportSettlementHarian.rdl';
        }
    }

    var
        PostingDate: Date;
        Company_Name: Text[100];
        Company_Address: Text[100];
        ReportDateTxt: Text[30];
        JmlFakturPeng: Integer;
        QtyBesarPeng: Decimal;
        ValuePeng: Decimal;
        JmlFakturRetur: Integer;
        QtyBesarRetur: Decimal;
        ValueRetur: Decimal;
        JmlFakturTolak: Integer;
        QtyBesarTolak: Decimal;
        ValueTolak: Decimal;
        JmlFakturOmset: Integer;
        QtyBesarOmset: Decimal;
        ValueOmset: Decimal;
        JmlFakturCash: Integer;
        QtyBesarCash: Decimal;
        ValueCash: Decimal;
        JmlFakturTRF: Integer;
        QtyBesarTRF: Decimal;
        ValueTRF: Decimal;
        JmlFakturRetur2: Integer;
        QtyBesarRetur2: Decimal;
        ValueRetur2: Decimal;
        JmlFakturTOP: Integer;
        QtyBesarTOP: Decimal;
        ValueTOP: Decimal;
        JmlFakturTotal: Integer;
        QtyBesarTotal: Decimal;
        ValueTotal: Decimal;
        JmlTbtTTBT: Integer;
        ValueTbtTTBT: Decimal;
        JmlTbtCash: Integer;
        ValueTbtCash: Decimal;
        JmlTbtTRF: Integer;
        ValueTbtTRF: Decimal;
        JmlTbtBalik: Integer;
        ValueTbtBalik: Decimal;
        JmlTbtTotal: Integer;
        ValueTbtTotal: Decimal;
        invoiceDict: Dictionary of [Code[20], Boolean];
        cashInvDict: Dictionary of [Code[20], Boolean];
        trfInvDict: Dictionary of [Code[20], Boolean];
        tbtCashDict: Dictionary of [Code[20], Boolean];
        tbtTrfDict: Dictionary of [Code[20], Boolean];
        tbtBalikDict: Dictionary of [Code[20], Boolean];

    local procedure HitungPengiriman()
    var
        postedShptLine: Record "Posted Whse. Shipment Line";
        salesHeader: Record "Sales Header";
        salesLine: Record "Sales Line";
        invNo: Code[20];
        unitValue: Decimal;
    begin
        postedShptLine.SetRange("Posting Date", PostingDate);
        if postedShptLine.FindSet() then
            repeat
                invNo := '';
                if salesHeader.Get(salesHeader."Document Type"::Order, postedShptLine."Source No.") then begin
                    invNo := salesHeader."Posting No.";
                    if invNo = '' then
                        invNo := salesHeader."VAT Invoice No.";
                end;

                if postedShptLine.Quantity > 0 then begin
                    if invNo <> '' then begin
                        if not invoiceDict.ContainsKey(invNo) then begin
                            invoiceDict.Add(invNo, true);
                            JmlFakturPeng += 1;
                        end;
                    end;

                    QtyBesarPeng += QtyBesarBase(postedShptLine."Qty. (Base)", postedShptLine."Item No.");

                    unitValue := 0;
                    if salesLine.Get(salesLine."Document Type"::Order, postedShptLine."Source No.", postedShptLine."Source Line No.") then
                        if salesLine.Quantity <> 0 then
                            unitValue := salesLine."Line Amount" / salesLine.Quantity;

                    ValuePeng += unitValue * postedShptLine.Quantity;
                end;
            until postedShptLine.Next() = 0;
    end;

    local procedure HitungRetur()
    var
        returnRcptHeader: Record "Return Receipt Header";
        returnRcptLine: Record "Return Receipt Line";
    begin
        returnRcptHeader.SetRange("Posting Date", PostingDate);
        if returnRcptHeader.FindSet() then
            repeat
                JmlFakturRetur += 1;

                returnRcptLine.SetRange("Document No.", returnRcptHeader."No.");
                if returnRcptLine.FindSet() then
                    repeat
                        QtyBesarRetur += QtyBesarBase(returnRcptLine."Quantity (Base)", returnRcptLine."No.");
                        ValueRetur += returnRcptLine.Quantity * returnRcptLine."Unit Price";
                    until returnRcptLine.Next() = 0;
            until returnRcptHeader.Next() = 0;

        JmlFakturRetur2 := JmlFakturRetur;
        QtyBesarRetur2 := QtyBesarRetur;
        ValueRetur2 := ValueRetur;
    end;

    local procedure HitungTolakan()
    var
        postedShptLine: Record "Posted Whse. Shipment Line";
        whseShptLine: Record "Warehouse Shipment Line";
        itemUoM: Record "Item Unit of Measure";
        salesLine: Record "Sales Line";
        qtyRetur: Decimal;
        qtyPer: Decimal;
        unitValue: Decimal;
    begin
        postedShptLine.SetRange("Posting Date", PostingDate);
        if postedShptLine.FindSet() then
            repeat
                qtyRetur := 0;
                if whseShptLine.Get(postedShptLine."Whse. Shipment No.", postedShptLine."Whse Shipment Line No.") then
                    qtyRetur := whseShptLine."Qty. to Return";

                if qtyRetur > 0 then begin
                    qtyPer := 1;
                    if itemUoM.Get(postedShptLine."Item No.", postedShptLine."Unit of Measure Code") then
                        qtyPer := itemUoM."Qty. per Unit of Measure";

                    QtyBesarTolak += QtyBesarBase(qtyRetur * qtyPer, postedShptLine."Item No.");

                    unitValue := 0;
                    if salesLine.Get(salesLine."Document Type"::Order, postedShptLine."Source No.", postedShptLine."Source Line No.") then
                        if salesLine.Quantity <> 0 then
                            unitValue := salesLine."Line Amount" / salesLine.Quantity;

                    ValueTolak += unitValue * qtyRetur;
                end;
            until postedShptLine.Next() = 0;
    end;

    local procedure HitungCashTransfer()
    var
        custLedgerEntry: Record "Cust. Ledger Entry";
    begin
        custLedgerEntry.SetRange("Posting Date", PostingDate);
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Payment);
        custLedgerEntry.SetFilter("Payment Method Code", 'CASH');
        custLedgerEntry.SetFilter("Document No.", '<>GCR*');
        if custLedgerEntry.FindSet() then
            repeat
                ValueCash += custLedgerEntry.Amount;
                if custLedgerEntry."Applies-to Doc. No." <> '' then begin
                    if not cashInvDict.ContainsKey(custLedgerEntry."Applies-to Doc. No.") then begin
                        cashInvDict.Add(custLedgerEntry."Applies-to Doc. No.", true);
                        JmlFakturCash += 1;
                        QtyBesarCash += QtyBesarInvoice(custLedgerEntry."Applies-to Doc. No.");
                    end;
                end;
            until custLedgerEntry.Next() = 0;

        custLedgerEntry.SetRange("Posting Date", PostingDate);
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Payment);
        custLedgerEntry.SetFilter("Payment Method Code", 'TRF');
        custLedgerEntry.SetFilter("Document No.", '<>GCR*');
        if custLedgerEntry.FindSet() then
            repeat
                ValueTRF += custLedgerEntry.Amount;
                if custLedgerEntry."Applies-to Doc. No." <> '' then begin
                    if not trfInvDict.ContainsKey(custLedgerEntry."Applies-to Doc. No.") then begin
                        trfInvDict.Add(custLedgerEntry."Applies-to Doc. No.", true);
                        JmlFakturTRF += 1;
                        QtyBesarTRF += QtyBesarInvoice(custLedgerEntry."Applies-to Doc. No.");
                    end;
                end;
            until custLedgerEntry.Next() = 0;
    end;

    local procedure HitungTOP()
    var
        custLedgerEntry: Record "Cust. Ledger Entry";
    begin
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Invoice);
        if custLedgerEntry.FindSet() then
            repeat
                custLedgerEntry.CalcFields("Remaining Amount");
                if custLedgerEntry."Remaining Amount" > 0 then begin
                    JmlFakturTOP += 1;
                    ValueTOP += custLedgerEntry."Remaining Amount";
                    QtyBesarTOP += QtyBesarInvoice(custLedgerEntry."Document No.");
                end;
            until custLedgerEntry.Next() = 0;
    end;

    local procedure HitungTTBT()
    var
        postedAdvHeader: Record "Posted Advance Header";
        postedAdvLine: Record "Posted Advance Line";
        custLedgerEntry: Record "Cust. Ledger Entry";
        docNo: Code[20];
    begin
        postedAdvHeader.SetRange("Posting Date", PostingDate);
        if postedAdvHeader.FindSet() then
            repeat
                ValueTbtTTBT += postedAdvHeader.Amount;

                postedAdvLine.SetRange("Document No.", postedAdvHeader."No.");
                if postedAdvLine.FindSet() then
                    repeat
                        docNo := postedAdvLine."Applies-to Doc. No.";
                        if docNo <> '' then begin
                            if postedAdvLine.Amount = 0 then begin
                                if not tbtBalikDict.ContainsKey(docNo) then begin
                                    tbtBalikDict.Add(docNo, true);
                                    JmlTbtBalik += 1;
                                    ValueTbtBalik += RemainingInvoiceAmount(docNo);
                                end;
                            end else if postedAdvLine."Payment Method" = postedAdvLine."Payment Method"::Cash then begin
                                if not tbtCashDict.ContainsKey(docNo) then begin
                                    tbtCashDict.Add(docNo, true);
                                    JmlTbtCash += 1;
                                end;
                            end else begin
                                if not tbtTrfDict.ContainsKey(docNo) then begin
                                    tbtTrfDict.Add(docNo, true);
                                    JmlTbtTRF += 1;
                                end;
                            end;
                        end;
                    until postedAdvLine.Next() = 0;
            until postedAdvHeader.Next() = 0;

        JmlTbtTTBT := JmlTbtCash + JmlTbtTRF + JmlTbtBalik;

        custLedgerEntry.SetRange("Posting Date", PostingDate);
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Payment);
        custLedgerEntry.SetFilter("Payment Method Code", 'CASH');
        custLedgerEntry.SetFilter("Document No.", 'GCR*');
        if custLedgerEntry.FindSet() then
            repeat
                if custLedgerEntry.Amount > 0 then
                    ValueTbtCash += custLedgerEntry.Amount;
            until custLedgerEntry.Next() = 0;

        custLedgerEntry.SetRange("Posting Date", PostingDate);
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Payment);
        custLedgerEntry.SetFilter("Payment Method Code", '<>CASH');
        custLedgerEntry.SetFilter("Document No.", 'GCR*');
        if custLedgerEntry.FindSet() then
            repeat
                if custLedgerEntry.Amount > 0 then
                    ValueTbtTRF += custLedgerEntry.Amount;
            until custLedgerEntry.Next() = 0;
    end;

    local procedure QtyBesarBase(QtyBase: Decimal; ItemNo: Code[20]): Decimal
    var
        item: Record Item;
        itemUoM: Record "Item Unit of Measure";
        qtyPer: Decimal;
        hasil: Decimal;
    begin
        hasil := 0;
        if QtyBase = 0 then
            exit(hasil);

        if item.Get(ItemNo) then begin
            if item."Satuan Besar" <> '' then begin
                qtyPer := 0;
                if itemUoM.Get(ItemNo, item."Satuan Besar") then
                    qtyPer := itemUoM."Qty. per Unit of Measure";

                if qtyPer <> 0 then
                    hasil := Round(QtyBase / qtyPer, 0.01);
            end;
        end;
        exit(hasil);
    end;

    local procedure QtyBesarInvoice(DocNo: Code[20]): Decimal
    var
        salesInvLine: Record "Sales Invoice Line";
        hasil: Decimal;
    begin
        hasil := 0;
        salesInvLine.SetRange("Document No.", DocNo);
        if salesInvLine.FindSet() then
            repeat
                if salesInvLine.Type = salesInvLine.Type::Item then
                    hasil += QtyBesarBase(salesInvLine."Quantity (Base)", salesInvLine."No.");
            until salesInvLine.Next() = 0;
        exit(hasil);
    end;

    local procedure RemainingInvoiceAmount(DocNo: Code[20]): Decimal
    var
        custLedgerEntry: Record "Cust. Ledger Entry";
        hasil: Decimal;
    begin
        hasil := 0;
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Invoice);
        custLedgerEntry.SetRange("Document No.", DocNo);
        if custLedgerEntry.FindFirst() then begin
            custLedgerEntry.CalcFields("Remaining Amount");
            exit(custLedgerEntry."Remaining Amount");
        end;
        exit(hasil);
    end;
}
