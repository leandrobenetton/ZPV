/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentPostingSp]    Script Date: 16/01/2015 03:12:10 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ARPaymentPostingSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_ARPaymentPostingSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentPostingSp]    Script Date: 16/01/2015 03:12:10 p.m. ******/
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

CREATE PROCEDURE [dbo].[ZPV_ARPaymentPostingSp] (
@PProcessID          RowPointer
, @PCustNum            CustNumType
, @PBankCode           BankCodeType
, @PType               ArpmtTypeType
, @PCheckNum           ArCheckNumType
, @PDrawer				varchar(20)
, @PCoPayRowPointer		RowPointerType
, @PZlaArPayId			ZlaArPayIdType
, @POrigen				varchar(2)
, @Infobar             Infobar        OUTPUT
) AS

DECLARE
  @Severity             INT

SET @Severity = 0
SET @Infobar  = NULL

DECLARE
	-- ARPMT
  @ArpmtRowPointer                 RowPointerType
, @ArpmtCustNum                    CustNumType
, @ArpmtBankCode                   BankCodeType
, @ArpmtType                       ArpmtTypeType
, @ArpmtCreditMemoNum              InvNumType
, @ArpmtCheckNum                   ArCheckNumType
, @ArpmtRecptDate                  DateType
, @ArpmtDepositDate                DateType
, @ArpmtDueDate                    DateType
, @ArpmtDomCheckAmt                AmountType
, @ArpmtForCheckAmt                AmountType
, @ArpmtPayCheckAmt                AmountType
, @ArpmtRef                        ReferenceType
, @ArpmtExchRate                   ExchRateType
, @ArpmtPayExchRate                ExchRateType
, @ArpmtDescription                DescriptionType
, @ArpmtTransferCash               ListYesNoType
, @ArpmtNoteExistsFlag             FlagNyType
, @ArpmtOffset                     ListYesNoType
, @ArpmtZlaRefBankCode			   BankCodeType
, @ArpmtZlaRefCheckNum			   ArCheckNumType		
, @ArpmtZlaThirdPartyCheck		   ListYesNoType
, @ArpmtZlaThirdBankId			   BankCodeType
, @ArpmtZlaThirdDescription		   DescriptionType
, @ArpmtZlaThirdTaxNumReg		   TaxRegNumType
, @ArpmtZlaThirdCheckDate		   DateType
, @ArpmtZlaArPayId				   ZlaArPayIdType
, @ArpmtZlaRefType				   GlbankTypeType
, @ArpmtZlaCreditCardExpDate	   DateType
, @ArpmtZlaCreditCardPayments	   int
		
	-- ARPMTD
, @ArpmtdRowPointer                RowPointerType
, @ArpmtdCustNum                   CustNumType
, @ArpmtdBankCode                  BankCodeType
, @ArpmtdType                      ArpmtTypeType
, @ArpmtdCreditMemoNum             InvNumType
, @ArpmtdCheckNum                  ArCheckNumType
, @ArpmtdInvNum                    InvNumType
, @ArpmtdSite                      SiteType
, @ArpmtdExchRate                  ExchRateType
, @ArpmtdDomDiscAmt                AmountType
, @ArpmtdForDiscAmt                AmountType
, @ArpmtdDomAllowAmt               AmountType
, @ArpmtdForAllowAmt               AmountType
, @ArpmtdDomAmtApplied             AmountType
, @ArpmtdForAmtApplied             AmountType
, @ArpmtdCoNum                     CoNumType
, @ArpmtdDoNum                     DoNumType
, @ArpmtdShipmentId                ShipmentIdType
, @ArpmtdDiscAcct                  AcctType
, @ArpmtdDiscAcctUnit1             UnitCode1Type
, @ArpmtdDiscAcctUnit2             UnitCode2Type
, @ArpmtdDiscAcctUnit3             UnitCode3Type
, @ArpmtdDiscAcctUnit4             UnitCode4Type
, @ArpmtdAllowAcct                 AcctType
, @ArpmtdAllowAcctUnit1            UnitCode1Type
, @ArpmtdAllowAcctUnit2            UnitCode2Type
, @ArpmtdAllowAcctUnit3            UnitCode3Type
, @ArpmtdAllowAcctUnit4            UnitCode4Type
, @ArpmtdDepositAcct               AcctType
, @ArpmtdDepositAcctUnit1          UnitCode1Type
, @ArpmtdDepositAcctUnit2          UnitCode2Type
, @ArpmtdDepositAcctUnit3          UnitCode3Type
, @ArpmtdDepositAcctUnit4          UnitCode4Type
, @ArpmtdApplyCustNum              CustNumType
, @ArpmtdZlaForCurrCode			   CurrCodeType
, @ArpmtdZlaForExchRate			   ExchRateType
, @ArpmtdZlaForAllowAmt			   AmountType	
, @ArpmtdZlaForAmtApplied		   AmountType
, @ArpmtdZlaForDiscAmt			   AmountType
, @ArpmtdZlaForNonArAmt			   AmountType

, @ArpmtdForTaxAmt1                AmountType
, @ArpmtdForTaxAmt2                AmountType
, @ArpmtdDomTaxAmt1                AmountType
, @ArpmtdDomTaxAmt2                AmountType
	-- CUSTOMER
, @CustomerRowPointer              RowPointerType
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
	-- ARTRAN
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

-- Mexico Country Pack Variable
--MAH CIMATIC Declare variables
Declare
@MXSATParmsReconReq     Flag,
@GlbankRowPointer       RowPointerType,
@IsReapp                Flag,
@BankRecon              Flag,
@TaskId                 TokenType,
@UserName               UserNameType,
@TaskHistoryRowPointer  RowPointerType ,
@ChkType                glbanktypetype,
@ReconDate              DateType,
@VATTranferred          ListYesNoType,
@PreviewInterval        GenericIntType,
@ArpmtCustNumMXL        CustNumType 

DECLARE 
	@Site SiteType
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare @WSite table (
  w_site_code nvarchar(20)
primary key (w_site_code)
)

declare @arpmtd_to_delete table (
  ArpmtdRowPointer nvarchar(256)
)

create table #customer (
  cust_num nvarchar(20) primary key
, disc_ytd decimal(25,10) default 0
, posted_bal decimal(25,10) default 0
, order_bal decimal(25,10) default 0
)

