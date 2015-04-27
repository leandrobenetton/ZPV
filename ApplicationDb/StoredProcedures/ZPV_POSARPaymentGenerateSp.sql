/****** Object:  StoredProcedure [dbo].[ZPV_POSARPaymentGenerateSp]    Script Date: 16/01/2015 03:11:35 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_POSARPaymentGenerateSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_POSARPaymentGenerateSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_POSARPaymentGenerateSp]    Script Date: 16/01/2015 03:11:35 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* $Header: /ApplicationDB/Stored Procedures/ZPV_POSARPaymentGenerateSp.sp 3     3/04/10 10:13a Dahn $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/ZPV_POSARPaymentGenerateSp.sp $
 *
 * SL9.00.10 1 ljb Benetton Fri May 16 13:00:00 2014

 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_POSARPaymentGenerateSp] (
	@POS_CoNum			CoNumType = null
,	@POS_ArRcpt			varchar(10) = null
,	@POS_Type			varchar(10) = null
,	@Drawer				varchar(20) = null
,	@Origen				varchar(2) = null
,	@RecDate			DateType = null
,	@Txt				DescriptionType = null
,	@Infobar         InfobarType     OUTPUT
) AS

DECLARE 
	@Site SiteType,
	@NextCheckNumber GlCheckNumType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare
	@Severity int

SET @Severity = 0
SET @Infobar  = ''

declare
	@TInvNum			InvNumType
,	@ArinvRowPointer	RowPointerType
,	@TmpSessionId		RowPointerType
,	@PCurrCode			CurrCodeType
	
declare
	@PayBankCode		BankCodeType
,	@PayDueDate			DateType
,	@PayExchRate		ExchRateType
,	@PayAmount			AmountType
,	@PayForAmount		AmountType
,	@PayPayDate			DateType
,	@PayCheckNum		ArCheckNumType
,	@PayCcName			varchar(60)
,	@PayCcDueDate		DateType
,	@PayCcNumber		varchar(30)
,	@PayCcAuthCode		varchar(25)
,	@PayCcPhone			PhoneType
,	@PayCcEmit			varchar(60)
,	@PayCcBank			varchar(60)
,	@PayCcCupon			varchar(20)
,	@PayCcQuotes		int
,	@PayCkOrderBy		int
,	@PayCkBank			varchar(20)
,	@PayCkCheckDate		DateType
,	@PayCkCuit			varchar(30)
,	@PayCkDescription	varchar(60)
,	@PayCkCheck3ros		int
,	@PayCkDueDate		DateType
,	@PayTaxDocument		varchar(30)
,	@PayRefType			GlbankTypeType
,	@PayRowPointer		RowpointerType
	
-- CO/AR
declare
	@CoCustNum			CustNumType
,	@ArInvNum			InvNumType
		
-- ZLA_AR_HDR
declare 
	@ZlaArSiteRef		SiteType
,	@ZlaArCustNun		CustNumType
,	@ZlaArCustSeq		CustSeqType
,	@ZlaArPayType		varchar(10)
,	@ZlaArArPayId		varchar(10)
,	@ZlaArPayDate		DateType
,	@ZlaArCurrCode		CurrCodeType
,	@ZlaArExchRate		ExchRateType
,	@ZlaArArReceipt		varchar(10)
,	@ZlaArStat			varchar(1)

-- ARPMT
declare
	@ArpmtSiteRef		SiteType
,	@ArpmtCustNum		CustNumType
,	@ArpmtCheckNum		ArCheckNumType
,	@ArpmtRecptDate		DateType
,	@ArpmtDomCheck		AmountType
,	@ArpmtRef			RefType
,	@ArpmtDescription	DescriptionType
,	@ArpmtTranferCash	int
,	@ArpmtType			ArpmtTypeType
,	@ArpmtBankCode		BankCodeType
,	@ArpmtExchRate		ExchRateType
,	@ArpmtForCheckAmt	AmountType
,	@ArpmtDepositDate	DateType
,	@ArpmtDueDate		DateType
,	@ArpmtZlaRefBankCode	BankCodeType
,	@ArpmtZlaRefCheckNum	ArCheckNumType
,	@ArpmtZlaThirdPartyCheck	ListYesNoType
,	@ArpmtZlaThirdBankId		BankCodeType
,	@ArpmtZlaThirdDescription	DescriptionType
,	@ArpmtZlaThirdTaxNumReg		TaxRegNumType
,	@ArpmtZlaThirdCheckDate		DateType
,	@ArpmtZlaArPayId	ZlaArPayIdType
,	@ArpmtZlaRefType	GlbankTypeType
,	@ArpmtZlaCreditCardExpDate	DateType
,	@ArpmtZlaCreditCardPayments int


-- ARPMTD
declare
	@ArpmtdSiteRef		SiteType
,	@ArpmtdCustNum		CustNumType
,	@ArpmtdCheckNum		numeric(10)
,	@ArpmtdInvNum		InvNumType
,	@ArpmtdDomAmtApplied	AmountType
,	@ArpmtdApplyCustNum		CustNumType
,	@ArpmtdBankCode		BankCodeType
,	@ArpmtdType			varchar(1)
,	@ArpmtdCoNum		CoNumType
,	@ArpmtdForAmtApplied	AmountType
,	@ArpmtdExchRate		ExchRateType
,	@ArpmtdZlaForCurrCode	CurrCodeType
,	@ArpmtdZlaForAmtApplied AmountType
,	@ArpmtdZlaForExchRate	ExchRateType

-- Variables para generar releases
declare
	@CoitemCoNum		CoNumType
,	@CoitemCoLine		int

BEGIN TRANSACTION;

BEGIN TRY
	set @TmpSessionId = NEWID()

	if @POS_Type is null
	begin
		select 
			@POS_Type			= par.lasttran_id
		from zpv_parms par
		where
			par.parms_key = 0
	end	
	
	-- Completa datos CO
	select
		@CoCustNum			= co.cust_num
	from co
	where
		co.co_num = @POS_CoNum

	-- Completa datos AR
	select
		@ArInvNum			= ar.inv_num
	from artran ar
	where
		ar.co_num = @POS_CoNum and
		ar.[type] = 'I'
	
	-- Busca la moneda por defecto
	select @PCurrCode = curr_code from currparms_mst where parm_key = 0

	
	-- Asigna el numero de recibo interno
	EXEC	[dbo].[ZLA_NextARPayTypeSp]
		@pLastTranId = @POS_Type,
		@Key = @ZlaArArPayId OUTPUT,
		@Infobar = @Infobar OUTPUT
		
	select
		@ZlaArSiteRef		= @Site,
		@ZlaArCustNun		= co.cust_num,
		@ZlaArCustSeq		= co.cust_seq,
		@ZlaArPayType		= @POS_Type,
		--@ZlaArArPayId		= 'R000001',
		@ZlaArPayDate		= isnull(@RecDate,getdate()),
		@ZlaArCurrCode		= cus.curr_code,
		@ZlaArExchRate		= co.exch_rate,
		@ZlaArArReceipt		= @POS_ArRcpt,
		@ZlaArStat			= 'O'
	from co
	left join custaddr cus on cus.cust_num = co.cust_num and cus.cust_seq = 0
	where
		co.co_num = @POS_CoNum

	insert into [zla_ar_hdr_mst]
			   ([site_ref]
			   ,[cust_num]
			   ,[cust_seq]
			   ,[pay_type]
			   ,[ar_pay_id]
			   ,[pay_date]
			   ,[curr_code]
			   ,[exch_rate]
			   ,[txt]
			   ,[ar_receipt]
			   ,[stat])
		 values
			(@ZlaArSiteRef,
			@ZlaArCustNun,
			@ZlaArCustSeq,
			@ZlaArPayType,
			@ZlaArArPayId,
			@ZlaArPayDate,
			@ZlaArCurrCode,
			@ZlaArExchRate,
			@Txt,
			@ZlaArArReceipt,
			@ZlaArStat)
	
	declare PaymentCur cursor for
	select
		pay.bank_code,
		pay.due_date,
		pay.exch_rate,
		pay.amount,
		pay.for_amount,
		pay.pay_date,
		pay.check_num,
		---------------
		pay.cc_name,
		pay.cc_due_date,
		pay.cc_number,
		pay.cc_auth_code,
		pay.cc_phone,
		pay.cc_emit,
		pay.cc_bank,
		pay.cc_cupon,
		pay.cc_quotes,
		---------------
		pay.ck_order_by,
		pay.ck_bank,
		pay.ck_check_date,
		pay.ck_cuit,
		pay.ck_description,
		pay.ck_check_3ros,
		pay.ck_due_date,
		---------------
		pay.tax_document,
		bank.zla_bank_type,
		pay.RowPointer
	from zpv_co_payments pay
	left join bank_hdr bank on bank.bank_code = pay.bank_code
	where
		pay.co_num = @POS_CoNum
	open PaymentCur
	
	
	fetch next from PaymentCur
	into
		@PayBankCode,
		@PayDueDate,
		@PayExchRate,
		@PayAmount,
		@PayForAmount,
		@PayPayDate,
		@PayCheckNum,
		@PayCcName,
		@PayCcDueDate,
		@PayCcNumber,
		@PayCcAuthCode,
		@PayCcPhone,
		@PayCcEmit,
		@PayCcBank,
		@PayCcCupon,
		@PayCcQuotes,
		@PayCkOrderBy,
		@PayCkBank,
		@PayCkCheckDate,
		@PayCkCuit,
		@PayCkDescription,
		@PayCkCheck3ros,
		@PayCkDueDate,
		@PayTaxDocument,
		@PayRefType,
		@PayRowpointer
	while @@fetch_status = 0
	begin
		if @PayCheckNum is null
		begin
			EXEC [dbo].[ZPV_GetNextCheckNumberSp]
				@PayBankCode,
				'D',
				@NextCheckNumber OUTPUT		

			update zpv_co_payments set check_num = @NextCheckNumber
			where RowPointer = @PayRowPointer
		end
		else
		begin
			set @NextCheckNumber = @PayCheckNum
		end
		
		select 
			@ArpmtBankCode			= @PayBankCode,
			@ArpmtCheckNum			= @NextCheckNumber,
			/*
			@ArpmtCheckNum			= case @PayRefType
										when 'B' then @NextCheckNumber
										when 'T' then @PayCheckNum
										when 'E' then @NextCheckNumber	
										when 'I' then @NextCheckNumber
										when 'C' then @PayCheckNum
										when 'Q' then @PayCheckNum
										when 'R' then @NextCheckNumber
									end,*/
			@ArpmtCustNum			= @CoCustNUm,
			@ArpmtDescription		= 'POS Payment ' + @POS_CoNum,
			@ArpmtDomCheck			= isnull(@PayAmount,0),
			@ArpmtDueDate			= @PayDueDate,
			@ArpmtDepositDate		= @PayDueDate,
			@ArpmtExchRate			= isnull(@PayExchRate,1),
			@ArpmtForCheckAmt		= isnull(@PayAmount,0),
			@ArpmtRecptDate			= isnull(@RecDate,getdate()),
			@ArpmtRef				= 'ARP ' + @ZlaArArPayId,
			@ArpmtSiteRef			= @Site, 
			@ArpmtTranferCash		= 0,
			@ArpmtType				= 'C',
			@ArpmtZlaArPayId		= @ZlaArArPayId,
			-- Cuando es Tarjeta o Cheque se debe completar
			@ArpmtZlaRefBankCode	= null,
			@ArpmtZlaRefCheckNum	= null, 
			@ArpmtZlaThirdBankId	= isnull(@PayCkBank,@PayCcBank),
			@ArpmtZlaThirdCheckDate = @PayCkCheckDate,
			@ArpmtZlaThirdDescription = @PayCkDescription,
			@ArpmtZlaThirdPartyCheck = null,
			@ArpmtZlaThirdTaxNumReg = @PayCkCuit,
			@ArpmtZlaRefType		= @PayRefType,
			@ArpmtZlaCreditCardExpDate	= @PayCcDueDate,
			@ArpmtZlaCreditCardPayments	= @PayCcQuotes
		
		insert into [arpmt]
			   ([cust_num]
			   ,[check_num]
			   ,[recpt_date]
			   ,[dom_check_amt]
			   ,[ref]
			   ,[description]
			   ,[transfer_cash]
			   ,[type]
			   ,[bank_code]
			   ,[exch_rate]
			   ,[for_check_amt]
			   ,[due_date]
			   ,[credit_memo_num]
			   ,[deposit_date]
			   ,[payment_check_amt]
			   ,[payment_exch_rate]
			   ,[zla_ref_bank_code]
			   ,[zla_ref_check_num]
			   ,[zla_third_party_check]
			   ,[zla_third_bank_id]
			   ,[zla_third_description]
			   ,[zla_third_tax_num_reg]
			   ,[zla_third_check_date]
			   ,[zla_ar_pay_id]
			   ,[zla_ref_type]
			   ,[offset]
			   ,[zla_credit_card_exp_date]
			   ,[zla_credit_card_payments])
		 VALUES
			   (@ArpmtCustNum,
			   @ArpmtCheckNum,
			   @ArpmtRecptDate,
			   @ArpmtDomCheck,
			   @ArpmtRef,
			   @ArpmtDescription,
			   @ArpmtTranferCash,
			   @ArpmtType,
			   @ArpmtBankCode,
			   @ArpmtExchRate,
			   @ArpmtForCheckAmt,
			   @ArpmtDueDate,
			   null,
			   @ArpmtDepositDate,
			   @ArpmtDomCheck,
			   @ArpmtExchRate,
			   @ArpmtZlaRefBankCode,
			   @ArpmtZlaRefCheckNum,
			   @ArpmtZlaThirdPartyCheck,
			   @ArpmtZlaThirdBankId,
			   @ArpmtZlaThirdDescription,
			   @ArpmtZlaThirdTaxNumReg,
			   @ArpmtZlaThirdCheckDate,
			   @ArpmtZlaArPayId,
			   @ArpmtZlaRefType,
			   0,
			   @ArpmtZlaCreditCardExpDate,
			   @ArpmtZlaCreditCardPayments)
			   
		-- Genera Distribucion del pago
		select
			@ArpmtdSiteRef			= @Site,
			@ArpmtdCustNum			= @CoCustNum,
			@ArpmtdCheckNum			= @NextCheckNumber,
			@ArpmtdInvNum			= isnull(@ArInvNum,0),
			@ArpmtdDomAmtApplied	= isnull(@PayAmount,0),
			@ArpmtdApplyCustNum		= @CoCustNum,
			@ArpmtdBankCode			= @PayBankCode,
			@ArpmtdType				= 'C',
			@ArpmtdCoNum			= @POS_CoNum,
			@ArpmtdForAmtApplied	= isnull(@PayAmount,0),
			@ArpmtdExchRate			= isnull(@PayExchRate,1),
			@ArpmtdZlaForCurrCode	= isnull(@ZlaArCurrCode,@PCurrCode),
			@ArpmtdZlaForExchRate	= isnull(@PayExchRate,1),
			@ArpmtdZlaForAmtApplied	= isnull(@PayAmount,0)
		           	
		           
		insert into [arpmtd]
				   ([cust_num]
				   ,[check_num]
				   ,[inv_num]
				   ,[site]
				   ,[dom_amt_applied]
				   ,[dom_disc_amt]
				   ,[disc_acct]
				   ,[dom_allow_amt]
				   ,[allow_acct]
				   ,[deposit_acct]
				   ,[apply_cust_num]
				   ,[bank_code]
				   ,[type]
				   ,[co_num]
				   ,[disc_acct_unit1]
				   ,[disc_acct_unit2]
				   ,[disc_acct_unit3]
				   ,[disc_acct_unit4]
				   ,[allow_acct_unit1]
				   ,[allow_acct_unit2]
				   ,[allow_acct_unit3]
				   ,[allow_acct_unit4]
				   ,[deposit_acct_unit1]
				   ,[deposit_acct_unit2]
				   ,[deposit_acct_unit3]
				   ,[deposit_acct_unit4]
				   ,[for_amt_applied]
				   ,[for_disc_amt]
				   ,[for_allow_amt]
				   ,[exch_rate]
				   ,[do_num]
				   ,[for_tax_1]
				   ,[zla_for_curr_code]
				   ,[zla_for_amt_applied]
				   ,[zla_for_exch_rate]
				   ,NoteExistsFlag )
			 VALUES
				   (@ArpmtdCustNum, 
				   @ArpmtdCheckNum,
				   @ArpmtdInvNum,
				   @ArpmtdSiteRef,
				   @ArpmtdDomAmtApplied,
				   0,
				   null,
				   0,
				   null,
				   null,
				   @ArpmtdApplyCustNum,
				   @ArpmtdBankCode,
				   @ArpmtdType,
				   @ArpmtdCoNum,
				   null,
				   null,
				   null,
				   null,
				   null,
				   null,
				   null,
				   null,
				   null,
				   null,
				   null,
				   null,
				   @ArpmtdForAmtApplied,
				   0,
				   0,
				   @ArpmtdExchRate,
				   null,
				   0,
				   @ArpmtdZlaForCurrCode,
				   @ArpmtdZlaForAmtApplied,
				   @ArpmtdZlaForExchRate,
				   0)
			
		update zpv_co_payments
		set ar_pay_id	= @ZlaArArPayId,
			posted		= 1,
			drawer		= @Drawer
		where RowPointer = @PayRowPointer
		
		fetch next from PaymentCur
		into
			@PayBankCode,
			@PayDueDate,
			@PayExchRate,
			@PayAmount,
			@PayForAmount,
			@PayPayDate,
			@PayCheckNum,
			@PayCcName,
			@PayCcDueDate,
			@PayCcNumber,
			@PayCcAuthCode,
			@PayCcPhone,
			@PayCcEmit,
			@PayCcBank,
			@PayCcCupon,
			@PayCcQuotes,
			@PayCkOrderBy,
			@PayCkBank,
			@PayCkCheckDate,
			@PayCkCuit,
			@PayCkDescription,
			@PayCkCheck3ros,
			@PayCkDueDate,
			@PayTaxDocument,
			@PayRefType,
			@PayRowPointer
						
	end
	close PaymentCur
	deallocate PaymentCur

	update zla_sys_lasttran_mst
		set lasttran = lasttran + 1
	where
		lastttran_id = @POS_Type
		
	update co
		set zpv_payment_generated = 1
	where co_num = @POS_CoNum		
	
	--Actualiza Status de Lineas de CO a Cobrado
	--update co_bln_mst
	--	set co_bln_mst.zpv_stat = 'X99'
	--where
	--	co_bln_mst.co_num = @POS_CoNum		

	--update co_mst
	--	set co_mst.zpv_stat_internal = 'X99',
	--		co_mst.zpv_stat = 'X99' 
	--where
	--	co_mst.co_num = @POS_CoNum	

	-- Posteo de pagos generados
	EXEC @Severity = [dbo].[ZPV_ARPaymentSp]
		@PayId		= @ZlaArArPayId,
		@Drawer		= @Drawer,
		@CoPayRowPointer = @PayRowPointer,
		@Origen		= @Origen,
		@Infobar = @Infobar OUTPUT

	update zla_ar_hdr
	set stat = 'P'
	where ar_pay_id = @ZlaArArPayId

	if @Severity <> 0
	begin
		select 'ERROR'
		ROLLBACK TRANSACTION
		return 0
	end	

	set @Infobar = 'Recibo Generado'
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

