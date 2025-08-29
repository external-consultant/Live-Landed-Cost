pageextension 50126 PPsetupCardExt extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(General)
        {
            field("Provisional Vendor"; Rec."Provisional Vendor")
            {
                ApplicationArea = All;
            }
            field("Provisional Vendor For SO"; Rec."Provisional Vendor For SO")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Provisional Vendor For SO field.', Comment = '%';
            }
        }
    }


}