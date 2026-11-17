codeunit 52000 "Whse. Shpt. Line Amount"
{
    procedure GetAmounts(WhseShptLine: Record "Warehouse Shipment Line"; Qty: Decimal; var LineAmt: Decimal; var InvDisc: Decimal; var VATPct: Decimal; var UnitPrice: Decimal; var LineDisc: Decimal): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        LineAmt := 0;
        InvDisc := 0;
        VATPct := 0;
        UnitPrice := 0;
        LineDisc := 0;

        if WhseShptLine."Source Document" <> WhseShptLine."Source Document"::"Sales Order" then
            exit(false);
        if not SalesLine.Get(SalesLine."Document Type"::Order, WhseShptLine."Source No.", WhseShptLine."Source Line No.") then
            exit(false);
        if SalesLine.Quantity = 0 then
            exit(false);

        UnitPrice := SalesLine."Unit Price";
        VATPct := SalesLine."VAT %";
        LineAmt := Round(SalesLine."Line Amount" * Qty / SalesLine.Quantity);
        InvDisc := Round(SalesLine."Inv. Discount Amount" * Qty / SalesLine.Quantity);
        LineDisc := Round(SalesLine."Line Discount Amount" * Qty / SalesLine.Quantity);
        exit(true);
    end;

    procedure AmountInclVAT(WhseShptLine: Record "Warehouse Shipment Line"; Qty: Decimal): Decimal
    var
        LineAmt: Decimal;
        InvDisc: Decimal;
        VATPct: Decimal;
        UnitPrice: Decimal;
        LineDisc: Decimal;
    begin
        if not GetAmounts(WhseShptLine, Qty, LineAmt, InvDisc, VATPct, UnitPrice, LineDisc) then
            exit(0);
        exit(Round((LineAmt - InvDisc) * (1 + VATPct / 100)));
    end;
}
