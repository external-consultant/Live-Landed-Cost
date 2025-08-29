codeunit 50125 SubscribeCodeunit90
{
    Description = 'T47283';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePostPurchaseDoc, '', false, false)]
    local procedure "Purch.-Post_OnBeforePostPurchaseDoc"(var Sender: Codeunit "Purch.-Post"; var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var HideProgressWindow: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var IsHandled: Boolean)
    var
        LandedCostDetail_lRec: Record "Landed Cost Detail";
    begin
        If PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
            LandedCostDetail_lRec.Reset();
            LandedCostDetail_lRec.SetRange("Document No.", PurchaseHeader."No.");
            LandedCostDetail_lRec.SetRange("Document Type", LandedCostDetail_lRec."Document Type"::"Purchase Order");
            LandedCostDetail_lRec.SetRange(Posted, false);
            LandedCostDetail_lRec.SetFilter(Amount, '<>%1', 0);
            if not LandedCostDetail_lRec.FindFirst() then begin
                if not Confirm('Do you want to post without landed cost?') then
                    IsHandled := true;
            end
        End;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPostPurchaseDoc, '', false, false)]
    local procedure "Purch.-Post_OnAfterPostPurchaseDoc"(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        PurchaseHdr_lRec: Record "Purchase Header";
        PurchaseLine_lRec: Record "Purchase Line";
        LandedCostDetail_lRec: Record "Landed Cost Detail";
        ItemChargeAsslRec: Record "Item Charge Assignment (Purch)";
        PurchRcptLine_lRec: Record "Purch. Rcpt. Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        LineNo_lInt: Integer;
        Currency: Record Currency;
        PurchHeader: Record "Purchase Header";
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        ItemChargesAssigned: Boolean;
    begin
        if not PurchRcptHeader.Get(PurchRcpHdrNo) then
            exit;

        if PurchInvHeader.Get(PurchInvHdrNo) then
            exit;

        LandedCostDetail_lRec.Reset();
        LandedCostDetail_lRec.SetRange("Document No.", PurchRcptHeader."Order No.");
        LandedCostDetail_lRec.SetRange("Document Type", LandedCostDetail_lRec."Document Type"::"Purchase Order");
        LandedCostDetail_lRec.SetRange(Posted, false);
        LandedCostDetail_lRec.SetFilter(Amount, '<>0');//Hypercare 24-02-2025
        if not LandedCostDetail_lRec.FindFirst() then
            exit;

        if PurchRcptHeader.IsEmpty then
            exit;

        if PurchInvHeader."No." <> '' then
            exit;

        if PurchRcptHeader.IsTemporary then
            exit;

        PurchPaySetup_gRec.Get();
        PurchPaySetup_gRec.TestField("Provisional Vendor");
        PurchaseHdr_lRec.Init();

        PurchaseHdr_lRec."Document Type" := PurchaseHdr_lRec."Document Type"::Invoice;
        PurchaseHdr_lRec.Validate("No.", NoSeriesMgmt_gCdu.GetNextNo(PurchPaySetup_gRec."Invoice Nos.", today, true));
        PurchaseHdr_lRec.Validate("Buy-from Vendor No.", PurchPaySetup_gRec."Provisional Vendor");
        PurchaseHdr_lRec.Validate("Posting No. Series", PurchPaySetup_gRec."Posted Invoice Nos.");
        PurchaseHdr_lRec.Validate("Posting Date", PurchRcptHeader."Posting Date");
        PurchaseHdr_lRec.Validate("Document Date", PurchRcptHeader."Document Date");//Hypercare
        PurchaseHdr_lRec.Validate("Location Code", PurchRcptHeader."Location Code");
        PurchaseHdr_lRec.Validate("Vendor Invoice No.", PurchRcptHeader."No.");
        PurchaseHdr_lRec.Insert();
        LandedCostDetail_lRec.Reset();
        LandedCostDetail_lRec.SetRange("Document No.", PurchRcptHeader."Order No.");
        LandedCostDetail_lRec.SetRange("Document Type", LandedCostDetail_lRec."Document Type"::"Purchase Order");
        LandedCostDetail_lRec.SetRange(Posted, false);
        LandedCostDetail_lRec.SetFilter(Amount, '<>0');
        if LandedCostDetail_lRec.FindSet() then
            repeat
                Clear(LineNo_lInt);
                PurchaseLine_lRec.Init();
                PurchaseLine_lRec.Validate("Document Type", PurchaseLine_lRec."Document Type"::Invoice);
                PurchaseLine_lRec.Validate("Document No.", PurchaseHdr_lRec."No.");
                PurchaseLine_lRec."Line No." := LandedCostDetail_lRec."Line No.";
                PurchaseLine_lRec.Insert(true);
                PurchaseLine_lRec.Reset();
                PurchaseLine_lRec.SetRange("Document Type", PurchaseLine_lRec."Document Type"::Invoice);
                PurchaseLine_lRec.SetRange("Document No.", PurchaseHdr_lRec."No.");
                PurchaseLine_lRec.SetRange("Line No.", LandedCostDetail_lRec."Line No.");
                if PurchaseLine_lRec.FindFirst() then begin
                    PurchaseLine_lRec.Validate("Buy-from Vendor No.", PurchPaySetup_gRec."Provisional Vendor");
                    PurchaseLine_lRec.Validate(Type, PurchaseLine_lRec.Type::"Charge (Item)");
                    PurchaseLine_lRec.Validate("No.", LandedCostDetail_lRec."Expense Type");
                    PurchaseLine_lRec.Validate("location code", PurchaseHdr_lRec."Location Code");
                    PurchaseLine_lRec.Validate(Quantity, 1);
                    PurchaseLine_lRec.Validate("Direct Unit Cost", LandedCostDetail_lRec.Amount / PurchaseLine_lRec.Quantity);
                    PurchaseLine_lRec.Modify();
                end;
                PurchRcptLine_lRec.Reset();
                PurchRcptLine_lRec.SetRange("Document No.", PurchRcptHeader."No.");
                if PurchRcptLine_lRec.FindSet() then
                    repeat
                        if LineNo_lInt = 0 then
                            LineNo_lInt := 10000
                        else
                            LineNo_lInt := LineNo_lInt + 10000;
                        ItemChargeAsslRec.Init();
                        ItemChargeAsslRec.Validate("Document Type", PurchaseLine_lRec."Document Type"::Invoice);
                        ItemChargeAsslRec.Validate("Document No.", PurchaseLine_lRec."Document No.");
                        ItemChargeAsslRec.Validate("Document Line No.", PurchaseLine_lRec."Line No.");
                        ItemChargeAsslRec.Validate("Item Charge No.", PurchaseLine_lRec."No.");
                        ItemChargeAsslRec.Validate("Line No.", LineNo_lInt);
                        ItemChargeAsslRec.Validate("Applies-to Doc. Type", ItemChargeAsslRec."Applies-to Doc. Type"::Receipt);
                        ItemChargeAsslRec.Validate("Applies-to Doc. No.", PurchRcptHeader."No.");
                        ItemChargeAsslRec.Validate("Applies-to Doc. Line No.", PurchRcptLine_lRec."Line No.");
                        ItemChargeAsslRec.Validate("Item No.", PurchRcptLine_lRec."No.");
                        ItemChargeAsslRec.Validate(Description, PurchRcptLine_lRec.Description);
                        ItemChargeAsslRec.Validate("Qty. to Assign", PurchaseLine_lRec.Quantity);
                        ItemChargeAsslRec.Validate("Amount to Assign", PurchaseLine_lRec."Line Amount");
                        ItemChargeAsslRec.Insert(true);
                    until PurchRcptLine_lRec.Next() = 0;

                PurchaseLine_lRec.TestField("Qty. to Invoice");
                PurchHeader.Get(PurchaseLine_lRec."Document Type", PurchaseLine_lRec."Document No.");
                if not Currency.Get(PurchHeader."Currency Code") then
                    Currency.InitRoundingPrecision();

                ItemChargeAssgntPurch.SetRange("Document Type", PurchaseLine_lRec."Document Type");
                ItemChargeAssgntPurch.SetRange("Document No.", PurchaseLine_lRec."Document No.");
                ItemChargeAssgntPurch.SetRange("Document Line No.", PurchaseLine_lRec."Line No.");

                if not ItemChargeAssgntPurch.IsEmpty() then begin
                    ItemChargeAssgntPurch.ModifyAll("Amount to Assign", 0);
                    ItemChargeAssgntPurch.ModifyAll("Qty. to Assign", 0);
                    ItemChargeAssgntPurch.ModifyAll("Amount to Handle", 0);
                    ItemChargeAssgntPurch.ModifyAll("Qty. to Handle", 0);
                    ItemChargeAssgntPurch.FindSet();
                    AssignByAmount(ItemChargeAssgntPurch, Currency, PurchHeader, PurchaseLine_lRec.Quantity, PurchaseLine_lRec."Line Amount", PurchaseLine_lRec.Quantity, PurchaseLine_lRec."Line Amount");
                end;

                LandedCostDetail_lRec.Posted := true;
                LandedCostDetail_lRec."Purchase Invoice No." := PurchaseHdr_lRec."No.";
                LandedCostDetail_lRec."Purchase Invoice Date" := PurchaseHdr_lRec."Posting Date";
                LandedCostDetail_lRec.Modify();
            until LandedCostDetail_lRec.Next() = 0;
        //Message('Purchase Invoice %1 created Successfully', PurchaseHdr_lRec."No.");
        PurchPost_gCdu.Run(PurchaseHdr_lRec);
    end;



    local procedure AssignByAmount(var ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; Currency: Record Currency; PurchHeader: Record "Purchase Header"; TotalQtyToAssign: Decimal; TotalAmtToAssign: Decimal; TotalQtyToHandle: Decimal; TotalAmtToHandle: Decimal)
    var
        TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary;
        PurchLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        CurrExchRate: Record "Currency Exchange Rate";
        ReturnRcptLine: Record "Return Receipt Line";
        ReturnShptLine: Record "Return Shipment Line";
        SalesShptLine: Record "Sales Shipment Line";
        CurrencyCode: Code[10];
        TotalAppliesToDocLineAmount: Decimal;
    begin
        repeat
            if not ItemChargeAssgntPurch.PurchLineInvoiced() then begin
                TempItemChargeAssgntPurch := ItemChargeAssgntPurch;
                case ItemChargeAssgntPurch."Applies-to Doc. Type" of
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::Quote,
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::Order,
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::Invoice,
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::"Return Order",
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::"Credit Memo":
                        begin
                            GetPurchLineForItemChargeAssgntPurch(PurchLine, ItemChargeAssgntPurch);
                            TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" :=
                              Abs(PurchLine."Line Amount");
                        end;
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::Receipt:
                        begin
                            PurchRcptLine.Get(
                              ItemChargeAssgntPurch."Applies-to Doc. No.",
                              ItemChargeAssgntPurch."Applies-to Doc. Line No.");
                            CurrencyCode := PurchRcptLine.GetCurrencyCodeFromHeader();
                            if CurrencyCode = PurchHeader."Currency Code" then
                                TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" :=
                                  Abs(PurchRcptLine."Item Charge Base Amount")
                            else
                                TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" :=
                                  CurrExchRate.ExchangeAmtFCYToFCY(
                                    PurchHeader."Posting Date", CurrencyCode, PurchHeader."Currency Code",
                                    Abs(PurchRcptLine."Item Charge Base Amount"));
                        end;
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::"Return Shipment":
                        begin
                            ReturnShptLine.Get(
                              ItemChargeAssgntPurch."Applies-to Doc. No.",
                              ItemChargeAssgntPurch."Applies-to Doc. Line No.");
                            CurrencyCode := ReturnShptLine.GetCurrencyCode();
                            if CurrencyCode = PurchHeader."Currency Code" then
                                TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" :=
                                  Abs(ReturnShptLine."Item Charge Base Amount")
                            else
                                TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" :=
                                  CurrExchRate.ExchangeAmtFCYToFCY(
                                    PurchHeader."Posting Date", CurrencyCode, PurchHeader."Currency Code",
                                    Abs(ReturnShptLine."Item Charge Base Amount"));
                        end;
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::"Sales Shipment":
                        begin
                            SalesShptLine.Get(
                              ItemChargeAssgntPurch."Applies-to Doc. No.",
                              ItemChargeAssgntPurch."Applies-to Doc. Line No.");
                            CurrencyCode := SalesShptLine.GetCurrencyCode();
                            if CurrencyCode = PurchHeader."Currency Code" then
                                TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" :=
                                  Abs(SalesShptLine."Item Charge Base Amount")
                            else
                                TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" :=
                                  CurrExchRate.ExchangeAmtFCYToFCY(
                                    PurchHeader."Posting Date", CurrencyCode, PurchHeader."Currency Code",
                                    Abs(SalesShptLine."Item Charge Base Amount"));
                        end;
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::"Return Receipt":
                        begin
                            ReturnRcptLine.Get(
                              ItemChargeAssgntPurch."Applies-to Doc. No.",
                              ItemChargeAssgntPurch."Applies-to Doc. Line No.");
                            CurrencyCode := ReturnRcptLine.GetCurrencyCode();
                            if CurrencyCode = PurchHeader."Currency Code" then
                                TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" :=
                                  Abs(ReturnRcptLine."Item Charge Base Amount")
                            else
                                TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" :=
                                  CurrExchRate.ExchangeAmtFCYToFCY(
                                    PurchHeader."Posting Date", CurrencyCode, PurchHeader."Currency Code",
                                    Abs(ReturnRcptLine."Item Charge Base Amount"));
                        end;
                end;

                if TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" <> 0 then
                    TempItemChargeAssgntPurch.Insert()
                else begin
                    ItemChargeAssgntPurch."Amount to Assign" := 0;
                    ItemChargeAssgntPurch."Qty. to Assign" := 0;
                    ItemChargeAssgntPurch."Amount to Handle" := 0;
                    ItemChargeAssgntPurch."Qty. to Handle" := 0;
                    ItemChargeAssgntPurch.Modify();
                end;
                TotalAppliesToDocLineAmount += TempItemChargeAssgntPurch."Applies-to Doc. Line Amount";
            end;
        until ItemChargeAssgntPurch.Next() = 0;

        if TempItemChargeAssgntPurch.FindSet(true) then
            repeat
                ItemChargeAssgntPurch.Get(
                  TempItemChargeAssgntPurch."Document Type",
                  TempItemChargeAssgntPurch."Document No.",
                  TempItemChargeAssgntPurch."Document Line No.",
                  TempItemChargeAssgntPurch."Line No.");
                if TotalQtyToAssign <> 0 then begin
                    ItemChargeAssgntPurch."Qty. to Assign" :=
                      Round(
                        TempItemChargeAssgntPurch."Applies-to Doc. Line Amount" / TotalAppliesToDocLineAmount * TotalQtyToAssign,
                        UOMMgt.QtyRndPrecision());
                    ItemChargeAssgntPurch."Amount to Assign" :=
                      Round(
                        ItemChargeAssgntPurch."Qty. to Assign" / TotalQtyToAssign * TotalAmtToAssign,
                        Currency."Amount Rounding Precision");
                    ItemChargeAssgntPurch."Qty. to Handle" := ItemChargeAssgntPurch."Qty. to Assign";
                    ItemChargeAssgntPurch."Amount to Handle" := ItemChargeAssgntPurch."Amount to Assign";
                    TotalQtyToAssign -= ItemChargeAssgntPurch."Qty. to Assign";
                    TotalAmtToAssign -= ItemChargeAssgntPurch."Amount to Assign";
                    TotalQtyToHandle -= ItemChargeAssgntPurch."Qty. to Handle";
                    TotalAmtToHandle -= ItemChargeAssgntPurch."Amount to Handle";
                    TotalAppliesToDocLineAmount -= TempItemChargeAssgntPurch."Applies-to Doc. Line Amount";
                    ItemChargeAssgntPurch.Modify();

                end;
            until TempItemChargeAssgntPurch.Next() = 0;
        TempItemChargeAssgntPurch.DeleteAll();
    end;

    local procedure GetPurchLineForItemChargeAssgntPurch(var PurchaseLine: Record "Purchase Line"; var ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;

        if IsHandled then
            exit;

        PurchaseLine.Get(ItemChargeAssgntPurch."Applies-to Doc. Type", ItemChargeAssgntPurch."Applies-to Doc. No.", ItemChargeAssgntPurch."Applies-to Doc. Line No.");
    end;

    var
#pragma warning disable
        NoSeriesMgmt_gCdu: Codeunit NoSeriesManagement;
        PurchPaySetup_gRec: Record "Purchases & Payables Setup";
        PurchPost_gCdu: Codeunit "Purch.-Post";
        UOMMgt: Codeunit "Unit of Measure Management";
}