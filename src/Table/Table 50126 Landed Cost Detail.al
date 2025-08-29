table 50126 "Landed Cost Detail"
{
    DataClassification = ToBeClassified;
    Description = 'T47283';

    fields
    {
        field(1; "Document Type"; Option)
        {
            OptionMembers = " ","Purchase Order","Sales Order";
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
            Editable = false;
        }
        field(30; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Container Type"; Enum "Container Type")
        {
            DataClassification = ToBeClassified;
            Editable = false;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                CalculateAmount();
            end;
        }
        field(50; "No. Of Container"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                CalculateAmount();
            end;
        }
        field(60; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Purchase Invoice No."; code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(80; "Purchase Invoice Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(90; Posted; Boolean)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(100; Incoterm; Code[20])
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Transaction Specification".Code;//T12937-O
            TableRelation = "Shipment Method".Code;//T12937-N
            Editable = false;
        }
        field(110; "Expense Type"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Charge"."No.";
            Editable = false;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                CalculateAmount();
            end;
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure CalculateAmount()
    var
        LandedCostMaster_lRec: Record "Landed Cost Master";
    begin

        LandedCostMaster_lRec.Reset();
        LandedCostMaster_lRec.SetRange(Incoterms, Rec.Incoterm);
        LandedCostMaster_lRec.SetRange("Container Type", Rec."Container Type");
        LandedCostMaster_lRec.SetRange("Expense Type", Rec."Expense Type");
        LandedCostMaster_lRec.SetRange("Calculation Method", LandedCostMaster_lRec."Calculation Method"::"Per Container");
        if LandedCostMaster_lRec.FindFirst() then begin
            Rec.Amount := LandedCostMaster_lRec.Amount * Rec."No. Of Container";
        end else begin
            LandedCostMaster_lRec.Reset();
            LandedCostMaster_lRec.SetRange(Incoterms, Rec.Incoterm);
            LandedCostMaster_lRec.SetRange("Container Type", Rec."Container Type");
            LandedCostMaster_lRec.SetRange("Expense Type", Rec."Expense Type");
            LandedCostMaster_lRec.SetRange("Calculation Method", LandedCostMaster_lRec."Calculation Method"::"Variable Amount");
            if LandedCostMaster_lRec.FindFirst() then begin
                Rec.Amount := LandedCostMaster_lRec.Amount;
            end;
        end;

    end;
}