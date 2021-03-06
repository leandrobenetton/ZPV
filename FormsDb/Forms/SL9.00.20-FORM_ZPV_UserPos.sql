-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:50
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
SET @FormID = NULL
SELECT @FormID = Forms.ID FROM Forms WHERE [Name] = N'ZPV_UserPos' AND [ScopeType] = 1
IF @FormID IS NOT NULL
BEGIN
   DELETE FROM Forms WHERE ID = @FormID
   DELETE FROM FormEventHandlers WHERE FormID = @FormID
   DELETE FROM FormComponents WHERE FormID = @FormID
   DELETE FROM ActiveXComponentProperties WHERE FormID = @FormID
   DELETE FROM Variables WHERE FormID = @FormID
   DELETE FROM FormComponentDragDropEvents WHERE FormID = @FormID
   DELETE FROM DerivedFormOverrides WHERE FormID = @FormID
END
INSERT INTO [Forms] (
  [ScopeType], [ScopeName], [Component], [Name], [SubComponent], [Type], [Caption], 
  [PrimaryDataSource], 
  [StandardOperations], [TopPos], [LeftPos], [Height], [Width], [IconFileName], [HelpFileName], [HelpContextID], [Flags], [LockedBy], 
  [FilterFormSpec], [PaneZeroSize], [Description], [MasterDeviceID], [BaseFormName] ) 
VALUES ( 
  1, N'[NULL]', NULL, N'ZPV_UserPos', NULL, 1, N'fZRT_UserPos', 
  N'ZPV_Userpos( OBJNAME(oZpvUserpos) )', 
  1019, CAST('0' AS float), CAST('0' AS float), CAST('14.4' AS float), CAST('80' AS float), NULL, NULL, -1, 8, N'sa', 
  NULL, N'0', NULL, 0, NULL)
SELECT @FormID = Forms.ID FROM Forms WHERE [Name] = N'ZPV_UserPos' AND [ScopeType] = 1
INSERT INTO FormComponents (
  [FormID], [Name], [DeviceID], 
  [TabOrder], [Type], [TopPos], [LeftPos],[Height], [ListHeight], [Width], [Caption], 
  [Validators], 
  [ContainerName], [ContainerSequence], [DataSource], 
  [Binding], [EventToGenerate], [SelectionEventToGenerate], [LoseFocusEventToGenerate], [GainFocusEventToGenerate], [RadioButtonSelectedValue], 
  [ComboListSource], 
  [Flags], [DefaultData], [ReadOnly], [Hidden], [BitmapFileName], [HelpString], [HelpFileName], [HelpContextID], [MenuName], 
  [Format], [FindFromSpec], [MaintainFromSpec], 
  [MaxCharacters], [DefaultFrom], [DataType], [ActiveXControlName], [PropertyClassName], 
  [Post301DataType], [Post301Format], 
  [Description], [EffectiveCaption] )
VALUES (
  @FormID, N'EndUserTypeGridCol', -1, 
  0, 15, CAST('0' AS float), CAST('0' AS float), CAST('6.666666666666667' AS float), CAST('0' AS float), CAST('14.285714285714287' AS float), NULL, 
  NULL, 
  N'FormCollectionGrid', 2, N'object.EndUserType', 
  1, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  0, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', N'ZPV_POSEndUserType()', NULL, NULL, NULL, 
  NULL, N'AUTOIME(NoControl)', 
  NULL, N'sEndUserType')
INSERT INTO FormComponents (
  [FormID], [Name], [DeviceID], 
  [TabOrder], [Type], [TopPos], [LeftPos],[Height], [ListHeight], [Width], [Caption], 
  [Validators], 
  [ContainerName], [ContainerSequence], [DataSource], 
  [Binding], [EventToGenerate], [SelectionEventToGenerate], [LoseFocusEventToGenerate], [GainFocusEventToGenerate], [RadioButtonSelectedValue], 
  [ComboListSource], 
  [Flags], [DefaultData], [ReadOnly], [Hidden], [BitmapFileName], [HelpString], [HelpFileName], [HelpContextID], [MenuName], 
  [Format], [FindFromSpec], [MaintainFromSpec], 
  [MaxCharacters], [DefaultFrom], [DataType], [ActiveXControlName], [PropertyClassName], 
  [Post301DataType], [Post301Format], 
  [Description], [EffectiveCaption] )
VALUES (
  @FormID, N'FormCollectionGrid', -1, 
  0, 14, CAST('1' AS float), CAST('2' AS float), CAST('12.466666666666667' AS float), CAST('0' AS float), CAST('77' AS float), N'fZPV_UserPos', 
  NULL, 
  NULL, 0, N'objects', 
  3, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  384, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, NULL, 
  NULL, N'AUTOIME(NoControl)', 
  NULL, N'fZPV_UserPos')
INSERT INTO FormComponents (
  [FormID], [Name], [DeviceID], 
  [TabOrder], [Type], [TopPos], [LeftPos],[Height], [ListHeight], [Width], [Caption], 
  [Validators], 
  [ContainerName], [ContainerSequence], [DataSource], 
  [Binding], [EventToGenerate], [SelectionEventToGenerate], [LoseFocusEventToGenerate], [GainFocusEventToGenerate], [RadioButtonSelectedValue], 
  [ComboListSource], 
  [Flags], [DefaultData], [ReadOnly], [Hidden], [BitmapFileName], [HelpString], [HelpFileName], [HelpContextID], [MenuName], 
  [Format], [FindFromSpec], [MaintainFromSpec], 
  [MaxCharacters], [DefaultFrom], [DataType], [ActiveXControlName], [PropertyClassName], 
  [Post301DataType], [Post301Format], 
  [Description], [EffectiveCaption] )
