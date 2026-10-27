report 52010 "Pelunasan Cash Transfer"
{
    Caption = 'Pelunasan Cash & Transfer';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = PelunasanCashTransferExcel;

    dataset
    {
        dataitem(AdvanceHeader; "Advance Header")
        {
            RequestFilterFields = "No.", "Posting Date";

            dataitem(GenJournalLine; "Gen. Journal Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");

                // 1. Posting Date (Advance Header)
                column(PostingDate; AdvanceHeader."Posting Date") { }

                // 2. Invoice No (Gen. Journal Line)
                column(InvoiceNo; InvoiceNoValue) { }

                // 3. Invoice Date (Cust. Ledger Entry)
                column(InvoiceDate; InvoiceDateValue) { }

                // 4. Invoice Amount (Cust. Ledger Entry - Original Amount)
                column(InvoiceAmount; InvoiceAmountValue) { }

                // 5. Customer No. (Cust. Ledger Entry / Advance Header)
                column(CustomerNo; CustomerNoValue) { }

                // 6. Customer Name (Master Customer)
                column(CustomerName; CustomerNameValue) { }

                // 7. Document Source (Order No. dari Sales Invoice Header)
                column(DocumentSource; DocumentSourceValue) { }

                // 8. Payment Terms (Master Customer)
                column(PaymentTerms; PaymentTermsValue) { }

                // 9. Shipment Date (Posted Sales Invoice)
                column(ShipmentDate; ShipmentDateValue) { }

                // 10. Payment Date (Advance Header)
                column(PaymentDate; AdvanceHeader."Posting Date") { }

                // 11. Payment Source (Advance Header - Payment Method)
                column(PaymentSource; PaymentSourceValue) { }

                // 12. Payment Document (Gen. Journal Line - Bal. Account No.)
                column(PaymentDocument; GenJournalLine."Bal. Account No.") { }

                // 13. Payment Amount (Advance Header - Amount)
                column(PaymentAmount; PaymentAmountValue) { }

                // 14. Payment Type (full amount / partial amount)
                column(PaymentType; PaymentTypeValue) { }

                // 15. Outstanding Balance (Invoice Amount - Payment Amount)
                column(OutstandingBalance; OutstandingBalanceValue) { }

                trigger OnAfterGetRecord()
                begin
                    ClearValues();

                    // No. 2: Invoice No
                    InvoiceNoValue := GenJournalLine."Applies-to Doc. No.";

                    // No. 3, 4, 5, 6, 8: Info Invoice, Customer No, Customer Name & Payment Terms
                    GetInvoiceAndCustomerInfo(InvoiceNoValue);

                    // No. 7 & 9: Document Source (Order No.) & Shipment Date langsung dari Posted Sales Invoice
                    GetShipmentAndOrderInfo(InvoiceNoValue);

                    // No. 11, 13: Info Payment dari Header
                    PaymentSourceValue := Format(AdvanceHeader."Payment Method");
                    PaymentAmountValue := AdvanceHeader.Amount;

                    // No. 14: Payment Type (full amount / partial amount)
                    if InvoiceAmountValue <> 0 then begin
                        if PaymentAmountValue >= InvoiceAmountValue then
                            PaymentTypeValue := 'full amount'
                        else
                            PaymentTypeValue := 'partial amount';
                    end else
                        PaymentTypeValue := 'partial amount';

                    // No. 15: Outstanding Balance
                    OutstandingBalanceValue := InvoiceAmountValue - PaymentAmountValue;
                end;
            }
        }
    }

    rendering
    {
        layout(PelunasanCashTransferExcel)
        {
            Type = Excel;
            LayoutFile = './Report/FDD30/PelunasanCashTransfer.xlsx';
        }
    }

    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        InvoiceNoValue: Code[20];
        InvoiceDateValue: Date;
        InvoiceAmountValue: Decimal;
        CustomerNoValue: Code[20];
        CustomerNameValue: Text[100];
        DocumentSourceValue: Code[20];
        PaymentTermsValue: Code[10];
        ShipmentDateValue: Date;
        PaymentSourceValue: Text[50];
        PaymentAmountValue: Decimal;
        PaymentTypeValue: Text[30];
        OutstandingBalanceValue: Decimal;

    local procedure ClearValues()
    begin
        Clear(InvoiceNoValue);
        Clear(InvoiceDateValue);
        Clear(InvoiceAmountValue);
        Clear(CustomerNoValue);
        Clear(CustomerNameValue);
        Clear(DocumentSourceValue);
        Clear(PaymentTermsValue);
        Clear(ShipmentDateValue);
        Clear(PaymentSourceValue);
        Clear(PaymentAmountValue);
        Clear(PaymentTypeValue);
        Clear(OutstandingBalanceValue);
    end;

    local procedure GetInvoiceAndCustomerInfo(DocNo: Code[20])
    var
        CustRecord: Record Customer;
    begin
        if DocNo = '' then
            exit;

        // Ambil No. Customer, Tanggal Faktur, dan Nominal dari Cust. Ledger Entry
        CustomerLedgerEntry.Reset();
        CustomerLedgerEntry.SetRange("Document No.", DocNo);
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        if CustomerLedgerEntry.FindFirst() then begin
            CustomerLedgerEntry.CalcFields("Original Amount");
            InvoiceDateValue := CustomerLedgerEntry."Posting Date";
            InvoiceAmountValue := Abs(CustomerLedgerEntry."Original Amount");
            CustomerNoValue := CustomerLedgerEntry."Customer No.";

            // Panggil Nama dan Payment Terms dari Master Customer (Tabel 18)
            if CustRecord.Get(CustomerNoValue) then begin
                CustomerNameValue := CustRecord.Name;
                PaymentTermsValue := CustRecord."Payment Terms Code";
            end;
        end else begin
            // Fallback jika tidak ada di Ledger Entry
            if SalesInvHeader.Get(DocNo) then begin
                SalesInvHeader.CalcFields("Amount Including VAT");
                InvoiceDateValue := SalesInvHeader."Posting Date";
                InvoiceAmountValue := SalesInvHeader."Amount Including VAT";
                CustomerNoValue := SalesInvHeader."Sell-to Customer No.";

                if CustRecord.Get(CustomerNoValue) then begin
                    CustomerNameValue := CustRecord.Name;
                    PaymentTermsValue := CustRecord."Payment Terms Code";
                end;
            end;
        end;
    end;

    local procedure GetShipmentAndOrderInfo(DocNo: Code[20])
    begin
        if DocNo = '' then
            exit;

        // Ambil Order No. dan Shipment Date langsung dari Sales Invoice Header
        if SalesInvHeader.Get(DocNo) then begin
            DocumentSourceValue := SalesInvHeader."Order No.";
            ShipmentDateValue := SalesInvHeader."Shipment Date";
        end;
    end;
}