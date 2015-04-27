/****** Object:  StoredProcedure [dbo].[ZPV_DrawerCheckInSp]    Script Date: 16/01/2015 03:13:13 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_DrawerCheckInSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_DrawerCheckInSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_DrawerCheckInSp]    Script Date: 16/01/2015 03:13:13 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ZPV_DrawerCheckInSp] (
	@Drawer			varchar(15),
	@CheckInUser	UsernameType,
	@CheckInDate	DateTimeType,
	@InitialBalance	AmountType,
	@DrawerBalance	AmountType,
	@Infobar	InfobarType   OUTPUT
)
AS

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

DECLARE
  @Severity             INT
SET @Severity = 0
SET @Infobar  = NULL

DECLARE
	@ControlPrefix        JourControlPrefixType 
,	@ControlSite          SiteType
,	@ControlYear          FiscalYearType
,	@ControlPeriod        FinPeriodType
,	@ControlNumber        LastTranType		  
--
,	@TransDate			DateType
,	@SubKey				GenericKeyType
,	@CurrCode			CurrCodeType
,	@Ref				varchar(23)
,	@EndTrans			JournalSeqType
,	@ParmsCurrCode	CurrCodeType

declare
	@DrawerBankCode		BankCodeType

declare
	@DrawerTransAmount		AmountType
,	@DrawerTransArTypeId	ZlaArPayIdType
,	@DrawerTransCoNum		CoNumType
,	@DrawerTransCopayRowpointer	RowPointerType
,	@DrawerTransCurrCode	CurrCodeType
,	@DrawerTransDrawer		varchar(15)
,	@DrawerTransExchRate	ExchRateType
,	@DrawerTransForAmount	AmountType
,	@DrawerTransPacket		varchar(15)
,	@DrawerTransZlaBankType	ZlaBankType
,	@DrawerTransRowPointer	RowPointerType
,	@DrawerTransAmountTranfer		AmountType
,	@DrawerTransForAmountTranfer	AmountType

declare
	@DrawerBalanceNotCash	AmountType
,	@DrawerBalanceCash		AmountType

declare
	@TransNum		MatlTransNumType

declare
     @Transaction		GlCheckNumType
   , @Exists			INT
   , @CreateTempRec		tinyint
   , @CustCurrCode		CurrCodeType
   , @BankCurrCode		CurrCodeType
   , @BankCurrAmount	AmountType
   , @NewRecType		ArpmtTypeType

declare
	@NewGlBankBankCode		BankCodeType
,	@NewGlBankCheckDate		DateType		
,	@NewGlBankCheckNumber	ArCheckNumType
,	@NewGlBankCheckAmt		AmountType
,	@NewGlBankType			ArpmtTypeType
,	@NewGlBankRefType		ReferenceType
,	@NewGlBankRefNum		CustNumType
,	@NewGlBankDomCheckAmt			AmountType
,	@NewGlBankZlaThirdPartyCheck	ListYesNoType
,	@NewGlBankZlaThirdBankId		BankCodeType
,	@NewGlBankZlaThirdDescription	DescriptionType
,	@NewGlBankZlaThirdTaxNumReg	TaxRegNumType
,	@NewGlBankZlaThirdCheckDate	DateType
,	@NewGlBankZlaArPayId			ZlaArPayIdType
,	@NewGlBankZlaCreditCardExpDate ZlaCreditCardExpDateType
,	@NewGlBankZlaCreditCardPayments ZlaCreditCardPaymentType
,	@NewGlBankRowPointer	RowpointerType

declare
	@GlBankAcct1		AcctType
,	@GlBankAcct1Unit1	UnitCode1Type
,	@GlBankAcct1Unit2	UnitCode2Type
,	@GlBankAcct1Unit3	UnitCode3Type
,	@GlBankAcct1Unit4	UnitCode4Type
,	@GlBankAcct2		AcctType
,	@GlBankAcct2Unit1	UnitCode1Type
,	@GlBankAcct2Unit2	UnitCode2Type
,	@GlBankAcct2Unit3	UnitCode3Type
,	@GlBankAcct2Unit4	UnitCode4Type

declare
	@GlBankDifBankCode	BankCodeType
,	@AmountDif			AmountType
,	@GlBankDifAcct1		AcctType
,	@GlBankDifAcct1Unit1	UnitCode1Type
,	@GlBankDifAcct1Unit2	UnitCode2Type
,	@GlBankDifAcct1Unit3	UnitCode3Type
,	@GlBankDifAcct1Unit4	UnitCode4Type


BEGIN TRANSACTION;

BEGIN TRY
	SELECT TOP(1) @ParmsCurrCode = currency.curr_code FROM currency
	SET @Severity = 0
	SET @Infobar  = NULL
	SET @NewRecType = 'D'
	SET @TransDate	= getdate()

	BEGIN
		IF EXISTS(SELECT * FROM zpv_drawer WHERE drawer = @Drawer AND check_in = 0)
		BEGIN
			select 
				@DrawerBalanceNotCash = isnull(sum(drt.amount),0)
			from zpv_drawer_trans drt
			where	drt.drawer = @Drawer
				and drt.zla_bank_type <> 'E'
		
			if @DrawerBalanceNotCash <> 0
			BEGIN
				SET @Infobar = 'La Caja tiene Valores pendientes de cierre, no se puede realizar el CheckIn'		
			END
			ELSE
			BEGIN
				select 
					@DrawerBalanceCash = isnull(sum(drt.amount),0)
				from zpv_drawer_trans drt
				where	drt.drawer = @Drawer
					and drt.zla_bank_type = 'E'
			
				if @DrawerBalanceCash = @InitialBalance
				begin
					select
						@DrawerTransAmount		= 0
					,	@DrawerTransArTypeId	= null
					,	@DrawerTransCoNum		= null
					,	@DrawerTransCopayRowpointer	= null
					,	@DrawerTransCurrCode	= @ParmsCurrCode
					,	@DrawerTransDrawer		= @Drawer
					,	@DrawerTransExchRate	= 1
					,	@DrawerTransForAmount	= 0
					,	@DrawerTransPacket		= null
					,	@DrawerTransZlaBankType	= 'E'
					,	@DrawerTransAmountTranfer	= 0
					,	@DrawerTransForAmountTranfer	= 0

					select top 1 @TransNum =  isnull(trans_num + 1,1) from zpv_drawer_trans order by trans_num desc
					if @TransNum is null set @TransNum = 1

					insert into zpv_drawer_trans(
						type
					,	amount
					,	apply_date
					,	ar_type_id
					,	co_num
					,	copay_rowpointer
					,	drawer
					,	curr_code
					,	exch_rate
					,	for_amount
					,	from_drawer
					,	glbank_rowpointer
					,	packet
					,	trans_date
					,	trans_num
					,	zla_bank_type
					,	relief_num)
					values(
						'I'
					,	@DrawerTransAmount
					,	getdate()
					,	@DrawerTransArTypeId
					,	@DrawerTransCoNum
					,	@DrawerTransCopayRowpointer
					,	@DrawerTransDrawer
					,	@DrawerTransCurrCode
					,	@DrawerTransExchRate
					,	@DrawerTransAmount
					,	null
					,	null
					,	@DrawerTransPacket
					,	getdate()
					,	@TransNum
					,	@DrawerTransZlaBankType
					,	0)

					UPDATE zpv_drawer
						SET check_in = 1,
							check_in_date = @CheckInDate,
							check_in_user = @CheckInUser
					WHERE drawer = @Drawer
					SET @Infobar = 'Caja Abierta sin Diferencias'
				end
				else
				begin
					set @AmountDif = @InitialBalance - @DrawerBalanceCash 

					select @DrawerBankCode = drw.bank_code_draft from zpv_drawer drw where drw.drawer = @Drawer
			
					select
						@GlBankAcct1		= bhdr.acct
					,	@GlBankAcct1Unit1	= bhdr.acct_unit1
					,	@GlBankAcct1Unit2	= bhdr.acct_unit2
					,	@GlBankAcct1Unit3	= bhdr.acct_unit3
					,	@GlBankAcct1Unit4	= bhdr.acct_unit4
					from bank_hdr_mst bhdr
					where bhdr.bank_code = @DrawerBankCode

					EXEC @Severity = GetNextReconciliationTypeNumSp
							@DrawerBankCode
					,		@NewRecType
					,		@Transaction OUTPUT

					select
						@NewGlBankBankCode				= @DrawerBankCode	
					,	@NewGlBankCheckDate				= getdate()
					,	@NewGlBankCheckNumber			= @Transaction
					,	@NewGlBankCheckAmt				= @AmountDif
					,	@NewGlBankType					= @NewRecType
					,	@NewGlBankRefType				= 'A/R'
					,	@NewGlBankRefNum				= null
					,	@NewGlBankDomCheckAmt			= @AmountDif
					,	@NewGlBankZlaThirdPartyCheck	= null
					,	@NewGlBankZlaThirdBankId		= null
					,	@NewGlBankZlaThirdDescription	= null
					,	@NewGlBankZlaThirdTaxNumReg		= null
					,	@NewGlBankZlaThirdCheckDate		= null
					,	@NewGlBankZlaArPayId			= null
					,	@NewGlBankZlaCreditCardExpDate	= null
					,	@NewGlBankZlaCreditCardPayments = null
	
					EXEC @Severity = [dbo].[ZPV_CreateGlBankSp]
							@ProcessId		= NULL
					,		@BankCode		= @NewGlBankBankCode
					,		@CheckDate		= @NewGlBankCheckDate 
					,		@CheckNumber	= @NewGlBankCheckNumber
					,		@CheckAmt		= @NewGlBankCheckAmt
					,		@Type			= @NewGlBankType
					,		@RefType		= @NewGlBankRefType
					,		@RefNum			= @NewGlBankRefNum
					,		@DomCheckAmt	= @NewGlBankDomCheckAmt
					,		@Infobar		= @Infobar OUTPUT
					,		@ZlaThirdPartyCheck		= @NewGlBankZlaThirdPartyCheck
					,		@ZlaThirdBankId			= @NewGlBankZlaThirdBankId
					,		@ZlaThirdDescription	= @NewGlBankZlaThirdDescription
					,		@ZlaThirdTaxNumReg		= @NewGlBankZlaThirdTaxNumReg
					,		@ZlaThirdCheckDate		= @NewGlBankZlaThirdCheckDate
					,		@ZlaArPayId				= @NewGlBankZlaArPayId
					,		@ZlaCreditCardExpDate	= @NewGlBankZlaCreditCardExpDate
					,		@ZlaCreditCardPayments	= @NewGlBankZlaCreditCardPayments
					,		@GlBankRowPointer		= @NewGlBankRowPointer OUTPUT
			
					select
						@DrawerTransAmount		= @AmountDif
					,	@DrawerTransArTypeId	= null
					,	@DrawerTransCoNum		= null
					,	@DrawerTransCopayRowpointer	= null
					,	@DrawerTransCurrCode	= @ParmsCurrCode
					,	@DrawerTransDrawer		= @Drawer
					,	@DrawerTransExchRate	= 1
					,	@DrawerTransForAmount	= @AmountDif
					,	@DrawerTransPacket		= null
					,	@DrawerTransZlaBankType	= 'E'
					,	@DrawerTransAmountTranfer		= 0
					,	@DrawerTransForAmountTranfer	= 0

					select top 1 @TransNum =  isnull(trans_num + 1,1) from zpv_drawer_trans order by trans_num desc
					if @TransNum is null set @TransNum = 1

					insert into zpv_drawer_trans(
						type
					,	amount
					,	apply_date
					,	ar_type_id
					,	co_num
					,	copay_rowpointer
					,	drawer
					,	curr_code
					,	exch_rate
					,	for_amount
					,	from_drawer
					,	glbank_rowpointer
					,	packet
					,	trans_date
					,	trans_num
					,	zla_bank_type
					,	relief_num
					,	from_relief_num)
					values(
						'I'
					,	@DrawerTransAmount
					,	null
					,	@DrawerTransArTypeId
					,	@DrawerTransCoNum
					,	@DrawerTransCopayRowpointer
					,	@Drawer
					,	@DrawerTransCurrCode
					,	@DrawerTransExchRate
					,	@DrawerTransAmount
					,	null
					,	@NewGlBankRowPointer
					,	@DrawerTransPacket
					,	getdate()
					,	@TransNum
					,	@DrawerTransZlaBankType
					,	0
					,	0)

					-- Genera Asiento Contable
					EXEC dbo.NextControlNumberSp
	     				@JournalId = 'AR Dist'
						, @TransDate = @TransDate
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

					SET @CurrCode	= @ParmsCurrCode
					SET @Ref		= 'ARP AJC ' + cast(@Transaction as varchar(10))
			
					EXEC @Severity = dbo.ZPV_JourpostSp
					  @id                 = 'AR Dist'
					, @trans_date         = @TransDate
					, @acct               = @GlBankAcct1
					, @acct_unit1         = @GlBankAcct1Unit1
					, @acct_unit2         = @GlBankAcct1Unit2
					, @acct_unit3         = @GlBankAcct1Unit3
					, @acct_unit4         = @GlBankAcct1Unit4
					, @amount             = @AmountDif
					, @for_amount         = @AmountDif
					, @bank_code          = @NewGlBankBankCode
					, @exch_rate          = 1
					, @curr_code          = @CurrCode
					, @check_num          = @Transaction
					, @check_date         = @TransDate
					, @ref                = @Ref
					, @vend_num           = null
					, @ref_type           = 'P'
					, @ControlPrefix	  = @ControlPrefix
					, @ControlSite		  = @ControlSite
					, @ControlYear		  = @ControlYear
					, @ControlPeriod	  = @ControlPeriod
					, @ControlNumber	  = @ControlNumber
					, @last_seq           = @EndTrans     OUTPUT
					, @Infobar            = @Infobar      OUTPUT

			
					select @DrawerBankCode = drw.bank_code from zpv_drawer drw where drw.drawer = @Drawer
				
					select
						@GlBankAcct2		= bhdr.acct
					,	@GlBankAcct2Unit1	= bhdr.acct_unit1
					,	@GlBankAcct2Unit2	= bhdr.acct_unit2
					,	@GlBankAcct2Unit3	= bhdr.acct_unit3
					,	@GlBankAcct2Unit4	= bhdr.acct_unit4
					from bank_hdr_mst bhdr
					where bhdr.bank_code = @DrawerBankCode

					set @AmountDif = @AmountDif * -1

					-- Genera Asiento Contable Negativo
					EXEC @Severity = dbo.ZPV_JourpostSp
					  @id                 = 'AR Dist'
					, @trans_date         = @TransDate
					, @acct               = @GlBankAcct2
					, @acct_unit1         = @GlBankAcct2Unit1
					, @acct_unit2         = @GlBankAcct2Unit2
					, @acct_unit3         = @GlBankAcct2Unit3
					, @acct_unit4         = @GlBankAcct2Unit4
					, @amount             = @AmountDif
					, @for_amount         = @AmountDif
					, @bank_code          = @NewGlBankBankCode
					, @exch_rate          = 1
					, @curr_code          = @CurrCode
					, @check_num          = @Transaction
					, @check_date         = @TransDate
					, @ref                = @Ref
					, @vend_num           = null
					, @ref_type           = 'P'
					, @ControlPrefix	  = @ControlPrefix
					, @ControlSite		  = @ControlSite
					, @ControlYear		  = @ControlYear
					, @ControlPeriod	  = @ControlPeriod
					, @ControlNumber	  = @ControlNumber
					, @last_seq           = @EndTrans     OUTPUT
					, @Infobar            = @Infobar      OUTPUT
	
					UPDATE zpv_drawer
						SET check_in = 1,
							check_in_date = @CheckInDate,
							check_in_user = @CheckInUser
					WHERE drawer = @Drawer
					SET @Infobar = 'Caja Abierta con Diferencias'
				end
			END
		END
		ELSE
		BEGIN
			SET @Infobar = 'La Caja ya está abierta'
		END
	END
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

