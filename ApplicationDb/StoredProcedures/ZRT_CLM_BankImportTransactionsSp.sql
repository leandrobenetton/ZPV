/****** Object:  StoredProcedure [dbo].[ZPV_CLM_BankImportTransactionsSp]    Script Date: 12/01/2015 01:00:59 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CLM_BankImportTransactionsSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CLM_BankImportTransactionsSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CLM_BankImportTransactionsSp]    Script Date: 12/01/2015 01:00:59 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_CLM_BankImportTransactionsSp](
	@PathFile		varchar(500) = null,
	@FilterString	LongListType = null,
	@Infobar		InfobarType = null OUTPUT)
 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

EXEC sp_configure 'Show Advanced Options', 1
RECONFIGURE

EXEC sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE

--if @PathFile is null set @PathFile = 'C:\C-RIO.xlsx'

BEGIN TRANSACTION;

BEGIN TRY

	declare @tt_trans table(
		fecha	numeric(8) --DateType
	,	descrip	varchar(100)
	,	cheque	numeric(10,0)
	,	valor	AmountType)
	
	declare
		@SQL				LongListType
	,	@File				LongListType
	,	@File1				LongListType
	,	@File2				LongListType
	,	@File3				LongListType
	,	@TBankSelect		Int
	,	@TBankTransDate		DateType
	,	@TBankDescription	varchar(100)
	,	@TBankCheckNum		APCheckNumType
	,	@TBankAmount		AmountType
	
	set @File1 = '''Microsoft.ACE.OLEDB.12.0'''
	set @File2 = '''Excel 12.0 Xml;HDR=YES;Database=' + @PathFile + ''''
	set @File3 = '''SELECT * FROM [extracto$]'''

	set @File = @File1 + ',' + @File2 + ',' + @File3
 
	IF OBJECT_ID('tempdb..#zpv_tt_tbanks') IS NULL
	SELECT
		@TBankTransDate		as 'TBankTransDate'
	,	@TBankDescription	as 'TBankDescription'
	,	@TBankCheckNum		as 'TBankCheckNum'
	,	@TBankAmount		as 'TBankAmount'
	,	@TBankSelect		as 'TBankSelect'
	INTO #zpv_tt_tbanks
	WHERE 1=2

	-- Process
	BEGIN
 		set @SQL = 'select * from OPENROWSET(' + @File + ')'
	
	
		insert into @tt_trans(
						fecha
					,	descrip
					,	cheque
					,	valor)
				
  
		EXECUTE sp_executesql @SQL

		insert into #zpv_tt_tbanks
		select
			convert(Datetime,CONVERT(CHAR(8), tt.fecha))
		,	tt.descrip
		,	tt.cheque
		,	tt.valor
		,	1
		from @tt_trans tt
		--where
		--	tt.ttInvDate between @fromdate and @todate
	END


	BEGIN
		set @SQL = 'select * from #zpv_tt_tbank where ' + @FilterString + ' order by TBankTransDate'
		if @FilterString is null
		   select * from #zpv_tt_tbanks order by TBankTransDate
		else
		   exec (@SQL)
	END
END TRY
BEGIN CATCH
	SET @Infobar = 'No se encuentra el archivo'
	SELECT 
         ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
	COMMIT TRANSACTION;

GO

