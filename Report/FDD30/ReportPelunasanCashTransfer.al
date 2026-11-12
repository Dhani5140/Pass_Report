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

                column(PostingDate; AdvanceHeader."Posting Date") { }
                column(InvoiceNo; InvoiceNoValue) { }
                column(InvoiceDate; InvoiceDateValue) { }
                column(InvoiceAmount; InvoiceAmountValue) { }
                column(CustomerNo; CustomerNoValue) { }
                column(CustomerName; CustomerNameValue) { }
                column(DocumentSource; DocumentSourceValue) { }
                column(PaymentTerms; PaymentTermsValue) { }
                column(ShipmentDate; ShipmentDateValue) { }
                column(PaymentDate; AdvanceHeader."Posting Date") { }
                column(PaymentSource; PaymentSourceValue) { }
                column(PaymentDocument; GenJournalLine."Bal. Account No.") { }
                column(PaymentAmount; PaymentAmountValue) { }
                column(PaymentType; PaymentTypeValue) { }
                column(OutstandingBalance; OutstandingBalanceValue) { }

                trigger OnAfterGetRecord()
                begin
                    // Skip baris kosong jika ada
                    if (GenJournalLine."Account No." = '') and (GenJournalLine.Amount = 0) then
                        CurrReport.Skip();

                    ClearValues();

                    // No. 2: Invoice No
                    InvoiceNoValue := GenJournalLine."Applies-to Doc. No.";

                    // No. 3, 4, 5, 6, 8: Info Invoice, Customer No, Customer Name & Payment Terms
                    GetInvoiceAndCustomerInfo(InvoiceNoValue);

                    // No. 7 & 9: Document Source (Order No.) & Shipment Date langsung dari Posted Sales Invoice
                    GetShipmentAndOrderInfo(InvoiceNoValue);

                    // No. 11: Payment Source dari Header
                    PaymentSourceValue := Format(AdvanceHeader."Payment Method");

                    // No. 13: Payment Amount ambil dari Line (GCR Lines), bukan Header!
                    // Gunakan Abs() karena pelunasan Customer di Gen. Journal Line bernilai negatif (Kredit)
                    PaymentAmountValue := Abs(GenJournalLine.Amount);

                    // Jika InvoiceAmount dari Ledger Entry 0, coba ambil dari Original Amount di Line GCR (jika field custom tersedia)
                    // if InvoiceAmountValue = 0 then
                    //     InvoiceAmountValue := Abs(GenJournalLine."Original Amount");

                    // No. 14: Payment Type (Full Amount / Partial Amount)
                    if (InvoiceAmountValue > 0) and (Round(PaymentAmountValue, 0.01) >= Round(InvoiceAmountValue, 0.01)) then
                        PaymentTypeValue := 'Full Amount'
                    else
                        PaymentTypeValue := 'Partial Amount';

                    // No. 15: Outstanding Balance = Invoice Amount - Payment Amount
                    OutstandingBalanceValue := InvoiceAmountValue - PaymentAmountValue;
                    if OutstandingBalanceValue < 0 then
                        OutstandingBalanceValue := 0;
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

        CustomerLedgerEntry.Reset();
        CustomerLedgerEntry.SetRange("Document No.", DocNo);
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        if CustomerLedgerEntry.FindFirst() then begin
            CustomerLedgerEntry.CalcFields("Original Amount");
            InvoiceDateValue := CustomerLedgerEntry."Posting Date";
            InvoiceAmountValue := Abs(CustomerLedgerEntry."Original Amount");
            CustomerNoValue := CustomerLedgerEntry."Customer No.";

            if CustRecord.Get(CustomerNoValue) then begin
                CustomerNameValue := CustRecord.Name;
                PaymentTermsValue := CustRecord."Payment Terms Code";
            end;
        end else begin
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

        if SalesInvHeader.Get(DocNo) then begin
            DocumentSourceValue := SalesInvHeader."Order No.";
            ShipmentDateValue := SalesInvHeader."Shipment Date";
        end;
    end;
}