BEGIN
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

	SET @ArpmtRowPointer = NULL

	SELECT
	  @ArpmtRowPointer = arpmt.RowPointer
	, @ArpmtCustNum    = arpmt.cust_num
	, @ArpmtBankCode   = arpmt.bank_code
	, @ArpmtType       = arpmt.type
	, @ArpmtCheckNum   = arpmt.check_num
	, @ArpmtRecptDate  = arpmt.recpt_date
	, @ArpmtDepositDate = arpmt.deposit_date
	, @ArpmtDueDate    = arpmt.due_date
	, @ArpmtDomCheckAmt = arpmt.dom_check_amt
	, @ArpmtForCheckAmt = arpmt.for_check_amt
	, @ArpmtPayCheckAmt = arpmt.payment_check_amt
	, @ArpmtRef         = arpmt.ref
	, @ArpmtExchRate    = arpmt.exch_rate
	, @ArpmtPayExchRate = arpmt.payment_exch_rate
	, @ArpmtTransferCash = arpmt.transfer_cash
	, @ArpmtDescription  = arpmt.description
	, @ArpmtNoteExistsFlag = arpmt.NoteExistsFlag
	, @ArpmtCreditMemoNum  = arpmt.credit_memo_num
	, @ArpmtOffset = arpmt.offset
	, @ArpmtZlaRefBankCode = arpmt.zla_ref_bank_code
	, @ArpmtZlaRefCheckNum = arpmt.zla_ref_check_num
	, @ArpmtZlaThirdPartyCheck = arpmt.zla_third_party_check
	, @ArpmtZlaThirdBankId	= arpmt.zla_third_bank_id
	, @ArpmtZlaThirdDescription = arpmt.zla_third_description
	, @ArpmtZlaThirdTaxNumReg = arpmt.zla_third_tax_num_reg
	, @ArpmtZlaThirdCheckDate = arpmt.zla_third_check_date
	, @ArpmtZlaArPayId		= arpmt.zla_ar_pay_id
	, @ArpmtZlaRefType		= arpmt.zla_ref_type
	, @ArpmtZlaCreditCardExpDate = null --arpmt.zla_credit_card_exp_date
	, @ArpmtZlaCreditCardPayments = arpmt.zla_credit_card_payments
	FROM arpmt WITH (UPDLOCK)
	WHERE arpmt.bank_code = @PBankCode
	   AND arpmt.cust_num = @PCustNum
	   AND arpmt.type = @PType
	   AND arpmt.check_num = @PCheckNum
	   AND ((arpmt.type = 'C' AND arpmt.deposit_date IS NOT NULL AND arpmt.deposit_date <= dbo.GetSiteDate(GETDATE()))OR
	   arpmt.deposit_date IS NULL)

	IF @ArpmtRowPointer IS NULL
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist0'
		  , '@arpmt'

	   RETURN @Severity
	END

	EXEC @Severity = dbo.PerGetSp
					 @ArpmtRecptDate,
					 @CurrentPeriod output,
					 @PeriodsRowPointer output,
					 @Infobar output
				   , @Site = @ParmsSite
	IF @Severity <> 0
	   RETURN @Severity

	SET @CustomerRowPointer  = NULL
	SET @CustomerEndUserType = NULL

	SELECT
	  @CustomerRowPointer  = customer.RowPointer
	, @CustomerEndUserType = customer.end_user_type
	FROM customer WITH (READUNCOMMITTED)
	WHERE customer.cust_num = @ArpmtCustNum
	   and customer.cust_seq = 0

	if @CustomerRowPointer IS NULL
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
		  , '@customer'
		  , '@arpmt.cust_num'
		  , @ArpmtCustNum

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
	WHERE custaddr.cust_num = @ArpmtCustNum
	   and custaddr.cust_seq = 0

	if @CustaddrRowPointer IS NULL
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
		  , '@custaddr'
		  , '@arpmt.cust_num'
		  , @ArpmtCustNum

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
	WHERE bank_hdr.bank_code = @ArpmtBankCode

	if @BankHdrRowPointer IS NULL
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
	   , '@bank_hdr'
	   , '@arpmt.bank_code'
	   , @ArpmtBankCode

	   RETURN @Severity
	END

	SET @PaymentCurrencyPlaces = 0
	SELECT @PayRateIsDivisor = currency.rate_is_divisor
	, @PaymentCurrencyPlaces = currency.places
	FROM currency with (readuncommitted)
	where currency.curr_code = @BankHdrCurrCode

	if @ArpmtRecptDate IS NULL
	BEGIN
	   SET @Infobar = NULL
	   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare='
	   , '@arpmt.recpt_date'
	   , @ArpmtRecptDate

	   RETURN @Severity
	END

	SET @DomesticCheckAmt = @ArpmtDomCheckAmt
	SET @ForeignCheckAmt = @ArpmtForCheckAmt
	SET @PaymentCheckAmt = @ArpmtPayCheckAmt

	if @CustaddrCurrCode = @CurrparmsCurrCode
	   SET @TcAmtCompare = @ArpmtDomCheckAmt
	else
	   SET @TcAmtCompare = @ArpmtForCheckAmt

	SET @ArtranRowPointer  = NULL
	SET @ArtranType        = NULL
	SET @ArtranAmount      = 0
	SET @ArtranMiscCharges = 0
	SET @ArtranSalesTax    = 0
	SET @ArtranSalesTax2   = 0
	SET @ArtranFreight     = 0
	SET @ArtranIssueDate   = NULL
	SET @ArtranInvSeq      = 0
	SET @ArtranDiscAmt     = 0
	SET @ArtranBankCode    = NULL
	SET @ArtranExchRate    = 0
	SET @ArtranAcct        = NULL
	SET @ArtranNoteExistsFlag = 0
	SET @ArtranAcctUnit1   = NULL
	SET @ArtranAcctUnit2   = NULL
	SET @ArtranAcctUnit3   = NULL
	SET @ArtranAcctUnit4   = NULL
	SET @ArtranCoNum       = NULL
	SET @ArtranRma         = 0
	SET @TCoNum            = NULL
	SET @TRma              = 0

	SET @ArtranZlaForAmount      = 0
	SET @ArtranZlaForMiscCharges = 0
	SET @ArtranZlaForSalesTax    = 0
	SET @ArtranZlaForSalesTax2   = 0
	SET @ArtranZlaForFreight     = 0
	SET @ArtranZlaForExchRate    = 0
	SET @ArtranZlaArPayId  = NULL
	SET @ArtranZlaArTypeId = NULL
	SET @ArtranZlaDocId	   = NULL
	SET @ArtranZlaInvNum   = NULL		

	SELECT TOP 1
	  @ArtranRowPointer  = artran.RowPointer
	, @ArtranType        = artran.type
	, @ArtranAmount      = artran.amount
	, @ArtranMiscCharges = artran.misc_charges
	, @ArtranSalesTax    = artran.sales_tax
	, @ArtranSalesTax2   = artran.sales_tax_2
	, @ArtranFreight     = artran.freight
	, @ArtranIssueDate   = artran.issue_date
	, @ArtranInvSeq      = artran.inv_seq
	, @ArtranDiscAmt     = artran.disc_amt
	, @ArtranBankCode    = artran.bank_code
	, @ArtranExchRate    = artran.exch_rate
	, @ArtranAcct        = artran.acct
	, @ArtranNoteExistsFlag = artran.NoteExistsFlag
	, @ArtranAcctUnit1   = artran.acct_unit1
	, @ArtranAcctUnit2   = artran.acct_unit2
	, @ArtranAcctUnit3   = artran.acct_unit3
	, @ArtranAcctUnit4   = artran.acct_unit4
	, @ArtranCoNum       = artran.co_num
	, @ArtranRma         = artran.rma
	, @ArtranZlaForAmount      = artran.zla_for_amount
	, @ArtranZlaForMiscCharges = artran.zla_for_misc_charges
	, @ArtranZlaForSalesTax    = artran.zla_for_sales_tax
	, @ArtranZlaForSalesTax2   = artran.zla_for_sales_tax_2
	, @ArtranZlaForFreight     = artran.zla_for_freight
	, @ArtranZlaForExchRate    = artran.zla_for_exch_rate
	, @ArtranZlaArPayId  = artran.zla_ar_pay_id
	, @ArtranZlaArTypeId = artran.zla_ar_type_id
	, @ArtranZlaDocId	   = artran.zla_doc_id
	, @ArtranZlaInvNum   = artran.zla_inv_num		
	FROM artran
	WHERE artran.cust_num = @ArpmtCustNum and
		  artran.apply_to_inv_num = '0' and
		  artran.inv_num = case when @ArpmtCreditMemoNum is not null then ISNULL(@ArpmtCreditMemoNum,'')
																	 else artran.inv_num end and
		  artran.inv_seq = @ArpmtCheckNum and
		  artran.check_seq = 0

	if @ArtranRowPointer IS NOT NULL
	   and CHARINDEX( @ArtranType, 'CP') <> 0
	BEGIN -- artran exists and type = C or P
	
	   SET @TOpenType   = @ArtranType
	   SET @TcAmtArtran = @ArtranAmount + @ArtranMiscCharges +
						  @ArtranSalesTax + @ArtranSalesTax2 +
						  @ArtranFreight
	   SET @TCoNum      = @ArtranCoNum
	   SET @TRma        = @ArtranRma

	   if @ArtranIssueDate IS NOT NULL
	   BEGIN
		  SET @TIssueDate = @ArtranIssueDate
		  SET @TInvSeq = @ArtranInvSeq
	   END

	   --if @TcAmtArtran <> @TcAmtCompare
	   --BEGIN
		  --SET @Infobar = NULL
		  --EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=MustCompare='
		  --, '@arpmt.dom_check_amt'
		  --, @TcAmtArtran

		  --RETURN @Severity
	   --END

	   SET @TOpenDisc = @ArtranDiscAmt
	   SET @TBankCode = @ArtranBankCode
	   SET @ExchangeRate = @ArtranExchRate

	   SET @ChartRowPointer = NULL
	   SET @ChartAcct       = NULL

	   SELECT
		 @ChartRowPointer = chart.RowPointer
	   , @ChartAcct       = chart.acct
	   FROM chart WITH (READUNCOMMITTED)
	   WHERE chart.acct = @ArtranAcct

	   if @ChartRowPointer IS NULL or @ArtranAcct IS NULL
	   BEGIN
		  SET @Infobar = NULL
		  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistForIs'
		  , '@chart'
		  , '@chart.acct'
		  , @ArtranAcct
		  , '@arpmt'

		  RETURN @Severity
	   END

	   EXEC @Severity = dbo.ChkAcctSp
		 @ArtranAcct
	   , @ArpmtRecptDate
	   , @Infobar OUTPUT

	   IF @Severity <> 0
		  RETURN @Severity

	   IF @ArtranNoteExistsFlag > 0
	   BEGIN
		  EXEC @Severity = dbo.NotesDeleteSp
			  'artran'
			 , @ArtranRowPointer

		  if @Severity <> 0
			 RETURN @Severity
	   END

	   SET @TAcct  = @ArtranAcct
	   SET @TUnit1 = @ArtranAcctUnit1
	   SET @TUnit2 = @ArtranAcctUnit2
	   SET @TUnit3 = @ArtranAcctUnit3
	   SET @TUnit4 = @ArtranAcctUnit4

	   DELETE artran
	   WHERE RowPointer = @ArtranRowPointer

	END -- artran exists and type = C or P
	ELSE
	BEGIN -- artran does not exist
	
	   SET @TOpenType = NULL
	   SET @TOpenDisc = 0

	   SET @ChartRowPointer = NULL
	   SET @ChartAcct       = NULL

	   SELECT
		 @ChartRowPointer = chart.RowPointer
	   , @ChartAcct       = chart.acct
	   FROM chart WITH (READUNCOMMITTED)
	   WHERE chart.acct = @BankHdrAcct

	   if @ChartRowPointer IS NULL or @BankHdrAcct IS NULL
	   BEGIN
		  SET @Infobar = NULL
		  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistForIs'
		  , '@chart'
		  , '@chart.acct'
		  , @BankHdrAcct
		  , '@arpmt'

		  RETURN @Severity
	   END

	   EXEC @Severity = dbo.ChkAcctSp
		 @BankHdrAcct
	   , @ArpmtRecptDate
	   , @Infobar OUTPUT

	   IF @Severity <> 0
		  RETURN @Severity

	   SET @TAcct  = @BankHdrAcct
	   SET @TUnit1 = @BankHdrAcctUnit1
	   SET @TUnit2 = @BankHdrAcctUnit2
	   SET @TUnit3 = @BankHdrAcctUnit3
	   SET @TUnit4 = @BankHDrAcctUnit4

	END -- artran does not exist

	if @ArpmtType = 'D'
	BEGIN -- Draft
	   if SUBSTRING(@ArpmtRef, 1, 4) = 'ARPR'
	   BEGIN -- arpmt.ref = 'ARPR'

		  SET @ArpmtdRowPointer       = NULL
		  SET @ArpmtdDepositAcct      = NULL
		  SET @ArpmtdDepositAcctUnit1 = NULL
		  SET @ArpmtdDepositAcctUnit2 = NULL
		  SET @ArpmtdDepositAcctUnit3 = NULL
		  SET @ArpmtdDepositAcctUnit4 = NULL

		  SELECT TOP 1 -- first
			@ArpmtdRowPointer       = arpmtd.RowPointer
		  , @ArpmtdDepositAcct      = arpmtd.deposit_acct
		  , @ArpmtdDepositAcctUnit1 = arpmtd.deposit_acct_unit1
		  , @ArpmtdDepositAcctUnit2 = arpmtd.deposit_acct_unit2
		  , @ArpmtdDepositAcctUnit3 = arpmtd.deposit_acct_unit3
		  , @ArpmtdDepositAcctUnit4 = arpmtd.deposit_acct_unit4
		  FROM arpmtd
		  WHERE arpmtd.bank_code = @ArpmtBankCode and
				arpmtd.cust_num = @ArpmtCustNum and
				arpmtd.type = @ArpmtType and
				arpmtd.check_num = @ArpmtCheckNum and
				ISNULL(arpmtd.credit_memo_num, CHAR(1)) = ISNULL(@ArpmtCreditMemoNum, CHAR(1))
				and arpmtd.type = 'C'

		  if @ArpmtdRowPointer IS NOT NULL
		  BEGIN
			 SET @TAcct  = @ArpmtdDepositAcct
			 SET @TUnit1 = @ArpmtdDepositAcctUnit1
			 SET @TUnit2 = @ArpmtdDepositAcctUnit2
			 SET @TUnit3 = @ArpmtdDepositAcctUnit3
			 SET @TUnit4 = @ArpmtdDepositAcctUnit4
		  END
	   END -- arpmt.ref = 'ARPR'
	   ELSE
	   BEGIN -- arpmt.ref <> 'ARPR'

		  SET @CustomerRowPointer  = NULL
		  SET @CustomerEndUserType = NULL

		  SELECT TOP 1 -- first
			@CustomerRowPointer  = customer.RowPointer
		  , @CustomerEndUserType = customer.end_user_type
		  FROM customer WITH (READUNCOMMITTED)
		  WHERE customer.cust_num = @ArpmtCustNum

		  if @CustomerRowPointer IS NOT NULL and
			 @CustomerEndUserType <> '' and
			 @CustomerEndUserType IS NOT NULL
		  BEGIN -- Customer has an EndUserType

			 SET @EndtypeRowPointer               = NULL
			 SET @EndtypeDraftReceivableAcct      = NULL
			 SET @EndtypeDraftReceivableAcctUnit1 = NULL
			 SET @EndtypeDraftReceivableAcctUnit2 = NULL
			 SET @EndtypeDraftReceivableAcctUnit3 = NULL
			 SET @EndtypeDraftReceivableAcctUnit4 = NULL

			 SELECT TOP 1 -- first
			   @EndtypeRowPointer               = endtype.RowPointer
			 , @EndtypeDraftReceivableAcct      = endtype.draft_receivable_acct
			 , @EndtypeDraftReceivableAcctUnit1 = endtype.draft_receivable_acct_unit1
			 , @EndtypeDraftReceivableAcctUnit2 = endtype.draft_receivable_acct_unit2
			 , @EndtypeDraftReceivableAcctUnit3 = endtype.draft_receivable_acct_unit3
			 , @EndtypeDraftReceivableAcctUnit4 = endtype.draft_receivable_acct_unit4
			 FROM endtype WITH (READUNCOMMITTED)
			 WHERE endtype.end_user_type = @CustomerEndUserType

			 if @EndtypeRowPointer IS NOT NULL and
				@EndtypeDraftReceivableAcct IS NOT NULL
			 BEGIN
				SET @TAcct = @EndtypeDraftReceivableAcct
				SET @TUnit1 = @EndtypeDraftReceivableAcctUnit1
				SET @TUnit2 = @EndtypeDraftReceivableAcctUnit2
				SET @TUnit3 = @EndtypeDraftReceivableAcctUnit3
				SET @TUnit4 = @EndtypeDraftReceivableAcctUnit4
			 END
			 ELSE
			 BEGIN
				SET @TAcct  = @ArparmsDraftReceivableAcct
				SET @TUnit1 = @ArparmsDraftReceivableAcctUnit1
				SET @TUnit2 = @ArparmsDraftReceivableAcctUnit2
				SET @TUnit3 = @ArparmsDraftReceivableAcctUnit3
				SET @TUnit4 = @ArparmsDraftReceivableAcctUnit4
			 END
		  END -- Customer has an EndUserType
		  ELSE
		  BEGIN
			 SET @TAcct  = @ArparmsDraftReceivableAcct
			 SET @TUnit1 = @ArparmsDraftReceivableAcctUnit1
			 SET @TUnit2 = @ArparmsDraftReceivableAcctUnit2
			 SET @TUnit3 = @ArparmsDraftReceivableAcctUnit3
			 SET @TUnit4 = @ArparmsDraftReceivableAcctUnit4
		  END
	   END -- arpmt.ref <> 'ARPR'

	   if @TAcct IS NULL
	   BEGIN
		  SET @Infobar = NULL
		  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare'
		  , '@arparms.draft_receivable_acct'
		  , @ArparmsDraftReceivableAcct

		  RETURN @Severity
	   END

	END -- Draft


	IF @BankHdrCurrCode = @CustaddrCurrCode
	BEGIN

	   SET @TAmt = @PaymentCheckAmt
	   SET @TExchRate = @ArpmtExchRate
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
			 SET @TExchRate = @ArpmtExchRate / @EuroCurrencyEuroRate
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
				SET @TExchRate = @ArpmtExchRate / @EuroCurrencyEuroRate
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
				   SET @TExchRate = @ArpmtDomCheckAmt / @PaymentCheckAmt
				END
			 ELSE IF @PayRateIsDivisor = 0 AND ISNULL(@ArpmtDomCheckAmt, 0) <> 0
				BEGIN
				   SET @TExchRate = @PaymentCheckAmt / @ArpmtDomCheckAmt
				END
			 ELSE
				BEGIN
				   SET @TExchRate = 1
				   SET @TAmt = @ArpmtDomCheckAmt
				END
		  END
	   END
	END -- check euro

	EXEC @Severity = dbo.ChkUnitSp
	  @TAcct
	, @TUnit1
	, @TUnit2
	, @TUnit3
	, @TUnit4
	, @Infobar OUTPUT

	IF @Severity <> 0
	   RETURN @Severity

	-- DEBIT Cash - Asset OR Deposit - Liability
	IF @ArpmtType = 'D'
	   SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
	ELSE
	   SET @Ref = @ArpmtRef

	set @ControlSite = @ParmsSite

	EXEC dbo.NextControlNumberSp
	  @JournalId = 'AR Dist'
	, @TransDate = @ArpmtRecptDate
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

	EXEC @Severity = dbo.ZPV_JourpostSp
	  @id                 = 'AR Dist'
	, @trans_date         = @ArpmtRecptDate
	, @acct               = @TAcct
	, @acct_unit1         = @TUnit1
	, @acct_unit2         = @TUnit2
	, @acct_unit3         = @TUnit3
	, @acct_unit4         = @TUnit4
	, @amount             = @DomesticCheckAmt
	, @for_amount         = @TAmt
	, @bank_code          = @ArpmtBankCode
	, @exch_rate          = @TExchRate
	, @curr_code          = @BankHdrCurrCode
	, @check_num          = @ArpmtCheckNum
	, @check_date         = @ArpmtRecptDate
	, @ref                = @Ref
	, @vend_num           = @ArpmtCustNum
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

	-- Disable this branch because in Mexico Country Pack already do it.
	IF @ArpmtOffset = 0
	BEGIN
		IF dbo.IsAddonAvailable('SyteLineMX') = 0
		begin
			IF @ReApplication = 0
			and @ArpmtType in ('A', 'C', 'W')
			BEGIN
				IF @ArpmtCustNum IS NULL
				SET @ArpmtCustNum = 0

				EXEC @Severity = dbo.ZPV_CreateGlBankSp
					@PProcessID
				, @BankCode					= @ArpmtBankCode
				, @CheckDate				= @ArpmtRecptDate
				, @CheckNumber				= @ArpmtCheckNum
				, @CheckAmt					= @DomesticCheckAmt
				, @Type						= @ArpmtType
				, @RefType					= 'A/R'
				, @RefNum					= @ArpmtCustNum
				, @DomCheckAmt				= @DomesticCheckAmt
				, @Infobar					= @Infobar OUTPUT
				, @ZlaThirdPartyCheck		= @ArpmtZlaThirdPartyCheck
				, @ZlaThirdBankId			= @ArpmtZlaThirdBankId
				, @ZlaThirdDescription		= @ArpmtZlaThirdDescription
				, @ZlaThirdTaxNumReg		= @ArpmtZlaThirdTaxNumReg
				, @ZlaThirdCheckDate		= @ArpmtZlaThirdCheckDate
				, @ZlaArPayId				= @ArpmtZlaArPayId
				, @ZlaCreditCardExpDate		= @ArpmtZlaCreditCardExpDate 
				, @ZlaCreditCardPayments	= @ArpmtZlaCreditCardPayments
				, @GlbankRowPointer			= @GlbankRowPointer OUTPUT

				set @PCoPayRowPointer = null

				select @PCoPayRowPointer = pay.RowPointer
				from zpv_co_payments pay
				where	pay.bank_code		= @ArpmtBankCode
					and	pay.amount			= @DomesticCheckAmt
					--and pay.due_date		= @ArpmtDueDate
					--and pay.pay_date		= @ArpmtRecptDate
					and pay.ar_pay_id		= @ArpmtZlaArPayId
					and pay.check_num		= @ArpmtCheckNum
					
				if @PCoPayRowPointer is null
				begin
					select top 1 @PCoPayRowPointer = pay.RowPointer
					from zpv_ar_payments pay
					where	pay.cust_num		= @ArpmtCustNum
						and	pay.[apply]			= 1
						
				end
				
				
				if @PCoPayRowPointer is null
				begin
					set @Severity = 16
					Set @Infobar = 'Error al Crear DrawerTrans'
					RETURN @Severity
				end	

				EXEC @Severity =  dbo.ZPV_CreateDrawerTransSp
					@pDrawer			= @PDrawer,
					@pGlBankRowPointer	= @GlbankRowPointer,
					@pCoPayRowPointer	= @PCoPayRowPointer,
					@pAmount			= @DomesticCheckAmt,
					@pTransDate			= @ArpmtRecptDate,
					@pArPayId			= @PZlaArPayId,
					@pOrigen			= @POrigen,
					@Infobar			= @Infobar OUTPUT

			END

		end
	END -- ArpmtOffset
	
	
	DECLARE ArpmtdCrs CURSOR LOCAL STATIC FOR
	SELECT
	  arpmtd.bank_code
	, arpmtd.cust_num
	, arpmtd.type
	, arpmtd.credit_memo_num
	, arpmtd.check_num
	, arpmtd.inv_num
	, arpmtd.site
	, arpmtd.exch_rate
	, arpmtd.apply_cust_num
	, arpmtd.dom_disc_amt
	, arpmtd.for_disc_amt
	, arpmtd.dom_allow_amt
	, arpmtd.for_allow_amt
	, arpmtd.dom_amt_applied
	, arpmtd.for_amt_applied
	, arpmtd.co_num
	, arpmtd.do_num
	, arpmtd.disc_acct
	, arpmtd.disc_acct_unit1
	, arpmtd.disc_acct_unit2
	, arpmtd.disc_acct_unit3
	, arpmtd.disc_acct_unit4
	, arpmtd.allow_acct
	, arpmtd.allow_acct_unit1
	, arpmtd.allow_acct_unit2
	, arpmtd.allow_acct_unit3
	, arpmtd.allow_acct_unit4
	, arpmtd.deposit_acct
	, arpmtd.deposit_acct_unit1
	, arpmtd.deposit_acct_unit2
	, arpmtd.deposit_acct_unit3
	, arpmtd.deposit_acct_unit4
	, arpmtd.RowPointer
	, arpmtd.for_tax_1
	, arpmtd.for_tax_2
	, arpmtd.dom_tax_1
	, arpmtd.dom_tax_2
	, arpmtd.shipment_id
	, arpmtd.zla_for_curr_code
	, arpmtd.zla_for_exch_rate
	, arpmtd.zla_for_allow_amt
	, arpmtd.zla_for_amt_applied
	, arpmtd.zla_for_disc_amt
	, arpmtd.zla_for_non_ar_amt
	FROM arpmtd
	WHERE arpmtd.bank_code = @ArpmtBankCode and
		  arpmtd.cust_num = @ArpmtCustNum and
		  arpmtd.type = @ArpmtType and
		  arpmtd.check_num = @ArpmtCheckNum 

	OPEN ArpmtdCrs
	WHILE @Severity = 0
	BEGIN
	   FETCH ArpmtdCrs INTO
		 @ArpmtdBankCode
	   , @ArpmtdCustNum
	   , @ArpmtdType
	   , @ArpmtdCreditMemoNum
	   , @ArpmtdCheckNum
	   , @ArpmtdInvNum
	   , @ArpmtdSite
	   , @ArpmtdExchRate
	   , @ArpmtdApplyCustNum
	   , @ArpmtdDomDiscAmt
	   , @ArpmtdForDiscAmt
	   , @ArpmtdDomAllowAmt
	   , @ArpmtdForAllowAmt
	   , @ArpmtdDomAmtApplied
	   , @ArpmtdForAmtApplied
	   , @ArpmtdCoNum
	   , @ArpmtdDoNum
	   , @ArpmtdDiscAcct
	   , @ArpmtdDiscAcctUnit1
	   , @ArpmtdDiscAcctUnit2
	   , @ArpmtdDiscAcctUnit3
	   , @ArpmtdDiscAcctUnit4
	   , @ArpmtdAllowAcct
	   , @ArpmtdAllowAcctUnit1
	   , @ArpmtdAllowAcctUnit2
	   , @ArpmtdAllowAcctUnit3
	   , @ArpmtdAllowAcctUnit4
	   , @ArpmtdDepositAcct
	   , @ArpmtdDepositAcctUnit1
	   , @ArpmtdDepositAcctUnit2
	   , @ArpmtdDepositAcctUnit3
	   , @ArpmtdDepositAcctUnit4
	   , @ArpmtdRowPointer
	   , @ArpmtdForTaxAmt1
	   , @ArpmtdForTaxAmt2
	   , @ArpmtdDomTaxAmt1
	   , @ArpmtdDomTaxAmt2
	   , @ArpmtdShipmentId
	   , @ArpmtdZlaForCurrCode
	   , @ArpmtdZlaForExchRate
	   , @ArpmtdZlaForAllowAmt
	   , @ArpmtdZlaForAmtApplied
	   , @ArpmtdZlaForDiscAmt	
	   , @ArpmtdZlaForNonArAmt	

	   IF @@FETCH_STATUS = -1
		   BREAK

	   SET @ExchangeRate = @ArpmtdExchRate
	   SET @AutoCr = 0
	
	   IF (dbo.IsAddonAvailable('SyteLineFSP') = 1 OR dbo.IsAddonAvailable('SyteLineFSPM') = 1 
		  OR dbo.IsAddonAvailable('SyteLineFSP_MS') = 1 OR dbo.IsAddonAvailable('SyteLineFSPM_MS') = 1)
	   BEGIN
		  DECLARE @EXTSSSFS_Spname Sysname
		  SET @EXTSSSFS_Spname = 'dbo.EXTSSSFSARPaymentPostingSp'

		  EXEC @Severity = @EXTSSSFS_Spname
						   @ParmsSite
						 , @TOpenType
						 , @TBankCode
						 , @TOpenDisc
						 , @ExchangeRate
						 , @TIssueDate
						 , @TInvSeq
						 , @CurrParmsCurrCode
						 , @CorpSiteName
						 , @ArpmtRowPointer
						 , @ArpmtCustNum
						 , @ArpmtBankCode
						 , @ArpmtType
						 , @ArpmtCreditMemoNum
						 , @ArpmtCheckNum
						 , @ArpmtRecptDate
						 , @ArpmtDueDate
						 , @ArpmtRef
						 , @ArpmtNoteExistsFlag
						 , @ArpmtDescription
						 , @ArpmtTransferCash
						 , @ArpmtdRowPointer
						 , @TAcct
						 , @TUnit1
						 , @TUnit2
						 , @TUnit3
						 , @TUnit4
						 , @EXTSSSFSSkipDist OUTPUT
						 , @Infobar OUTPUT
						 , @ControlPrefix
						 , @ControlSite
						 , @ControlYear
						 , @ControlPeriod
						 , @ControlNumber
		  IF @Severity > 1
			 RETURN @Severity
	   END
	   ELSE
	   BEGIN
		  SET @EXTSSSFSSkipDist = 0
	   END
  
	   IF @EXTSSSFSSkipDist = 0
	   BEGIN
		  SET @TIssueDate121Str = CONVERT(NVARCHAR(100), @TIssueDate, 121)
		  SET @ArpmtRecptDate121Str = CONVERT(NVARCHAR(100), @ArpmtRecptDate, 121)
		  SET @ArpmtDueDate121Str = CONVERT(NVARCHAR(100), @ArpmtDueDate, 121)
          
		  EXEC @Severity = dbo.ZPV_ARPaymentDistPostingSp
			@CorpSite                 = @ParmsSite                   
			, @ReApplyType            = @TOpenType                   
			, @ReApplyBankCode        = @TBankCode                   
			, @ReApplyDisc            = @TOpenDisc                   
			, @WireExchangeRate       = @ExchangeRate                
			, @TIssueDate             = @TIssueDate            
			, @TInvSeq                = @TInvSeq                     
			, @CorpSiteCurrCode       = @CurrparmsCurrCode           
			, @CorpSiteName           = @CorpSiteName                
			, @ArpmtRowPointer        = @ArpmtRowPointer             
			, @ArpmtCustNum           = @ArpmtCustNum                
			, @ArpmtBankCode          = @ArpmtBankCode               
			, @ArpmtType              = @ArpmtType                   
			, @ArpmtCreditMemoNum     = @ArpmtCreditMemoNum          
			, @ArpmtCheckNum          = @ArpmtCheckNum               
			, @ArpmtRecptDate         = @ArpmtRecptDate        
			, @ArpmtDueDate           = @ArpmtDueDate          
			, @ArpmtRef               = @ArpmtRef                    
			, @ArpmtNoteExistsFlag    = @ArpmtNoteExistsFlag         
			, @ArpmtDescription       = @ArpmtDescription            
			, @ArpmtTransferCash      = @ArpmtTransferCash           
			, @ArpmtdInvNum           = @ArpmtdInvNum                
			, @ArpmtdSite             = @ArpmtdSite                  
			, @ArpmtdApplyCustNum     = @ArpmtdApplyCustNum          
			, @ArpmtdExchRate         = @ArpmtdExchRate              
			, @ArpmtdDomDiscAmt       = @ArpmtdDomDiscAmt            
			, @ArpmtdForDiscAmt       = @ArpmtdForDiscAmt            
			, @ArpmtdDomAllowAmt      = @ArpmtdDomAllowAmt           
			, @ArpmtdForAllowAmt      = @ArpmtdForAllowAmt           
			, @ArpmtdDomAmtApplied    = @ArpmtdDomAmtApplied         
			, @ArpmtdForAmtApplied    = @ArpmtdForAmtApplied         
			, @ArpmtdCoNum            = @ArpmtdCoNum                 
			, @ArpmtdDoNum            = @ArpmtdDoNum                 
			, @ArpmtdDiscAcct         = @ArpmtdDiscAcct              
			, @ArpmtdDiscAcctUnit1    = @ArpmtdDiscAcctUnit1         
			, @ArpmtdDiscAcctUnit2    = @ArpmtdDiscAcctUnit2         
			, @ArpmtdDiscAcctUnit3    = @ArpmtdDiscAcctUnit3         
			, @ArpmtdDiscAcctUnit4    = @ArpmtdDiscAcctUnit4         
			, @ArpmtdAllowAcct        = @ArpmtdAllowAcct             
			, @ArpmtdAllowAcctUnit1   = @ArpmtdAllowAcctUnit1        
			, @ArpmtdAllowAcctUnit2   = @ArpmtdAllowAcctUnit2        
			, @ArpmtdAllowAcctUnit3   = @ArpmtdAllowAcctUnit3        
			, @ArpmtdAllowAcctUnit4   = @ArpmtdAllowAcctUnit4        
			, @ArpmtdDepositAcct      = @ArpmtdDepositAcct           
			, @ArpmtdDepositAcctUnit1 = @ArpmtdDepositAcctUnit1      
			, @ArpmtdDepositAcctUnit2 = @ArpmtdDepositAcctUnit2      
			, @ArpmtdDepositAcctUnit3 = @ArpmtdDepositAcctUnit3      
			, @ArpmtdDepositAcctUnit4 = @ArpmtdDepositAcctUnit4      
			, @CorpCustaddrCurrCode   = @CustaddrCurrCode            
			, @CorpCustaddrCorpCred   = @CustaddrCorpCred            
			, @CorpCustaddrCorpCust   = @CustaddrCorpCust            
			, @UpdatePrepaidAmt       = @UpdatePrepaidAmt      
			, @SubKey				  = @SubKey      
			, @ControlPrefix          = @ControlPrefix               
			, @ControlSite            = @ControlSite                 
			, @ControlYear            = @ControlYear                 
			, @ControlPeriod          = @ControlPeriod               
			, @ControlNumber          = @ControlNumber               
			, @ArpmtdForTaxAmt1       = @ArpmtdForTaxAmt1            
			, @ArpmtdForTaxAmt2       = @ArpmtdForTaxAmt2            
			, @ArpmtdDomTaxAmt1       = @ArpmtdDomTaxAmt1            
			, @ArpmtdDomTaxAmt2       = @ArpmtdDomTaxAmt2            
			, @ArpmtdFsSroDeposit     = 0    --SSS FSP               
			, @DepositDebitAcct       = NULL --SSS FSP               
			, @DepositDebitUnit1      = NULL --SSS FSP               
			, @DepositDebitUnit2      = NULL --SSS FSP               
			, @DepositDebitUnit3      = NULL --SSS FSP               
			, @DepositDebitUnit4      = NULL --SSS FSP               
			, @ArpmtdShipmentId       = @ArpmtdShipmentId            
			, @TCoNum                 = @TCoNum                      
			, @TRma                   = @TRma       
			, @ArpmtdZlaForCurrCode   = @ArpmtdZlaForCurrCode
			, @ArpmtdZlaForExchRate	  = @ArpmtdZlaForExchRate	
			, @ArpmtdZlaForAllowAmt	  = @ArpmtdZlaForAllowAmt	
			, @ArpmtdZlaForAmtApplied = @ArpmtdZlaForAmtApplied
			, @ArpmtdZlaForDiscAmt	  = @ArpmtdZlaForDiscAmt	
			, @ArpmtdZlaForNonArAmt	  = @ArpmtdZlaForNonArAmt
			, @ArpmtZlaArPayId		  = @ArpmtZlaArPayId	
			, @Infobar                = @Infobar OUTPUT 
	  
		  IF @Severity <> 0
			 RETURN @Severity
	   END

	   SET @PostAmount = 0
	   SET @SiteAmountPosted = 0
	   SET @PostAmount = CASE WHEN LTRIM(@ArpmtdInvNum) = '-2' THEN
										 (@PostAmount - @ArpmtdDomDiscAmt - @ArpmtdDomAllowAmt)
									ELSE (@PostAmount - @ArpmtdDomAmtApplied)
						 END

	   IF @BankHdrCurrCode <> @CurrparmsCurrCode AND
			  @BankHdrCurrCode <> @CustaddrCurrCode
	   BEGIN
		  SET @SiteAmountPosted = CASE WHEN @DomRateIsDivisor = 0 THEN
										  ROUND(@PostAmount * @TExchRate, @PaymentCurrencyPlaces)
									 WHEN ISNULL(@TExchRate, 0) <> 0 THEN
										  ROUND(@PostAmount / @TExchRate, @PaymentCurrencyPlaces)
									 ELSE  0 END
		  SET @ExchangeRate = 1 / @TExchRate
	   END
	   ELSE IF @BankHdrCurrCode = @CustaddrCurrCode
	   BEGIN
		  SET @SiteAmountPosted = CASE WHEN LTRIM(@ArpmtdInvNum) = '-2' THEN
								   (@SiteAmountPosted - @ArpmtdForDiscAmt - @ArpmtdForAllowAmt)
									 ELSE (@SiteAmountPosted - @ArpmtdForAmtApplied)
								END
	   END
	   ELSE
	   BEGIN
		   SET @ExchangeRate = 1
		   SET @SiteAmountPosted = @PostAmount
	   END

		  if (@SiteAmountPosted <> 0 and (@ArpmtdSite <> @ParmsSite))
		  BEGIN

			 SET @SitenetRowPointer = NULL

			 SELECT
			   @SitenetRowPointer = sitenet.RowPointer
			 , @SitenetArLiabAcct = sitenet.ar_liab_acct
			 , @SitenetArLiabAcctUnit1 = sitenet.ar_liab_acct_unit1
			 , @SitenetArLiabAcctUnit2 = sitenet.ar_liab_acct_unit2
			 , @SitenetArLiabAcctUnit3 = sitenet.ar_liab_acct_unit3
			 , @SitenetArLiabAcctUnit4 = sitenet.ar_liab_acct_unit4
			 FROM sitenet WITH (READUNCOMMITTED)
			 where sitenet.from_site = @ParmsSite and
				   sitenet.to_site = @ArpmtdSite

			 if @SitenetRowPointer IS NULL
			 BEGIN

				SET @Infobar = NULL
				SET @Infobar2 = NULL
				EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed2'
				, '@arpmtd'
				, '@arpmtd'
				, '@arpmtd.inv_num'
				, @ArpmtdInvNum
				, '@arpmtd.site'
				, @ArpmtdSite

				EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'E=NoExist2'
				, '@sitenet'
				, '@sitenet.from_site'
				, @ParmsSite
				, '@sitenet.to_site'
				, @ArpmtdSite

				SET @Infobar = @Infobar + '  ' + @Infobar2

				RETURN @Severity
			 END

			 /* "FROM" Site (symcorp):
			  * CREDIT Inter-Site Liability OR Cash - Asset */

			 if @ReApplication = 1 and @ArpmtTransferCash = 1
			 BEGIN
				SET @TBankHdrRowPointer = NULL

				SELECT
				  @TBankHdrRowPointer = bank_hdr.RowPointer
				, @TBankHdrAcct       = bank_hdr.acct
				, @TBankHdrAcctUnit1  = bank_hdr.acct_unit1
				, @TBankHdrAcctUnit2  = bank_hdr.acct_unit2
				, @TBankHdrAcctUnit3  = bank_hdr.acct_unit3
				, @TBankHdrAcctUnit4  = bank_hdr.acct_unit4
				FROM bank_hdr WITH (READUNCOMMITTED)
				where bank_hdr.bank_code = @TBankCode

				if @TBankHdrRowPointer IS NULL or @TBankHdrAcct IS NULL
				BEGIN
				   SET @Infobar = NULL
				   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
				   , '@bank_hdr'
				   , '@bank_hdr.bank_code'
				   , @TBankCode

				   RETURN @Severity
				END

				SET @ChartRowPointer = NULL

				SELECT
				 @ChartRowPointer = chart.RowPointer
				FROM chart WITH (READUNCOMMITTED)
				where chart.acct = @TBankHdrAcct

				if @ChartRowPointer IS NULL or @TBankHdrAcct IS NULL
				BEGIN
				   SET @Infobar = NULL

				   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistFor2'
				   , '@chart'
				   , '@bank_hdr'
				   , '@bank_hdr.acct'
				   , @TBankHdrAcct
				   , '@bank_hdr.bank_code'
				   , @TBankCode

				   RETURN @Severity
				END

				SET @TAcct  = @TBankHdrAcct
				SET @TUnit1 = @TBankHdrAcctUnit1
				SET @TUnit2 = @TBankHdrAcctUnit2
				SET @TUnit3 = @TBankHdrAcctUnit3
				SET @TUnit4 = @TBankHdrAcctUnit4

			 END -- Re-app and Transfer Cash
			 ELSE
			 BEGIN
				SET @ChartRowPointer = NULL

				SELECT
				 @ChartRowPointer = chart.RowPointer
				FROM chart WITH (READUNCOMMITTED)
				where chart.acct = @SitenetArLiabAcct

				if @ChartRowPointer IS NULL or @SitenetArLiabAcct IS NULL
				BEGIN
				   SET @Infobar = NULL

				   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistFor1'
				   , '@chart'
				   , '@sitenet'
				   , '@sitenet.ar_liab_acct'
				   , @SitenetArLiabAcct

				   RETURN @Severity
				END

				SET @TAcct  = @SitenetArLiabAcct
				SET @TUnit1 = @SitenetArLiabAcctUnit1
				SET @TUnit2 = @SitenetArLiabAcctUnit2
				SET @TUnit3 = @SitenetArLiabAcctUnit3
				SET @TUnit4 = @SitenetArLiabAcctUnit4
			 END

			 EXEC @Severity = dbo.ChkAcctSp
			   @TAcct
			 , @ArpmtRecptDate
			 , @Infobar OUTPUT

			 IF @Severity <> 0
				RETURN @Severity

			 EXEC @Severity = dbo.ChkUnitSp
			   @TAcct
			 , @TUnit1
			 , @TUnit2
			 , @TUnit3
			 , @TUnit4
			 , @Infobar OUTPUT

			 IF @Severity <> 0
				RETURN @Severity

			 SET @RefType = substring(@ArpmtRef, 3, 1)

			 EXEC @Severity = dbo.JourpostSp
			   @id                 = @TId
			 , @trans_date         = @ArpmtRecptDate
			 , @acct               = @TAcct
			 , @acct_unit1         = @TUnit1
			 , @acct_unit2         = @TUnit2
			 , @acct_unit3         = @TUnit3
			 , @acct_unit4         = @TUnit4
			 , @amount             = @PostAmount
			 , @for_amount         = @SiteAmountPosted
			 , @exch_rate          = @ExchangeRate
			 , @check_num          = @ArpmtCheckNum
			 , @check_date         = @ArpmtRecptDate
			 , @ref                = @ArpmtRef
			 , @vend_num           = @ArpmtdApplyCustNum
			 , @ref_type           = @RefType
			 , @voucher            = @ArpmtdInvNum
			 , @bank_code          = @ArpmtBankCode
			 , @curr_code          = @CurrparmsCurrCode
			 , @ControlPrefix = @ControlPrefix
			 , @ControlSite = @ControlSite
			 , @ControlYear = @ControlYear
			 , @ControlPeriod = @ControlPeriod
			 , @ControlNumber = @ControlNumber
			 , @Infobar            = @Infobar      OUTPUT

			 if @Severity <> 0
				RETURN @Severity

		  END -- @SiteAmountPosted <> 0

		  IF OBJECT_ID('dbo.SSSFSContPaidSp') IS NOT NULL
		  BEGIN
			 DECLARE @EXTSSSFS_Spname2 Sysname
			 SET @EXTSSSFS_Spname2 = 'dbo.SSSFSContPaidSp'
			 EXEC @Severity = @EXTSSSFS_Spname2
							  @ArpmtdInvNum
							, @ArpmtRecptDate
							, @Infobar OUTPUT
			IF @Severity <> 0
			RETURN @Severity
		  END

	   SET @DomAmountPostedTemp = CASE WHEN LTRIM(@ArpmtdInvNum) = '-2' THEN
									   (@ArpmtdDomDiscAmt + @ArpmtdDomAllowAmt)
								  ELSE @ArpmtdDomAmtApplied
							 END

	   SET @TotCr = @TotCr + @DomAmountPostedTemp

	   SET @AmountPosted = @AmountPosted - @DomAmountPostedTemp


	   SET @ForAmountPostedTemp = CASE WHEN LTRIM(@ArpmtdInvNum) = '-2' THEN
									   (@ArpmtdForDiscAmt + @ArpmtdForAllowAmt)
								  ELSE @ArpmtdForAmtApplied
							 END
	   SET @ForAmountPosted = @ForAmountPosted - @ForAmountPostedTemp

	   IF @BankHdrCurrCode <> @CurrparmsCurrCode
	   AND @BankHdrCurrCode <> @CustaddrCurrCode
		  BEGIN
			  SET @PayAmountPostedTemp = CASE
										  WHEN @PayRateIsDivisor = 0 THEN
										  ROUND(@DomAmountPostedTemp * @TExchRate, @PaymentCurrencyPlaces)
										  WHEN ISNULL(@TExchRate, 0) <> 0 THEN
											   ROUND(@DomAmountPostedTemp / @TExchRate, @PaymentCurrencyPlaces)
										  ELSE
										   0
										END
		  END
		ELSE
		  IF @BankHdrCurrCode = @CustaddrCurrCode
			BEGIN
				SET @PayAmountPostedTemp = @ForAmountPostedTemp
			END
		  ELSE
			BEGIN
				SET @PayAmountPostedTemp = @DomAmountPostedTemp
			END


   
	   SET @WSiteWSiteCode  = NULL

	   SELECT TOP 1 -- first
		 @WSiteWSiteCode  = w_site_code
	   FROM @WSite
	   where w_site_code = @ArpmtdSite

	   if @@rowcount = 0
	   BEGIN -- Add to site list
		  SELECT
			@WSiteWSiteCode  = @ArpmtdSite

		  INSERT INTO @WSite (
			w_site_code
		  ) VALUES (
			@WSiteWSiteCode
		  )
	   END -- Add to site list

	   INSERT INTO @arpmtd_to_delete (ArpmtdRowPointer)
		 VALUES (@ArpmtdRowPointer)

	END
	CLOSE      ArpmtdCrs
	DEALLOCATE ArpmtdCrs

	-- Define session variable "ARPaymentPostingSp.SkipDelOffsetPmt" to be used by arpmtDel.trg 
	EXEC @Severity = dbo.DefineVariableSp 'ARPaymentPostingSp.SkipDelOffsetPmt', '1', @Infobar OUTPUT 
	IF @Severity <> 0 
	   RETURN @Severity 
	
	DELETE arpmtd from arpmtd inner join @arpmtd_to_delete as tmp on 
	tmp.ArpmtdRowPointer = arpmtd.RowPointer 
 
	-- Undefine session variable 
	EXEC @Severity = dbo.UndefineVariableSp 'ARPaymentPostingSp.SkipDelOffsetPmt', @Infobar OUTPUT

	IF @AutoCr = 0
	BEGIN -- @AutoCr = 0
	   if @TotCr <> @ArpmtDomCheckAmt
	   BEGIN
		  SET @Infobar = NULL
		  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=MustCompare='
		  , '@arpmt.dom_check_amt'
		  , @TotCr

		  RETURN @Severity
	   END

	   if @AmountPosted <> 0.0
	   BEGIN -- Post currency gain/loss due to roundoff

		  SET @GainLossAmount = @AmountPosted * -1

		  EXEC @Severity = dbo.GlGainLossSp
			@PAmount     = @GainLossAmount
		  , @PCurrCode   = @BankHdrCurrCode
		  , @PRef        = @ArpmtRef
		  , @PId         = @TId
		  , @PTransDate  = @ArpmtRecptDate
		  , @PVendNum    = @ArpmtCustNum
		  , @PCheckNum   = @ArpmtCheckNum
		  , @PCheckDate  = @ArpmtRecptDate
		  , @ControlPrefix = @ControlPrefix
		  , @ControlSite = @ControlSite
		  , @ControlYear = @ControlYear
		  , @ControlPeriod = @ControlPeriod
		  , @ControlNumber = @ControlNumber
		  , @Infobar     = @Infobar       OUTPUT

		  if @Severity <> 0
			 RETURN @Severity
	   END -- Post currency gain/loss due to roundoff

	END -- @AutoCr = 0
	ELSE
	BEGIN -- Auto-Distribute

	   if @CustomerEndUserType <> '' and @CustomerEndUserType IS NOT NULL
	   BEGIN -- Customer has end_user_type

		  SET @EndtypeRowPointer  = NULL
		  SET @EndtypeArAcct      = NULL
		  SET @EndtypeArAcctUnit1 = NULL
		  SET @EndtypeArAcctUnit2 = NULL
		  SET @EndtypeArAcctUnit3 = NULL
		  SET @EndtypeArAcctUnit4 = NULL

		  SELECT
			@EndtypeRowPointer  = endtype.RowPointer
		  , @EndtypeArAcct      = endtype.ar_acct
		  , @EndtypeArAcctUnit1 = endtype.ar_acct_unit1
		  , @EndtypeArAcctUnit2 = endtype.ar_acct_unit2
		  , @EndtypeArAcctUnit3 = endtype.ar_acct_unit3
		  , @EndtypeArAcctUnit4 = endtype.ar_acct_unit4
		  FROM endtype WITH (READUNCOMMITTED)
		  WHERE endtype.end_user_type = @CustomerEndUserType

		  if @EndtypeRowPointer IS NOT NULL and @EndtypeArAcct IS NOT NULL
		  BEGIN
			 SET @TEndArAcct = @EndtypeArAcct
			 SET @TEndArAcctUnit1 = @EndtypeArAcctUnit1
			 SET @TEndArAcctUnit2 = @EndtypeArAcctUnit2
			 SET @TEndArAcctUnit3 = @EndtypeArAcctUnit3
			 SET @TEndArAcctUnit4 = @EndtypeArAcctUnit4
		  END
	   END -- Customer has end_user_type

	   if @CustaddrBalMethod = 'O'
	   BEGIN -- Open Balance Customer

		  SET @TBalDesc = '@:BalMethod:' + @CustaddrBalMethod
		  SET @Infobar = NULL
		  SET @Infobar2 = NULL
		  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistFor0'
		  , '@arpmtd'
		  , '@arpmt'

		  EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'I=IsCompare1'
		  , '@custaddr.bal_method'
		  , @TBalDesc
		  , '@customer'
		  , '@custaddr.cust_num'
		  , @ArpmtCustNum

		  SET @Infobar = @Infobar + '  ' + @Infobar2

		  RETURN @Severity
	   END -- Open Balance Customer

	   if @TOpenType IS NOT NULL
	   BEGIN
		  SET @Infobar = NULL
		  SET @Infobar2 = NULL
		  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistFor0'
		  , '@arpmtd'
		  , '@arpmt'

		  EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'I=CmdPerform'
		  , '@%pay-reap'

		  SET @Infobar = @Infobar + '  ' + @Infobar2

		  RETURN @Severity
	   END

	   SET @TAcct = CASE when @ArtranRowPointer IS NOT NULL THEN @ArtranAcct ELSE @TEndArAcct END
	   SET @TUnit1 = CASE when @ArtranRowPointer IS NOT NULL THEN @ArtranAcctUnit1 ELSE @TEndArAcctUnit1 END
	   SET @TUnit2 = CASE when @ArtranRowPointer IS NOT NULL THEN @ArtranAcctUnit2 ELSE @TEndArAcctUnit2 END
	   SET @TUnit3 = CASE when @ArtranRowPointer IS NOT NULL THEN @ArtranAcctUnit3 ELSE @TEndArAcctUnit3 END
	   SET @TUnit4 = CASE when @ArtranRowPointer IS NOT NULL THEN @ArtranAcctUnit4 ELSE @TEndArAcctUnit4 END

	   EXEC @Severity = dbo.ChkUnitSp
		 @TAcct
	   , @TUnit1
	   , @TUnit2
	   , @TUnit3
	   , @TUnit4
	   , @Infobar OUTPUT

	   IF @Severity <> 0
		  RETURN @Severity

	   IF @ArpmtType = 'D'
		  SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
	   ELSE
		  SET @Ref = @ArpmtRef

	   SET @PostAmount = @DomesticCheckAmt * -1

	   EXEC @Severity = dbo.JourpostSp
		 @id                 = @TId
	   , @trans_date         = @ArpmtRecptDate
	   , @acct               = @TAcct
	   , @acct_unit1         = @TUnit1
	   , @acct_unit2         = @TUnit2
	   , @acct_unit3         = @TUnit3
	   , @acct_unit4         = @TUnit4
	   , @amount             = @PostAmount
	   , @curr_code = @CurrparmsCurrCode
	   , @bank_code          = @ArpmtBankCode
	   , @check_num          = @ArpmtCheckNum
	   , @check_date         = @ArpmtRecptDate
	   , @ref                = @Ref
	   , @vend_num           = @ArpmtCustNum
	   , @ref_type           = 'P'
	   , @ControlPrefix = @ControlPrefix
	   , @ControlSite = @ControlSite
	   , @ControlYear = @ControlYear
	   , @ControlPeriod = @ControlPeriod
	   , @ControlNumber = @ControlNumber
	   , @last_seq           = @EndTrans     OUTPUT
	   , @Infobar            = @Infobar      OUTPUT

	   if @Severity <> 0
		  RETURN @Severity

	   IF @ArpmtNoteExistsFlag > 0
	   BEGIN -- copy notes
		  SET @JournalRowPointer = NULL
		  SELECT
			@JournalRowPointer = journal.RowPointer
		  FROM tmp_mass_journal as journal
		  WHERE journal.id = @TId and
				journal.seq = @EndTrans
		  and journal.ProcessId = @BufferJournal

		  if @JournalRowPointer IS NOT NULL
		  BEGIN
			 EXEC @Severity = dbo.CopyNotesSp
			  'arpmt'
			 , @ArpmtRowPointer
			 , 'journal'
			 , @JournalRowPointer

			 if @Severity <> 0
				RETURN @Severity

			 UPDATE tmp_mass_journal
			 SET NoteExistsFlag = 1
			 FROM tmp_mass_journal as journal
			 WHERE journal.id = @TId and
				journal.seq = @EndTrans
			 and journal.ProcessId = @BufferJournal
		  END
	   END -- copy notes

	   if @ArpmtType <> 'D'
	   BEGIN -- Not a Draft

		  UPDATE #customer
			 SET posted_bal = posted_bal - @ForeignCheckAmt
		  WHERE cust_num = @ArpmtCustNum

		  if @@rowcount = 0
			 insert into #customer (cust_num, posted_bal)
			 values(@ArpmtCustNum, - @ForeignCheckAmt)

		  if @CustaddrCorpCred = 1
		  BEGIN
			 SET @CorpCustomerRowPointer = NULL

			 SELECT
			   @CorpCustomerRowPointer = customer.RowPointer
			 FROM customer WITH (READUNCOMMITTED)
			 WHERE customer.cust_num = @CustaddrCorpCust

			 if @CorpCustomerRowPointer IS NULL
			 BEGIN
				EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=WillNotSet1'
				, '@customer.posted_bal'
				, '@customer'
				, '@customer.cust_num'
				, @CustaddrCorpCust

				RETURN @Severity
			 END

			 UPDATE #customer
				SET posted_bal = posted_bal - @ForeignCheckAmt
			 WHERE cust_num = @CustaddrCorpCust

			 if @@rowcount = 0
				insert into #customer (cust_num, posted_bal)
				values(@CustaddrCorpCust, - @ForeignCheckAmt)
		  END -- CorpCred

	   END -- Not a Draft

	   SET @ArtranRowPointer = NULL
	   SET @ArtranCustNum    = NULL
	   SET @ArtranInvNum     = '0'
	   SET @ArtranInvSeq     = 0

	   SELECT
		 @ArtranRowPointer = artran.RowPointer
	   , @ArtranCustNum    = artran.cust_num
	   , @ArtranInvNum     = artran.inv_num
	   , @ArtranInvSeq     = artran.inv_seq
	   FROM artran
	   WHERE artran.cust_num = @ArpmtCustNum
		 and artran.inv_num = '0'
		 and artran.inv_seq = @ArpmtCheckNum
		 and artran.check_seq = 0

	   IF @ArtranRowPointer IS NOT NULL AND @ArpmtOffset = 0
	   BEGIN
		  SET @Infobar = NULL
		  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=Exist3'
		  , '@artran'
		  , '@artran.cust_num'
		  , @ArtranCustNum
		  , '@artran.inv_num'
		  , @ArtranInvNum
		  , '@artran.inv_seq'
		  , @ArtranInvSeq

		  RETURN @Severity
	   END

	   SELECT
		 @ArtranRowPointer = NEWID ()
	   , @ArtranCustNum = @ArpmtCustNum
	   , @ArtranInvNum = '0'
	   , @ArtranInvSeq = @ArpmtCheckNum
	   , @ArtranType = 'P'
	   , @ArtranCheckSeq = 0
	   , @ArtranInvDate = @ArpmtRecptDate
	   , @ArtranAcct    = @TEndArAcct
	   , @ArtranAcctUnit1 = @TEndArAcctUnit1
	   , @ArtranAcctUnit2 = @TEndArAcctUnit2
	   , @ArtranAcctUnit3 = @TEndArAcctUnit3
	   , @ArtranAcctUnit4 = @TEndArAcctUnit4
	   , @ArtranBankCode = @ArpmtBankCode
	   , @ArtranDescription = @ArpmtDescription
	   , @ArtranExchRate = @ExchangeRate
	   , @ArtranAmount = @ForeignCheckAmt
	   , @ArtranCorpCust = @CustaddrCorpCust
	   , @ArtranPayType = @ArpmtType
	   , @ArtranDueDate = @ArpmtDueDate
	   , @ArtranRef = @ArpmtRef

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
	   ) VALUES (
		 @ArtranRowPointer
	   , @ArtranCustNum
	   , @ArtranInvNum
	   , @ArtranInvSeq
	   , @ArtranCheckSeq
	   , @ArtranType
	   , @ArtranInvDate
	   , @ArtranAcct
	   , @ArtranAcctUnit1
	   , @ArtranAcctUnit2
	   , @ArtranAcctUnit3
	   , @ArtranAcctUnit4
	   , @ArtranBankCode
	   , @ArtranDescription
	   , @ArtranExchRate
	   , @ArtranAmount
	   , @ArtranCorpCust
	   , @ArtranPayType
	   , @ArtranDueDate
	   , @ArtranRef
	   , '0'
	   )

	   IF @ArpmtNoteExistsFlag > 0
	   BEGIN -- copy notes
		  EXEC @Severity = dbo.CopyNotesSp
		   'arpmt'
		  , @ArpmtRowPointer
		  , 'artran'
		  , @ArtranRowPointer

		  if @Severity <> 0
			 RETURN @Severity

		  EXEC @Severity = dbo.CopyNotesSp
		   'arpmt'
		  , @ArpmtRowPointer
		  , 'artran_all'
		  , @ArtranRowPointer

		  if @Severity <> 0
			 RETURN @Severity
	   END -- copy notes

	   if @ArpmtType = 'A'
	   BEGIN -- Adjustment

		  SET @XArtranRowPointer = NULL
		  SET @XArtranCheckSeq   = NULL

		  SELECT TOP 1 -- last
			@XArtranRowPointer = artran.RowPointer
		  , @XArtranCheckSeq   = artran.check_seq
		  FROM artran
		  WHERE artran.cust_num = @ArpmtCustNum and
				artran.inv_seq =  @ArpmtCheckNum and
				artran.check_seq <> 0
		  ORDER BY cust_num, inv_num, inv_seq, check_seq DESC

		  UPDATE artran
			 SET check_seq = CASE WHEN @XArtranRowPointer IS NOT NULL then @XArtranCheckSeq + 1
								else 1 END
		  WHERE artran.RowPointer = @ArtranRowPointer
	   END -- Adjustment

	   if @ArpmtType = 'D'
	   BEGIN -- Draft
		  SET @CustdrftRowPointer = NULL

		  SELECT
			@CustdrftRowPointer = custdrft.RowPointer
		  FROM custdrft with (UPDLOCK)
		  WHERE custdrft.draft_num = @ArpmtCheckNum
		  and custdrft.stat != 'E'

		  if @CustdrftRowPointer IS NOT NULL
		  BEGIN
			 UPDATE custdrft
				SET stat = 'E'
			 WHERE custdrft.RowPointer = @CustdrftRowPointer
		  END
	   END -- Draft

	END -- Auto-Distribute

	update customer
	set posted_bal = customer.posted_bal + buf.posted_bal
	, disc_ytd = customer.disc_ytd + buf.disc_ytd
	from #customer as buf
	   inner join customer on
		  customer.cust_num = buf.cust_num
		  and customer.cust_seq = 0

	declare @ObCustNum CustNumType
	, @ObOrderBal AmtTotType
	declare ordbalCrs cursor local static for
	select cust_num
	, order_bal
	from #customer
	where order_bal != 0

	open ordbalCrs

	while 1 = 1
	begin
	   fetch ordbalCrs into
		 @ObCustNum
	   , @ObOrderBal
	   if @@fetch_status != 0
		  break
	   exec dbo.UpdObalSp
		 @CustNum = @ObCustNum
	   , @Adjust = @ObOrderBal
	end
	close ordbalCrs
	deallocate ordbalCrs

	DECLARE WSiteCrs CURSOR LOCAL STATIC FOR
	SELECT
	  w_site_code
	FROM @WSite

	OPEN WSiteCrs
	WHILE @Severity = 0
	BEGIN
	   FETCH WSiteCrs INTO
		 @WSiteWSiteCode
	   IF @@FETCH_STATUS = -1
		   BREAK

	   IF @WSiteWSiteCode = @ParmsSite
	   BEGIN
		  EXEC @Severity = dbo.ArpmbalSp
			@RowPointer  = @CustomerRowPointer
		  , @ReceiptDate = @ArpmtRecptDate
		  , @Infobar     = @Infobar OUTPUT

		  IF @Severity <> 0
			 RETURN @Severity
	   END
	   ELSE
	   BEGIN
		  SET @ArpmtRecptDate121Str = CONVERT(NVARCHAR(100), @ArpmtRecptDate, 121)
		  EXEC @Severity  = dbo.RemoteMethodCallSp
			@Site         = @WSiteWSiteCode
		  , @IdoName      = NULL
		  , @MethodName   = 'ArpmtpblSp'
		  , @Infobar      = @Infobar OUTPUT
		  , @Parm1Value   = @ArpmtCustNum
		  , @Parm2Value   = @ArpmtRecptDate121Str
		  , @Parm3Value   = @Infobar

		  IF @Severity <> 0
			 RETURN @Severity
	   END

	   DELETE @WSite
	   WHERE w_site_code = @WSiteWSiteCode

	END
	CLOSE      WSiteCrs
	DEALLOCATE WSiteCrs

	-- Define session variable "ARPaymentPostingSp.SkipCustdrft" to be used by arpmtDel.trg
	EXEC @Severity = dbo.DefineVariableSp 'ARPaymentPostingSp.SkipCustdrft', '1', @Infobar OUTPUT
	IF @Severity <> 0
	   RETURN @Severity
   
	EXEC @Severity = dbo.DefineVariableSp 'ARPaymentPostingSp.SkipDelOffsetPmt', '1', @Infobar OUTPUT
	IF @Severity <> 0
	   RETURN @Severity

	DELETE arpmt
	WHERE RowPointer = @ArpmtRowPointer

	-- Undefine session variable
	EXEC @Severity = dbo.UndefineVariableSp 'ARPaymentPostingSp.SkipCustdrft', @Infobar OUTPUT

	EXEC @Severity = dbo.UndefineVariableSp 'ARPaymentPostingSp.SkipDelOffsetPmt', @Infobar OUTPUT
	
END
RETURN @Severity

GO

