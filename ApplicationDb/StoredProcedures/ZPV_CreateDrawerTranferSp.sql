/****** Object:  StoredProcedure [dbo].[ZPV_CreateDrawerTranferSp]    Script Date: 16/01/2015 03:13:41 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CreateDrawerTranferSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_CreateDrawerTranferSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CreateDrawerTranferSp]    Script Date: 16/01/2015 03:13:41 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* $Header: /ApplicationDB/Stored Procedures/ARPaymentPostingSp.sp 73    4/11/14 4:02a Ychen1 $ */
/*
***************************************************************
*                                                             *
*                           NOTICE                            *
*                                                             *
*   THIS SOFTWARE IS THE PROPERTY OF AND CONTAINS             *
*   CONFIDENTIAL INFORMATION OF INFOR AND/OR ITS AFFILIATES   *
*   OR SUBSIDIARIES AND SHALL NOT BE DISCLOSED WITHOUT PRIOR  *
*   WRITTEN PERMISSION. LICENSED CUSTOMERS MAY COPY AND       *
*   ADAPT THIS SOFTWARE FOR THEIR OWN USE IN ACCORDANCE WITH  *
*   THE TERMS OF THEIR SOFTWARE LICENSE AGREEMENT.            *
*   ALL OTHER RIGHTS RESERVED.                                *
*                                                             *
*   (c) COPYRIGHT 2010 INFOR.  ALL RIGHTS RESERVED.           *
*   THE WORD AND DESIGN MARKS SET FORTH HEREIN ARE            *
*   TRADEMARKS AND/OR REGISTERED TRADEMARKS OF INFOR          *
*   AND/OR ITS AFFILIATES AND SUBSIDIARIES. ALL RIGHTS        *
*   RESERVED.  ALL OTHER TRADEMARKS LISTED HEREIN ARE         *
*   THE PROPERTY OF THEIR RESPECTIVE OWNERS.                  *
*                                                             *
***************************************************************
*/

CREATE PROCEDURE [dbo].[ZPV_CreateDrawerTranferSp] (
	@pFromDrawer		varchar(15)
,	@pToDrawer			varchar(15)
,	@pPacket			varchar(10)
,	@pBankType			ZlaBankType
,	@pAmountToTranfer	AmountType = 0
,	@Infobar			InfobarType	OUTPUT)

AS

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare
	@AmountToTranfer	AmountType
,	@ReliefNum			MatlTransNumType
,	@TransNum			MatlTransNumType

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
,	@DrawerTransAmountTranfer	AmountType
,	@DrawerTransForAmountTranfer	AmountType

declare
	@GlBankBankCode		BankCodeType
,	@GlBankCheckDate	DateType		
,	@GlBankCheckNumber	ArCheckNumType
,	@GlBankCheckAmt		AmountType
,	@GlBankType			ArpmtTypeType
,	@GlBankRefType		ReferenceType
,	@GlBankRefNum		CustNumType
,	@GlBankDomCheckAmt			AmountType
,	@GlBankZlaThirdPartyCheck	ListYesNoType
,	@GlBankZlaThirdBankId		BankCodeType
,	@GlBankZlaThirdDescription	DescriptionType
,	@GlBankZlaThirdTaxNumReg	TaxRegNumType
,	@GlBankZlaThirdCheckDate	DateType
,	@GlBankZlaArPayId			ZlaArPayIdType
,	@GlBankZlaCreditCardExpDate ZlaCreditCardExpDateType
,	@GlBankZlaCreditCardPayments ZlaCreditCardPaymentType
,	@GlBankRowPointer	RowpointerType

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

DECLARE
     @Severity       INT
   , @Transaction    GlCheckNumType
   , @Exists         INT
   , @CreateTempRec  tinyint
   , @CustCurrCode   CurrCodeType
   , @BankCurrCode   CurrCodeType
   , @BankCurrAmount AmountType
   , @NewRecType     ArpmtTypeType

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
,	@AmountCash			AmountType
,	@GlBankDifAcct1		AcctType
,	@GlBankDifAcct1Unit1	UnitCode1Type
,	@GlBankDifAcct1Unit2	UnitCode2Type
,	@GlBankDifAcct1Unit3	UnitCode3Type
,	@GlBankDifAcct1Unit4	UnitCode4Type

BEGIN TRANSACTION;

