-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:51
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
DELETE FROM [Validators] WHERE [Name] = N'VendorUMConv' AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

INSERT INTO [Validators] ([Name], [ScopeType], [ScopeName], [Type], [Parms], [Parms2], [Parms3], [ErrorMsg], [LockedBy], [Description] ) 
VALUES (N'VendorUMConv', 1, N'[NULL]', 7, N'SL.SLUMConvs.GetumcfSp( PARMS(VAR P(%2), VAR P(%1), VAR P(%3), VAR V(%4), RVAR V(%5), MESSAGE, VAR) )', NULL, NULL, N'mValidatorMethodMessage ', NULL, NULL) 
