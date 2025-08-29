page 50129 "Edit Tracking Specification"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Tracking Specification";
    ModifyAllowed = true;
    DeleteAllowed = True;
    Permissions = tabledata "Tracking Specification" = irdm;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Analysis Date"; Rec."Analysis Date")
                {
                    ToolTip = 'Specifies the value of the Analysis Date field.', Comment = '%';
                }
                field("Appl.-from Item Entry"; Rec."Appl.-from Item Entry")
                {
                    ToolTip = 'Specifies the number of the item ledger entry that the document or journal line is applied from.';
                }
                field("Appl.-to Item Entry"; Rec."Appl.-to Item Entry")
                {
                    ToolTip = 'Specifies the number of the item ledger entry that the document or journal line is applied to.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ToolTip = 'Specifies the value of the Bin Code field.', Comment = '%';
                }
                field("Buffer Status"; Rec."Buffer Status")
                {
                    ToolTip = 'Specifies the value of the Buffer Status field.', Comment = '%';
                }
                field("Buffer Status2"; Rec."Buffer Status2")
                {
                    ToolTip = 'Specifies the value of the Buffer Status2 field.', Comment = '%';
                }
                field("Buffer Value1"; Rec."Buffer Value1")
                {
                    ToolTip = 'Specifies the value of the Buffer Value1 field.', Comment = '%';
                }
                field("Buffer Value2"; Rec."Buffer Value2")
                {
                    ToolTip = 'Specifies the value of the Buffer Value2 field.', Comment = '%';
                }
                field("Buffer Value3"; Rec."Buffer Value3")
                {
                    ToolTip = 'Specifies the value of the Buffer Value3 field.', Comment = '%';
                }
                field("Buffer Value4"; Rec."Buffer Value4")
                {
                    ToolTip = 'Specifies the value of the Buffer Value4 field.', Comment = '%';
                }
                field("Buffer Value5"; Rec."Buffer Value5")
                {
                    ToolTip = 'Specifies the value of the Buffer Value5 field.', Comment = '%';
                }
                field(Correction; Rec.Correction)
                {
                    ToolTip = 'Specifies the value of the Correction field.', Comment = '%';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ToolTip = 'Specifies the value of the Creation Date field.', Comment = '%';
                }
                field(CustomBOENumber; Rec.CustomBOENumber)
                {
                    ToolTip = 'Specifies the value of the Custom BOE No. field.', Comment = '%';
                }
                field(CustomBOENumber2; Rec.CustomBOENumber2)
                {
                    ToolTip = 'Specifies the value of the Custom BOE No. 2 field.', Comment = '%';
                }
                field(CustomLotNumber; Rec.CustomLotNumber)
                {
                    ToolTip = 'Specifies the value of the Lot No. field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the entry.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ToolTip = 'Specifies the expiration date, if any, of the item carrying the item tracking number.';
                }
                field("Expiry Period 2"; Rec."Expiry Period 2")
                {
                    ToolTip = 'Specifies the value of the Expiry Period 2 field.', Comment = '%';
                }
                field("Gross Weight 2"; Rec."Gross Weight 2")
                {
                    ToolTip = 'Specifies the value of the Gross Weight 2 field.', Comment = '%';
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    ToolTip = 'Specifies the value of the Item Ledger Entry No. field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of the item associated with the entry.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the location code for the entry.';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ToolTip = 'Specifies the lot number of the item being handled for the associated document line.';
                }
                field("Manufacturing Date 2"; Rec."Manufacturing Date 2")
                {
                    ToolTip = 'Specifies the value of the Manufacturing Date 2 field.', Comment = '%';
                }
                field("Net Weight 2"; Rec."Net Weight 2")
                {
                    ToolTip = 'Specifies the value of the Net Weight 2 field.', Comment = '%';
                }
                field("New Custom BOE No."; Rec."New Custom BOE No.")
                {
                    ToolTip = 'Specifies the value of the New BOE No. field.', Comment = '%';
                }
                field("New Custom Lot No."; Rec."New Custom Lot No.")
                {
                    ToolTip = 'Specifies the value of the New Lot No. field.', Comment = '%';
                }
                field("New Expiration Date"; Rec."New Expiration Date")
                {
                    ToolTip = 'Specifies a new expiration date.';
                }
                field("New Lot No."; Rec."New Lot No.")
                {
                    ToolTip = 'Specifies a new lot number that will take the place of the lot number in the Lot No. field.';
                }
                field("New Package No."; Rec."New Package No.")
                {
                    ToolTip = 'Specifies a new package number that will take the place of the package number in the Package No. field.';
                }
                field("New Serial No."; Rec."New Serial No.")
                {
                    ToolTip = 'Specifies a new serial number that will take the place of the serial number in the Serial No. field.';
                }
                field("Of Spec"; Rec."Of Spec")
                {
                    ToolTip = 'Specifies the value of the Off-Spec field.', Comment = '%';
                }
                field("Package No."; Rec."Package No.")
                {
                    ToolTip = 'Specifies the package number of the item being handled for the associated document line.';
                }
                field(Positive; Rec.Positive)
                {
                    ToolTip = 'Specifies the value of the Positive field.', Comment = '%';
                }
                field("Prohibit Cancellation"; Rec."Prohibit Cancellation")
                {
                    ToolTip = 'Specifies the value of the Prohibit Cancellation field.', Comment = '%';
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ToolTip = 'Specifies the value of the Qty. per Unit of Measure field.', Comment = '%';
                }
                field("Qty. Rounding Precision (Base)"; Rec."Qty. Rounding Precision (Base)")
                {
                    ToolTip = 'Specifies the value of the Qty. Rounding Precision (Base) field.', Comment = '%';
                }
                field("Qty. to Handle"; Rec."Qty. to Handle")
                {
                    ToolTip = 'Specifies the value of the Qty. to Handle field.', Comment = '%';
                }
                field("Qty. to Handle (Base)"; Rec."Qty. to Handle (Base)")
                {
                    ToolTip = 'Specifies the quantity that you want to handle in the base unit of measure.';
                }
                field("Qty. to Invoice"; Rec."Qty. to Invoice")
                {
                    ToolTip = 'Specifies the value of the Qty. to Invoice field.', Comment = '%';
                }
                field("Qty. to Invoice (Base)"; Rec."Qty. to Invoice (Base)")
                {
                    ToolTip = 'Specifies how many of the items, in base units of measure, are scheduled for invoicing.';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ToolTip = 'Specifies the quantity on the line expressed in base units of measure.';
                }
                field("Quantity actual Handled (Base)"; Rec."Quantity actual Handled (Base)")
                {
                    ToolTip = 'Specifies the value of the Quantity actual Handled (Base) field.', Comment = '%';
                }
                field("Quantity Handled (Base)"; Rec."Quantity Handled (Base)")
                {
                    ToolTip = 'Specifies the quantity of serial/lot numbers shipped or received for the associated document line, expressed in base units of measure.';
                }
                field("Quantity Invoiced (Base)"; Rec."Quantity Invoiced (Base)")
                {
                    ToolTip = 'Specifies the quantity of serial/lot numbers that are invoiced with the associated document line, expressed in base units of measure.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ToolTip = 'Specifies the serial number associated with the entry.';
                }
                field("Source Batch Name"; Rec."Source Batch Name")
                {
                    ToolTip = 'Specifies the value of the Source Batch Name field.', Comment = '%';
                }
                field("Source ID"; Rec."Source ID")
                {
                    ToolTip = 'Specifies the value of the Source ID field.', Comment = '%';
                }
                field("Source Prod. Order Line"; Rec."Source Prod. Order Line")
                {
                    ToolTip = 'Specifies the value of the Source Prod. Order Line field.', Comment = '%';
                }
                field("Source Ref. No."; Rec."Source Ref. No.")
                {
                    ToolTip = 'Specifies the value of the Source Ref. No. field.', Comment = '%';
                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    ToolTip = 'Specifies the value of the Source Subtype field.', Comment = '%';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ToolTip = 'Specifies the value of the Source Type field.', Comment = '%';
                }
                field("Supplier Batch No. 2"; Rec."Supplier Batch No. 2")
                {
                    ToolTip = 'Specifies the value of the Supplier Batch No. 2 field.', Comment = '%';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                }
                field("Transfer Item Entry No."; Rec."Transfer Item Entry No.")
                {
                    ToolTip = 'Specifies the value of the Transfer Item Entry No. field.', Comment = '%';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Warranty Date"; Rec."Warranty Date")
                {
                    ToolTip = 'Specifies that a warranty date must be entered manually.';
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