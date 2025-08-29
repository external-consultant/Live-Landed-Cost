table 50125 "Landed Cost Master"
{
    DataClassification = ToBeClassified;
    Description = 'T47283';

    fields
    {
        field(1; Incoterms; Code[20])
        {
            DataClassification = ToBeClassified;
            // TableRelation = "Transaction Specification".Code;//T12937-O
            TableRelation = "Shipment Method".Code;//T12937-N
        }
        field(2; "Container Type"; Enum "Container Type")
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Expense Type"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Item Charge"."No.";
        }
        field(30; "Calculation Method"; Option)
        {
            OptionMembers = " ","Per Container","Variable Amount";
        }
        field(40; Amount; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(4; "Document Type"; Option)
        {
            OptionMembers = " ","Purchase Order","Sales Order";
        }
    }

    keys
    {
        key(Key1; Incoterms, "Container Type", "Expense Type", "Document Type")
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

}