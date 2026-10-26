report 52012 "General Receipt"
{
    Caption = 'Good Receipt Note';
    ApplicationArea = All;
    DefaultRenderingLayout = GeneralReceiptRDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Purch. Rcpt. Header"; "Purch. Rcpt. Header")
        {
            RequestFilterFields = "No.", "Location Code";

            column(COMPANYNAME_AdvanceHeader; Company_Name) { }
            column(CompanyInfoPicture_AdvanceHeader; CompanyInfo.Picture) { }
            column(CompanyInfoPicture_AdvanceHeaderMIMEType; GetCompanyPictureMimeType()) { }
            column(Address_CompanyInfo; Company_Address) { }
            column(Address2_CompanyInfo; '') { }
            column(City_CompanyInfo; BlankText) { }
            column(PostCode_CompanyInfo; BlankText) { }
            column(PhoneNo_CompanyInfo; Company_Phone) { }
            column(FaxNo_CompanyInfo; BlankText) { }
            column(No_PurchaseHeader; "No.") { }
            column(PostingDate_PurchaseHeader; "Posting Date") { }
            column(Vendor_Shipment_No_; "Vendor Shipment No.") { }
            column(Vendor_Name; "Buy-from Vendor Name") { }
            column(RequestorName_PurchaseHeader; BlankText) { }
            column(No_PurchaseHeader2; BlankText) { }
            column(FirstCode; BlankText) { }
            column(DimCodeBuffer_Code; BlankText) { }

            dataitem("Purch. Rcpt. Line"; "Purch. Rcpt. Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Type = const(Item));

                column(RowNo; LineRowNo) { }
                column(No_PurchaseLine; "No.") { }
                column(Description_PurchaseLine; Description) { }
                column(Quantity_PurchaseLine; Quantity) { }
                column(Unit_of_Measure_Code; "Unit of Measure") { }

                trigger OnPreDataItem()
                begin
                    LineRowNo := 0;
                end;

                trigger OnAfterGetRecord()
                begin
                    if Quantity = 0 then
                        CurrReport.Skip();

                    LineRowNo += 1;
                end;
            }
        }
    }

    rendering
    {
        layout(GeneralReceiptRDLC)
        {
            Type = RDLC;
            LayoutFile = './Report/FDD52/GeneralReceipt.rdl';
            Caption = 'Good Receipt Note';
            Summary = 'Print-out Good Receipt Note dari Posted Purchase Receipt.';
        }
    }

    var
        CompanyInfo: Record "Company Information";
        Company_Name: Text[100];
        Company_Address: Text[100];
        Company_Phone: Text[30];
        BlankText: Text[1];
        LineRowNo: Integer;

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);

        Company_Name := 'PT. PANGAN SEJAHTERA SANTOSA';
        Company_Address := 'Jl. Pluit Karang Karya Timur Blok E No. 6, Penjaringan, Jakarta Utara, 14440';
        Company_Phone := '021-66679167';
    end;

    local procedure GetCompanyPictureMimeType(): Text[100]
    var
        InStream: InStream;
        Header: array[4] of Byte;
        i: Integer;
    begin
        if not CompanyInfo.Picture.HasValue then
            exit('image/png');

        CompanyInfo.Picture.CreateInStream(InStream);
        for i := 1 to 4 do
            if InStream.Read(Header[i], 1) <> 1 then
                exit('image/png');

        // PNG: 89 50 4E 47
        if (Header[1] = 137) and (Header[2] = 80) and (Header[3] = 78) and (Header[4] = 71) then
            exit('image/png');

        // JPEG: FF D8 FF
        if (Header[1] = 255) and (Header[2] = 216) and (Header[3] = 255) then
            exit('image/jpeg');

        // BMP: 42 4D ('BM')
        if (Header[1] = 66) and (Header[2] = 77) then
            exit('image/bmp');

        // GIF: 47 49 46 38
        if (Header[1] = 71) and (Header[2] = 73) and (Header[3] = 70) then
            exit('image/gif');

        exit('image/png');
    end;
}
