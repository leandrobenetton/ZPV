-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:51
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
DELETE FROM [Validators] WHERE [Name] = N'ZrtPromCodeValidation' AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

INSERT INTO [Validators] ([Name], [ScopeType], [ScopeName], [Type], [Parms], [Parms2], [Parms3], [ErrorMsg], [LockedBy], [Description] ) 
VALUES (N'ZrtPromCodeValidation', 1, N'[NULL]', 9, N'ZRT_SLPricePromotions( PROPERTY(PromotionCode) SETP(%1=PromotionDiscount) )', NULL, NULL, N'mIsNotAValid', NULL, NULL) 