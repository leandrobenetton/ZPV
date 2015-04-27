-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:50
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
SET @FormID = NULL
SELECT @FormID = Forms.ID FROM Forms WHERE [Name] = N'ZPV_CustomerOrderTile' AND [ScopeType] = 1
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
  1, N'[NULL]', NULL, N'ZPV_CustomerOrderTile', NULL, 5, N'fZPV_CustomerOrderTile', 
  N'ZPV_SLCos( OBJNAME(oZpv_SLCos) RLAS() )', 
  33, CAST('0' AS float), CAST('0' AS float), CAST('10' AS float), CAST('60' AS float), NULL, N'default.html?helpcontent=mergedProjects/core/forms/system/tile_form.htm', -1, 960, N'sa', 
  NULL, N'0', NULL, 0, NULL)
SELECT @FormID = Forms.ID FROM Forms WHERE [Name] = N'ZPV_CustomerOrderTile' AND [ScopeType] = 1
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
  @FormID, N'CoNumEditStatic', -1, 
  0, 0, CAST('0.19999999999999998' AS float), CAST('1.1428571428571428' AS float), CAST('2.0666666666666669' AS float), CAST('0' AS float), CAST('36.857142857142854' AS float), NULL, 
  NULL, 
  NULL, 0, N'object.CoNum', 
  1, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  16, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, N'CoNumBase', 
  NULL, N'FONT(20.25,0,0,0,700,0,0,0,0,0,0,0,0,Microsoft Sans Serif) AUTOIME(NoControl) JUSTIFY(L)', 
  NULL, N'sOrder')
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
  @FormID, N'CreditLimitEditStatic', -1, 
  0, 0, CAST('5.4666666666666659' AS float), CAST('27.428571428571427' AS float), CAST('1.4833333333333334' AS float), CAST('0' AS float), CAST('29.714285714285712' AS float), NULL, 
  NULL, 
  NULL, 0, N'object.ZpvTotalCOAmt', 
  1, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  16, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, N'Amount', 
  NULL, N'BTF() FONT(14.25,0,0,0,0,0,0,0,0,0,0,0,0,Microsoft Sans Serif) AUTOIME(NoControl) JUSTIFY(R)', 
  NULL, N'sTotalAmount')
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
  @FormID, N'CreditLimitStatic', -1, 
  0, 0, CAST('5.4666666666666659' AS float), CAST('0.71428571428571419' AS float), CAST('1.55' AS float), CAST('0' AS float), CAST('25.571428571428569' AS float), N'sEstTotPrice', 
  NULL, 
  NULL, 0, NULL, 
  0, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  0, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, NULL, 
  NULL, N'BTF() FONT(14.25,0,0,0,0,0,0,0,0,0,0,0,0,Microsoft Sans Serif) AUTOIME(NoControl) JUSTIFY(R)', 
  NULL, N'sEstTotPrice')
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
  @FormID, N'NameEditStatic', -1, 
  5, 0, CAST('2.6666666666666665' AS float), CAST('1.1428571428571428' AS float), CAST('2' AS float), CAST('0' AS float), CAST('58.428571428571423' AS float), NULL, 
  NULL, 
  NULL, 0, N'object.ZpvBillFiscalName', 
  1, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  16, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, NULL, 
  NULL, N'FONT(18,0,0,0,0,0,0,0,0,0,0,0,0,Microsoft Sans Serif) AUTOIME(NoControl)', 
  NULL, N'sName')
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
  @FormID, N'OnOrderBalanceEditStatic', -1, 
  0, 0, CAST('8.3999999999999986' AS float), CAST('27.428571428571427' AS float), CAST('1.4833333333333334' AS float), CAST('0' AS float), CAST('29.714285714285712' AS float), NULL, 
  NULL, 
  NULL, 0, N'object.DerTotalPayments', 
  1, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  16, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, N'Amount', 
  NULL, N'FONT(14.25,0,0,0,0,0,0,0,0,0,0,0,0,Microsoft Sans Serif) AUTOIME(NoControl) JUSTIFY(R)', 
  NULL, N'sTotalPaymentAmount')
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
  @FormID, N'OnOrderBalanceStatic', -1, 
  0, 0, CAST('8.3999999999999986' AS float), CAST('0.71428571428571419' AS float), CAST('1.55' AS float), CAST('0' AS float), CAST('25.571428571428569' AS float), N'sTotalPaymentAmount', 
  NULL, 
  NULL, 0, NULL, 
  0, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  0, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, N'Amount', 
  NULL, N'FONT(14.25,0,0,0,0,0,0,0,0,0,0,0,0,Microsoft Sans Serif) AUTOIME(NoControl) JUSTIFY(R)', 
  NULL, N'sTotalPaymentAmount')
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
  @FormID, N'PostedBalanceEditStatic', -1, 
  0, 0, CAST('6.8666666666666663' AS float), CAST('27.428571428571427' AS float), CAST('1.4833333333333334' AS float), CAST('0' AS float), CAST('29.714285714285712' AS float), NULL, 
  NULL, 
  NULL, 0, N'object.DerTotalInvoicedAmt', 
  1, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  16, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, N'Amount', 
  NULL, N'BTF() FONT(14.25,0,0,0,0,0,0,0,0,0,0,0,0,Microsoft Sans Serif) AUTOIME(NoControl) JUSTIFY(R)', 
  NULL, N'sTotalInvoiced')
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
  @FormID, N'PostedBalanceStatic', -1, 
  0, 0, CAST('6.8666666666666663' AS float), CAST('0.71428571428571419' AS float), CAST('1.55' AS float), CAST('0' AS float), CAST('25.571428571428569' AS float), N'sTotalInvoiced', 
  NULL, 
  NULL, 0, NULL, 
  0, NULL, NULL, NULL, NULL, NULL, 
  NULL, 
  0, NULL, 0, 0, NULL, NULL, NULL, 0, NULL, 
  NULL, NULL, NULL, 
  N'0', NULL, NULL, NULL, N'Amount', 
  NULL, N'BTF() FONT(14.25,0,0,0,0,0,0,0,0,0,0,0,0,Microsoft Sans Serif) AUTOIME(NoControl) JUSTIFY(R)', 
  NULL, N'sTotalInvoiced')
INSERT INTO Variables ( [FormID], [Name], [ScopeType], [ScopeName], [Value], [Value2], [Value3], [LockedBy], [Description] ) 
VALUES (@FormID, N'bgc_CustNumEdit', 1, N'[NULL]', NULL, NULL, NULL, NULL, NULL)
INSERT INTO Variables ( [FormID], [Name], [ScopeType], [ScopeName], [Value], [Value2], [Value3], [LockedBy], [Description] ) 
VALUES (@FormID, N'fds_DataSource', 1, N'[NULL]', N'ZPV_SLCos( OBJNAME(oZpv_SLCos) FILTERPERM(CustSeq=0) RLAS() )', NULL, NULL, NULL, NULL)
INSERT INTO Variables ( [FormID], [Name], [ScopeType], [ScopeName], [Value], [Value2], [Value3], [LockedBy], [Description] ) 
VALUES (@FormID, N'InitialCommand', 1, N'[NULL]', N'Refresh', NULL, NULL, NULL, NULL)