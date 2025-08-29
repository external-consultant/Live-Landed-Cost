page 50130 "SO Landed Cost Master"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Landed Cost Master";
    Caption = 'Sales-Related Expenses';
    SourceTableView = where("Document Type" = const("Sales Order"));
    Description = 'T47283';


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Incoterms; Rec.Incoterms)
                {
                    ToolTip = 'Specifies the value of the Incoterms field.', Comment = '%';
                }
                field("Container Type"; Rec."Container Type")
                {
                    ToolTip = 'Specifies the value of the Container Type field.', Comment = '%';
                }
                field("Expense Type"; Rec."Expense Type")
                {
                    ToolTip = 'Specifies the value of the Expense Type field.', Comment = '%';
                }
                field("Calculation Method"; Rec."Calculation Method")
                {
                    ToolTip = 'Specifies the value of the Calculation Method field.', Comment = '%';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.', Comment = '%';
                    Editable = false;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }
}