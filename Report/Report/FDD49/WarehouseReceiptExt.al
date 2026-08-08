tableextension 52000 "Warehouse Receipt Header Ext" extends "Warehouse Receipt Header"
{
    fields
    {
        field(52000; "Shipping Agent Code"; Code[10])
        {
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";
            DataClassification = CustomerContent;

            // onvalidate => ter-triger saat user klik/pilih shipping agent
            trigger OnValidate()
            begin
                // panggil function
                VerifikasiApakahDokumenRetur();
            end;
        }
        field(52001; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                VerifikasiApakahDokumenRetur();
            end;
        }
    }

    // function self
    local procedure VerifikasiApakahDokumenRetur()
    var
        BarisPenerimaanGudang: Record "Warehouse Receipt Line";
    begin
        BarisPenerimaanGudang.SetRange("No.", Rec."No.");
        // Verifikasi bahwa yang bisa isi itu hanya source document dari sales return order (sro)
        BarisPenerimaanGudang.SetRange("Source Document", BarisPenerimaanGudang."Source Document"::"Sales Return Order");
        // kalau bukan dari sro tampilkan error nitif
        if BarisPenerimaanGudang.IsEmpty() then
            Error('No return orders');
    end;
}


