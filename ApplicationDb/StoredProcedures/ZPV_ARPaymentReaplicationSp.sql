/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentReaplicationSp]    Script Date: 16/01/2015 03:12:10 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ARPaymentReaplicationSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_ARPaymentReaplicationSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentReaplicationSp]    Script Date: 16/01/2015 03:12:10 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* $Header: /ApplicationDB/Stored Procedures/ZPV_ARPaymentReaplicationSp.sp 73    4/11/14 4:02a Ychen1 $ */
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

CREATE PROCEDURE [dbo].[ZPV_ARPaymentReaplicationSp] (
	@pCustNum           CustNumType
,	@pBankCode          BankCodeType
,	@pCheckNum          ArCheckNumType
,	@pDrawer			varchar(20)
,	@pCoPayRowPointer	RowPointerType
,	@pZlaArPayId		ZlaArPayIdType
,	@pOrigen			varchar(2)
,	@pInvNum			varchar(20)
,	@pAmount			AmountType
,	@Infobar            Infobar        OUTPUT
) AS

DECLARE
  @Severity             INT

SET @Severity = 0
SET @Infobar  = NULL

DECLARE
	-- CUSTOMER
  @CustomerRowPointer              RowPointerType
, @CustomerEndUserType             EndUserTypeType
, @CustomerPostedBal               AmountType

, @CorpCustomerRowPointer          RowPointerType

, @CustaddrRowPointer              RowPointerType
, @CustaddrCustNum                 CustNumType
, @CustaddrCurrCode                CurrCodeType
, @CustaddrCorpCred                ListYesNoType
, @CustaddrCorpCust                CustNumType
, @CustaddrBalMethod               BalMethodType

	-- BANKHDR
, @BankHdrRowPointer               RowPointerType
, @BankHdrAcct                     AcctType
, @BankHdrAcctUnit1                UnitCode1Type
, @BankHdrAcctUnit2                UnitCode2Type
, @BankHdrAcctUnit3                UnitCode3Type
, @BankHdrAcctUnit4                UnitCode4Type
, @BankHdrCurrCode                 CurrCodeType
, @BankHdrZlaBankType			   GlbankTypeType

, @TBankHdrRowPointer              RowPointerType
, @TBankHdrAcct                    AcctType
, @TBankHdrAcctUnit1               UnitCode1Type
, @TBankHdrAcctUnit2               UnitCode2Type
, @TBankHdrAcctUnit3               UnitCode3Type
, @TBankHdrAcctUnit4               UnitCode4Type

	-- ARTRAN 1
, @ArtranRowPointer                RowPointerType
, @ArtranType                      ArtranTypeType
, @ArtranAmount                    AmountType
, @ArtranMiscCharges               AmountType
, @ArtranSalesTax                  AmountType
, @ArtranSalesTax2                 AmountType
, @ArtranFreight                   AmountType
, @ArtranIssueDate                 DateType
, @ArtranInvSeq                    ArInvSeqType
, @ArtranDiscAmt                   AmountType
, @ArtranBankCode                  BankCodeType
, @ArtranExchRate                  ExchRateType
, @ArtranAcct                      AcctType
, @ArtranNoteExistsFlag            FlagNyType
, @ArtranAcctUnit1                 UnitCode1Type
, @ArtranAcctUnit2                 UnitCode2Type
, @ArtranAcctUnit3                 UnitCode3Type
, @ArtranAcctUnit4                 UnitCode4Type
, @ArtranCustNum                   CustNumType
, @ArtranInvNum                    InvNumType
, @ArtranCheckSeq                  ArCheckNumType
, @ArtranInvDate                   DateType
, @ArtranDueDate                   DateType
, @ArtranDescription               DescriptionType
, @ArtranCorpCust                  CustNumType
, @ArtranPayType                   CustPayTypeType
, @ArtranRef                       ReferenceType
, @ArtranCoNum                     CoNumType
, @ArtranRma                       ListYesNoType
, @ArtranZlaForAmount              AmountType
, @ArtranZlaForMiscCharges         AmountType
, @ArtranZlaForSalesTax            AmountType
, @ArtranZlaForSalesTax2           AmountType
, @ArtranZlaForFreight             AmountType
, @ArtranZlaForExchRate            ExchRateType
, @ArtranZlaArTypeId			   ZlaArTypeIdType
, @ArtranZlaInvNum				   InvNumType
, @ArtranZlaArPayId				   ZlaArPayIdType
, @ArtranZlaDocId				   ZlaDocumentIdType	
, @ArtranZlaForCurrCode			   CurrCodeType

	-- ARTRAN 2
