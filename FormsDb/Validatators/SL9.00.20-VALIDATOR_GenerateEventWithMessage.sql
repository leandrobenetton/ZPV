-------------------------------------------------------------------------------
-- SQL Script generated by FormSync 9.1.0.21 As of 26/04/2015 18:51
-- Source Configuration: ELDORADO_Forms
-------------------------------------------------------------------------------
DECLARE @FormID int
DELETE FROM [Validators] WHERE [Name] = N'GenerateEventWithMessage' AND [ScopeType] = 1 AND [ScopeName] = N'[NULL]' 

INSERT INTO [Validators] ([Name], [ScopeType], [ScopeName], [Type], [Parms], [Parms2], [Parms3], [ErrorMsg], [LockedBy], [Description] ) 
VALUES (N'GenerateEventWithMessage', 1, N'[NULL]', 14, N'SCRIPTTEXT(Option Explicit On' + NCHAR(10) + N'Option Strict On' + NCHAR(10) + NCHAR(10) + N'Imports System' + NCHAR(10) + N'Imports Microsoft.VisualBasic' + NCHAR(10) + N'Imports Mongoose.IDO.Protocol' + NCHAR(10) + N'Imports Mongoose.Scripting' + NCHAR(10) + NCHAR(10) + N'Namespace SyteLine.GlobalScripts' + NCHAR(10) + N'    Public Class Validator_GenerateEventWithMessage' + NCHAR(10) + N'        Inherits GlobalScript' + NCHAR(10) + NCHAR(10) + N'        Sub Main()' + NCHAR(10) + N'            ReturnValue = CStr(ThisForm.GenerateEvent(GetParameter(0)))' + NCHAR(10) + N'        End Sub' + NCHAR(10) + N'    End Class' + NCHAR(10) + N'End Namespace' + NCHAR(10) + N')', NULL, NULL, N'mVGenerateEventWithMessage', NULL, N'%1 is the event to generate; caller must set V(GenerateEventWithMessage) with the message to be displayed if an error occurs') 
