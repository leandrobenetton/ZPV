/****** Object:  StoredProcedure [dbo].[ZPV_ClearingExpensesPostSp]    Script Date: 10/29/2014 12:24:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_VoidClearingExpensesPostSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_VoidClearingExpensesPostSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_VoidClearingExpensesPostSp]    Script Date: 10/29/2014 12:24:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_VoidClearingExpensesPostSp] (
	@pClearing		ZpvClearingType = null
,	@Infobar	    InfobarType     OUTPUT
) AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_ZPV_VoidClearingExpensesPostSp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_VoidClearingExpensesPostSp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      DECLARE @EXTGEN_Severity int
      EXEC @EXTGEN_Severity = @EXTGEN_SpName
         @pClearing,
         @Infobar OUTPUT
 
      -- ETP routine can RETURN 1 to signal that the remainder of this standard routine should now proceed:
      IF @EXTGEN_Severity <> 1
         RETURN @EXTGEN_Severity
   END
   -- End of Generic External Touch Point code.

DECLARE @Site SiteType
SELECT @Site = [site] FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

DECLARE
	@Severity	int

DECLARE
	@ClearingBankCode		BankCodeType
,	@ClearingBankAcct		AcctType
,	@ClearingBankAcctUnit1	UnitCode1Type
,	@ClearingBankAcctUnit2	UnitCode2Type
,	@ClearingBankAcctUnit3	UnitCode3Type
,	@ClearingBankAcctUnit4	UnitCode4Type	
,	@ClearingBankCurrCode	CurrCodeType
,	@ClearingTotalExpenses	AmountType	  
,	@ClearingTotalPosted	AmountType
,	@ClearingTransDate		DateType
,	@ClearingCustNum		CustNumType

DECLARE
	@ControlPrefix			JourControlPrefixType 
,	@ControlSite			SiteType
,	@ControlYear			FiscalYearType
,	@ControlPeriod			FinPeriodType
,	@ControlNumber			LastTranType		  
,	@SubKey					GenericKeyType
,	@Ref					varchar(23)
,	@EndTrans				int
		  
DECLARE
	@ExpensesDescription	DescriptionType
,	@ExpensesAmount			AmountType
,	@ExpensesAcct			AcctType
,	@ExpensesAcctUnit1		UnitCode1Type			
,	@ExpensesAcctUnit2		UnitCode2Type			
,	@ExpensesAcctUnit3		UnitCode3Type			
,	@ExpensesAcctUnit4		UnitCode4Type			

BEGIN TRANSACTION;
BEGIN TRY
	select
		@ClearingBankCode	= cl.bank_code
	,	@ClearingTransDate	= cl.clearing_date
	,	@ClearingCustNum	= cl.cust_num
	from zpv_ar_clearing cl	
	where	cl.clearing = @pClearing

	if @ClearingBankCode is null
	begin
		set @Infobar = 'No existe Banco para Liquidacion'
		set @Severity = 17
		rollback transaction
		return @Severity
	end
	
	select
		@ClearingBankCurrCode	= bank.curr_code
	,	@ClearingBankAcct		= bank.acct
	,	@ClearingBankAcctUnit1	= bank.acct_unit1
	,	@ClearingBankAcctUnit2	= bank.acct_unit2
	,	@ClearingBankAcctUnit3	= bank.acct_unit3
	,	@ClearingBankAcctUnit4	= bank.acct_unit4
	from bank_hdr bank
	where	bank.bank_code = @ClearingBankCode

	if @ClearingBankAcct is null
	begin
		set @Infobar = 'No existe Cuenta Contable para Banco ' + @ClearingBankCode
		set @Severity = 17
		rollback transaction
		return @Severity
	end
	if @ClearingBankCurrCode is null
	begin
		set @Infobar = 'No existe Moneda para Banco ' + @ClearingBankCode
		set @Severity = 17
		rollback transaction
		return @Severity
	end

	select @ClearingTotalExpenses = sum(cle.amount) from zpv_ar_clearing_expenses cle where cle.clearing = @pClearing	
	if @ClearingTotalExpenses = 0 or @ClearingTotalExpenses is null
	begin
		set @Infobar = 'No existen Gastos para registrar'
		set @Severity = 17
		rollback transaction
		return @Severity
	end

	--set @ClearingTotalExpenses = -(@ClearingTotalExpenses)
	SET @ControlSite = @Site
	
	EXEC dbo.NextControlNumberSp
	  @JournalId = 'AR Dist'
	, @TransDate = @ClearingTransDate
	, @ControlPrefix = @ControlPrefix output
	, @ControlSite = @ControlSite output
	, @ControlYear = @ControlYear output
	, @ControlPeriod = @ControlPeriod output
	, @ControlNumber = @ControlNumber output
	, @Infobar = @Infobar OUTPUT

	SET @SubKey = @ControlPrefix + '-'
	   + @ControlSite + '-'
	   + convert(nvarchar, @ControlYear) + '-'
	   + convert(nvarchar, @ControlPeriod)
	   
	SELECT
		@ControlNumber = KeyID + 1
	FROM NextKeys
	WHERE
		TableColumnName = 'journal.control_number' and
		SubKey			= @SubKey
		
	IF @ControlNumber IS NULL SET @ControlNumber = 1

	SET @Ref		= 'ARPC Liq ' + @pClearing
	
	EXEC @Severity = dbo.ZPV_JourpostSp
		@id                 = 'AR Dist'
	, @trans_date         = @ClearingTransDate
	, @acct               = @ClearingBankAcct
	, @acct_unit1         = @ClearingBankAcctUnit1
	, @acct_unit2         = @ClearingBankAcctUnit2
	, @acct_unit3         = @ClearingBankAcctUnit3
	, @acct_unit4         = @ClearingBankAcctUnit4
	, @amount             = @ClearingTotalExpenses
	, @for_amount         = @ClearingTotalExpenses
	, @bank_code          = @ClearingBankCode
	, @exch_rate          = 1
	, @curr_code          = @ClearingBankCurrCode
	, @check_num          = null
	, @check_date         = null
	, @ref                = @Ref
	, @vend_num           = @ClearingCustNum
	, @ref_type           = 'P'
	, @ControlPrefix	  = @ControlPrefix
	, @ControlSite		  = @ControlSite
	, @ControlYear		  = @ControlYear
	, @ControlPeriod	  = @ControlPeriod
	, @ControlNumber	  = @ControlNumber
	, @last_seq           = @EndTrans     OUTPUT
	, @Infobar            = @Infobar      OUTPUT

	if @Severity <> 0
	begin
		rollback transaction
		return @Severity
	end

	declare CurExpenses cursor for
	select
		cle.description
	,	cle.amount 	
	,	cle.acct
	,	cle.acct_unit1	
	,	cle.acct_unit2	
	,	cle.acct_unit3	
	,	cle.acct_unit4
	from zpv_ar_clearing_expenses cle
	where	cle.clearing = @pClearing			
	open CurExpenses
	fetch next from CurExpenses
	into
		@ExpensesDescription
	,	@ExpensesAmount		
	,	@ExpensesAcct		
	,	@ExpensesAcctUnit1	
	,	@ExpensesAcctUnit2	
	,	@ExpensesAcctUnit3	
	,	@ExpensesAcctUnit4	
	while @@FETCH_STATUS = 0
	begin
		set @ExpensesAmount = -(@ExpensesAmount)

		EXEC @Severity = dbo.ZPV_JourpostSp
			@id                 = 'AR Dist'
		, @trans_date         = @ClearingTransDate
		, @acct               = @ExpensesAcct
		, @acct_unit1         = @ExpensesAcctUnit1
		, @acct_unit2         = @ExpensesAcctUnit2
		, @acct_unit3         = @ExpensesAcctUnit3
		, @acct_unit4         = @ExpensesAcctUnit4
		, @amount             = @ExpensesAmount
		, @for_amount         = @ExpensesAmount
		, @bank_code          = @ClearingBankCode
		, @exch_rate          = 1
		, @curr_code          = @ClearingBankCurrCode
		, @check_num          = null
		, @check_date         = null
		, @ref                = @Ref
		, @vend_num           = @ClearingCustNum
		, @ref_type           = 'P'
		, @ControlPrefix	  = @ControlPrefix
		, @ControlSite		  = @ControlSite
		, @ControlYear		  = @ControlYear
		, @ControlPeriod	  = @ControlPeriod
		, @ControlNumber	  = @ControlNumber
		, @last_seq           = @EndTrans     OUTPUT
		, @Infobar            = @Infobar      OUTPUT

		if @Severity <> 0
		begin
			rollback transaction
			return @Severity
		end

		fetch next from CurExpenses
		into
			@ExpensesDescription
		,	@ExpensesAmount		
		,	@ExpensesAcct		
		,	@ExpensesAcctUnit1	
		,	@ExpensesAcctUnit2	
		,	@ExpensesAcctUnit3	
		,	@ExpensesAcctUnit4	
	end
	close CurExpenses
	deallocate CurExpenses
END TRY
BEGIN CATCH
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
