-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:50
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
DELETE FROM PropertyDefaults WHERE [PropertyName] = N'ZRT_EndUserType' AND [IsPropertyClassExtension] = 0 AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

DELETE FROM PropertyDefaultDragDropEvents WHERE [PropertyName] = N'ZRT_EndUserType' AND [IsPropertyClassExtension] = 0 AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

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
 N'ZRT_EndUserType', 1, N'[NULL]', 
 NULL, NULL, N'STDOLE ZRT_PosEndUsers(  PROPERTIES(EndUserType, description, PosCode, DerEndUserTypeI, DerEndUserTypeC, DerEndUserTypeD) DISPLAY(1,2,4)FILTER(PosCode=FV(ZrtPOS)))', 
 NULL, NULL, N'ZLA_EndUserTypes', 
 N'ZRT_EndUserType(%1,%2)', 0, 1, 0, 
 NULL, NULL, 0, 0, 0, 
 NULL, NULL, NULL, NULL, 
 NULL, NULL, 0, NULL, 
 NULL, N'AUTOIME(NoControl)' ) 


