-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:51
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
DELETE FROM [Validators] WHERE [Name] = N'ZPV_TempResWhse' AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

INSERT INTO [Validators] ([Name], [ScopeType], [ScopeName], [Type], [Parms], [Parms2], [Parms3], [ErrorMsg], [LockedBy], [Description] ) 
VALUES (N'ZPV_TempResWhse', 1, N'[NULL]', 9, N'ZPV_SLLotLocs( PROPERTY(Lot) SETP(%1=Whse) )', NULL, NULL, N'mIsNotAValid', NULL, NULL) 