, @ToArtranRowPointer                RowPointerType
, @ToArtranType                      ArtranTypeType
, @ToArtranAmount                    AmountType
, @ToArtranMiscCharges               AmountType
, @ToArtranSalesTax                  AmountType
, @ToArtranSalesTax2                 AmountType
, @ToArtranFreight                   AmountType
, @ToArtranIssueDate                 DateType
, @ToArtranInvSeq                    ArInvSeqType
, @ToArtranDiscAmt                   AmountType
, @ToArtranBankCode                  BankCodeType
, @ToArtranExchRate                  ExchRateType
, @ToArtranAcct                      AcctType
, @ToArtranNoteExistsFlag            FlagNyType
, @ToArtranAcctUnit1                 UnitCode1Type
, @ToArtranAcctUnit2                 UnitCode2Type
, @ToArtranAcctUnit3                 UnitCode3Type
, @ToArtranAcctUnit4                 UnitCode4Type
, @ToArtranCustNum                   CustNumType
, @ToArtranInvNum                    InvNumType
, @ToArtranCheckSeq                  ArCheckNumType
, @ToArtranInvDate                   DateType
, @ToArtranDueDate                   DateType
, @ToArtranDescription               DescriptionType
, @ToArtranCorpCust                  CustNumType
, @ToArtranPayType                   CustPayTypeType
, @ToArtranRef                       ReferenceType
, @ToArtranCoNum                     CoNumType
, @ToArtranRma                       ListYesNoType
, @ToArtranZlaForAmount              AmountType
, @ToArtranZlaForMiscCharges         AmountType
, @ToArtranZlaForSalesTax            AmountType
, @ToArtranZlaForSalesTax2           AmountType
, @ToArtranZlaForFreight             AmountType
, @ToArtranZlaForExchRate            ExchRateType
, @ToArtranZlaArTypeId			   ZlaArTypeIdType
, @ToArtranZlaInvNum				   InvNumType
, @ToArtranZlaArPayId				   ZlaArPayIdType
, @ToArtranZlaDocId				   ZlaDocumentIdType	
, @ToArtranZlaForCurrCode			CurrCodeType

, @ChartRowPointer                 RowPointerType
, @ChartAcct                       AcctType

, @TChartRowPointer                RowPointerType
, @TChartAcct                      AcctType

	-- ENDUSERTYPE
, @EndtypeRowPointer               RowPointerType
, @EndtypeDraftReceivableAcct      AcctType
, @EndtypeDraftReceivableAcctUnit1 UnitCode1Type
, @EndtypeDraftReceivableAcctUnit2 UnitCode2Type
, @EndtypeDraftReceivableAcctUnit3 UnitCode3Type
, @EndtypeDraftReceivableAcctUnit4 UnitCode4Type
, @EndtypeArAcct                   AcctType
, @EndtypeArAcctUnit1              UnitCode1Type
, @EndtypeArAcctUnit2              UnitCode2Type
, @EndtypeArAcctUnit3              UnitCode3Type
, @EndtypeArAcctUnit4              UnitCode4Type

	-- ARPARMS
, @ArparmsDraftReceivableAcct      AcctType
, @ArparmsDraftReceivableAcctUnit1 UnitCode1Type
, @ArparmsDraftReceivableAcctUnit2 UnitCode2Type
, @ArparmsDraftReceivableAcctUnit3 UnitCode3Type
, @ArparmsDraftReceivableAcctUnit4 UnitCode4Type

, @EuroCurrencyRowPointer          RowPointerType
, @EuroCurrencyEuroRate            ExchRateType
, @EuroCurrencyPlaces              DecimalPlacesType
, @PaymentCurrencyPlaces           DecimalPlacesType
, @ParmsSite                       SiteType

, @CurrparmsCurrCode               CurrCodeType

, @EuroParmsCurrCode               CurrCodeType

, @WSiteWSiteCode                  SiteType

, @DomRateIsDivisor                FlagNyType
, @PayRateIsDivisor                FlagNyType
, @DomCurrencyPlaces               DecimalPlacesType

, @XArtranRowPointer               RowPointerType
, @XArtranCheckSeq                 ArCheckNumType

, @CustdrftRowPointer              RowPointerType

, @SitenetRowPointer               RowPointerType
, @SitenetArLiabAcct               AcctType
, @SitenetArLiabAcctUnit1          UnitCode1Type
, @SitenetArLiabAcctUnit2          UnitCode2Type
, @SitenetArLiabAcctUnit3          UnitCode3Type
, @SitenetArLiabAcctUnit4          UnitCode4Type

, @JournalRowPointer               RowPointerType