VALUES (
  @FormID, N'PosCodeGridCol', -1, 
  2, 15, CAST('1' AS float), CAST('18' AS float), CAST('12.5' AS float), CAST('0' AS float), CAST('15' AS float), N'sZRT_PosCode', 
  NULL, 
  N'FormCollectionGrid', 1, N'object.PosCode', 
  1, NULL, NULL, NULL, NULL, NULL, 
  N'STDOLE ZPV_CoPos(  PROPERTIES(PosCode, Description) )', 
  0, NULL, 0, 0, NULL, NULL, NULL, 0, N'StdDefault', 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, NULL, 
  NULL, N'AUTOIME(NoControl)', 
  NULL, N'sZRT_PosCode')
INSERT INTO FormComponents (
  [FormID], [Name], [DeviceID], 
  [TabOrder], [Type], [TopPos], [LeftPos],[Height], [ListHeight], [Width], [Caption], 
  [Validators], 
  [ContainerName], [ContainerSequence], [DataSource], 
  [Binding], [EventToGenerate], [SelectionEventToGenerate], [LoseFocusEventToGenerate], [GainFocusEventToGenerate], [RadioButtonSelectedValue], 
  [ComboListSource], 
  [Flags], [DefaultData], [ReadOnly], [Hidden], [BitmapFileName], [HelpString], [HelpFileName], [HelpContextID], [MenuName], 
  [Format], [FindFromSpec], [MaintainFromSpec], 
  [MaxCharacters], [DefaultFrom], [DataType], [ActiveXControlName], [PropertyClassName], 
  [Post301DataType], [Post301Format], 
  [Description], [EffectiveCaption] )
VALUES (
  @FormID, N'PosDefaultGridCol', -1, 
  0, 15, CAST('0' AS float), CAST('0' AS float), CAST('6.666666666666667' AS float), CAST('0' AS float), CAST('14.285714285714287' AS float), N'Defecto', 
  NULL, 
  N'FormCollectionGrid', 3, N'object.PosDefault', 
  1, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  8, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, NULL, 
  NULL, N'AUTOIME(NoControl)', 
  NULL, N'Defecto')
INSERT INTO FormComponents (
  [FormID], [Name], [DeviceID], 
  [TabOrder], [Type], [TopPos], [LeftPos],[Height], [ListHeight], [Width], [Caption], 
  [Validators], 
  [ContainerName], [ContainerSequence], [DataSource], 
  [Binding], [EventToGenerate], [SelectionEventToGenerate], [LoseFocusEventToGenerate], [GainFocusEventToGenerate], [RadioButtonSelectedValue], 
  [ComboListSource], 
  [Flags], [DefaultData], [ReadOnly], [Hidden], [BitmapFileName], [HelpString], [HelpFileName], [HelpContextID], [MenuName], 
  [Format], [FindFromSpec], [MaintainFromSpec], 
  [MaxCharacters], [DefaultFrom], [DataType], [ActiveXControlName], [PropertyClassName], 
  [Post301DataType], [Post301Format], 
  [Description], [EffectiveCaption] )
VALUES (
  @FormID, N'UserMasterGridCol', -1, 
  0, 15, CAST('0' AS float), CAST('0' AS float), CAST('5.882352941176471' AS float), CAST('0' AS float), CAST('12.5' AS float), N'Supervisor', 
  NULL, 
  N'FormCollectionGrid', 4, N'object.Master', 
  1, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  8, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, NULL, 
  NULL, N'AUTOIME(NoControl)', 
  NULL, N'Supervisor')
INSERT INTO FormComponents (
  [FormID], [Name], [DeviceID], 
  [TabOrder], [Type], [TopPos], [LeftPos],[Height], [ListHeight], [Width], [Caption], 
  [Validators], 
  [ContainerName], [ContainerSequence], [DataSource], 
  [Binding], [EventToGenerate], [SelectionEventToGenerate], [LoseFocusEventToGenerate], [GainFocusEventToGenerate], [RadioButtonSelectedValue], 
  [ComboListSource], 
  [Flags], [DefaultData], [ReadOnly], [Hidden], [BitmapFileName], [HelpString], [HelpFileName], [HelpContextID], [MenuName], 
  [Format], [FindFromSpec], [MaintainFromSpec], 
  [MaxCharacters], [DefaultFrom], [DataType], [ActiveXControlName], [PropertyClassName], 
  [Post301DataType], [Post301Format], 
  [Description], [EffectiveCaption] )
VALUES (
  @FormID, N'UsernameGridCol', -1, 
  1, 15, CAST('1' AS float), CAST('6' AS float), CAST('12.5' AS float), CAST('0' AS float), CAST('20' AS float), N'sUserName', 
  NULL, 
  N'FormCollectionGrid', 0, N'object.Username', 
  1, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  0, NULL, 0, 0, NULL, NULL, NULL, 0, N'StdDefault', 
  NULL, NULL, NULL, 
  N'0', N'UsernameVar()', NULL, NULL, NULL, 
  NULL, N'AUTOIME(NoControl)', 
  NULL, N'sUserName')
INSERT INTO Variables ( [FormID], [Name], [ScopeType], [ScopeName], [Value], [Value2], [Value3], [LockedBy], [Description] ) 
VALUES (@FormID, N'InitialCommand', 1, N'[NULL]', N'Refresh', NULL, NULL, NULL, NULL)
