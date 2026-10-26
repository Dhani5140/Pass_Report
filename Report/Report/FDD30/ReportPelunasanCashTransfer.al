report 52010 "Pelunasan Cash Transfer"
{
    Caption = 'Pelunasan Cash & Transfer';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = PelunasanCashTransfer;

    dataset
    {
        dataitem(PostedAdvanceHeader; "Posted Advance Header")
        {
            RequestFilterFields = "Posting Date", "No.";

            dataitem(PostedAdvanceLine; "Posted Advance Line")
            {
                DataItemLink = "Document No." = field("No.");

                column(PostingDate; PostedAdvanceHeader."Posting Date") { }
                column(InvoiceNo; InvoiceNoValue) { }
                column(InvoiceDate; InvoiceDateValue) { }
                column(InvoiceAmount; InvoiceAmountValue) { }
                column(CustomerNo; CustomerNoValue) { }
                column(CustomerName; CustomerNameValue) { }
                column(DocumentSource; DocumentSourceValue) { }
                column(PaymentTerms; PaymentTermsValue) { }
                column(ShipmentDate; ShipmentDateValue) { }
                column(PaymentDate; PostedAdvanceHeader."Posting Date") { }
                column(PaymentSource; PaymentSourceValue) { }
                column(PaymentDocument; PostedAdvanceHeader."No.") { }
                column(PaymentAmount; PaymentAmountValue) { }
                column(PaymentType; PaymentTypeValue) { }
                column(OutstandingBalance; OutstandingBalanceValue) { }

                trigger OnAfterGetRecord()
                begin
                    ClearValues();
                    GetInvoiceInformation(PostedAdvanceLine."Applies-to Doc. No.");

                    PaymentAmountValue := Abs(PostedAdvanceLine.Amount);
                    PaymentSourceValue := Format(PostedAdvanceLine."Payment Method");

                    if InvoiceAmountValue <> 0 then begin
                        if PaymentAmountValue >= InvoiceAmountValue then
                            PaymentTypeValue := 'Full Amount'
                        else
                            PaymentTypeValue := 'Partial Amount';
                    end else
                        PaymentTypeValue := 'Partial Amount';

                    OutstandingBalanceValue := InvoiceAmountValue - PaymentAmountValue;
                end;
            }
        }
    }

    rendering
    {
        layout(PelunasanCashTransfer)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD30/PelunasanCashTransfer.rdl';
        }
    }

    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoiceNoValue: Code[20];
        InvoiceDateValue: Date;
        InvoiceAmountValue: Decimal;
        CustomerNoValue: Code[20];
        CustomerNameValue: Text[100];
        DocumentSourceValue: Text[50];
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

    local procedure GetInvoiceInformation(DocNo: Code[20])
    begin
        if DocNo = '' then
            exit;

        CustomerLedgerEntry.Reset();
        CustomerLedgerEntry.SetRange("Document No.", DocNo);
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        if CustomerLedgerEntry.FindFirst() then begin
            InvoiceNoValue := CustomerLedgerEntry."Document No.";
            InvoiceDateValue := CustomerLedgerEntry."Posting Date";
            InvoiceAmountValue := Abs(CustomerLedgerEntry.Amount);
            CustomerNoValue := CustomerLedgerEntry."Customer No.";

            if Customer.Get(CustomerNoValue) then begin
                CustomerNameValue := Customer.Name;
                PaymentTermsValue := Customer."Payment Terms Code";
            end;
        end;

        SalesInvoiceHeader.Reset();
        if SalesInvoiceHeader.Get(DocNo) then begin
            DocumentSourceValue := SalesInvoiceHeader."Order No.";
            ShipmentDateValue := SalesInvoiceHeader."Shipment Date";
        end else
            DocumentSourceValue := 'Posted Sales Invoice';
    end;
}
