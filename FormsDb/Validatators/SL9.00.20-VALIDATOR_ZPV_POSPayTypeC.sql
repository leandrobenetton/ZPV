-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:51
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
DELETE FROM [Validators] WHERE [Name] = N'ZPV_POSPayTypeC' AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

INSERT INTO [Validators] ([Name], [ScopeType], [ScopeName], [Type], [Parms], [Parms2], [Parms3], [ErrorMsg], [LockedBy], [Description] ) 
VALUES (N'ZPV_POSPayTypeC', 1, N'[NULL]', 9, N'ZPV_POSMPayTypes( PROPERTY(PosmPayType) SETP(%1=BankCode)SETV(%1=BankCode)SETC(%2=Description) )', NULL, NULL, N'mIsNotAValid', NULL, NULL) 
