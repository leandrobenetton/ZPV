-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:50
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
DELETE FROM PropertyDefaults WHERE [PropertyName] = N'ZPV_POSPayType' AND [IsPropertyClassExtension] = 0 AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

DELETE FROM PropertyDefaultDragDropEvents WHERE [PropertyName] = N'ZPV_POSPayType' AND [IsPropertyClassExtension] = 0 AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

INSERT INTO PropertyDefaults ( 
 [PropertyName], [ScopeType], [ScopeName], 
 [Description], [Label], [ListSource], 
 [FindFromForm], [FindFromProperty], [MaintainFromSpec], 
 [Validators], [MaxCharacters], [ValidateImmediately], [ValueIsListIndex], 
 [LockedBy], [DataType], [IsPropertyClassExtension], [Flags], [ComponentFlags], 
 [EventToGenerate], [SelectionEventToGenerate], [LoseFocusEventToGenerate], [GainFocusEventToGenerate], 
 [HelpString], [HelpFileName], [HelpContextID], [MenuName], 
 [Post301DataType], [Post301Format] ) 
VALUES ( 
 N'ZPV_POSPayType', 1, N'[NULL]', 
 NULL, NULL, N'STDOLE ZPV_POSMPayTypes(  PROPERTIES(PosmPayType, Description, Logifld, ZpvTermsCode, BankCode, ZlaBankType, TransType) DISPLAY(1,2))', 
 NULL, NULL, N'ZPV_POSSetup( )', 
 N'ZPV_POSPayCode(%1,%2,%3,%4,%5)', 0, 1, 0, 
 NULL, NULL, 0, 0, 0, 
 NULL, NULL, NULL, NULL, 
 NULL, NULL, 0, NULL, 
 NULL, N'AUTOIME(NoControl)' ) 


