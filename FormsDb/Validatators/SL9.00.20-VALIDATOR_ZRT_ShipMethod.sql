-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:51
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
DELETE FROM [Validators] WHERE [Name] = N'ZRT_ShipMethod' AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

INSERT INTO [Validators] ([Name], [ScopeType], [ScopeName], [Type], [Parms], [Parms2], [Parms3], [ErrorMsg], [LockedBy], [Description] ) 
VALUES (N'ZRT_ShipMethod', 1, N'[NULL]', 10, N'SETP(ShipMethodDesc=ShippingMethodDescription)SETV(ShipMethodDesc=ShippingMethodDescription)', NULL, NULL, N'mIsNotAValid', NULL, NULL) 
