codeunit 50126 SubscribeCodeunit80
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', false, false)]
    local procedure "Sales-Post_OnBeforePostSalesDoc"(var Sender: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        LandedCostDetail_lRec: Record "Landed Cost Detail";
        SalesShipmentLines: Record "Sales Shipment Line";
        SalesInvoiceSalesLines: Record "Sales Line";
    begin
        if PreviewMode then exit;
        //T13414-NS
        If SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            LandedCostDetail_lRec.Reset();
            LandedCostDetail_lRec.SetRange("Document No.", SalesHeader."No.");
            LandedCostDetail_lRec.SetRange("Document Type", LandedCostDetail_lRec."Document Type"::"Sales Order");
            LandedCostDetail_lRec.SetRange(Posted, false);
            LandedCostDetail_lRec.SetFilter(Amount, '<>%1', 0);
            if not LandedCostDetail_lRec.FindFirst() then begin
                if not Confirm('Do you want to post without landed cost?') then
                    IsHandled := true;
            end;
        End;
        //T13414-NE
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then begin
            SalesInvoiceSalesLines.Reset();
            SalesInvoiceSalesLines.SetRange("Document No.", SalesHeader."No.");
            SalesInvoiceSalesLines.SetRange("Document Type", SalesHeader."Document Type");
            SalesInvoiceSalesLines.SetFilter("Shipment No.", '<>%1', '');
            if SalesInvoiceSalesLines.FindFirst() then begin
                SalesShipmentLines.Reset();
                SalesShipmentLines.SetRange("Document No.", SalesInvoiceSalesLines."Shipment No.");
                SalesShipmentLines.SetFilter(Quantity, '<>%1', 0);
                if SalesShipmentLines.FindFirst() then begin
                    LandedCostDetail_lRec.Reset();
                    LandedCostDetail_lRec.SetRange("Document No.", SalesShipmentLines."Order No.");
                    LandedCostDetail_lRec.SetRange("Document Type", LandedCostDetail_lRec."Document Type"::"Sales Order");
                    LandedCostDetail_lRec.SetRange(Posted, false);
                    LandedCostDetail_lRec.SetFilter(Amount, '<>%1', 0);
                    if not LandedCostDetail_lRec.FindFirst() then begin
                        if not Confirm('Do you want to post without landed cost?') then
                            IsHandled := true;
                    end
                end;
            end;
        end;
    end;


    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterInsertPostedHeaders, '', false, false)]
    // local procedure "Sales-Post_OnAfterInsertPostedHeaders"(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHdr: Record "Sales Cr.Memo Header"; var ReceiptHeader: Record "Return Receipt Header")
    // begin
    //     // if SalesInvoiceHeader.IsEmpty then
    //     //     exit;
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesDoc"(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        PurchaseHdr_lRec: Record "Purchase Header";
        PurchaseLine_lRec: Record "Purchase Line";
        LandedCostDetail_lRec: Record "Landed Cost Detail";
        ItemChargeAsslRec: Record "Item Charge Assignment (Purch)";
        SalesShptLine_lRec: Record "Sales Shipment Line";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        LineNo_lInt: Integer;
        Currency: Record Currency;
        PurchHeader: Record "Purchase Header";
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        ItemChargesAssigned: Boolean;
        SalesShipmentHdr_lRec: Record "Sales Shipment Header";
        SalesInvoiceHdr_lRec: Record "Sales Invoice Header";
        SalesInvoiceLine_lRec: Record "Sales Invoice Line";
        SalesShipementLine1_lRec: Record "Sales Shipment Line";
        PICount_lInt: Integer;
    begin
        if SalesInvHdrNo = '' then
            exit;
        SalesInvoiceHdr_lRec.get(SalesInvHdrNo);
        if SalesInvoiceHdr_lRec.IsTemporary then exit;

        SalesInvoiceLine_lRec.Reset();
        SalesInvoiceLine_lRec.SetRange("Document No.", SalesInvoiceHdr_lRec."No.");
        SalesInvoiceLine_lRec.SetFilter(Quantity, '<>0');
        if SalesInvoiceLine_lRec.FindFirst() then begin
            if SalesInvoiceLine_lRec."Shipment No." <> '' then begin
                SalesShipementLine1_lRec.Reset();
                SalesShipementLine1_lRec.SetRange("Document No.", SalesInvoiceLine_lRec."Shipment No.");
                if SalesShipementLine1_lRec.FindFirst() then;
            end else begin
                SalesShipementLine1_lRec.Reset();
                SalesShipementLine1_lRec.SetCurrentKey("Document No.");
                SalesShipementLine1_lRec.SetRange("Order No.", SalesInvoiceHdr_lRec."Order No.");
                //SalesShipementLine1_lRec.SetFilter("Qty. Shipped Not Invoiced", '<>0');
                SalesShipementLine1_lRec.SetRange(Type, SalesShipementLine1_lRec.Type::Item);
                if SalesShipementLine1_lRec.FindLast() then;
            end;
        end;

        if not SalesShipmentHdr_lRec.Get(SalesShipementLine1_lRec."Document No.") then
            exit;

        if SalesShipmentHdr_lRec.get(SalesShipementLine1_lRec."Document No.") then;
        if SalesShipmentHdr_lRec.IsTemporary then
            exit;
        LandedCostDetail_lRec.Reset();
        LandedCostDetail_lRec.SetRange("Document No.", SalesShipmentHdr_lRec."Order No.");
        LandedCostDetail_lRec.SetRange("Document Type", LandedCostDetail_lRec."Document Type"::"Sales Order");
        LandedCostDetail_lRec.SetRange(Posted, false);
        LandedCostDetail_lRec.SetFilter(Amount, '<>0');
        if not LandedCostDetail_lRec.FindFirst() then
            exit;

        if SalesShipmentHdr_lRec.IsEmpty then
            exit;



        PurchPaySetup_gRec.Get();
        PurchPaySetup_gRec.TestField("Provisional Vendor For SO");
        PurchaseHdr_lRec.Init();

        PurchaseHdr_lRec."Document Type" := PurchaseHdr_lRec."Document Type"::Invoice;
        PurchaseHdr_lRec.Validate("No.", NoSeriesMgmt_gCdu.GetNextNo(PurchPaySetup_gRec."Invoice Nos.", today, true));
        PurchaseHdr_lRec.Validate("Buy-from Vendor No.", PurchPaySetup_gRec."Provisional Vendor For SO");
        PurchaseHdr_lRec.Validate("Posting No. Series", PurchPaySetup_gRec."Posted Invoice Nos.");
        PurchaseHdr_lRec.Validate("Posting Date", SalesInvoiceHdr_lRec."Posting Date");
        PurchaseHdr_lRec.Validate("Location Code", SalesInvoiceHdr_lRec."Location Code");
        Clear(PICount_lInt);
        PurchInvHeader.Reset();
        PurchInvHeader.SetFilter("Vendor Invoice No.", '%1', SalesInvoiceHdr_lRec."Order No." + '*');
        if PurchInvHeader.FindSet() then
            repeat
                PICount_lInt += 1;
            until PurchInvHeader.Next() = 0;
        PurchaseHdr_lRec.Validate("Vendor Invoice No.", SalesInvoiceHdr_lRec."Order No." + '-' + Format(PICount_lInt));
        PurchaseHdr_lRec.Insert();
        LandedCostDetail_lRec.Reset();
        LandedCostDetail_lRec.SetRange("Document No.", SalesInvoiceHdr_lRec."Order No.");
        LandedCostDetail_lRec.SetRange("Document Type", LandedCostDetail_lRec."Document Type"::"Sales Order");
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
                    PurchaseLine_lRec.Validate("Buy-from Vendor No.", PurchPaySetup_gRec."Provisional Vendor For SO");
                    PurchaseLine_lRec.Validate(Type, PurchaseLine_lRec.Type::"Charge (Item)");
                    PurchaseLine_lRec.Validate("No.", LandedCostDetail_lRec."Expense Type");
                    PurchaseLine_lRec.Validate("location code", PurchaseHdr_lRec."Location Code");
                    PurchaseLine_lRec.Validate(Quantity, 1);
                    PurchaseLine_lRec.Validate("Direct Unit Cost", LandedCostDetail_lRec.Amount / PurchaseLine_lRec.Quantity);
                    PurchaseLine_lRec.Modify();
                end;
                SalesShptLine_lRec.Reset();
                SalesShptLine_lRec.SetRange("Document No.", SalesShipmentHdr_lRec."No.");
                SalesShptLine_lRec.SetfILTER(Quantity, '<>0');
                SalesShptLine_lRec.SetRange(Type, SalesShptLine_lRec.Type::Item);
                if SalesShptLine_lRec.FindSet() then
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
                        ItemChargeAsslRec.Validate("Applies-to Doc. Type", ItemChargeAsslRec."Applies-to Doc. Type"::"Sales Shipment");
                        ItemChargeAsslRec.Validate("Applies-to Doc. No.", SalesShipmentHdr_lRec."No.");
                        ItemChargeAsslRec.Validate("Applies-to Doc. Line No.", SalesShptLine_lRec."Line No.");
                        ItemChargeAsslRec.Validate("Item No.", SalesShptLine_lRec."No.");
                        ItemChargeAsslRec.Validate(Description, SalesShptLine_lRec.Description);
                        ItemChargeAsslRec.Validate("Qty. to Assign", PurchaseLine_lRec.Quantity);
                        ItemChargeAsslRec.Validate("Amount to Assign", PurchaseLine_lRec."Line Amount");
                        ItemChargeAsslRec.Insert(true);
                    until SalesShptLine_lRec.Next() = 0;

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
                    //AssignByAmount(ItemChargeAssgntPurch, Currency, PurchHeader, PurchaseLine_lRec.Quantity, PurchaseLine_lRec."Line Amount", PurchaseLine_lRec.Quantity, PurchaseLine_lRec."Line Amount");
                    AssignEqually(ItemChargeAssgntPurch, Currency, PurchaseLine_lRec.Quantity, PurchaseLine_lRec."Direct Unit Cost", PurchaseLine_lRec.Quantity, PurchaseLine_lRec."Direct Unit Cost");
                end;

                LandedCostDetail_lRec.Posted := true;
                LandedCostDetail_lRec."Purchase Invoice No." := PurchaseHdr_lRec."No.";
                LandedCostDetail_lRec."Purchase Invoice Date" := PurchaseHdr_lRec."Posting Date";
                LandedCostDetail_lRec.Modify();
            until LandedCostDetail_lRec.Next() = 0;
        //Message('Purchase Invoice %1 created Successfully', PurchaseHdr_lRec."No.");
        Commit();
        PurchPost_gCdu.Run(PurchaseHdr_lRec);
    end;

    local procedure AssignByAmount(var ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; Currency: Record Currency; PurchHeader: Record "Purchase Header"; TotalQtyToAssign: Decimal; TotalAmtToAssign: Decimal; TotalQtyToHandle: Decimal; TotalAmtToHandle: Decimal)
    var
        TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary;
        PurchLine: Record "Sales Line";
        PurchRcptLine: Record "Sales Shipment Line";
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
                            CurrencyCode := PurchRcptLine.GetCurrencyCode();
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

    local procedure AssignEqually(var ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; Currency: Record Currency; TotalQtyToAssign: Decimal; TotalAmtToAssign: Decimal; TotalQtyToHandle: Decimal; TotalAmtToHandle: Decimal)
    var
        TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary;
        RemainingNumOfLines: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // OnBeforeAssignEqually(ItemChargeAssgntPurch, Currency, TotalQtyToAssign, TotalAmtToAssign, IsHandled);
        if IsHandled then
            exit;

        repeat
            if not ItemChargeAssgntPurch.PurchLineInvoiced() then begin
                TempItemChargeAssgntPurch := ItemChargeAssgntPurch;
                TempItemChargeAssgntPurch.Insert();
            end;
        until ItemChargeAssgntPurch.Next() = 0;

        if TempItemChargeAssgntPurch.FindSet(true) then begin
            RemainingNumOfLines := TempItemChargeAssgntPurch.Count();
            repeat
                ItemChargeAssgntPurch.Get(
                  TempItemChargeAssgntPurch."Document Type",
                  TempItemChargeAssgntPurch."Document No.",
                  TempItemChargeAssgntPurch."Document Line No.",
                  TempItemChargeAssgntPurch."Line No.");
                ItemChargeAssgntPurch."Qty. to Assign" := Round(TotalQtyToAssign / RemainingNumOfLines, UOMMgt.QtyRndPrecision());
                ItemChargeAssgntPurch."Amount to Assign" :=
                  Round(
                    ItemChargeAssgntPurch."Qty. to Assign" / TotalQtyToAssign * TotalAmtToAssign,
                    Currency."Amount Rounding Precision");
                ItemChargeAssgntPurch."Qty. to Handle" := ItemChargeAssgntPurch."Qty. to Assign";
                ItemChargeAssgntPurch."Amount to Handle" := ItemChargeAssgntPurch."Amount to Assign";
                // OnAssignEquallyOnAfterAmountToAssignCalculated(ItemChargeAssgntPurch);
                TotalQtyToAssign -= ItemChargeAssgntPurch."Qty. to Assign";
                TotalAmtToAssign -= ItemChargeAssgntPurch."Amount to Assign";
                TotalQtyToHandle -= ItemChargeAssgntPurch."Qty. to Handle";
                TotalAmtToHandle -= ItemChargeAssgntPurch."Amount to Handle";
                RemainingNumOfLines := RemainingNumOfLines - 1;
                // OnAssignEquallyOnBeforeItemChargeAssignmentPurchModify(ItemChargeAssgntPurch);
                ItemChargeAssgntPurch.Modify();
            // OnAssignEquallyOnAfterItemChargeAssignmentPurchModify(ItemChargeAssgntPurch);
            until TempItemChargeAssgntPurch.Next() = 0;
        end;
        TempItemChargeAssgntPurch.DeleteAll();
    end;

    local procedure GetPurchLineForItemChargeAssgntPurch(var PurchaseLine: Record "Sales Line"; var ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)")
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