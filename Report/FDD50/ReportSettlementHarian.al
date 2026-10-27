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

                JmlFakturTotal := JmlFakturCash + JmlFakturTRF + JmlFakturRetur2 + JmlFakturTOP;
                QtyBesarTotal := QtyBesarCash + QtyBesarTRF + QtyBesarRetur2 + QtyBesarTOP;
                ValueTotal := ValueCash + ValueTRF + ValueRetur2 + ValueTOP;

                JmlTbtTotal := JmlTbtCash + JmlTbtTRF + JmlTbtBalik;
                ValueTbtTotal := ValueTbtCash + ValueTbtTRF + ValueTbtBalik;
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
        salesInvLine: Record "Sales Invoice Line";
        invNo: Code[20];
        unitValue: Decimal;
        invLineFound: Boolean;
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

                // SO yang sudah fully invoiced terhapus, ambil dari Sales Invoice Line
                salesInvLine.Reset();
                salesInvLine.SetRange("Shipment No.", postedShptLine."Posted Source No.");
                salesInvLine.SetRange("Order No.", postedShptLine."Source No.");
                salesInvLine.SetRange("Order Line No.", postedShptLine."Source Line No.");
                invLineFound := salesInvLine.FindFirst();
                if (invNo = '') and invLineFound then
                    invNo := salesInvLine."Document No.";

                if postedShptLine.Quantity > 0 then begin
                    if invNo <> '' then begin
                        if not invoiceDict.ContainsKey(invNo) then begin
                            invoiceDict.Add(invNo, true);
                            JmlFakturPeng += 1;
                        end;
                    end;

                    QtyBesarPeng += QtyBesarBase(postedShptLine."Qty. (Base)", postedShptLine."Item No.");

                    unitValue := 0;
                    if salesLine.Get(salesLine."Document Type"::Order, postedShptLine."Source No.", postedShptLine."Source Line No.") then begin
                        if salesLine.Quantity <> 0 then
                            unitValue := salesLine."Line Amount" / salesLine.Quantity;
                    end else
                        if invLineFound and (salesInvLine.Quantity <> 0) then
                            unitValue := salesInvLine."Line Amount" / salesInvLine.Quantity;

                    ValuePeng += unitValue * postedShptLine.Quantity;
                end;
            until postedShptLine.Next() = 0;
    end;

    local procedure HitungRetur()
    var
        returnRcptHeader: Record "Return Receipt Header";
        returnRcptLine: Record "Return Receipt Line";
        crMemoLine: Record "Sales Cr.Memo Line";
    begin
        returnRcptHeader.SetRange("Posting Date", PostingDate);
        if returnRcptHeader.FindSet() then
            repeat
                JmlFakturRetur += 1;

                returnRcptLine.SetRange("Document No.", returnRcptHeader."No.");
                returnRcptLine.SetRange(Type, returnRcptLine.Type::Item);
                if returnRcptLine.FindSet() then
                    repeat
                        QtyBesarRetur += QtyBesarBase(returnRcptLine."Quantity (Base)", returnRcptLine."No.");

                        // Nilai per line diambil dari credit memo (Amount) yang terbentuk
                        crMemoLine.SetRange("Return Receipt No.", returnRcptLine."Document No.");
                        crMemoLine.SetRange("Return Receipt Line No.", returnRcptLine."Line No.");
                        crMemoLine.CalcSums(Amount);
                        ValueRetur += crMemoLine.Amount;
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
        custLedgerEntry.SetAutoCalcFields(Amount);
        custLedgerEntry.SetRange("Posting Date", PostingDate);
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Payment);
        custLedgerEntry.SetFilter("Payment Method Code", 'CASH');
        custLedgerEntry.SetFilter("Document No.", '<>GCR*');
        if custLedgerEntry.FindSet() then
            repeat
                // Amount payment bernilai negatif, dikali -1
                ValueCash += -custLedgerEntry.Amount;
                HitungFakturApplied(custLedgerEntry."Entry No.", cashInvDict, JmlFakturCash, QtyBesarCash);
            until custLedgerEntry.Next() = 0;

        custLedgerEntry.SetFilter("Payment Method Code", 'TRF');
        if custLedgerEntry.FindSet() then
            repeat
                ValueTRF += -custLedgerEntry.Amount;
                HitungFakturApplied(custLedgerEntry."Entry No.", trfInvDict, JmlFakturTRF, QtyBesarTRF);
            until custLedgerEntry.Next() = 0;
    end;

    // Cari invoice yang di-apply oleh payment (Detailed Cust. Ledg. Entry type Application)
    local procedure HitungFakturApplied(PaymentEntryNo: Integer; var InvDict: Dictionary of [Code[20], Boolean]; var JmlFaktur: Integer; var QtyBesar: Decimal)
    var
        dtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        dtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        dtldCustLedgEntry.SetRange("Cust. Ledger Entry No.", PaymentEntryNo);
        dtldCustLedgEntry.SetRange("Entry Type", dtldCustLedgEntry."Entry Type"::Application);
        dtldCustLedgEntry.SetRange(Unapplied, false);
        if dtldCustLedgEntry.FindSet() then
            repeat
                if dtldCustLedgEntry."Cust. Ledger Entry No." = dtldCustLedgEntry."Applied Cust. Ledger Entry No." then begin
                    // Payment sebagai applying entry: cari entry lain dalam application yang sama
                    dtldCustLedgEntry2.SetRange("Applied Cust. Ledger Entry No.", dtldCustLedgEntry."Applied Cust. Ledger Entry No.");
                    dtldCustLedgEntry2.SetRange("Entry Type", dtldCustLedgEntry2."Entry Type"::Application);
                    dtldCustLedgEntry2.SetRange(Unapplied, false);
                    if dtldCustLedgEntry2.FindSet() then
                        repeat
                            if dtldCustLedgEntry2."Cust. Ledger Entry No." <> dtldCustLedgEntry2."Applied Cust. Ledger Entry No." then
                                TambahFakturApplied(dtldCustLedgEntry2."Cust. Ledger Entry No.", InvDict, JmlFaktur, QtyBesar);
                        until dtldCustLedgEntry2.Next() = 0;
                end else
                    TambahFakturApplied(dtldCustLedgEntry."Applied Cust. Ledger Entry No.", InvDict, JmlFaktur, QtyBesar);
            until dtldCustLedgEntry.Next() = 0;
    end;

    local procedure TambahFakturApplied(InvEntryNo: Integer; var InvDict: Dictionary of [Code[20], Boolean]; var JmlFaktur: Integer; var QtyBesar: Decimal)
    var
        invCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        if not invCustLedgEntry.Get(InvEntryNo) then
            exit;
        if invCustLedgEntry."Document Type" <> invCustLedgEntry."Document Type"::Invoice then
            exit;
        if InvDict.ContainsKey(invCustLedgEntry."Document No.") then
            exit;

        InvDict.Add(invCustLedgEntry."Document No.", true);
        JmlFaktur += 1;
        QtyBesar += QtyBesarInvoice(invCustLedgEntry."Document No.");
    end;

    local procedure HitungTOP()
    var
        custLedgerEntry: Record "Cust. Ledger Entry";
    begin
        custLedgerEntry.SetAutoCalcFields("Remaining Amount");
        custLedgerEntry.SetRange("Posting Date", PostingDate);
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Invoice);
        if custLedgerEntry.FindSet() then
            repeat
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
        postedAdvHeader.SetRange("Document Type", postedAdvHeader."Document Type"::"General Cash Receipt");
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

        // Amount payment bernilai negatif, dikali -1 sebelum dicek > 0
        custLedgerEntry.SetAutoCalcFields(Amount);
        custLedgerEntry.SetRange("Posting Date", PostingDate);
        custLedgerEntry.SetRange("Document Type", custLedgerEntry."Document Type"::Payment);
        custLedgerEntry.SetFilter("Payment Method Code", 'CASH');
        custLedgerEntry.SetFilter("Document No.", 'GCR*');
        if custLedgerEntry.FindSet() then
            repeat
                if -custLedgerEntry.Amount > 0 then
                    ValueTbtCash += -custLedgerEntry.Amount;
            until custLedgerEntry.Next() = 0;

        custLedgerEntry.SetFilter("Payment Method Code", '<>CASH');
        if custLedgerEntry.FindSet() then
            repeat
                if -custLedgerEntry.Amount > 0 then
                    ValueTbtTRF += -custLedgerEntry.Amount;
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