, @CurrentPeriod        FinPeriodType
, @PeriodsRowPointer    RowPointerType
, @TId                  JournalIdType
, @DomesticCheckAmt     AmountType
, @ForeignCheckAmt      AmountType
, @PaymentCheckAmt      AmountType
, @ForeignApplyAmount   AmountType
, @TcAmtCompare         AmountType
, @TcAmtArtran          AmountType
, @TOpenType            ArtranTypeType
, @TIssueDate           DateType
, @TInvSeq              ArInvSeqType
, @TOpenDisc            AmountType
, @TBankCode            BankCodeType
, @ExchangeRate         ExchRateType
, @TAcct                AcctType
, @TUnit1               UnitCode1Type
, @TUnit2               UnitCode2Type
, @TUnit3               UnitCode3Type
, @TUnit4               UnitCode4Type
, @TAmt                 AmountType
, @TExchRate            ExchRateType
, @Ref                  ReferenceType
, @TCoNum               CoNumType
, @TRma                 ListYesNoType
, @AmountPosted         AmountType
, @ForAmountPosted      AmountType
, @ForAmountPostedTemp  AmountType
, @DomAmountPostedTemp  AmountType
, @PayAmountPostedTemp  AmountType
, @TotCr                AmountType
, @AutoCr               FlagNyType
, @EndTrans             JournalSeqType
, @ReApplication        ListYesNoType
, @CorpSiteName         NameType
, @TEndArAcct           AcctType
, @TEndArAcctUnit1      UnitCode1Type
, @TEndArAcctUnit2      UnitCode2Type
, @TEndArAcctUnit3      UnitCode3Type
, @TEndArAcctUnit4      UnitCode4Type
, @TBalDesc             InfobarType
, @Infobar2             InfobarType
, @GainLossAmount       GenericDecimalType
, @PostAmount           AmountType
, @SiteAmountPosted     AmountType
, @RefType              ReferenceType
, @UpdatePrepaidAmt     FlagNyType

, @TIssueDate121Str     NVARCHAR(100)
, @ArpmtRecptDate121Str NVARCHAR(100)
, @ArpmtDueDate121Str   NVARCHAR(100)

declare
  @SubKey					GenericKeyType
, @ControlPrefix        JourControlPrefixType
, @ControlSite          SiteType
, @ControlYear          FiscalYearType
, @ControlPeriod        FinPeriodType
, @ControlNumber        LastTranType
, @BufferJournal        RowPointerType
, @XactState            Int
, @EXTSSSFSSkipDist     ListYesNoType --SSS FSP

DECLARE 
	@Site SiteType
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare @WSite table (
  w_site_code nvarchar(20)
primary key (w_site_code)
)

BEGIN TRANSACTION;

