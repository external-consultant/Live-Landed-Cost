page 50126 "Landed Cost Detail"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Landed Cost Detail";
    AutoSplitKey = true;
    DelayedInsert = true;
    Description = 'T47283';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field(Incoterm; Rec.Incoterm)
                {
                    ToolTip = 'Specifies the value of the Incoterm field.', Comment = '%';
                }
                field("Expense Type"; Rec."Expense Type")
                {
                    ToolTip = 'Specifies the value of the Expense Type field.', Comment = '%';
                }
                field("Container Type"; Rec."Container Type")
                {
                    ToolTip = 'Specifies the value of the Container Type field.', Comment = '%';
                }
                field("No. Of Container"; Rec."No. Of Container")
                {
                    ToolTip = 'Specifies the value of the No. Of Container field.', Comment = '%';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.', Comment = '%';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Specifies the value of the Posted field.', Comment = '%';
                }
                field("Purchase Invoice No."; Rec."Purchase Invoice No.")
                {
                    ToolTip = 'Specifies the value of the Purchase Invoice No. field.', Comment = '%';
                }
                field("Purchase Invoice Date"; Rec."Purchase Invoice Date")
                {
                    ToolTip = 'Specifies the value of the Purchase Invoice Date field.', Comment = '%';
                }
            }
        }
    }

}