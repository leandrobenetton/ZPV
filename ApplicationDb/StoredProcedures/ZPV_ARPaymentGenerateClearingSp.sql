/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentGenerateSp]    Script Date: 16/01/2015 03:12:00 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ARPaymentGenerateClearingSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_ARPaymentGenerateClearingSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentGenerateClearingSp]    Script Date: 16/01/2015 03:12:00 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* $Header: /ApplicationDB/Stored Procedures/ZPV_POSARPaymentGenerateClearingSp.sp 3     3/04/10 10:13a Dahn $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/ZPV_POSARPaymentGenerateClearingSp.sp $
 *
 * SL9.00.10 1 ljb Benetton Fri May 16 13:00:00 2014

 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_ARPaymentGenerateClearingSp] (
	@pCustNum		CustNumType
,	@pPayAmount		AmountType
,	@pArPayType		varchar(20)
,	@pClearing		ZpvClearingType
,	@pRecDate		DateType
,	@pBankCode		BankCodeType
,	@Infobar        InfobarType     OUTPUT
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
	
	
-- ZPV_TT_ARPMTD
declare
	@TTArpmtdCustNum	CustNumType
,	@TTArpmtdInvNum		InvNumType
,	@TTArpmtdDomAmtApplied	AmountType
,	@TTArpmtdCoNum		CoNumType
,	@TTArpmtdForAmtApplied	AmountType
,	@TTArpmtdExchRate	ExchRateType
			
	
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
,	@ZlaArClearing		ZpvClearingType

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
,	@ArpmtBalance		AmountType
,	@ArpmtZlaCreditCardExpDate	varchar(20)
,	@ArpmtZlaCreditCardPayments	int

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


BEGIN TRANSACTION;

BEGIN TRY
	set @TmpSessionId = NEWID()

	if @pArPayType is null
	begin
		select 
			@pArPayType			= par.lasttran_id
		from zpv_parms par
		where
			par.parms_key = 0
	end	
	
	-- Asigna el numero de recibo interno
	EXEC	[dbo].[ZLA_NextARPayTypeSp]
		@pLastTranId = @pArPayType,
		@Key = @ZlaArArPayId OUTPUT,
		@Infobar = @Infobar OUTPUT

	select
		@ZlaArSiteRef		= @Site
	,	@ZlaArCustNun		= @pCustNum
	,	@ZlaArCustSeq		= 0
	,	@ZlaArPayType		= @pArPayType
	,	@ZlaArPayDate		= @pRecDate
	,	@ZlaArCurrCode		= cus.curr_code
	,	@ZlaArExchRate		= 1
	,	@ZlaArArReceipt		= null
	,	@ZlaArStat			= 'O'
	,	@ZlaArClearing		= @pClearing
	from custaddr cus 
	where cus.cust_num = @pCustNum and cus.cust_seq = 0

	-- zla_ar_hdr
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
			   ,[stat]
			   ,[zpv_clearing]
			   ,[zpv_amount])
		 values
			(@ZlaArSiteRef
		,	@ZlaArCustNun
		,	@ZlaArCustSeq
		,	@ZlaArPayType
		,	@ZlaArArPayId
		,	@ZlaArPayDate
		,	@ZlaArCurrCode
		,	@ZlaArExchRate
		,	null
		,	@ZlaArArReceipt
		,	@ZlaArStat
		,	@ZlaArClearing
		,	@pPayAmount)

	-- arpmt	
	EXEC [dbo].[ZPV_GetNextCheckNumberSp]
	@pBankCode,
	'D',
	@NextCheckNumber OUTPUT		

	select 
	@ArpmtBankCode			= @pBankCode,
	@ArpmtCheckNum			= @NextCheckNumber,
	@ArpmtCustNum			= @pCustNum,
	@ArpmtDescription		= 'AR Payment ' + @pCustNum,
	@ArpmtDomCheck			= isnull(@pPayAmount,0),
	@ArpmtDueDate			= isnull(@pRecDate,getdate()),
	@ArpmtDepositDate		= isnull(@pRecDate,getdate()),
	@ArpmtExchRate			= 1,
	@ArpmtForCheckAmt		= isnull(@pPayAmount,0),
	@ArpmtRecptDate			= isnull(@pRecDate, getdate()),
	@ArpmtRef				= 'ARPC Liq' + @pClearing,
	@ArpmtSiteRef			= @Site, 
	@ArpmtTranferCash		= 0,
	@ArpmtType				= 'W',
	@ArpmtZlaArPayId		= @ZlaArArPayId,
	@ArpmtZlaRefBankCode	= null,
	@ArpmtZlaRefCheckNum	= null,
	@ArpmtZlaThirdBankId	= null,
	@ArpmtZlaThirdCheckDate = null,
	@ArpmtZlaThirdDescription = null,
	@ArpmtZlaThirdPartyCheck = null,
	@ArpmtZlaThirdTaxNumReg = null,
	@ArpmtZlaRefType		= null,
	@ArpmtZlaCreditCardExpDate	= null,
	@ArpmtZlaCreditCardPayments	= null
		
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
		
	declare CurTTArpmtd cursor for
	select
		tt.cust_num,
		tt.inv_num,
		tt.dom_amt_applied,
		tt.co_num,
		tt.for_amt_applied,
		tt.exch_rate
	from zpv_tt_arpmtd tt
	where
		tt.cust_num = @pCustNum and
		tt.dom_amt_applied > 0
	open CurTTArpmtd
		
	fetch next from CurTTArpmtd
	into
		@TTArpmtdCustNum,
		@TTArpmtdInvNum,
		@TTArpmtdDomAmtApplied,
		@TTArpmtdCoNum,
		@TTArpmtdForAmtApplied,
		@TTArpmtdExchRate
	while @@FETCH_STATUS = 0
	begin
		-- Genera Distribucion del pago
		select
			@ArpmtdSiteRef			= @Site,
			@ArpmtdCustNum			= @ArpmtCustNum,
			@ArpmtdCheckNum			= @ArpmtCheckNum,
			@ArpmtdInvNum			= @TTArpmtdInvNum,
			@ArpmtdDomAmtApplied	= @TTArpmtdDomAmtApplied,
			@ArpmtdApplyCustNum		= @ArpmtCustNum,
			@ArpmtdBankCode			= @pBankCode,
			@ArpmtdType				= 'W',
			@ArpmtdCoNum			= @TTArpmtdCoNum,
			@ArpmtdForAmtApplied	= @TTArpmtdForAmtApplied,
			@ArpmtdExchRate			= @TTArpmtdExchRate,
			@ArpmtdZlaForCurrCode	= @ZlaArCurrCode,
			@ArpmtdZlaForExchRate	= @TTArpmtdExchRate,
			@ArpmtdZlaForAmtApplied	= @TTArpmtdForAmtApplied
				           	
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

		update zpv_tt_arpmtd
			set dom_amt_applied = 0,
				for_amt_applied = 0
		where	cust_num	= @TTArpmtdCustNum
			and	inv_num		= @TTArpmtdInvNum

		fetch next from CurTTArpmtd
		into
			@TTArpmtdCustNum,
			@TTArpmtdInvNum,
			@TTArpmtdDomAmtApplied,
			@TTArpmtdCoNum,
			@TTArpmtdForAmtApplied,
			@TTArpmtdExchRate
	end
	close CurTTArpmtd
	deallocate CurTTArpmtd
		
	update zla_sys_lasttran_mst
		set lasttran = lasttran + 1
	where
		lastttran_id = @pArPayType
	
	delete from zpv_tt_arpmtd
	
	select @ZlaArArPayId
	
	-- Posteo de pagos generados
	--EXEC  @Severity = [dbo].[ZPV_ARPaymentClearingSp]
	--	@PayId = @ZlaArArPayId
	--,	@Infobar = @Infobar OUTPUT

	--update zla_ar_hdr
	--set stat = 'P'
	--where ar_pay_id = @ZlaArArPayId
	
	if @Severity <> 0
	begin
		ROLLBACK TRANSACTION
		return 0
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