BEGIN TRY

	SET @TId = 'AR Dist'
	SET @TIssueDate = NULL
	SET @TInvSeq = 1
	SET @TAcct = NULL

	SELECT
	   @ParmsSite = site
	FROM parms WITH (READUNCOMMITTED)

	SELECT
	   @CurrparmsCurrCode = curr_code
	FROM currparms WITH (READUNCOMMITTED)

	SELECT
	   @EuroParmsCurrCode = curr_code
	FROM euro_parms WITH (READUNCOMMITTED)

	SET @EuroCurrencyPlaces = 0
	SELECT
	  @EuroCurrencyPlaces = currency.places
	FROM currency WITH (READUNCOMMITTED)
	WHERE currency.curr_code = @EuroParmsCurrCode
	
	SELECT
	  @ArtranRowPointer        = ar.RowPointer        
	, @ArtranType			   = ar.type			
	, @ArtranAmount            = -(@pAmount)
	, @ArtranMiscCharges       = ar.misc_charges        
	, @ArtranSalesTax          = ar.sales_tax        
	, @ArtranSalesTax2         = ar.sales_tax_2        
	, @ArtranFreight           = ar.freight        
	, @ArtranIssueDate         = ar.issue_date        
	, @ArtranInvSeq            = ar.inv_seq        
	, @ArtranDiscAmt           = ar.disc_amt        
	, @ArtranBankCode          = ar.bank_code        
	, @ArtranExchRate          = ar.exch_rate        
	, @ArtranAcct              = ar.acct        
	, @ArtranNoteExistsFlag    = ar.NoteExistsFlag        
	, @ArtranAcctUnit1         = ar.acct_unit1        
	, @ArtranAcctUnit2         = ar.acct_unit2        
	, @ArtranAcctUnit3         = ar.acct_unit3        
	, @ArtranAcctUnit4         = ar.acct_unit4        
	, @ArtranCustNum           = ar.cust_num        
	, @ArtranInvNum            = ar.inv_num        
	, @ArtranCheckSeq          = ar.check_seq        
	, @ArtranInvDate           = ar.inv_date        
	, @ArtranDueDate           = ar.due_date        
	, @ArtranDescription       = ar.description        
	, @ArtranCorpCust          = ar.corp_cust        
	, @ArtranPayType           = ar.pay_type        
	, @ArtranRef               = ar.ref        
	, @ArtranCoNum             = ar.co_num        
	, @ArtranRma               = ar.rma        
	, @ArtranZlaForAmount      = @pAmount
	, @ArtranZlaForMiscCharges = ar.zla_for_misc_charges        
	, @ArtranZlaForSalesTax    = ar.zla_for_sales_tax        
	, @ArtranZlaForSalesTax2   = ar.zla_for_sales_tax_2        
	, @ArtranZlaForFreight     = ar.zla_for_freight        
	, @ArtranZlaForExchRate    = ar.zla_for_exch_rate        
	, @ArtranZlaArTypeId	   = ar.zla_ar_pay_id			   
	, @ArtranZlaInvNum		   = ar.zla_inv_num		   
	, @ArtranZlaArPayId		   = ar.zla_ar_pay_id		   
	, @ArtranZlaDocId		   = ar.zla_doc_id			   
	, @ArtranZlaForCurrCode	   = ar.zla_for_curr_code			
	, @TAmt					   = ar.amount
	FROM artran ar
	WHERE	ar.cust_num		= @pCustNum
		and	ar.inv_num		= '0'
		and	ar.type			= 'P'
		and	ar.inv_seq		= @pCheckNum
		and ar.bank_code	= @pBankCode
		and	ar.zla_ar_pay_id = @pZlaArPayId	

		
	SELECT
	  @ArparmsDraftReceivableAcct      = arparms.draft_receivable_acct
	, @ArparmsDraftReceivableAcctUnit1 = arparms.draft_receivable_acct_unit1
	, @ArparmsDraftReceivableAcctUnit2 = arparms.draft_receivable_acct_unit2
	, @ArparmsDraftReceivableAcctUnit3 = arparms.draft_receivable_acct_unit3
	, @ArparmsDraftReceivableAcctUnit4 = arparms.draft_receivable_acct_unit4
	, @TEndArAcct      = arparms.ar_acct
	, @TEndArAcctUnit1 = arparms.ar_acct_unit1
	, @TEndArAcctUnit2 = arparms.ar_acct_unit2
	, @TEndArAcctUnit3 = arparms.ar_acct_unit3
	, @TEndArAcctUnit4 = arparms.ar_acct_unit4
	FROM arparms WITH (READUNCOMMITTED)

	IF @@ROWCOUNT <> 1
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist0'
		  , '@arparms'
	   RETURN @Severity
	END


	SET @CustomerRowPointer  = NULL
	SET @CustomerEndUserType = NULL

	SELECT
	  @CustomerRowPointer  = customer.RowPointer
	, @CustomerEndUserType = customer.end_user_type
	FROM customer WITH (READUNCOMMITTED)
	WHERE customer.cust_num = @pCustNum
	   and customer.cust_seq = 0

	if @CustomerRowPointer IS NULL
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
		  , '@customer'
		  , '@arpmt.cust_num'
		  , @pCustNum

	   RETURN @Severity
	END

	SET @CustaddrRowPointer = NULL
	SET @CustaddrCurrCode   = NULL

	SELECT
	  @CustaddrRowPointer = custaddr.RowPointer
	, @CustaddrCurrCode   = custaddr.curr_code
	, @CustaddrBalMethod  = custaddr.bal_method
	, @CustaddrCorpCred   = custaddr.corp_cred
	, @CustaddrCorpCust   = custaddr.corp_cust
	FROM custaddr WITH (READUNCOMMITTED)
	WHERE custaddr.cust_num = @pCustNum
	   and custaddr.cust_seq = 0

	if @CustaddrRowPointer IS NULL
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
		  , '@custaddr'
		  , '@arpmt.cust_num'
		  , @pCustNum

	   RETURN @Severity
	END

	SELECT @DomRateIsDivisor = rate_is_divisor
	FROM currency with (readuncommitted)
	WHERE curr_code = @CurrparmsCurrCode

	SET @BankHdrRowPointer = NULL
	SET @BankHdrAcct       = NULL
	SET @BankHdrAcctUnit1  = NULL
	SET @BankHdrAcctUnit2  = NULL
	SET @BankHdrAcctUnit3  = NULL
	SET @BankHdrAcctUnit4  = NULL
	SET @BankHdrCurrCode   = NULL
	SET @BankHdrZlaBankType = NULL

	SELECT
	  @BankHdrRowPointer = bank_hdr.RowPointer
	, @BankHdrAcct       = bank_hdr.acct
	, @BankHdrAcctUnit1  = bank_hdr.acct_unit1
	, @BankHdrAcctUnit2  = bank_hdr.acct_unit2
	, @BankHdrAcctUnit3  = bank_hdr.acct_unit3
	, @BankHdrAcctUnit4  = bank_hdr.acct_unit4
	, @BankHdrCurrCode   = bank_hdr.curr_code
	, @BankHdrZlaBankType = bank_hdr.zla_bank_type	
	FROM bank_hdr WITH (READUNCOMMITTED)
	WHERE bank_hdr.bank_code = @pBankCode

	if @BankHdrRowPointer IS NULL
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
	   , '@bank_hdr'
	   , '@artran.bank_code'
	   , @pBankCode

	   RETURN @Severity
	END

	SET @PaymentCurrencyPlaces = 0
	SELECT @PayRateIsDivisor = currency.rate_is_divisor
	, @PaymentCurrencyPlaces = currency.places
	FROM currency with (readuncommitted)
	where currency.curr_code = @BankHdrCurrCode

	
	if @ArtranInvDate IS NULL
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare='
	   , '@artran.inv_date'
	   , @ArtranInvDate

	   RETURN @Severity
	END

	SET @DomesticCheckAmt = @ArtranAmount
	SET @ForeignCheckAmt = @ArtranAmount
	SET @PaymentCheckAmt = @ArtranAmount

	if @CustaddrCurrCode = @CurrparmsCurrCode
	   SET @TcAmtCompare = @ArtranAmount
	else
	   SET @TcAmtCompare = @ArtranAmount

	
	IF @BankHdrCurrCode = @CustaddrCurrCode
	BEGIN

	   SET @TAmt = @PaymentCheckAmt
	   SET @TExchRate = @ArtranExchRate
	END
	ELSE IF @BankHdrCurrCode = @CurrparmsCurrCode
	BEGIN
	   SET @TAmt = @PaymentCheckAmt
	   SET @TExchRate = 1
	END
	ELSE
	BEGIN -- check euro
	   SET @EuroCurrencyRowPointer = NULL
	   SET @EuroCurrencyEuroRate   = NULL

	   SELECT
		 @EuroCurrencyRowPointer = ec.RowPointer
	   , @EuroCurrencyEuroRate   = ec.euro_rate
	   FROM currency AS ec WITH (READUNCOMMITTED)
	   WHERE ec.curr_code = @CurrparmsCurrCode AND
			 ec.part_of_euro = 1

	   IF @EuroCurrencyRowPointer IS NOT NULL
	   BEGIN
		  IF NOT (@EuroCurrencyEuroRate = 0 AND @EuroCurrencyEuroRate IS NULL)
		  BEGIN
			 SET @TAmt = ROUND(@DomesticCheckAmt / @EuroCurrencyEuroRate,  @EuroCurrencyPlaces)
			 SET @TExchRate = @ArtranExchRate / @EuroCurrencyEuroRate
		  END
		  ELSE
		  BEGIN
			 SET @Infobar = NULL

			 EXEC dbo.MsgAppSp @Infobar OUTPUT, 'I=IsCompare1'
			 , '@currency.euro_rate'
			 , @EuroCurrencyEuroRate
			 , '@currency'
			 , '@currency.curr_code'
			 , @CurrparmsCurrCode

			 RETURN @Severity
		  END
	   END
	   ELSE
	   BEGIN
		  SET @EuroCurrencyRowPointer = NULL
		  SET @EuroCurrencyEuroRate   = NULL

		  SELECT
			@EuroCurrencyRowPointer = ec.RowPointer
		  , @EuroCurrencyEuroRate   = ec.euro_rate
		  FROM currency AS ec WITH (READUNCOMMITTED)
		  WHERE ec.curr_code = @CustaddrCurrCode AND
				ec.part_of_euro = 1

		  if @EuroCurrencyRowPointer IS NOT NULL
		  BEGIN
			 IF NOT (@EuroCurrencyEuroRate = 0 AND @EuroCurrencyEuroRate IS NULL)
			 BEGIN
				SET @TAmt = round(@ForeignCheckAmt / @EuroCurrencyEuroRate,  @EuroCurrencyPlaces)
				SET @TExchRate = @ArtranExchRate / @EuroCurrencyEuroRate
			 END
			 ELSE
			 BEGIN
				SET @Infobar = NULL

				EXEC dbo.MsgAppSp @Infobar OUTPUT, 'I=IsCompare1'
				, '@currency.euro_rate'
				, @EuroCurrencyEuroRate
				, '@currency'
				, '@currency.curr_code'
				, @CustaddrCurrCode

				RETURN @Severity
			 END
		  END
		  ELSE
		  BEGIN
			 SET @TAmt = @PaymentCheckAmt

			 IF @PayRateIsDivisor = 1 AND ISNULL(@PaymentCheckAmt, 0) <> 0
				BEGIN
				   SET @TExchRate = @ArtranAmount / @PaymentCheckAmt
				END
			 ELSE IF @PayRateIsDivisor = 0 AND ISNULL(@ArtranAmount, 0) <> 0
				BEGIN
				   SET @TExchRate = @PaymentCheckAmt / @ArtranAmount
				END
			 ELSE
				BEGIN
				   SET @TExchRate = 1
				   SET @TAmt = @ArtranAmount
				END
		  END
	   END
	END -- check euro

	EXEC @Severity = dbo.ChkUnitSp
	  @ArtranAcct
	, @ArtranAcctUnit1
	, @ArtranAcctUnit2
	, @ArtranAcctUnit3
	, @ArtranAcctUnit4
	, @Infobar OUTPUT

	IF @Severity <> 0
	   RETURN @Severity

	SET @Ref = @ArtranRef

	set @ControlSite = @ParmsSite

	EXEC dbo.NextControlNumberSp
	  @JournalId		= 'AR Dist'
	, @TransDate		= @ArtranInvDate
	, @ControlPrefix	= @ControlPrefix output
	, @ControlSite		= @ControlSite output
	, @ControlYear		= @ControlYear output
	, @ControlPeriod	= @ControlPeriod output
	, @ControlNumber	= @ControlNumber output
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

	EXEC @Severity = dbo.ZPV_JourpostSp
	  @id                 = 'AR Dist'
	, @trans_date         = @ArtranInvDate
	, @acct               = @ArtranAcct
	, @acct_unit1         = @ArtranAcctUnit1
	, @acct_unit2         = @ArtranAcctUnit2
	, @acct_unit3         = @ArtranAcctUnit3
	, @acct_unit4         = @ArtranAcctUnit4
	, @amount             = @ArtranAmount
	, @for_amount         = @ArtranAmount
	, @bank_code          = @ArtranBankCode
	, @exch_rate          = @ArtranExchRate
	, @curr_code          = @BankHdrCurrCode
	, @check_num          = @ArtranInvSeq
	, @check_date         = @ArtranInvDate
	, @ref                = @Ref
	, @vend_num           = @ArtranCustNum
	, @ref_type           = 'P'
	, @ControlPrefix	  = @ControlPrefix
	, @ControlSite		  = @ControlSite
	, @ControlYear		  = @ControlYear
	, @ControlPeriod	  = @ControlPeriod
	, @ControlNumber	  = @ControlNumber
	, @last_seq           = @EndTrans     OUTPUT
	, @Infobar            = @Infobar      OUTPUT

	
	if @Severity <> 0
		RETURN @Severity


	SET @AmountPosted = @DomesticCheckAmt
	SET @ForAmountPosted = @ForeignCheckAmt
	SET @TotCr = 0
	SET @AutoCr = 1
	SET @ForAmountPostedTemp = 0
	SET @DomAmountPostedTemp = 0
	SET @PayAmountPostedTemp = 0

	SELECT
	   @CorpSiteName = site_name
	FROM site WITH (READUNCOMMITTED)
	WHERE site = @ParmsSite

	SET @ReApplication = CASE WHEN @TOpenType IS NULL THEN 0 ELSE 1 END

	---- Disable this branch because in Mexico Country Pack already do it.
	--IF @ArpmtOffset = 0
	--BEGIN
	--	IF dbo.IsAddonAvailable('SyteLineMX') = 0
	--	begin
	--		IF @ReApplication = 0
	--		and @ArpmtType in ('A', 'C', 'W')
	--		BEGIN
	--			IF @ArpmtCustNum IS NULL
	--			SET @ArpmtCustNum = 0

	--			EXEC @Severity = dbo.ZPV_CreateGlBankSp
	--				@PProcessID
	--			, @BankCode					= @ArpmtBankCode
	--			, @CheckDate				= @ArpmtRecptDate
	--			, @CheckNumber				= @ArpmtCheckNum
	--			, @CheckAmt					= @DomesticCheckAmt
	--			, @Type						= @ArpmtType
	--			, @RefType					= 'A/R'
	--			, @RefNum					= @ArpmtCustNum
	--			, @DomCheckAmt				= @DomesticCheckAmt
	--			, @Infobar					= @Infobar OUTPUT
	--			, @ZlaThirdPartyCheck		= @ArpmtZlaThirdPartyCheck
	--			, @ZlaThirdBankId			= @ArpmtZlaThirdBankId
	--			, @ZlaThirdDescription		= @ArpmtZlaThirdDescription
	--			, @ZlaThirdTaxNumReg		= @ArpmtZlaThirdTaxNumReg
	--			, @ZlaThirdCheckDate		= @ArpmtZlaThirdCheckDate
	--			, @ZlaArPayId				= @ArpmtZlaArPayId
	--			, @ZlaCreditCardExpDate		= @ArpmtZlaCreditCardExpDate 
	--			, @ZlaCreditCardPayments	= @ArpmtZlaCreditCardPayments
	--			, @GlbankRowPointer			= @GlbankRowPointer OUTPUT

	--			set @PCoPayRowPointer = null

	--			select @PCoPayRowPointer = pay.RowPointer
	--			from zpv_co_payments pay
	--			where	pay.bank_code		= @ArpmtBankCode
	--				and	pay.amount			= @DomesticCheckAmt
	--				--and pay.due_date		= @ArpmtDueDate
	--				--and pay.pay_date		= @ArpmtRecptDate
	--				and pay.ar_pay_id		= @ArpmtZlaArPayId
	--				and pay.check_num		= @ArpmtCheckNum
					
	--			if @PCoPayRowPointer is null
	--			begin
	--				select top 1 @PCoPayRowPointer = pay.RowPointer
	--				from zpv_ar_payments pay
	--				where	pay.cust_num		= @ArpmtCustNum
	--					and	pay.[apply]			= 1
						
	--			end
				
				
	--			if @PCoPayRowPointer is null
	--			begin
	--				set @Severity = 16
	--				Set @Infobar = 'Error al Crear DrawerTrans'
	--				RETURN @Severity
	--			end	

	--			EXEC @Severity =  dbo.ZPV_CreateDrawerTransSp
	--				@pDrawer			= @PDrawer,
	--				@pGlBankRowPointer	= @GlbankRowPointer,
	--				@pCoPayRowPointer	= @PCoPayRowPointer,
	--				@pAmount			= @DomesticCheckAmt,
	--				@pTransDate			= @ArpmtRecptDate,
	--				@pArPayId			= @PZlaArPayId,
	--				@pOrigen			= @POrigen,
	--				@Infobar			= @Infobar OUTPUT

	--		END

	--	end
	--END -- ArpmtOffset
	
	   SELECT
		 @ToArtranAcct			= arto.acct
	   , @ToArtranAcctUnit1		= arto.acct_unit1
	   , @ToArtranAcctUnit2		= arto.acct_unit2
	   , @ToArtranAcctUnit3		= arto.acct_unit3
	   , @ToArtranAcctUnit4		= arto.acct_unit4
	   FROM artran arto
	   WHERE	arto.cust_num	= @pCustNum
			and arto.inv_num	= @pInvNum
			and arto.inv_seq	= 0 
			and arto.type		= 'I'	

	   SELECT
		 @ToArtranRowPointer	= NEWID ()
	   , @ToArtranCustNum		= @ArtranCustNum
	   , @ToArtranInvNum		= @pInvNum
	   , @ToArtranInvSeq		= @ArtranInvSeq
	   , @ToArtranType			= 'P'
	   , @ToArtranCheckSeq		= @ArtranCheckSeq
	   , @ToArtranInvDate		= @ArtranInvDate
	   , @ToArtranBankCode		= @ArtranBankCode
	   , @ToArtranExchRate		= @ArtranExchRate
	   , @ToArtranAmount		= @pAmount
	   , @ToArtranCorpCust		= @CustaddrCorpCust
	   , @ToArtranPayType		= @ArtranType
	   , @ToArtranDueDate		= @ArtranDueDate
	   , @ToArtranRef			= @ArtranRef

	   , @ToArtranZlaArPayId	= @ArtranZlaArPayId
	   , @ToArtranZlaArTypeId	= @ArtranZlaArTypeId
	   , @ToArtranZlaDocId		= @ArtranZlaDocId
	   , @ToArtranZlaForAmount	= @ArtranZlaForAmount
	   , @ToArtranZlaForExchRate = @ArtranZlaForExchRate
	   , @ToArtranZlaForFreight	= @ArtranZlaForFreight	
	   , @ToArtranZlaForMiscCharges = @ArtranZlaForMiscCharges
	   , @ToArtranZlaForSalesTax = @ArtranZlaForSalesTax
	   , @ToArtranZlaForSalesTax2 = @ArtranZlaForSalesTax2
	   , @ToArtranZlaForCurrCode = @ArtranZlaForCurrCode

	   if exists(select 1 from artran 
					where	cust_num = @ToArtranCustNum
						and	inv_num = @ToArtranInvNum
						and inv_seq = @ToArtranInvSeq
						and check_seq = @ToArtranCheckSeq)
	   begin
			select top 1
				@ToArtranCheckSeq = ar.check_seq + 1
			from artran ar
			where	ar.cust_num = @ToArtranCustNum
				and	ar.inv_num = @ToArtranInvNum
				and ar.inv_seq = @ToArtranInvSeq
			order by ar.check_seq desc
	   end

	   INSERT INTO artran (
		 RowPointer
	   , cust_num
	   , inv_num
	   , inv_seq
	   , check_seq
	   , type
	   , inv_date
	   , acct
	   , acct_unit1
	   , acct_unit2
	   , acct_unit3
	   , acct_unit4
	   , bank_code
	   , description
	   , exch_rate
	   , amount
	   , corp_cust
	   , pay_type
	   , due_date
	   , ref
	   , apply_to_inv_num
	   , zla_ar_pay_id
	   , zla_ar_type_id
	   , zla_doc_id
	   , zla_for_amount
	   , zla_for_curr_code
	   , zla_for_disc_amt
	   , zla_for_exch_rate
	   ) VALUES (
		 @ToArtranRowPointer
	   , @ToArtranCustNum
	   , @ToArtranInvNum
	   , @ToArtranInvSeq
	   , @ToArtranCheckSeq
	   , @ToArtranType
	   , @ToArtranInvDate
	   , @ToArtranAcct
	   , @ToArtranAcctUnit1
	   , @ToArtranAcctUnit2
	   , @ToArtranAcctUnit3
	   , @ToArtranAcctUnit4
	   , @ToArtranBankCode
	   , @ToArtranDescription
	   , @ToArtranExchRate
	   , @ToArtranAmount
	   , @ToArtranCorpCust
	   , 'C'
	   , @ToArtranDueDate
	   , @ToArtranRef
	   , @ToArtranInvNum
   	   , @ToArtranZlaArPayId	-- zla_ar_pay_id
	   , @ToArtranZlaArTypeId	-- zla_ar_type_id
	   , @ToArtranZlaDocId		-- zla_doc_id
	   , @ToArtranZlaForAmount	-- zla_for_amount
	   , @ToArtranZlaForCurrCode -- zla_for_curr_code
	   , 0
	   , @ToArtranExchRate
	   )

	IF @ControlNumber IS NULL SET @ControlNumber = 1

	EXEC @Severity = dbo.ZPV_JourpostSp
	  @id                 = 'AR Dist'
	, @trans_date         = @ArtranInvDate
	, @acct               = @ToArtranAcct
	, @acct_unit1         = @ToArtranAcctUnit1
	, @acct_unit2         = @ToArtranAcctUnit2
	, @acct_unit3         = @ToArtranAcctUnit3
	, @acct_unit4         = @ToArtranAcctUnit4
	, @amount             = @ToArtranAmount
	, @for_amount         = @ToArtranAmount
	, @bank_code          = @ToArtranBankCode
	, @exch_rate          = @ToArtranExchRate
	, @curr_code          = @ToArtranZlaForCurrCode
	, @check_num          = @ToArtranInvSeq
	, @check_date         = @ArtranInvDate
	, @ref                = @Ref
	, @vend_num           = @ToArtranCustNum
	, @ref_type           = 'P'
	, @ControlPrefix	  = @ControlPrefix
	, @ControlSite		  = @ControlSite
	, @ControlYear		  = @ControlYear
	, @ControlPeriod	  = @ControlPeriod
	, @ControlNumber	  = @ControlNumber
	, @last_seq           = @EndTrans     OUTPUT
	, @Infobar            = @Infobar      OUTPUT

	
	if @TAmt = @pAmount
	begin
		delete from artran
		where	cust_num		= @pCustNum
			and	inv_num			= '0'
			and	type			= 'P'
			and	inv_seq			= @pCheckNum
			and bank_code		= @pBankCode
			and	zla_ar_pay_id	= @pZlaArPayId	
	end
	else 
	begin
		update artran
			set amount				= amount - @pAmount
			,	zla_for_amount		= zla_for_amount - @pAmount
		where	cust_num		= @pCustNum
			and	inv_num			= '0'
			and	type			= 'P'
			and	inv_seq			= @pCheckNum
			and bank_code		= @pBankCode
			and	zla_ar_pay_id	= @pZlaArPayId	
	end

	if @Severity <> 0
	begin
		RETURN @Severity
		ROLLBACK TRANSACTION;
	end

	set @Infobar = 'Pago Re-Aplicado'
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