BEGIN TRY

	SET @Severity = 0
	SET @Infobar  = NULL
	SET @NewRecType = 'D'
	SET @TransDate	= getdate()


	
	if @pBankType <> 'E'
	begin
		set @AmountToTranfer = 0
		select top 1 @ReliefNum =  isnull(relief_num + 1,1) from zpv_drawer_trans order by relief_num desc

		declare CurGlBank cursor for
		select
			drt.glbank_rowpointer
		,	drt.amount
		,	drt.ar_type_id
		,	drt.co_num
		,	drt.copay_rowpointer
		,	drt.curr_code
		,	drt.drawer
		,	drt.exch_rate
		,	drt.for_amount
		,	drt.packet
		,	drt.zla_bank_type
		,	drt.RowPointer
		,	drt.amount_tranfer
		,	drt.for_amount_tranfer
		from zpv_drawer_trans drt
		where	drt.pending = 1
			and	drt.zla_bank_type = @pBankType
			and drt.drawer	= @pFromDrawer	
		open CurGlBank
		fetch next from CurGlBank
		into
			@GlBankRowPointer
		,	@DrawerTransAmount
		,	@DrawerTransArTypeId
		,	@DrawerTransCoNum
		,	@DrawerTransCopayRowpointer
		,	@DrawerTransCurrCode
		,	@DrawerTransDrawer	
		,	@DrawerTransExchRate
		,	@DrawerTransForAmount
		,	@DrawerTransPacket
		,	@DrawerTransZlaBankType
		,	@DrawerTransRowPointer
		,	@DrawerTransAmountTranfer
		,	@DrawerTransForAmountTranfer
	
		while @@FETCH_STATUS = 0
		begin
			-- Si el monto a transferir difiere del original
			if @DrawerTransAmount <> @DrawerTransAmountTranfer
			begin
				set @AmountDif = @DrawerTransAmount - @DrawerTransAmountTranfer

				select
					@Transaction	= glb.check_num
				from glbank glb
				where glb.RowPointer = @GlBankRowPointer

				if @Transaction is null
				begin
					select @Infobar = 'NO existe CheckNum para el movimiento de caja a ajustar'
					ROLLBACK TRANSACTION
					return 0
				end

				select @DrawerBankCode = drw.bank_code_draft from zpv_drawer drw where drw.drawer = @pToDrawer
				select
					@GlBankDifBankCode		= bhdr.bank_code
				,	@GlBankDifAcct1			= bhdr.acct
				,	@GlBankDifAcct1Unit1	= bhdr.acct_unit1
				,	@GlBankDifAcct1Unit2	= bhdr.acct_unit2
				,	@GlBankDifAcct1Unit3	= bhdr.acct_unit3
				,	@GlBankDifAcct1Unit4	= bhdr.acct_unit4
				from bank_hdr_mst bhdr
				where bhdr.bank_code = @DrawerBankCode

				select @DrawerBankCode = drw.bank_code from zpv_drawer drw where drw.drawer = @pFromDrawer
				select
					@NewGlBankBankCode	= bhdr.bank_code
				,	@GlBankAcct2		= bhdr.acct
				,	@GlBankAcct2Unit1	= bhdr.acct_unit1
				,	@GlBankAcct2Unit2	= bhdr.acct_unit2
				,	@GlBankAcct2Unit3	= bhdr.acct_unit3
				,	@GlBankAcct2Unit4	= bhdr.acct_unit4
				from bank_hdr_mst bhdr
				where bhdr.bank_code = @DrawerBankCode

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

				SET @CurrCode	= 'ARS'
				SET @Ref		= 'ARP AJC ' + cast(@Transaction as varchar(10))
			
				EXEC @Severity = dbo.ZPV_JourpostSp
				  @id                 = 'AR Dist'
				, @trans_date         = @TransDate
				, @acct               = @GlBankDifAcct1
				, @acct_unit1         = @GlBankDifAcct1Unit1
				, @acct_unit2         = @GlBankDifAcct1Unit2
				, @acct_unit3         = @GlBankDifAcct1Unit3
				, @acct_unit4         = @GlBankDifAcct1Unit4
				, @amount             = @AmountDif
				, @for_amount         = @AmountDif
				, @bank_code          = @GlBankDifBankCode
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

				set @AmountDif = @AmountDif * -1
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

				-- Actualiza GLBank
				Update glbank
				set		glbank.check_amt		= @DrawerTransAmountTranfer
					,	glbank.dom_check_amt	= @DrawerTransAmountTranfer
				where glbank.RowPointer = @GlBankRowPointer
				
				-- Actualiza DrawerTrans
				update zpv_drawer_trans
				set		zpv_drawer_trans.amount	= @DrawerTransAmountTranfer
					,	zpv_drawer_trans.for_amount = @DrawerTransAmountTranfer		
				where zpv_drawer_trans.RowPointer = @DrawerTransRowPointer
			end

			select
				@GlBankBankCode		= glbank.bank_code
			,	@GlBankCheckDate	= glbank.check_date
			,	@GlBankCheckNumber	= glbank.check_num
			,	@GlBankCheckAmt		= glbank.check_amt * -1
			,	@GlBankType			= glbank.type
			,	@GlBankRefType		= glbank.ref_type
			,	@GlBankRefNum		= glbank.ref_num
			,	@GlBankDomCheckAmt			= glbank.dom_check_amt * -1
			,	@GlBankZlaThirdPartyCheck	= glbank.zla_third_party_check
			,	@GlBankZlaThirdBankId		= glbank.zla_third_bank_id
			,	@GlBankZlaThirdDescription	= glbank.zla_third_description
			,	@GlBankZlaThirdTaxNumReg	= glbank.zla_third_description
			,	@GlBankZlaThirdCheckDate	= glbank.zla_third_check_date
			,	@GlBankZlaArPayId			= glbank.zla_pay_id
			,	@GlBankZlaCreditCardExpDate = glbank.zla_credit_card_exp_date
			,	@GlBankZlaCreditCardPayments = glbank.zla_credit_card_payments
			from glbank
			where glbank.RowPointer = @GlBankRowPointer

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
				'A'
			,	-(@DrawerTransAmountTranfer)
			,	getdate()
			,	@DrawerTransArTypeId
			,	@DrawerTransCoNum
			,	@DrawerTransCopayRowpointer
			,	@DrawerTransDrawer
			,	@DrawerTransCurrCode
			,	@DrawerTransExchRate
			,	-(@DrawerTransAmountTranfer)
			,	null
			,	@GlBankRowPointer
			,	@DrawerTransPacket
			,	getdate()
			,	@TransNum
			,	@DrawerTransZlaBankType
			,	@ReliefNum)

			select @DrawerBankCode = drw.bank_code from zpv_drawer drw where drw.drawer = @pToDrawer
		
			select
				@NewGlBankBankCode				= @DrawerBankCode	
			,	@NewGlBankCheckDate				= getdate()
			,	@NewGlBankCheckNumber			= @Transaction
			,	@NewGlBankCheckAmt				= @DrawerTransAmountTranfer
			,	@NewGlBankType					= @NewRecType
			,	@NewGlBankRefType				= 'A/R'
			,	@NewGlBankRefNum				= null
			,	@NewGlBankDomCheckAmt			= @DrawerTransAmountTranfer
			,	@NewGlBankZlaThirdPartyCheck	= null
			,	@NewGlBankZlaThirdBankId		= null
			,	@NewGlBankZlaThirdDescription	= null
			,	@NewGlBankZlaThirdTaxNumReg		= null
			,	@NewGlBankZlaThirdCheckDate		= null
			,	@NewGlBankZlaArPayId			= null
			,	@NewGlBankZlaCreditCardExpDate	= null
			,	@NewGlBankZlaCreditCardPayments = null
	
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
				'T'
			,	@NewGlBankCheckAmt
			,	null
			,	null
			,	null
			,	null
			,	@pToDrawer
			,	'ARS'
			,	1
			,	@NewGlBankCheckAmt
			,	@pFromDrawer
			,	@GlBankRowPointer
			,	@pPacket
			,	getdate()
			,	@TransNum
			,	@pBankType
			,	0
			,	@ReliefNum)
			
			update zpv_drawer_trans
				set		zpv_drawer_trans.relief_num		= @ReliefNum
					,	zpv_drawer_trans.apply_date		= getdate()
					,	zpv_drawer_trans.amount_tranfer	= 0
					,	zpv_drawer_trans.for_amount_tranfer	= 0
					,	zpv_drawer_trans.pending			= 0
			where RowPointer = @DrawerTransRowPointer 

			select @AmountToTranfer = @AmountToTranfer + @DrawerTransAmountTranfer

			fetch next from CurGlBank
			into
				@GlBankRowPointer
			,	@DrawerTransAmount
			,	@DrawerTransArTypeId
			,	@DrawerTransCoNum
			,	@DrawerTransCopayRowpointer
			,	@DrawerTransCurrCode
			,	@DrawerTransDrawer	
			,	@DrawerTransExchRate
			,	@DrawerTransForAmount
			,	@DrawerTransPacket
			,	@DrawerTransZlaBankType
			,	@DrawerTransRowPointer
			,	@DrawerTransAmountTranfer
			,	@DrawerTransForAmountTranfer
		end
		close CurGlBank
		deallocate CurGlBank
	end
	else
	begin
		if @pAmountToTranfer > 0
		begin
			select 
				@AmountCash = isnull(sum(drt.amount),0)
			from zpv_drawer_trans drt
			where	drt.drawer = @pFromDrawer
				and	drt.zla_bank_type = 'E'

			if @AmountCash < @pAmountToTranfer
			begin
				select @Infobar = 'El Monto a tranferir en efectivo supera al disponible en caja'
				ROLLBACK TRANSACTION
				return 0
			end

			select top 1 @ReliefNum =  isnull(relief_num + 1,1) from zpv_drawer_trans order by relief_num desc
			if @ReliefNum is null set @ReliefNum = 1

			-- Genera GL Bank Positivo (Transaccion)
			
			select @DrawerBankCode = drw.bank_code from zpv_drawer drw where drw.drawer = @pToDrawer
			
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
			,	@NewGlBankCheckAmt				= @pAmountToTranfer
			,	@NewGlBankType					= @NewRecType
			,	@NewGlBankRefType				= 'A/R'
			,	@NewGlBankRefNum				= null
			,	@NewGlBankDomCheckAmt			= @pAmountToTranfer
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
				'T'
			,	@NewGlBankCheckAmt
			,	null
			,	null
			,	null
			,	null
			,	@pToDrawer
			,	'ARS'
			,	1
			,	@NewGlBankCheckAmt
			,	@pFromDrawer
			,	@GlBankRowPointer
			,	@pPacket
			,	getdate()
			,	@TransNum
			,	@pBankType
			,	0
			,	@ReliefNum)

			-- Genera Asiento Contable Positivo
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

			SET @CurrCode	= 'ARS'
			SET @Ref		= 'ARP TRF ' + cast(@Transaction as varchar(10))
			
			EXEC @Severity = dbo.ZPV_JourpostSp
			  @id                 = 'AR Dist'
			, @trans_date         = @TransDate
			, @acct               = @GlBankAcct1
			, @acct_unit1         = @GlBankAcct1Unit1
			, @acct_unit2         = @GlBankAcct1Unit2
			, @acct_unit3         = @GlBankAcct1Unit3
			, @acct_unit4         = @GlBankAcct1Unit4
			, @amount             = @NewGlBankCheckAmt
			, @for_amount         = @NewGlBankCheckAmt
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

			
			-- Genera GL Bank Negativo (Alivio)
			select @DrawerBankCode = drw.bank_code from zpv_drawer drw where drw.drawer = @pFromDrawer
			
			select
				@GlBankAcct2		= bhdr.acct
			,	@GlBankAcct2Unit1	= bhdr.acct_unit1
			,	@GlBankAcct2Unit2	= bhdr.acct_unit2
			,	@GlBankAcct2Unit3	= bhdr.acct_unit3
			,	@GlBankAcct2Unit4	= bhdr.acct_unit4
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
			,	@NewGlBankCheckAmt				= -(@pAmountToTranfer)
			,	@NewGlBankType					= @NewRecType
			,	@NewGlBankRefType				= 'A/R'
			,	@NewGlBankRefNum				= null
			,	@NewGlBankDomCheckAmt			= -(@pAmountToTranfer)
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
				'A'
			,	@NewGlBankCheckAmt
			,	getdate()
			,	null
			,	null
			,	null
			,	@pFromDrawer
			,	'ARS'
			,	1
			,	@NewGlBankCheckAmt
			,	null
			,	@GlBankRowPointer
			,	@pPacket
			,	getdate()
			,	@TransNum
			,	@pBankType
			,	@ReliefNum)

			-- Genera Asiento Contable Negativo
			EXEC @Severity = dbo.ZPV_JourpostSp
			  @id                 = 'AR Dist'
			, @trans_date         = @TransDate
			, @acct               = @GlBankAcct2
			, @acct_unit1         = @GlBankAcct2Unit1
			, @acct_unit2         = @GlBankAcct2Unit2
			, @acct_unit3         = @GlBankAcct2Unit3
			, @acct_unit4         = @GlBankAcct2Unit4
			, @amount             = @NewGlBankCheckAmt
			, @for_amount         = @NewGlBankCheckAmt
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

		end
	end

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

