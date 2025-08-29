tableextension 50126 PPsetupExt extends "Purchases & Payables Setup"
{
    fields
    {
        field(50125; "Provisional Vendor"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";
            Caption = 'Provisional Vendor For PO';
        }
        field(50126; "Provisional Vendor For SO"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";
        }
    }

}