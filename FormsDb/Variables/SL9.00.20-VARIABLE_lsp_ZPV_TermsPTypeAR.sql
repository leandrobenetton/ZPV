-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:51
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
DELETE FROM [Variables] WHERE FormID = -1 AND Name = N'lsp_ZPV_TermsPTypeAR' AND ScopeType = 1 AND ScopeName = N'[NULL]' 

INSERT INTO Variables ( [FormID], [Name], [ScopeType], [ScopeName], [Value], [Value2], [Value3], [LockedBy], [Description] ) 
VALUES (-1, N'lsp_ZPV_TermsPTypeAR', 1, N'[NULL]', N'PROPERTIES(TermsPayPayType, TermsPayTermsCode, TermsPayCC, TermsPayBankCode, TermsPayTransType, TermsPayZlaBankType, TermsPayDescription, TermsPayQuotes)', NULL, NULL, NULL, NULL)
