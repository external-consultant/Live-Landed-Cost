pageextension 50128 SalesOrderExt extends "Sales Order"
{
    layout
    {
        addafter("Transaction Specification")
        {
            field("Container Type"; Rec."Container Type")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addafter("Prepa&yment")

        {
            action("Sales-Related Expenses")
            {
                ApplicationArea = All;
                Promoted = true;
                Image = Attach;

                trigger OnAction()
                var
                    LandedCostMaster_lRec: Record "Landed Cost Master";
                    LandedCostDetaillRec: Record "Landed Cost Detail";
                    LandedCostDetailPge: Page "Landed Cost Detail";
                begin
                    if Rec."Completely Shipped" then begin
                        LandedCostDetaillRec.Reset();
                        LandedCostDetaillRec.SetRange("Document Type", LandedCostDetaillRec."Document Type"::"Sales Order");
                        LandedCostDetaillRec.SetRange("Document No.", Rec."No.");
                        if LandedCostDetaillRec.FindFirst() then
                            page.Run(50126, LandedCostDetaillRec)
                    end;

                    LandedCostDetaillRec.Reset();
                    LandedCostDetaillRec.SetRange("Document Type", LandedCostDetaillRec."Document Type"::"Sales Order");
                    LandedCostDetaillRec.SetRange("Document No.", Rec."No.");
                    LandedCostDetaillRec.SetRange(Posted, false);
                    if LandedCostDetaillRec.FindFirst() then
                        page.Run(50126, LandedCostDetaillRec)
                    else begin
                        LandedCostDetaillRec.Reset();
                        LandedCostDetaillRec.SetRange("Document Type", LandedCostDetaillRec."Document Type"::"Sales Order");
                        LandedCostDetaillRec.SetRange("Document No.", Rec."No.");
                        if LandedCostDetaillRec.FindLast() then
                            LineNo_gInt := LandedCostDetaillRec."Line No.";
                        LandedCostMaster_lRec.Reset();
                        // LandedCostMaster_lRec.SetRange(Incoterms, Rec."Transaction Specification");
                        LandedCostMaster_lRec.SetRange(Incoterms, Rec."Shipment Method Code");
                        LandedCostMaster_lRec.SetRange("Container Type", Rec."Container Type");
                        LandedCostMaster_lRec.SetRange("Document Type", LandedCostMaster_lRec."Document Type"::"Sales Order");
                        if LandedCostMaster_lRec.FindSet() then
                            repeat
                                LineNo_gInt := LineNo_gInt + 10000;
                                LandedCostDetaillRec.Init();
                                LandedCostDetaillRec."Document Type" := LandedCostDetaillRec."Document Type"::"Sales Order";
                                LandedCostDetaillRec."Document No." := Rec."No.";
                                LandedCostDetaillRec."Line No." := LineNo_gInt;
                                LandedCostDetaillRec.Incoterm := Rec."Shipment Method Code";
                                LandedCostDetaillRec."Container Type" := LandedCostMaster_lRec."Container Type";
                                LandedCostDetaillRec."Expense Type" := LandedCostMaster_lRec."Expense Type";
                                LandedCostDetaillRec.Insert();
                            until LandedCostMaster_lRec.Next() = 0;
                        LandedCostDetaillRec.Reset();
                        LandedCostDetaillRec.SetRange("Document Type", LandedCostDetaillRec."Document Type"::"Sales Order");
                        LandedCostDetaillRec.SetRange("Document No.", Rec."No.");
                        LandedCostDetaillRec.SetRange(Posted, false);
                        if LandedCostDetaillRec.FindFirst() then
                            page.Run(50126, LandedCostDetaillRec);
                    end;
                end;
            }
        }
    }

    var
        LineNo_gInt: Integer;
}