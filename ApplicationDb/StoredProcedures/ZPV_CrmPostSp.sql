/****** Object:  StoredProcedure [dbo].[ZPV_CrmPostSp]    Script Date: 16/01/2015 03:12:53 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CrmPostSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_CrmPostSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CrmPostSp]    Script Date: 16/01/2015 03:12:53 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* $Header: /ApplicationDB/Stored Procedures/CrmPostSp.sp 51    9/17/13 4:54a Bbai $  */
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
*   (c) COPYRIGHT 2008 INFOR.  ALL RIGHTS RESERVED.           *
*   THE WORD AND DESIGN MARKS SET FORTH HEREIN ARE            *
*   TRADEMARKS AND/OR REGISTERED TRADEMARKS OF INFOR          *
*   AND/OR ITS AFFILIATES AND SUBSIDIARIES. ALL RIGHTS        *
*   RESERVED.  ALL OTHER TRADEMARKS LISTED HEREIN ARE         *
*   THE PROPERTY OF THEIR RESPECTIVE OWNERS.                  *
*                                                             *
***************************************************************
*/


CREATE PROCEDURE [dbo].[ZPV_CrmPostSp] (
  @TNewInvoice          LongListType
, @TCrmDate             DateType
, @TTransDomCurr        ListYesNoType
, @BRmaNum              RmaNumType
, @ERmaNum              RmaNumType
, @BRmaLine             RmaLineType
, @ERmaLine             RmaLineType
, @BCustNum             CustNumType
, @ECustNum             CustNumType
, @BLastReturnDate      DateType
, @ELastReturnDate      DateType
, @BCrmNum              InvNumType  OUTPUT
, @ECrmNum              InvNumType  OUTPUT
, @BCrmDate             DateType    OUTPUT
, @ECrmDate             DateType    OUTPUT
, @PrintOrderNotes      ListYesNoType = 0
, @PrintRMANotes        ListYesNoType = 0
, @PrintShipToNotes     ListYesNoType = 0
, @PrintBillToNotes     ListYesNoType = 0
, @PrintInternalNotes   ListYesNoType = 0
, @PrintExternalNotes   ListYesNoType = 0
, @PrintRMALineNotes    ListYesNoType = 0
, @Infobar              InfobarType OUTPUT
, @ProcessId            RowPointerType OUTPUT
, @Invoice              ListYesNoType = NULL OUTPUT
, @ApplyToInvNum		InvNumType = NULL
, @CoCoNum				CoNumType = NULL
) AS

IF @BLastReturnDate IS NOT NULL
   EXEC dbo.ApplyDateOffsetSp @BLastReturnDate output,null, 0

IF @ELastReturnDate IS NOT NULL
   EXEC dbo.ApplyDateOffsetSp @ELastReturnDate output,null, 1

SET @ProcessId = NEWID()

DECLARE
  @Severity                 INT
, @BalAdj                   AmountType
, @DAmt                     AmountType
, @PrintFlag                FlagNyType
, @TSubTotal                AmountType
, @TAccRestTaxBasis         AmountType
, @TAccRestTax1             AmountType
, @TAccRestTax2             AmountType
, @TAdjPrice                GenericDecimalType
, @TArCredit                ReferenceType
, @TCrMemo                  LongListType
, @TDistSeq                 INT
, @TEndAr                   AcctType
, @TEndArUnit1              UnitCode1Type
, @TEndArUnit2              UnitCode2Type
, @TEndArUnit3              UnitCode3Type
, @TEndArUnit4              UnitCode4Type
, @TInvNum                  InvNumType
, @TInvCount                InvNumType
, @TmpBalAdj                AmountType
, @TOpen                    LongListType
, @TPrintInvNum             InvNumType
, @TRate                    ExchRateType
, @TSalesTax                AmountType
, @TSalesTax2               AmountType
, @TServCust                CustNumType
, @TTaxSeq                  GenericNoType
, @TTemp                    Int
, @TaxPromptForSystem1      ListYesNoType
, @TaxPromptForSystem2      ListYesNoType
, @Flag                     INT

DECLARE
  @ArinvRowPointer          RowPointerType
, @ArinvInvSeq              ArInvSeqType
, @ArinvCustNum             CustNumType
, @ArinvInvNum              InvNumType
, @ArinvType                ArinvTypeType
, @ArinvCoNum               CoNumType
, @ArinvInvDate             DateType
, @ArinvDueDate             DateType
, @ArinvTaxCode1            TaxCodeType
, @ArinvTaxCode2            TaxCodeType
, @ArinvTermsCode           TermsCodeType
, @ArinvAcct                AcctType
, @ArinvAcctUnit1           UnitCode1Type
, @ArinvAcctUnit2           UnitCode2Type
, @ArinvAcctUnit3           UnitCode3Type
, @ArinvAcctUnit4           UnitCode4Type
, @ArinvRef                 ReferenceType
, @ArinvDescription         DescriptionType
, @ArinvPostFromCo          ListYesNoType
, @ArinvExchRate            ExchRateType
, @ArinvUseExchRate         ListYesNoType
, @ArinvFixedRate           ListYesNoType
, @ArinvRma                 ListYesNoType
, @ArinvSalesTax            AmountType
, @ArinvSalesTax2           AmountType
, @ArinvMiscCharges         AmountType
, @ArinvFreight             AmountType
, @ArinvAmount              AmountType
, @ArparmsRowPointer        RowPointerType
, @ArparmsArAcct            AcctType
, @ArparmsArAcctUnit1       UnitCode1Type
, @ArparmsArAcctUnit2       UnitCode2Type
, @ArparmsArAcctUnit3       UnitCode3Type
, @ArparmsArAcctUnit4       UnitCode4Type
, @ArparmsMiscAcct          AcctType
, @ArparmsMiscAcctUnit1     UnitCode1Type
, @ArparmsMiscAcctUnit2     UnitCode2Type
, @ArparmsMiscAcctUnit3     UnitCode3Type
, @ArparmsMiscAcctUnit4     UnitCode4Type
, @ArparmsFreightAcct       AcctType
, @ArparmsFreightAcctUnit1  UnitCode1Type
, @ArparmsFreightAcctUnit2  UnitCode2Type
, @ArparmsFreightAcctUnit3  UnitCode3Type
, @ArparmsFreightAcctUnit4  UnitCode4Type
, @ArparmUsePrePrintedForms ListYesNoType
, @ArparmLinesPerInv        LinesPerDocType
, @ArparmLinesPerDM         LinesPerDocType
, @ArparmLinesPerCM         LinesPerDocType
, @BillToCustomerRowPointer RowPointerType
, @BillToCustomerTermsCode  TermsCodeType
, @CountryRowPointer        RowPointerType
, @CountryEcCode            EcCodeType
, @CurrencyRowPointer       RowPointerType
, @CurrencyCurrCode         CurrCodeType
, @CurrencyPlaces           DecimalPlacesType
, @CurrparmsCurrCode        CurrCodeType
, @DomCurrPlaces            DecimalPlacesType
, @CustaddrRowPointer       RowPointerType
, @CustaddrState            StateType
, @CustaddrCountry          CountryType
, @CustaddrCurrCode         CurrCodeType
, @CustomerRowPointer       RowPointerType
, @CustomerEdiCust          ListYesNoType
, @EndtypeRowPointer        RowPointerType
, @EndtypeArAcct            AcctType
, @EndtypeArAcctUnit1       UnitCode1Type
, @EndtypeArAcctUnit2       UnitCode2Type
, @EndtypeArAcctUnit3       UnitCode3Type
, @EndtypeArAcctUnit4       UnitCode4Type
, @InvHdrRowPointer         RowPointerType
, @InvHdrInvNum             InvNumType
, @InvHdrInvSeq             InvSeqType
, @InvHdrCustNum            CustNumType
, @InvHdrCustSeq            CustSeqType
, @InvHdrCoNum              CoNumType
, @InvHdrInvDate            DateType
, @InvHdrTermsCode          TermsCodeType
, @InvHdrShipCode           ShipCodeType
, @InvHdrBillType           BillingTypeType
, @InvHdrState              StateType
, @InvHdrExchRate           ExchRateType
, @InvHdrUseExchRate        ListYesNoType
, @InvHdrTaxCode1           TaxCodeType
, @InvHdrTaxCode2           TaxCodeType
, @InvHdrFrtTaxCode1        TaxCodeType
, @InvHdrFrtTaxCode2        TaxCodeType
, @InvHdrMscTaxCode1        TaxCodeType
, @InvHdrMscTaxCode2        TaxCodeType
, @InvHdrTaxDate            DateType
, @InvHdrPrepaidAmt         AmountType
, @InvHdrEcCode             EcCodeType
, @InvHdrMiscCharges        AmountType
, @InvHdrFreight            AmountType
, @InvHdrPrice              AmountType
, @InvHdrMiscAcct           AcctType
, @InvHdrMiscAcctUnit1      UnitCode1Type
, @InvHdrMiscAcctUnit2      UnitCode2Type
, @InvHdrMiscAcctUnit3      UnitCode3Type
, @InvHdrMiscAcctUnit4      UnitCode4Type
, @InvHdrFreightAcct        AcctType
, @InvHdrFreightAcctUnit1   UnitCode1Type
, @InvHdrFreightAcctUnit2   UnitCode2Type
, @InvHdrFreightAcctUnit3   UnitCode3Type
, @InvHdrFreightAcctUnit4   UnitCode4Type
, @InvStaxRowPointer        RowPointerType
, @InvStaxInvNum            InvNumType
, @InvStaxInvSeq            InvSeqType
, @InvStaxSeq               StaxSeqType
, @InvStaxTaxCode           TaxCodeType
, @InvStaxSalesTax          AmountType
, @InvStaxStaxAcct          AcctType
, @InvStaxStaxAcctUnit1     UnitCode1Type
, @InvStaxStaxAcctUnit2     UnitCode2Type
, @InvStaxStaxAcctUnit3     UnitCode3Type
, @InvStaxStaxAcctUnit4     UnitCode4Type
, @InvStaxInvDate           DateType
, @InvStaxCustNum           CustNumType
, @InvStaxCustSeq           CustSeqType
, @InvStaxTaxBasis          AmountType
, @InvStaxTaxSystem         TaxSystemType
, @InvStaxTaxRate           TaxRateType
, @InvStaxTaxJur            TaxJurType
, @InvStaxTaxCodeE          TaxCodeType
, @ParmsSite                SiteType
, @ParmsCountry             CountryType
, @ParmsECReporting         ListYesNoType
, @RmaRowPointer            RowPointerType
, @RmaCustNum               CustNumType
, @RmaCustSeq               CustSeqType
, @RmaRmaNum                RmaNumType
, @RmaEndUserType           EndUserTypeType
, @RmaShipCode              ShipCodeType
, @RmaFixedRate             ListYesNoType
, @RmaExchRate              ExchRateType
, @RmaUseExchRate           ListYesNoType
, @RmaTaxCode1              TaxCodeType
, @RmaTaxCode2              TaxCodeType
, @RmaFrtTaxCode1           TaxCodeType
, @RmaFrtTaxCode2           TaxCodeType
, @RmaMscTaxCode1           TaxCodeType
, @RmaMscTaxCode2           TaxCodeType
, @RmaMiscCharges           AmountType
, @RmaFreight               AmountType
, @RmaSalesTax              AmountType
, @RmaSalesTax2             AmountType
, @RmaMChargesT             AmountType
, @RmaFreightT              AmountType
, @RmaSalesTaxT             AmountType
, @RmaSalesTaxT2            AmountType
, @RmaStat                  RmaStatusType
, @RmaitemRowPointer        RowPointerType
, @RmaitemStat              RmaItemStatusType
, @RmaApplyToInvNum         InvNumType
, @TaxparmsRowPointer       RowPointerType
, @TaxparmsLastTaxReport1   DateType
, @TaxparmsCashRound        CashRoundingFactorType
, @TermsRowPointer          RowPointerType
, @TermsCashOnly            ListYesNoType
, @WTaxCalcRowPointer       RowPointerType
, @WTaxCalcRecordZero       Flag
, @WTaxCalcTaxAmt           AmountType
, @WTaxCalcTaxCode          TaxCodeType
, @WTaxCalcArAcct           AcctType
, @WTaxCalcArAcctUnit1      UnitCode1Type
, @WTaxCalcArAcctUnit2      UnitCode2Type
, @WTaxCalcArAcctUnit3      UnitCode3Type
, @WTaxCalcArAcctUnit4      UnitCode4Type
, @WTaxCalcTaxBasis         AmountType
, @WTaxCalcTaxSystem        TaxSystemType
, @WTaxCalcTaxRate          ExchRateType
, @WTaxCalcTaxJur           TaxJurType
, @WTaxCalcTaxCodeE         TaxCodeType
, @XCountryRowPointer       RowPointerType
, @XCountryEcCode           EcCodeType
, @XRmaRowPointer           RowPointerType
, @XRmaRmaNum               RmaNumType
, @SessionId                RowPointerType
, @ReleaseTmpTaxTables      FlagNyType
, @RestockFeeTaxProcessId   RowPointerType
, @NewTotCredit             AmountType
, @LinesPerDoc               INT
, @CurrLinesDoc              INT
, @LoopLinesDoc              INT
, @SSSRMXInvoice             ListYesNoType    -- SSSRMX added
, @RmaIncludeTaxInPrice      ListYesNoType
, @TaxDiff                   AmountType
, @TolAmtTax1                AmountType     
, @TolAmtTax2                AmountType    
, @TmpTaxCalcRowPointer      RowPointerType

declare
	@CoBlnRmaQtyCredited	QtyUnitType
,	@CoBlnRmaCoLine			CoLineType
	
DECLARE
  @CoparmsDueOnPmt    ListYesNoType
, @OInvHdrRowpointer  RowPointerType
, @OInvHdrInvNum      InvNumType
, @OInvHdrInvSeq      InvSeqType
, @OInvHdrPrice       AmountType
, @OInvHdrPrepaidAmt  AmountType
, @OInvHdrFreight     AmountType
, @OInvHdrMiscCharges AmountType
, @OTaxAmt            AmountType
, @OInvSum            AmountType
, @CommdueRowpointer  RowPointerType
, @CommdueDueDate     DateType
, @CommdueCommDue     AmountType
, @CommdueCommCalc    AmountType
, @TPerCent           GenericDecimalType

DECLARE @temp_tmp_tax_calc TABLE(
  temp_InvHdrInvNum        InvNumType
, temp_Seq                 INT
, temp_WTaxCalcTaxCode     NVARCHAR(255)
, temp_WTaxCalcTaxAmt      AmtTotType
, temp_WTaxCalcArAcct      AcctType
, temp_InvHdrTaxDate       DateType
, temp_InvHdrCustNum       CustNumType
, temp_InvHdrCustSeq       CustSeqType
, temp_WTaxCalcTaxBasis    AmtTotType
, temp_InvHdrInvSeq        InvSeqType
, temp_WTaxCalcTaxSystem   TaxSystemType
, temp_WTaxCalcTaxRate     TaxRateType
, temp_WTaxCalcTaxJur      TaxJurType
, temp_WTaxCalcTaxCodeE    NVARCHAR(255)
, temp_WTaxCalcArAcctUnit1 UnitCode1Type
, temp_WTaxCalcArAcctUnit2 UnitCode2Type
, temp_WTaxCalcArAcctUnit3 UnitCode3Type
, temp_WTaxCalcArAcctUnit4 UnitCode4Type
, zla_ref_type			  RefTypeIJKMNOTType
, zla_ref_num			  EmpJobCoPoRmaProjPsTrnNumType
, zla_ref_line_suf		  CoLineSuffixPoLineProjTaskRmaTrnLineType
, zla_ref_release		  CoReleaseOperNumPoReleaseType
, zla_for_tax_basis		  AmountType
, zla_for_sales_tax		  AmountType
)

DECLARE @temp_inv_stax TABLE(
  temp_cust_num     CustNumType
, temp_inv_num      InvNumType
, temp_dist_seq     INT
, temp_acct         AcctType
, temp_amount       AmtTotType
, temp_acct_unit1   UnitCode1Type
, temp_acct_unit2   UnitCode2Type
, temp_acct_unit3   UnitCode3Type
, temp_acct_unit4   UnitCode4Type
, temp_tax_system   TaxSystemType
, temp_tax_code     TaxCodeType
, temp_tax_code_e   TaxCodeType
, temp_tax_basis    AmountType
, temp_ref_line_suf SMALLINT
, temp_ref_release  SMALLINT
, zla_ref_type		 RefTypeIJKMNOTType
, zla_ref_num		 EmpJobCoPoRmaProjPsTrnNumType
, zla_ref_line_suf	 CoLineSuffixPoLineProjTaskRmaTrnLineType
, zla_ref_release	 CoReleaseOperNumPoReleaseType
, zla_tax_group_id	 ZlaTaxGroupIdType
, zla_for_tax_basis	 AmountType
, zla_for_sales_tax	 AmountType
)

-- DECLARE ZLA Vars
DECLARE
  @RmaZlaArType			ZlaArTypeIdType
, @RmaZlaDocId			ZlaDocumentIdType  
, @RmaZlaForCurrCode	CurrCodeType
, @RmaZlaForExchRate	ExchRateType
, @RmaZlaForFixedRate	ListYesNoType
, @RmaZlaForFreight	     AmountType
, @RmaZlaForFreightT	AmountType
, @RmaZlaForMChargesT	AmountType
, @RmaZlaForMiscCharges	AmountType
, @RmaZlaForSalesTax	AmountType
, @RmaZlaForSalesTax2	AmountType
, @RmaZlaForSalesTaxT2	AmountType
, @RmaZlaForSalesTaxT	AmountType
, @RmaZlaForTotCredit	AmountType
-- Arinv
, @ArinvZlaForAmount		AmountType
, @ArinvZlaForMiscCharges	AmountType
, @ArinvZlaForFreight	AmountType
, @ArinvZlaForExchRate	ExchRateType
, @ArinvZlaForCurrCode	CurrCodeType
, @ArinvZlaForSalesTax	AmountType
, @ArinvZlaForSalesTax2	AmountType
, @ArinvZlaForFixedRate	ListYesNoType
, @ArinvZlaAuthEndDate	Date4Type
, @ArinvZlaArTypeId	     ZlaArTypeIdType
, @ArinvZlaDocId	     ZlaDocumentIdType
, @ArinvZlaInvNum	     ZlaInvNumType
, @ArinvZlaAuthCode	     ZlaAuthCode
-- Arinvd
, @ArinvdAmount	    AmountType
, @ArinvdTaxBasis	    AmountType
, @ArinvdRowPointer	    RowPointerType
, @ArinvdZlaForAmount	AmountType
, @ArinvdZlaForTaxBasis	AmountType
, @ArinvdZlaTaxGroupId	ZlaTaxGroupIdType
, @ArinvdZlaBaseDistSeq	ArDistSeqType
, @ArinvdZlaDescription	DescriptionType
, @ArinvdZlaTaxRate		TaxRateType
-- Invoice Header
, @InvHdrZlaForCurrCode	CurrCodeType
, @InvHdrZlaForExchRate	ExchRateType
, @InvHdrZlaForPrice	AmountType
, @InvHdrZlaForMiscCharges	AmountType
, @InvHdrZlaForFreight	AmountType
, @InvHdrZlaForDiscAmount	AmountType
, @InvHdrZlaForPrepaidAmt	AmountType
, @InvHdrZlaInvNum	ZlaInvNumType
-- Invoice Tax
, @InvStaxZlaRefType	RefTypeIJKMNOTType
, @InvStaxZlaRefNum	     EmpJobCoPoRmaProjPsTrnNumType
, @InvStaxZlaRefLineSuf	CoLineSuffixPoLineProjTaskRmaTrnLineType
, @InvStaxZlaRefRelease	CoReleaseOperNumPoReleaseType
, @InvStaxZlaTaxGroupId	ZlaTaxGroupIdType
, @InvStaxZlaForTaxBasis	AmountType
, @InvStaxZlaForSalesTax	AmountType
-- Tax Calc
, @WTaxCalcZlaRefType	  RefTypeIJKMNOTType
, @WTaxCalcZlaRefNum	  EmpJobCoPoRmaProjPsTrnNumType
, @WTaxCalcZlaRefLineSuf	  CoLineSuffixPoLineProjTaskRmaTrnLineType
, @WTaxCalcZlaRefRelease	  CoReleaseOperNumPoReleaseType
, @WTaxCalcZlaForTaxBasis  AmountType
, @WTaxCalcZlaForSalesTax  AmountType

-- Temp Vars
, @ZlaTSalesTax                AmountType
, @ZlaTSalesTax2               AmountType
DECLARE
  @tax_type_id varchar(15)
, @tax_group_id varchar(15)
, @base_amount decimal(15,2)
, @base_amount_country decimal(15,2)
, @tax_amount decimal(15,2)
, @tax_amount_country decimal(15,2)
, @tax_percent decimal(6,3)

, @TTaxSeq2						GenericNoType


-- ZLA Temp Tax Tables

-- Declare Temp Tables
IF OBJECT_ID(N'dbo.#temp_ar_tax_in') IS NOT NULL
  DROP TABLE #temp_ar_tax_in

CREATE TABLE #temp_ar_tax_in
(
  [tax_type_id] nvarchar(15) NULL
 ,[tax_group_id] nvarchar(15) NULL
 ,[acct] nvarchar(12) NULL
 ,[amount] decimal(21,8) NULL
 ,[vat_amount] decimal(21,8) NULL
 ,[vat_acct] nvarchar(12) NULL
 ,[state] nvarchar(5) NULL
)


IF OBJECT_ID(N'dbo.#temp_ar_tax_out') IS NOT NULL
  DROP TABLE temp_ar_tax_out

CREATE TABLE #temp_ar_tax_out
(
  [tax_type_id] varchar(15)
 ,[tax_group_id] varchar(15)
 ,[base_amount] decimal(15,2)
 ,[base_amount_country] decimal(15,2)
 ,[tax_amount] decimal(15,2)
 ,[tax_amount_country] decimal(15,2)
 ,[tax_percent] decimal(6,3)
)


SET @Severity   = 0
SET @TSalesTax  = 0
SET @TSalesTax2 = 0
SET @TTaxSeq    = 0
SET @PrintFlag  = 0
SET @TAdjPrice  = 0
SET @TInvCount  = 0
SET @TTemp      = 0

SET @ZlaTSalesTax = 0
SET @ZlaTSalesTax2 = 0

SET @LinesPerDoc   = 0

-- To pass back starting and ending InvNum and date to print
SET @BCrmNum  = '0'
SET @ECrmNum  = '0'
SET @BCrmDate = NULL
SET @ECrmDate = NULL

IF @TCrmDate IS NULL
   SET @TCrmDate = getdate()

-- Create new tax table records
SET @SessionId = dbo.SessionIDSp()
EXEC @Severity = dbo.UseTmpTaxTablesSp @SessionId, @ReleaseTmpTaxTables OUTPUT, @Infobar OUTPUT

-- use separate process ID to calculate tax on restock fee
SET @RestockFeeTaxProcessId = NEWID()

SET @TArCredit = dbo.GetLabel('@!ARCOPEN') -- "ARC OPEN"
SET @TOpen = dbo.GetLabel('@CapitalOPEN')

SELECT
  @ArparmsRowPointer       = arparms.RowPointer
, @ArparmsArAcct           = arparms.ar_acct
, @ArparmsArAcctUnit1      = arparms.ar_acct_unit1
, @ArparmsArAcctUnit2      = arparms.ar_acct_unit2
, @ArparmsArAcctUnit3      = arparms.ar_acct_unit3
, @ArparmsArAcctUnit4      = arparms.ar_acct_unit4
, @ArparmsMiscAcct         = arparms.misc_acct
, @ArparmsMiscAcctUnit1    = arparms.misc_acct_unit1
, @ArparmsMiscAcctUnit2    = arparms.misc_acct_unit2
, @ArparmsMiscAcctUnit3    = arparms.misc_acct_unit3
, @ArparmsMiscAcctUnit4    = arparms.misc_acct_unit4
, @ArparmsFreightAcct      = arparms.freight_acct
, @ArparmsFreightAcctUnit1 = arparms.freight_acct_unit1
, @ArparmsFreightAcctUnit2 = arparms.freight_acct_unit2
, @ArparmsFreightAcctUnit3 = arparms.freight_acct_unit3
, @ArparmsFreightAcctUnit4 = arparms.freight_acct_unit4
FROM arparms WITH (READUNCOMMITTED)

SELECT
  @TaxparmsRowPointer     = taxparms.RowPointer
, @TaxparmsLastTaxReport1 = taxparms.last_tax_report_1
, @TaxparmsCashRound      = taxparms.cash_round
, @TaxPromptForSystem1    = taxparms.prompt_for_system1
, @TaxPromptForSystem2    = taxparms.prompt_for_system2
FROM taxparms WITH (READUNCOMMITTED)

SELECT @CurrparmsCurrCode = currparms.curr_code
FROM currparms WITH (READUNCOMMITTED)

SELECT @DomCurrPlaces = currency.places
FROM currency WITH (READUNCOMMITTED)
WHERE currency.curr_code = @CurrparmsCurrCode

SELECT
  @CoparmsDueOnPmt = coparms.due_on_pmt
FROM coparms WITH (READUNCOMMITTED)

SELECT
  @ParmsSite        = parms.site
, @ParmsECReporting = parms.ec_reporting
, @ParmsCountry     = parms.country
FROM parms WITH (READUNCOMMITTED)

IF @ParmsECReporting = 1
BEGIN
   SET @XCountryRowPointer = NULL
   SET @XCountryEcCode     = NULL

   SELECT
     @XCountryRowPointer = country.RowPointer
   , @XCountryEcCode     = country.ec_code
   FROM country WITH (READUNCOMMITTED)
   WHERE country.country = @ParmsCountry
END

   EXEC dbo.GetArparmLinesPerDocSp
                @ArparmUsePrePrintedForms OUTPUT,
                @ArparmLinesPerInv OUTPUT,
                @ArparmLinesPerDM OUTPUT,
                @ArparmLinesPerCM OUTPUT

IF @ArparmUsePrePrintedForms >0
   SET @LinesPerDoc = @ArparmLinesPerCM



DECLARE CrmPostSp1Crs CURSOR LOCAL STATIC FOR
SELECT
  rma.RowPointer
, rma.rma_num
, rma.cust_num
, rma.cust_seq
, rma.rma_num
, rma.end_user_type
, rma.ship_code
, rma.fixed_rate
, rma.exch_rate
, rma.use_exch_rate
, rma.tax_code1
, rma.tax_code2
, rma.frt_tax_code1
, rma.frt_tax_code2
, rma.msc_tax_code1
, rma.msc_tax_code2
, rma.misc_charges
, rma.freight
, rma.sales_tax
, rma.sales_tax_2
, rma.m_charges_t
, rma.freight_t
, rma.sales_tax_t
, rma.sales_tax_t2
, rma.stat
, isnull(rma.apply_to_inv_num,@ApplyToInvNum)
, rma.include_tax_in_price
, rma.zla_ar_type
, rma.zla_doc_id
, rma.zla_for_curr_code
, rma.zla_for_exch_rate
, rma.zla_for_fixed_rate
, rma.zla_for_freight
, rma.zla_for_freight_t
, rma.zla_for_m_charges_t
, rma.zla_for_misc_charges
, rma.zla_for_sales_tax
, rma.zla_for_sales_tax_2
, rma.zla_for_sales_tax_t2
, rma.zla_for_sales_tax_t
, rma.zla_for_tot_credit
FROM rma
WHERE
   rma.rma_num BETWEEN ISNULL (@BRmaNum, rma.rma_num) AND ISNULL (@ERmaNum, rma.rma_num) AND
   rma.cust_num BETWEEN ISNULL (@BCustNum, rma.cust_num) AND ISNULL (@ECustNum, rma.cust_num) AND
   rma.stat = 'O'
OPEN CrmPostSp1Crs
WHILE @Severity = 0
BEGIN
   FETCH CrmPostSp1Crs INTO
     @XRmaRowPointer
   , @XRmaRmaNum
   , @RmaCustNum
   , @RmaCustSeq
   , @RmaRmaNum
   , @RmaEndUserType
   , @RmaShipCode
   , @RmaFixedRate
   , @RmaExchRate
   , @RmaUseExchRate
   , @RmaTaxCode1
   , @RmaTaxCode2
   , @RmaFrtTaxCode1
   , @RmaFrtTaxCode2
   , @RmaMscTaxCode1
   , @RmaMscTaxCode2
   , @RmaMiscCharges
   , @RmaFreight
   , @RmaSalesTax
   , @RmaSalesTax2
   , @RmaMChargesT
   , @RmaFreightT
   , @RmaSalesTaxT
   , @RmaSalesTaxT2
   , @RmaStat
   , @RmaApplyToInvNum
   , @RmaIncludeTaxInPrice
   , @RmaZlaArType
   , @RmaZlaDocId
   , @RmaZlaForCurrCode
   , @RmaZlaForExchRate
   , @RmaZlaForFixedRate
   , @RmaZlaForFreight
   , @RmaZlaForFreightT
   , @RmaZlaForMChargesT
   , @RmaZlaForMiscCharges
   , @RmaZlaForSalesTax
   , @RmaZlaForSalesTax2
   , @RmaZlaForSalesTaxT2
   , @RmaZlaForSalesTaxT
   , @RmaZlaForTotCredit

   IF @@FETCH_STATUS = -1
      BREAK

   SET @RmaitemRowPointer = NULL
   SET @RmaitemStat       = NULL
   
   SELECT
     @RmaitemRowPointer = rmaitem.RowPointer
   , @RmaitemStat       = rmaitem.stat
   FROM rmaitem
   WHERE
      rmaitem.rma_num = @XRmaRmaNum AND
      ((rmaitem.return_item = 1 AND rmaitem.qty_received > rmaitem.qty_credited)
            OR (rmaitem.return_item = 0 AND rmaitem.qty_to_return > rmaitem.qty_credited)) AND
      (rmaitem.stat = 'O' OR rmaitem.stat = 'F') AND
      rmaitem.rma_line BETWEEN ISNULL (@BRmaLine, rmaitem.rma_line) AND ISNULL (@ERmaLine, rmaitem.rma_line) AND
          (rmaitem.last_return_date BETWEEN ISNULL (@BLastReturnDate, rmaitem.last_return_date) AND ISNULL (@ELastReturnDate, rmaitem.last_return_date)
                   OR rmaitem.last_return_date IS NULL) AND
		rmaitem.co_num = @CoCoNum

   IF @RmaitemRowPointer IS NULL
      CONTINUE
   
	select 
		@ArinvCoNum		= a.co_num,
		@InvHdrCoNum	= a.co_num
	from rmaitem_mst a
	--inner join artran_mst b on b.inv_num = a.apply_to_inv_num and b.type = 'I'
	where a.RowPointer = @RmaitemRowPointer
   	
	if @ArinvCoNum is null set @ArinvCoNum = @CoCoNum
	if @InvHdrCoNum is null set @InvHdrCoNum = @CoCoNum

   -- SSSRMX Start
   IF OBJECT_ID('dbo.EXTSSSRMXCrmPostSp') IS NOT NULL
   BEGIN
      DECLARE @Sysname Sysname
      SET @Sysname = 'dbo.EXTSSSRMXCrmPostSp'
      SET @SSSRMXInvoice = 1

      EXEC @Severity = @Sysname
                       @XRmaRmaNum
                     , @BRmaLine
                     , @ERmaLine
                     , @BLastReturnDate 
                     , @ELastReturnDate
                     , @SSSRMXInvoice          OUTPUT
      IF @SSSRMXInvoice = 0
         CONTINUE
   END
   -- SSSRMX End

   SET @CurrLinesDoc  = 0
   SET @LoopLinesDoc  = 0

   SELECT @LoopLinesDoc = COUNT(*)
   FROM rmaitem
   WHERE
   rmaitem.rma_num = @XRmaRmaNum AND
   ((rmaitem.return_item = 1 AND rmaitem.qty_received > rmaitem.qty_credited)
         OR (rmaitem.return_item = 0 AND rmaitem.qty_to_return > rmaitem.qty_credited)) AND
   (rmaitem.stat = 'O' OR rmaitem.stat = 'F') AND
   rmaitem.rma_line BETWEEN ISNULL (@BRmaLine, rmaitem.rma_line) AND ISNULL (@ERmaLine, rmaitem.rma_line) AND
       (rmaitem.last_return_date BETWEEN ISNULL (@BLastReturnDate, rmaitem.last_return_date) AND ISNULL (@ELastReturnDate, rmaitem.last_return_date)
                OR rmaitem.last_return_date IS NULL) AND
	rmaitem.co_num = @CoCoNum

   while (@LoopLinesDoc > @CurrLinesDoc or @ArparmUsePrePrintedForms = 0)
   BEGIN
      DELETE tmp_tax_basis WHERE ProcessId = @SessionId
      DELETE tmp_tax_calc  WHERE ProcessId = @SessionId

      SET @RmaRowPointer      = @XRmaRowPointer
      SET @CustomerRowPointer = NULL
      SELECT
        @CustomerRowPointer = customer.RowPointer
      , @CustomerEdiCust    = customer.edi_cust
      FROM customer
      WHERE customer.cust_num = @RmaCustNum AND customer.cust_seq = @RmaCustSeq

      IF @CustomerRowPointer IS NULL
      BEGIN
         SET @Infobar = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistForIsAndIs1'
            , '@customer'
            , '@customer.cust_num', @RmaCustNum
            , '@customer.cust_seq', @RmaCustSeq
            , '@rma'
            , '@rma.rma_num', @RmaRmaNum

         GOTO EXIT_SP
      END

      SET @BillToCustomerRowPointer = NULL
      SET @BillToCustomerTermsCode = NULL
      SELECT
        @BillToCustomerRowPointer = customer.RowPointer
      , @BillToCustomerTermsCode  = customer.terms_code
      FROM customer
      WHERE customer.cust_num = @RmaCustNum AND customer.cust_seq = 0

      SET @CustaddrRowPointer = NULL
      SELECT
        @CustaddrRowPointer = custaddr.RowPointer
      , @CustaddrState      = custaddr.state
      , @CustaddrCountry    = custaddr.country
      , @CustaddrCurrCode   = custaddr.curr_code
      FROM custaddr
      WHERE custaddr.cust_num = @RmaCustNum AND custaddr.cust_seq = @RmaCustSeq

      IF @CustaddrRowPointer IS NULL
      BEGIN
         SET @Infobar = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistForIsAndIs1'
            , '@custaddr'
            , '@custaddr.cust_num', @RmaCustNum
            , '@customer.cust_seq', @RmaCustSeq
            , '@rma'
            , '@rma.rma_num', @RmaRmaNum

         GOTO EXIT_SP
      END

      SET @TEndAr             = @ArparmsArAcct
      SET @TEndArUnit1        = @ArparmsArAcctUnit1
      SET @TEndArUnit2        = @ArparmsArAcctUnit2
      SET @TEndArUnit3        = @ArparmsArAcctUnit3
      SET @TEndArUnit4        = @ArparmsArAcctUnit4

      SET @CurrencyRowPointer = NULL
      SET @CurrencyCurrCode   = NULL
      SET @CurrencyPlaces     = 0

      SELECT
        @CurrencyRowPointer = currency.RowPointer
      , @CurrencyCurrCode   = currency.curr_code
      , @CurrencyPlaces     = currency.places
      FROM currency with (readuncommitted)
      WHERE currency.curr_code = @CustaddrCurrCode
      IF @RmaEndUserType IS NOT NULL
      BEGIN
         SET @EndtypeRowPointer  = NULL
         SELECT
           @EndtypeRowPointer  = endtype.RowPointer
         , @EndtypeArAcct      = endtype.ar_acct
         , @EndtypeArAcctUnit1 = endtype.ar_acct_unit1
         , @EndtypeArAcctUnit2 = endtype.ar_acct_unit2
         , @EndtypeArAcctUnit3 = endtype.ar_acct_unit3
         , @EndtypeArAcctUnit4 = endtype.ar_acct_unit4
         FROM endtype with (readuncommitted)
         WHERE endtype.end_user_type = @RmaEndUserType

         IF @EndtypeRowPointer IS NOT NULL AND @EndtypeArAcct IS NOT NULL
         BEGIN
            SET @TEndAr      = @EndtypeArAcct
            SET @TEndArUnit1 = @EndtypeArAcctUnit1
            SET @TEndArUnit2 = @EndtypeArAcctUnit2
            SET @TEndArUnit3 = @EndtypeArAcctUnit3
            SET @TEndArUnit4 = @EndtypeArAcctUnit4
         END
      END

	  
      IF @RmaFixedRate <> 1
         IF @CurrparmsCurrCode <> @CurrencyCurrCode
         BEGIN
            SET @InvHdrExchRate = null
            EXEC @Severity = dbo.CurrCnvtSp
               @CurrencyCurrCode,  /* CurrCode      */
               0,                  /* FromDomestic  */
               0,                  /* UseBuyRate    */
               0,                  /* RoundResult   */
               @TCrmDate,          /* Date          */
               NULL,               /* RoundPlaces   */
               0,
               NULL,               /* ForceRate     */
               NULL,               /* FindTTFixed   */
               @InvHdrExchRate OUTPUT, /* TRate         */
               @Infobar OUTPUT,    /* Inforbar      */
               @DAmt ,                  /* Amount1       */
               @DAmt  OUTPUT /* Result1    */

            IF @Severity <> 0
               GOTO EXIT_SP
         END
         ELSE
            SET @InvHdrExchRate = 1
      ELSE
         SET @InvHdrExchRate = @RmaExchRate

      IF @TCrmDate < @TaxparmsLastTaxReport1
         SET @InvHdrTaxDate = @TaxparmsLastTaxReport1
      ELSE
         SET @InvHdrTaxDate = @TCrmDate

      SET @InvHdrEcCode = NULL
      IF @ParmsECReporting = 1
      BEGIN
         SET @CustaddrRowPointer = NULL
         SET @CustaddrState      = NULL
         SET @CustaddrCountry    = NULL
         SET @CustaddrCurrCode   = NULL

         SELECT
           @CustaddrRowPointer = custaddr.RowPointer
         , @CustaddrState      = custaddr.state
         , @CustaddrCountry    = custaddr.country
         , @CustaddrCurrCode   = custaddr.curr_code
         FROM custaddr
         WHERE custaddr.cust_num = @RmaCustNum AND custaddr.cust_seq = 0

         IF @ParmsCountry <> @CustaddrCountry
         BEGIN
            SET @CountryRowPointer = NULL
            SELECT
              @CountryRowPointer = country.RowPointer
            , @CountryEcCode     = country.ec_code
            FROM country with (readuncommitted)
            WHERE country.country = @CustaddrCountry
            IF (@CountryRowPointer IS NOT NULL and @XCountryRowPointer IS NULL) or
               (@CountryRowPointer IS NOT NULL and @XCountryRowPointer IS NOT NULL and @CountryEcCode <> @XCountryEcCode)
               SET @InvHdrEcCode = @CountryEcCode
            ELSE
               SET @InvHdrEcCode = null
         END
      END

	 -- ZLA Set AR Operation Type for Credit Memo Sequence
	 SET @ArinvZlaArTypeId = @RmaZlaArType
	 SET @ArinvZlaDocId       = @RmaZlaDocId  
	 
	 
      EXEC @Severity = dbo.ZLA_NextInvNumSp
        @Custnum	= @RmaCustNum
      , @InvDate    = @TCrmDate
      , @Type       = 'C'
      , @InvNum     = @TInvNum OUTPUT
      , @Action     = 'NextNumSkip'
	 , @Infobar      = @Infobar OUTPUT
	 , @ZlaArTypeId  = @ArinvZlaArTypeId
	 , @ZlaInvNum    = @ArinvZlaInvNum OUTPUT
	 , @ZlaAuthCode  = @ArinvZlaAuthCode OUTPUT 
	 , @ZlaAuthEndDate = @ArinvzlaAuthEndDate OUTPUT
	 , @ZlaDocId	   = @ArinvZlaDocId

      IF @Severity <> 0
         GOTO EXIT_SP

      EXEC @Severity = dbo.ZLA_NextInvNumSp
        @Custnum    = @RmaCustNum
      , @InvDate    = @TCrmDate
      , @Type       = 'C'
      , @InvNum     = @TInvNum OUTPUT
      , @Action     = 'AddedNum'
	 , @Infobar      = @Infobar OUTPUT
	 , @ZlaArTypeId  = @ArinvZlaArTypeId
	 , @ZlaInvNum    = @ArinvZlaInvNum OUTPUT
	 , @ZlaAuthCode  = @ArinvZlaAuthCode OUTPUT 
	 , @ZlaAuthEndDate = @ArinvzlaAuthEndDate OUTPUT
 	 , @ZlaDocId	    = @ArinvZlaDocId

	 	 
      IF @Severity <> 0
         GOTO EXIT_SP

      SET @InvHdrInvNum = @TInvNum
      SET @InvHdrInvSeq = 0
      SET @InvHdrInvDate = @TCrmDate
      SET @InvHdrTermsCode = @BillToCustomerTermsCode
      SET @InvHdrUseExchRate = @RmaUseExchRate
      SET @InvHdrCustNum = @RmaCustNum
      SET @InvHdrCustSeq = @RmaCustSeq

      Set @InvHdrRowPointer = NewId()

	  SET @InvHdrZlaForCurrCode = @RmaZlaForCurrCode
	  SET @InvHdrZlaForExchRate = @RmaZlaForExchRate
	  SET @InvHdrZlaInvNum	  = @ArinvZlaInvNum
      SET @InvHdrZlaForMiscCharges = - @RmaZlaForMiscCharges
      SET @InvHdrZlaForFreight     = - @RmaZlaForFreight


      INSERT INTO inv_hdr (
         inv_num, inv_seq, cust_num, cust_seq, co_num,
         inv_date, terms_code, ship_code, bill_type, state,
         exch_rate, use_exch_rate, tax_code1, tax_code2, frt_tax_code1,
         frt_tax_code2, msc_tax_code1, msc_tax_code2, tax_date, ec_code,
         prepaid_amt, misc_charges, freight, price,RowPointer
	    , zla_for_curr_code
	    , zla_for_exch_rate
	    , zla_inv_num
		  )
      VALUES (
         @InvHdrInvNum, @InvHdrInvSeq, @InvHdrCustNum, @InvHdrCustSeq, @InvHdrCoNum,
         @InvHdrInvDate, @InvHdrTermsCode, @RmaShipCode, 'M', @CustaddrState,
         @InvHdrExchRate, @RmaUseExchRate, @RmaTaxCode1, @RmaTaxCode2, @RmaFrtTaxCode1,
         @RmaFrtTaxCode2, @RmaMscTaxCode1, @RmaMscTaxCode2, @InvHdrTaxDate, @InvHdrEcCode,
         0, 0, 0, 0,@InvHdrRowPointer
	    ,@InvHdrZlaForCurrCode
	    ,@InvHdrZlaForExchRate
	    ,@InvHdrZlaInvNum
		)
      -- Enter record in TrackRows for printing
      INSERT INTO TrackRows (
        SessionId
      , TrackedOperType
      , RowPointer )
      VALUES (
        @ProcessId
      , 'inv_hdr'
      , @InvHdrRowPointer ) 

      -- To pass back starting and ending InvNum and date to print
      IF @BCrmNum = '0'
      BEGIN
         SET @BCrmNum  = @InvHdrInvNum
         SET @BCrmDate = @InvHdrInvDate
      END
      SET @ECrmNum  = @InvHdrInvNum
      SET @ECrmDate = @InvHdrInvDate

      SET @ArinvCustNum = @RmaCustNum
      SET @ArinvInvNum = @InvHdrInvNum
      Set @ArinvRowPointer = NewId()
	
	 SET @ArinvZlaForCurrCode = @RmaZlaForCurrCode
	 SET @ArinvZlaForExchRate = @RmaZlaForExchRate
	 SET @ArinvZlaForFixedRate = @RmaZlaForFixedRate
	
      INSERT INTO arinv (
         cust_num, inv_num, type, co_num, inv_date,
         due_date, acct, amount, misc_charges, sales_tax,
         freight, ref, terms_code, description, post_from_co,
         exch_rate, sales_tax_2, use_exch_rate, tax_code1, tax_code2,
         acct_unit1, acct_unit2, acct_unit3, acct_unit4, fixed_rate, rma, apply_to_inv_num,rowpointer
	    , zla_for_exch_rate
	    , zla_for_curr_code
	    , zla_for_fixed_rate
	    , zla_auth_end_date
	    , zla_ar_type_id
	    , zla_doc_id
	    , zla_inv_num
	    , zla_auth_code
	    )
      VALUES (
         @ArinvCustNum, @TInvNum, 'C', @ArinvCoNum, @TCrmDate,
         @TCrmDate, @TEndAr, 0, 0, 0,
         0, 'ARC'  + ' ' + @TInvNum, @BillToCustomerTermsCode, @TOpen  + ' ' + @TInvNum , 1,
         @InvHdrExchRate, 0, @RmaUseExchRate, @RmaTaxCode1, @RmaTaxCode2,
         @TEndArUnit1, @TEndArUnit2, @TEndArUnit3, @TEndArUnit4, @RmaFixedRate, 1, ISNULL(@RmaApplyToInvNum,'0'), @ArinvRowPointer
	    , @ArinvZlaForExchRate
	    , @ArinvZlaForCurrCode
	    , @ArinvZlaForFixedRate
	    , @ArinvZlaAuthEndDate
	    , @ArinvZlaArTypeId
	    , @ArinvZlaDocId
	    , @ArinvZlaInvNum
	    , @ArinvZlaAuthCode
	    )
		

      SET @TDistSeq          = 0
      SET @TSubTotal         = 0
      SET @BalAdj            = 0
      SET @TolAmtTax1        = 0
      SET @TolAmtTax2        = 0
      EXEC dbo.DefineVariableSp 'RMACreditMemo', '1', @Infobar output
      EXEC @Severity = dbo.ZPV_CrmPost1Sp
         @TCrmDate,
         @BRmaLine,
         @ERmaLine,
         @BLastReturnDate,
         @ELastReturnDate,
         @RmaRowPointer,
         @ArinvRowPointer,
         @InvHdrRowPointer,
         @RestockFeeTaxProcessId,
         @BalAdj OUTPUT,
         @DAmt OUTPUT,
         @TDistSeq OUTPUT,
         @TSubTotal OUTPUT,
         @TInvNum OUTPUT,
         @TAccRestTaxBasis OUTPUT,
         @TAccRestTax1 OUTPUT,
         @TAccRestTax2 OUTPUT,
         @LinesPerDoc,
         @Infobar OUTPUT,
         @TolAmtTax1 OUTPUT,
         @TolAmtTax2 OUTPUT
      IF @Severity <> 0
         GOTO EXIT_SP
	  
	  select @TInvNum
      EXEC dbo.UnDefineVariableSp 'RMACreditMemo', @Infobar output

      SET @InvHdrMiscCharges = - @RmaMiscCharges
      SET @InvHdrFreight     = - @RmaFreight

	 SET @InvHdrZlaForMiscCharges = @RmaZlaForMiscCharges
	 SET @InvHdrZlaForFreight	 = @RmaZlaForFreight
   
	SET @Flag = 1

      IF NOT (@TaxPromptForSystem1 = 1 or @TaxPromptForSystem2 = 1)
	  IF @RmaTaxCode1 is null and @RmaTaxCode2 is null
	     SET @Flag = 0
      
	  
      IF @Flag = 1
      BEGIN
         EXEC @Severity = dbo.ZLA_TaxCalcSp
           'R',
           @RmaTaxCode1,
           @RmaTaxCode2,
           @InvHdrFreight,
           @RmaFrtTaxCode1,
           @RmaFrtTaxCode2,
           @InvHdrMiscCharges,
           @RmaMscTaxCode1,
           @RmaMscTaxCode2,
           @InvHdrInvDate,
           @InvHdrTermsCode,
           @InvHdrUseExchRate,
           @CustaddrCurrCode,
           @CurrencyPlaces,
           @InvHdrExchRate,
           @TSalesTax OUTPUT,
           @TSalesTax2 OUTPUT,
           @Infobar OUTPUT,
           @pRefType = 'RI',
           @pHdrPtr  = @InvHdrRowPointer
		  , @pZlaRefType = 'M'
		  , @pZlaRefNum  = @RmaRmaNum
		  , @pZlaRefLineSuf = 0
		  , @pZlaRefRelease = 0
		  , @PZlaForCurrCode = @RmaZlaForCurrCode
		  , @pZlaForExchRate = @RmaZlaForExchRate
		  , @pZlaForSalesTax1 = @ZlaTSalesTax OUTPUT
		  , @pZlaForSalesTax2 = @ZlaTSalesTax2 OUTPUT

         IF @Severity <> 0
         BEGIN
            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed1'
              , '@%co/tax-calc', '@rma'
              , '@rma.rma_num', @RmaRmaNum
            GOTO EXIT_SP
         END
      END
	  
      IF @RmaIncludeTaxInPrice = 1
      BEGIN
         -- fudge total tax to match the sum of the detail if it looks like a minor rounding difference
         SET @TaxDiff = @TolAmtTax1 - @TSalesTax
         IF @TaxDiff != 0         
         BEGIN
            DECLARE taxadjCrs CURSOR LOCAL STATIC FOR
            SELECT RowPointer
            FROM tmp_tax_calc
            WHERE ProcessId = @SessionId
            AND tax_amt != 0
            AND tax_system = 1

            OPEN taxadjCrs
            WHILE @TaxDiff != 0
            BEGIN
               FETCH taxadjCrs INTO
                 @TmpTaxCalcRowPointer
               IF @@fetch_status != 0
                  break

               UPDATE tmp_tax_calc
               SET tax_amt = tax_amt + CASE WHEN @TaxDiff > 0 THEN 0.01 ELSE -0.01 END
               WHERE ProcessId = @SessionId
               AND RowPointer = @TmpTaxCalcRowPointer

               SET @TSalesTax = @TSalesTax + CASE WHEN @TaxDiff > 0 THEN 0.01 ELSE -0.01 END
               SET @TaxDiff = @TaxDiff - CASE WHEN @TaxDiff > 0 THEN 0.01 ELSE -0.01 END
            END
            CLOSE taxadjCrs
            DEALLOCATE taxadjCrs
         END

         SET @TaxDiff = @TolAmtTax2 - @TSalesTax2
         IF @TaxDiff != 0        
         BEGIN
            DECLARE taxadjCrs CURSOR LOCAL STATIC FOR
            SELECT RowPointer
            FROM tmp_tax_calc
            WHERE ProcessId = @SessionId
            AND tax_amt != 0
            AND tax_system = 2

            OPEN taxadjCrs
            WHILE @TaxDiff != 0
            BEGIN
               FETCH taxadjCrs INTO
                 @TmpTaxCalcRowPointer
               IF @@fetch_status != 0
                  break

               UPDATE tmp_tax_calc
               SET tax_amt = tax_amt + CASE WHEN @TaxDiff > 0 THEN 0.01 ELSE -0.01 END
               WHERE ProcessId = @SessionId
               AND RowPointer = @TmpTaxCalcRowPointer

               SET @TSalesTax2 = @TSalesTax2 + CASE WHEN @TaxDiff > 0 THEN 0.01 ELSE -0.01 END
               SET @TaxDiff = @TaxDiff - CASE WHEN @TaxDiff > 0 THEN 0.01 ELSE -0.01 END
            END
            CLOSE taxadjCrs
            DEALLOCATE taxadjCrs
         END
      END
	  
      SET @TTaxSeq = 0

      DELETE FROM @temp_tmp_tax_calc
      INSERT INTO @temp_tmp_tax_calc (
        temp_InvHdrInvNum
      , temp_Seq
      , temp_WTaxCalcTaxCode
      , temp_WTaxCalcTaxAmt
      , temp_WTaxCalcArAcct
      , temp_InvHdrTaxDate
      , temp_InvHdrCustNum
      , temp_InvHdrCustSeq
      , temp_WTaxCalcTaxBasis
      , temp_InvHdrInvSeq
      , temp_WTaxCalcTaxSystem
      , temp_WTaxCalcTaxRate
      , temp_WTaxCalcTaxJur
      , temp_WTaxCalcTaxCodeE
      , temp_WTaxCalcArAcctUnit1
      , temp_WTaxCalcArAcctUnit2
      , temp_WTaxCalcArAcctUnit3
      , temp_WTaxCalcArAcctUnit4
	 , zla_ref_type
	 , zla_ref_num	
	 , zla_ref_line_suf
	 , zla_ref_release
	 , zla_for_tax_basis
	 , zla_for_sales_tax
	 )
      SELECT
        @InvHdrInvNum
      , @TTaxSeq
      , w_tax_calc.tax_code
      , round(w_tax_calc.tax_amt, @CurrencyPlaces)
      , w_tax_calc.ar_acct
      , @InvHdrTaxDate
      , @InvHdrCustNum
      , @InvHdrCustSeq
      , w_tax_calc.tax_basis
      , @InvHdrInvSeq
      , w_tax_calc.tax_system
      , w_tax_calc.tax_rate
      , w_tax_calc.tax_jur
      , w_tax_calc.tax_code_e
      , w_tax_calc.ar_acct_unit1
      , w_tax_calc.ar_acct_unit2
      , w_tax_calc.ar_acct_unit3
      , w_tax_calc.ar_acct_unit4
	 , zla_ref_type
	 , @InvHdrCoNum --zla_ref_num	
	 , zla_ref_line_suf
	 , zla_ref_release
	 , zla_for_tax_basis
	 , zla_for_sales_tax
      FROM  tmp_tax_calc AS w_tax_calc
      WHERE w_tax_calc.ProcessId = @SessionId
            AND (w_tax_calc.record_zero = 1 OR w_tax_calc.tax_amt <> 0)

      UPDATE @temp_tmp_tax_calc SET temp_Seq = @TTaxSeq, @TTaxSeq = @TTaxSeq + 1

      INSERT INTO inv_stax (
         inv_num,
         seq,
         tax_code,
         sales_tax,
         stax_acct,
         inv_date,
         cust_num,
         cust_seq,
         tax_basis,
         inv_seq,
         tax_system,
         tax_rate,
         tax_jur,
         tax_code_e,
         stax_acct_unit1,
         stax_acct_unit2,
         stax_acct_unit3,
         stax_acct_unit4
	    , zla_ref_type
	    , zla_ref_num
	    , zla_ref_line_suf
	    , zla_ref_release
	    , zla_for_tax_basis
	    , zla_for_sales_tax
	    )
      SELECT * FROM @temp_tmp_tax_calc
	  

      -- update tax amount and tax basis on all rows as multi-level tax codes are used
      UPDATE inv_stax
      SET
        inv_stax.sales_tax = inv_stax.sales_tax + ISNULL(tmp_tax_calc.tax_amt, 0.0)
      , inv_stax.tax_basis = inv_stax.tax_basis + ISNULL(tmp_tax_calc.tax_basis, 0.0)
      FROM inv_stax
         INNER JOIN tmp_tax_calc
         ON tmp_tax_calc.ProcessId = @RestockFeeTaxProcessId
         AND tmp_tax_calc.tax_system = 1
         AND tmp_tax_calc.tax_code = inv_stax.tax_code
         INNER JOIN taxcode
         ON taxcode.tax_system = 1
         AND taxcode.tax_code_type = 'R'
         AND taxcode.tax_code = tmp_tax_calc.tax_code /* tmp_tax_calc.tax_code is a rate type tax code */
         AND taxcode.tax_restock = 1
      WHERE inv_stax.inv_num = @InvHdrInvNum
      AND inv_stax.inv_seq = @InvHdrInvSeq
      AND inv_stax.tax_system = 1

      -- update tax amount and tax basis on all rows as multi-level tax codes are used
      UPDATE inv_stax
      SET
        inv_stax.sales_tax = inv_stax.sales_tax + ISNULL(tmp_tax_calc.tax_amt, 0.0)
      , inv_stax.tax_basis = inv_stax.tax_basis + ISNULL(tmp_tax_calc.tax_basis, 0.0)
      FROM inv_stax
         INNER JOIN tmp_tax_calc
         ON tmp_tax_calc.ProcessId = @RestockFeeTaxProcessId
         AND tmp_tax_calc.tax_system = 2
         AND tmp_tax_calc.tax_code = inv_stax.tax_code
         INNER JOIN taxcode
         ON taxcode.tax_system = 2
         AND taxcode.tax_code_type = 'R'
         AND taxcode.tax_code = tmp_tax_calc.tax_code /* tmp_tax_calc.tax_code is a rate type tax code */
         AND taxcode.tax_restock = 1
      WHERE inv_stax.inv_num = @InvHdrInvNum
      AND inv_stax.inv_seq = @InvHdrInvSeq
      AND inv_stax.tax_system = 2

      -- remove rows in temp tax tables related to restock fee amount tax calculation
      DELETE tmp_tax_basis WHERE ProcessId = @RestockFeeTaxProcessId
      DELETE tmp_tax_calc  WHERE ProcessId = @RestockFeeTaxProcessId

      DELETE tmp_tax_calc WHERE ProcessId = @SessionId
	 
	 /*
	 ZLA - Populate MUCI Tax Records

	 */
		DELETE #temp_ar_tax_in
		DELETE #temp_ar_tax_out


		-- ZLA FILL INPUT TABLE / For Items
		INSERT INTO #temp_ar_tax_in(
		   [tax_type_id]
		  ,[tax_group_id]
		  ,[acct]
		  ,[amount]
		  ,[vat_amount]
		  ,[vat_acct]
		  ,[state]
		  )
		  SELECT	 TaxGroup.TAX_TYPE_ID 
				,citax.tax_group_id 
				,invi.sales_acct
				,-(stax.zla_for_tax_basis)
				,-(stax.zla_for_sales_tax)
				,stax.stax_acct  
				,NULL
		  FROM inv_stax stax   
   			LEFT OUTER JOIN rmaitem ritem   ON ritem.rma_num = @BRmaNum --stax.zla_ref_num
								  AND ritem.rma_line = @BRmaLine --stax.zla_ref_line_suf

			LEFT OUTER JOIN zla_coitem_tax citax ON citax.co_num = ritem.co_num 
									   AND citax.co_line = ritem.co_line
									   AND citax.co_release = ritem.co_release

			LEFT OUTER  JOIN zla_tax_group TaxGroup ON TaxGroup.GROUP_ID = citax.tax_group_id 

			LEFT OUTER JOIN inv_item invi ON invi.inv_num = stax.inv_num
								 AND invi.inv_seq	= stax.inv_seq
								 AND invi.inv_line	= 0
								 AND invi.co_num	= ritem.co_num 
								 AND invi.co_line	= ritem.co_line
								 AND invi.co_release = ritem.co_release


		   WHERE stax.inv_num = @InvHdrInvNum
		  AND stax.inv_seq = @InvHdrInvSeq
/*
	      IF @RmaMiscCharges <> 0 OR @RmaFreight <> 0
		  BEGIN
		   -- ZLA FILL INPUT TABLE /  Misc charges
		   INSERT INTO #temp_ar_tax_in(
			 [tax_type_id]
			,[tax_group_id]
			,[acct]
			,[amount]
			,[vat_amount]
			,[vat_acct]
			,[state]
			)
			SELECT	 TaxGroup.TAX_TYPE_ID 
				   ,citax.tax_group_id 
				   , CASE stax.zla_ref_line_suf
					  When 998 THEN @ArparmsMiscAcct
					ELSE  @ArparmsFreightAcct
					END
				   ,stax.zla_for_tax_basis 
				   ,-stax.zla_for_sales_tax
				   ,stax.stax_acct  
				   ,NULL
			FROM inv_stax stax  
			   INNER JOIN rma on rma.rma_num = stax.zla_ref_num 
			   INNER JOIN zla_co_tax cotax ON cotax.co_num = (SELECT TOP 1 co_num from rmaitem where rmaitem.rma_num = rma.rma_num)
								  AND type = CASE stax.zla_ref_line
											When  998 THEN 'M'
										    ELSE   'F'
										    END

			INNER JOIN zla_tax_group TaxGroup ON TaxGroup.GROUP_ID = cotax.tax_group_id 

	 WHERE stax.inv_stax.inv_num = @InvHdrInvNum
      AND	  stax.inv_stax.inv_seq = @InvHdrInvSeq
	 And	  stax.zla_ref_line_suf between 998 And 999  -- Misc charges
		  END
*/

	    -- Call MUCI Tax Calculation
		 
	    EXECUTE [dbo].[ZLA_MuciSp]  'AR' ,@InvHdrInvDate ,@InvHdrCustNum, @CustaddrCurrCode,@ArinvZlaArTypeId,@InvHdrZlaForExchRate,NULL		
	    
		select * from #temp_ar_tax_out
	    IF EXISTS ( SELECT 1 FROM 	#temp_ar_tax_out )
	    BEGIN
		  DECLARE ZlaTaxOutCur CURSOR LOCAL STATIC
			FOR SELECT
				    [tax_type_id]
					,[tax_group_id]
					,[base_amount]
					,[base_amount_country]
					,[tax_amount]
					,[tax_amount_country]
					,[tax_percent]
				    FROM
				    #temp_ar_tax_out

			OPEN ZlaTaxOutCur
			WHILE 1 = 1
				BEGIN

				   FETCH ZlaTaxOutCur INTO 
				    @tax_type_id 
				   ,@tax_group_id 
				   ,@base_amount 
				   ,@base_amount_country
				   ,@tax_amount 
				   ,@tax_amount_country 
				   ,@tax_percent

					IF @@FETCH_STATUS <> 0
						BREAK

					SET @InvStaxRowPointer = NULL
					SET @InvStaxSeq = 0

					SET @TTaxSeq = 0
					SET @TTaxSeq2 = 0

					SELECT TOP 1 -- last
						@TTaxSeq = seq
					FROM inv_stax
					WHERE
					inv_num = @InvHdrInvNum
					AND inv_seq = @InvHdrInvSeq
					ORDER BY  inv_num	,inv_seq ,seq DESC

					SET @TTaxSeq = ISNULL(@TTaxSeq, 0)
					SET @TTaxSeq2 = @TTaxSeq + 1


					-- Load Tax System, Tax Code and Tax Account for Tax Group
				    SELECT   @InvStaxTaxSystem = grp.tax_system
								 ,@InvStaxTaxCode	  = grp.tax_code
								 ,@InvStaxStaxAcct	= grp.ACCOUNT_ID 
							FROM zla_tax_group grp
							WHERE grp.GROUP_ID = @tax_group_id

					SET @InvStaxRowPointer = newid()
					SET @InvStaxInvNum = @InvHdrInvNum
					SET @InvStaxInvSeq = @InvHdrInvSeq
					SET @InvStaxSeq = @TTaxSeq2
					SET @InvStaxStaxAcctUnit1 = NULL
					SET @InvStaxStaxAcctUnit2 = NULL
					SET @InvStaxStaxAcctUnit3 = NULL
					SET @InvStaxStaxAcctUnit4 = NULL
					SET @InvStaxInvDate = @InvHdrTaxDate
					SET @InvStaxCustNum = @InvHdrCustNum
					SET @InvStaxCustSeq = @InvHdrCustSeq
					SET @InvStaxTaxBasis = @base_amount_country
					SET @InvStaxTaxRate = @tax_percent
					SET @InvStaxTaxJur = NULL
					SET @InvStaxTaxCodeE = NULL
					SET @InvStaxSalesTax = @tax_amount_country 

					SET @InvStaxZlaForSalesTax = @tax_amount
					SET @InvStaxZlaForTaxBasis = @base_amount
					SET @InvStaxZlaTaxGroupId = @tax_group_id

					SET @InvStaxZlaRefType = 'R'
					SET @InvStaxzlaRefNum	 = @InvHdrCoNum --@RmaRmaNum
					SET @InvStaxZlaRefLineSuf		= 0
					SET @InvStaxzlaRefRelease		= 0

				     -- Accumulate Tax based on tax system defined for tax group 
					SET @TSalesTax  = @TSalesTax + (CASE WHEN @InvStaxTaxSystem = 1 THEN @InvStaxSalesTax ELSE 0 END)
					SET @TSalesTax2 = @TSalesTax2  + (CASE WHEN @InvStaxTaxSystem = 2 THEN @InvStaxSalesTax ELSE 0 END)

					SET @ZlaTSalesTax  = @ZlaTSalesTax  + (CASE WHEN @InvStaxTaxSystem = 1 THEN @InvStaxZlaForSalesTax ELSE 0 END)
					SET @ZlaTSalesTax2 = @ZlaTSalesTax2 +  (CASE WHEN @InvStaxTaxSystem = 2 THEN @InvStaxZlaForSalesTax ELSE 0 END)



					IF ( EXISTS(SELECT 1 from tax_system 
									Where tax_system = @InvStaxTaxSystem
									And record_zero = 1 ) OR @InvStaxSalesTax <> 0 )
						BEGIN 
							
							INSERT INTO
							    inv_stax
								(
									inv_num
								,inv_seq
								,seq
								,tax_code
								,stax_acct
								,stax_acct_unit1
								,stax_acct_unit2
								,stax_acct_unit3
								,stax_acct_unit4
								,inv_date
								,cust_num
								,cust_seq
								,tax_basis
								,tax_system
								,tax_rate
								,tax_jur
								,tax_code_e
								,sales_tax
								,zla_for_sales_tax
								,zla_for_tax_basis
								,zla_tax_group_id
								,zla_ref_type
								,zla_ref_num
								,zla_ref_line_suf
								,zla_ref_release
								)
							VALUES
								(
									@InvStaxInvNum
								,@InvStaxInvSeq
								,@InvStaxSeq
								,@InvStaxTaxCode
								,@InvStaxStaxAcct
								,@InvStaxStaxAcctUnit1
								,@InvStaxStaxAcctUnit2
								,@InvStaxStaxAcctUnit3
								,@InvStaxStaxAcctUnit4
								,@InvStaxInvDate
								,@InvStaxCustNum
								,@InvStaxCustSeq
								,-(@InvStaxTaxBasis)
								,@InvStaxTaxSystem
								,@InvStaxTaxRate
								,@InvStaxTaxJur
								,@InvStaxTaxCodeE
								,-(@InvStaxSalesTax)
								,-(@InvStaxZlaForSalesTax)
								,-(@InvStaxZlaForTaxBasis)
								,@InvStaxZlaTaxGroupId
								,@InvStaxZlaRefType
								,@InvStaxZlaRefNum
								,@InvStaxZlaRefLineSuf
								,@InvStaxZlaRefRelease
								)

						END
					END
			CLOSE ZlaTaxOutCur
			DEALLOCATE ZlaTaxOutCur

		END
		
	  IF @RmaMiscCharges <> 0
      BEGIN
         SET @TDistSeq = @TDistSeq + 5
         INSERT INTO arinvd (
            cust_num, inv_num, dist_seq, acct,
            amount, acct_unit1, acct_unit2, acct_unit3, acct_unit4,
            ref_line_suf, ref_release, tax_basis, tax_system)
         VALUES (
            @ArinvCustNum, @TInvNum, @TDistSeq, @ArparmsMiscAcct,
            @RmaMiscCharges, @ArparmsMiscAcctUnit1, @ArparmsMiscAcctUnit2, @ArparmsMiscAcctUnit3, @ArparmsMiscAcctUnit4,
            0, 0, 0, 0)

         UPDATE inv_hdr
         SET inv_hdr.misc_acct = @ArparmsMiscAcct,
            inv_hdr.misc_acct_unit1 = @ArparmsMiscAcctUnit1,
            inv_hdr.misc_acct_unit2 = @ArparmsMiscAcctUnit2,
            inv_hdr.misc_acct_unit3 = @ArparmsMiscAcctUnit3,
            inv_hdr.misc_acct_unit4 = @ArparmsMiscAcctUnit4
         WHERE
            inv_hdr.inv_num = @InvHdrInvNum AND inv_hdr.inv_seq = @InvHdrInvSeq
      END
      IF @RmaFreight <> 0
      BEGIN
         SET @TDistSeq = @TDistSeq + 5
         INSERT INTO arinvd (
            cust_num, inv_num, dist_seq, acct,
            amount, acct_unit1, acct_unit2, acct_unit3, acct_unit4,
            ref_line_suf, ref_release, tax_basis, tax_system)
         VALUES (
            @ArinvCustNum, @TInvNum, @TDistSeq, @ArparmsFreightAcct,
            @RmaFreight, @ArparmsFreightAcctUnit1, @ArparmsFreightAcctUnit2, @ArparmsFreightAcctUnit3, @ArparmsFreightAcctUnit4,
            0, 0, 0, 0)

         UPDATE inv_hdr
         SET inv_hdr.freight_acct = @ArparmsFreightAcct,
            inv_hdr.freight_acct_unit1 = @ArparmsFreightAcctUnit1,
            inv_hdr.freight_acct_unit2 = @ArparmsFreightAcctUnit2,
            inv_hdr.freight_acct_unit3 = @ArparmsFreightAcctUnit3,
            inv_hdr.freight_acct_unit4 = @ArparmsFreightAcctUnit4
         WHERE
            inv_hdr.inv_num = @InvHdrInvNum AND inv_hdr.inv_seq = @InvHdrInvSeq
      END

      DELETE FROM @temp_inv_stax
      INSERT INTO @temp_inv_stax (
        temp_cust_num
      , temp_inv_num
      , temp_dist_seq
      , temp_acct
      , temp_amount
      , temp_acct_unit1
      , temp_acct_unit2
      , temp_acct_unit3
      , temp_acct_unit4
      , temp_tax_system
      , temp_tax_code
      , temp_tax_code_e
      , temp_tax_basis
      , temp_ref_line_suf
      , temp_ref_release
	 , zla_tax_group_id
      )
      SELECT
        @ArinvCustNum
      , @TInvNum
      , @TDistSeq
      , inv_stax.stax_acct
      , - inv_stax.sales_tax
      , inv_stax.stax_acct_unit1
      , inv_stax.stax_acct_unit2
      , inv_stax.stax_acct_unit3
      , inv_stax.stax_acct_unit4
      , inv_stax.tax_system
      , inv_stax.tax_code
      , inv_stax.tax_code_e
      , - inv_stax.tax_basis
      , 0
      , 0
	 , zla_tax_group_id
      FROM inv_stax
      WHERE inv_stax.inv_num = @InvHdrInvNum AND inv_stax.inv_seq = @InvHdrInvSeq

      UPDATE @temp_inv_stax
      SET temp_dist_seq = @TDistSeq, @TDistSeq = @TDistSeq + 5
	  
	  INSERT INTO arinvd (
      cust_num, inv_num, dist_seq, acct,
      amount, acct_unit1, acct_unit2, acct_unit3, acct_unit4,
      tax_system, tax_code, tax_code_e, tax_basis,
      ref_line_suf, ref_release
	 , zla_for_amount
	 , zla_for_tax_basis
	 , zla_tax_group_id
	 )
      SELECT 
			temp_cust_num     
			, temp_inv_num      
			, temp_dist_seq     
			, temp_acct         
			, temp_amount       
			, temp_acct_unit1   
			, temp_acct_unit2   
			, temp_acct_unit3   
			, temp_acct_unit4   
			, temp_tax_system   
			, temp_tax_code     
			, temp_tax_code_e   
			, temp_tax_basis    
			, temp_ref_line_suf 
			, temp_ref_release  
			, zla_for_tax_basis	 
			, zla_for_sales_tax	 
			, zla_tax_group_id
      FROM @temp_inv_stax

	  
		/* ZLA MultiCurrency
				Update all ZLA_FOR fields based on standard amounts and Invoice ExchRate
			*/ 
	 IF @ArinvZlaForCurrCode = @CustaddrCurrCode 
	 BEGIN
		 UPDATE arinvd SET   zla_for_amount= amount
					    , zla_for_tax_basis = tax_basis
			  Where cust_num = @InvHdrCustNum
			  AND   inv_num = @InvHdrInvNum 	
			  AND   inv_seq = @InvHdrInvSeq

		 UPDATE inv_stax SET zla_for_sales_tax = sales_tax
						, zla_for_tax_basis = tax_basis			
		   	  Where cust_num = @InvHdrCustNum
			  AND   inv_num = @InvHdrInvNum 	
			  AND   inv_seq = @InvHdrInvSeq

	END
	 ELSE	
	 BEGIN		 -- Multicurr, convert customer currency to txn curr
	    Declare TmpArinvdCur CURSOR LOCAL STATIC FOR
	    SELECT amount
			 ,tax_basis
			 ,RowPointer
		 FROM arinvd
		  Where cust_num = @InvHdrCustNum
		  AND   inv_num = @InvHdrInvNum 	
		  AND   inv_seq = @InvHdrInvSeq

		OPEN TmpArinvdCur
		WHILE 1=1
		BEGIN
		   FETCH TmpArinvdCur INTO
			 @ArinvdAmount
			,@ArinvdTaxBasis
			,@ArinvdRowPointer

		  IF @@FETCH_STATUS <> 0
			BREAK

		  EXECUTE [CurrCnvtSp] 
				  @CurrCode = @ArinvZlaForCurrCode
				 ,@FromDomestic = 1
				 ,@RoundResult = 1
				 ,@UseBuyRate = 0
				 ,@Date = NULL
				 ,@TRate = @ArinvZlaForExchRate OUTPUT
				 ,@Infobar = @Infobar OUTPUT
				 ,@Amount1 = @ArinvdAmount
				 ,@Result1 = @ArinvdZlaForAmount OUTPUT
				 ,@Amount2 = @ArinvdTaxBasis
				 ,@Result2 = @ArinvdZlaForTaxBasis OUTPUT


		  UPDATE arinvd SET zla_for_amount= @ArinvdZlaForAmount
				, zla_for_tax_basis = @ArinvdZlaForTaxBasis
				WHERE RowPointer = @ArinvdRowPointer

	    END

	CLOSE TmpArinvdCur
	DEALLOCATE TmpArinvdCur
	
	Declare TmpInvStaxCur CURSOR LOCAL STATIC FOR
	SELECT sales_tax
				 ,tax_basis
				 ,Seq
		 FROM inv_stax
			Where inv_num = @InvHdrInvNum 
			  AND inv_seq = @InvHdrInvSeq


	OPEN TmpInvStaxCur
	WHILE 1=1
	BEGIN
		FETCH TmpInvStaxCur INTO
					 @InvStaxSalesTax
					,@InvStaxTaxBasis
					,@InvStaxSeq

		 IF @@FETCH_STATUS <> 0
				BREAK

		 EXECUTE [CurrCnvtSp] 
					  @CurrCode = @ArinvZlaForCurrCode
					 ,@FromDomestic = 1
					 ,@RoundResult = 1
					 ,@UseBuyRate = 0
					 ,@Date = NULL
					 ,@TRate = @ArinvZlaForExchRate OUTPUT
					 ,@Infobar = @Infobar OUTPUT
					 ,@Amount1 = @InvStaxSalesTax
					 ,@Result1 = @InvStaxZlaForSalesTax OUTPUT
					 ,@Amount2 = @InvStaxTaxBasis
					 ,@Result2 = @InvStaxZlaForTaxBasis OUTPUT

				UPDATE inv_stax SET zla_for_sales_tax = @InvStaxZlaForSalesTax
							   , zla_for_tax_basis = @InvStaxZlaForTaxBasis
				FROM inv_stax
				Where inv_num = @InvHdrInvNum 
				  AND inv_seq = @InvHdrInvSeq
				  AND seq = @InvStaxSeq


	END

	CLOSE TmpInvStaxCur
	DEALLOCATE TmpInvStaxCur
     			
		END		-- END IF MultiCurrency flag = 0


	  -- Calculate the Sales Amount after currency conversion due rounding problems.
	    SELECT  @ZlaTSalesTax = SUM(CASE WHEN tax_system = 1 Then zla_for_amount ELSE 0 END )
		  , @ZlaTSalesTax2 = SUM(CASE WHEN tax_system = 2 Then zla_for_amount ELSE 0 END )
	    FROM arinvd 
	    Where inv_num = @InvHdrInvNum 	
	    AND   inv_seq = @InvHdrInvSeq

      SET @TSalesTax = @TSalesTax + @TAccRestTax1
      SET @TSalesTax2 = @TSalesTax2 + @TAccRestTax2
      SET @InvHdrPrice = @TSubTotal + @InvHdrMiscCharges + @TSalesTax + @TSalesTax2 + @InvHdrFreight

      IF @TaxparmsCashRound > 0
      BEGIN
         SET @TermsRowPointer = NULL
         SET @TermsCashOnly   = 0
         SELECT
           @TermsRowPointer = terms.RowPointer
         , @TermsCashOnly   = terms.cash_only
         FROM terms with (readuncommitted)
         WHERE terms.terms_code = @BillToCustomerTermsCode

         IF @TermsRowPointer IS NOT NULL AND @TermsCashOnly = 1
         BEGIN
            SET @TAdjPrice = round(@InvHdrPrice / @TaxparmsCashRound, 0, 1) * @TaxparmsCashRound
            IF @TAdjPrice <> @InvHdrPrice
            BEGIN
               SET @TAdjPrice   = @TAdjPrice - @InvHdrPrice
               SET @InvHdrPrice = @InvHdrPrice + @TAdjPrice
               SET @TSubTotal   = @TSubTotal   + @TAdjPrice

               UPDATE arinvd
               SET arinvd.amount = arinvd.amount - @TAdjPrice
               WHERE
                  arinvd.cust_num = @InvHdrCustNum AND
                  arinvd.inv_num = @InvHdrInvNum AND
                  arinvd.inv_seq = @InvHdrInvSeq AND
                  arinvd.dist_seq = @TDistSeq
            END
         END
      END

      SET @TSubTotal        = - @TSubTotal
      SET @ArinvSalesTax    = - @TSalesTax
      SET @ArinvSalesTax2   = - @TSalesTax2
      SET @ArinvMiscCharges = @RmaMiscCharges
      SET @ArinvFreight     = @RmaFreight
      SET @ArinvAmount      = @TSubTotal

      SET @ArinvZlaForMiscCharges = @RmaZlaForMiscCharges
      SET @ArinvZlaForFreight     = @RmaZlaForFreight

      SET @TmpBalAdj = 0
      EXEC @TmpBalAdj = dbo.ArBalSp 'C', @ArinvMiscCharges, @ArinvFreight, @ArinvSalesTax, @ArinvAmount, @ArinvSalesTax2
      SET @BalAdj           = @BalAdj + @TmpBalAdj

	 IF @ArinvZlaForCurrCode = @CustaddrCurrCode
	 BEGIN
	    SET @InvHdrZlaForPrice = @InvHdrPrice
	    SET @ArinvZlaForSalesTax = @ArinvSalesTax
	    SET @ArinvZlaForSalesTax2 = @ArinvSalesTax2
	    SET @ArinvZlaForAmount      = @ArinvAmount
	 END
	 ELSE  -- MultiCurrency Invoice
	 BEGIN
		  EXECUTE [CurrCnvtSp] 
				  @CurrCode = @ArinvZlaForCurrCode
				 ,@FromDomestic = 1
				 ,@RoundResult = 1
				 ,@UseBuyRate = 0
				 ,@Date = NULL
				 ,@TRate = @ArinvZlaForExchRate OUTPUT
				 ,@Infobar = @Infobar OUTPUT
				 ,@Amount1 = @InvHdrPrice
				 ,@Result1 = @InvHdrZlaForPrice OUTPUT
				 ,@Amount4 = @ArinvAmount
				 ,@Result4 = @ArinvZlaForAmount OUTPUT


	 END	

	 UPDATE inv_hdr
      SET inv_hdr.price = @InvHdrPrice,
         inv_hdr.misc_charges = @InvHdrMiscCharges,
         inv_hdr.freight = @InvHdrFreight,
	    inv_hdr.zla_for_price = @InvHdrPrice,
	    inv_hdr.zla_for_misc_charges = @InvHdrMiscCharges,
	    inv_hdr.zla_for_freight = @InvHdrPrice

      WHERE inv_hdr.RowPointer = @InvHdrRowPointer

      UPDATE arinv
      SET arinv.sales_tax = @ArinvSalesTax,
         arinv.sales_tax_2 = -(@ArinvSalesTax2),
         arinv.misc_charges = @ArinvMiscCharges,
         arinv.freight = @ArinvFreight,
         arinv.amount = @ArinvAmount,
	    arinv.zla_for_sales_tax = @ArinvSalesTax,
	    arinv.zla_for_sales_tax_2 = -(@ArinvSalesTax2),
	    arinv.zla_for_misc_charges = @ArinvMiscCharges,
	    arinv.zla_for_freight = @ArinvFreight,
	    arinv.zla_for_amount = @ArinvAmount
	    
      WHERE arinv.RowPointer = @ArinvRowPointer
	
	  update co
	  set co.zpv_inv_num = @TInvNum
	  where co.co_num = @ArinvCoNum

	  declare CurCoBlnCredit cursor for
	  select
			rmai.co_line
		,	rmai.qty_credited
	  from rmaitem rmai
	  where	rmai.co_num = @CoCoNum	
		and	rmai.rma_num = @RmaRmaNum
	  open CurCoBlnCredit
	  fetch next from CurCoBlnCredit
	  into
			@CoBlnRmaCoLine
		,	@CoBlnRmaQtyCredited
	  while @@FETCH_STATUS = 0
	  begin
		  update co_bln
				set co_bln.zpv_qty_invoiced = co_bln.zpv_qty_invoiced - @CoBlnRmaQtyCredited
		  where co_bln.co_num = @CoCoNum
			and co_bln.co_line = @CoBlnRmaCoLine
		  fetch next from CurCoBlnCredit
		  into
				@CoBlnRmaCoLine
			,	@CoBlnRmaQtyCredited
	  end
	  close CurCoBlnCredit
	  deallocate CurCoBlnCredit			  		

      SET @RmaSalesTax    = - @TSalesTax
      SET @RmaSalesTax2  = - @TSalesTax2
	 
	 SET @RmaZlaForSalesTax = - @ZlaTSalesTax
	 SET @RmaZlaForSalesTax2  = -@ZlaTSalesTax2 
	    

      SET @TmpBalAdj = 0
      EXEC @TmpBalAdj = dbo.RmaBalSp @RmaMiscCharges, @RmaFreight, @RmaSalesTax, @RmaSalesTax2
      SET @BalAdj = @BalAdj + @TmpBalAdj

      SET @RmaMChargesT  = @RmaMChargesT - @InvHdrMiscCharges
      SET @RmaFreightT    = @RmaFreightT   - @InvHdrFreight
      SET @RmaSalesTaxT  = @RmaSalesTaxT  - @TSalesTax
      SET @RmaSalesTaxT2 = @RmaSalesTaxT2 - @TSalesTax2
	 -- ZLA
      SET @RmaZlaForSalesTaxT  = @RmaZlaForSalesTaxT  - @ZlaTSalesTax
      SET @RmaZlaForSalesTaxT2 = @RmaZlaForSalesTaxT2 - @ZlaTSalesTax2
      SET @RmaZlaForMChargesT  = @RmaZlaForMChargesT - @InvHdrZlaForMiscCharges
      SET @RmaZlaForFreightT    = @RmaZlaForFreightT   - @InvHdrZlaForFreight
	   
      SET @RmaMiscCharges = 0
      SET @RmaFreight      = 0
      SET @RmaSalesTax    = 0
      SET @RmaSalesTax2  = 0

      SET @RmaZlaForMiscCharges = 0
      SET @RmaZlaForFreight      = 0
      SET @RmaZlaForSalesTax    = 0
      SET @RmaZlaForSalesTax2  = 0


      SET @TmpBalAdj = 0
      EXEC @TmpBalAdj = dbo.RmaBalSp @RmaMiscCharges, @RmaFreight, @RmaSalesTax, @RmaSalesTax2
      SET @BalAdj = @BalAdj - @TmpBalAdj

      EXEC dbo.DefineVariableSp 'RMACreditMemo', '1', @Infobar output
      UPDATE rma
      SET rma.sales_tax = @RmaSalesTax,
         rma.sales_tax_2 = @RmaSalesTax2,
         rma.m_charges_t = @RmaMChargesT,
         rma.freight_t = @RmaFreightT,
         rma.sales_tax_t = @RmaSalesTaxT,
         rma.sales_tax_t2 = @RmaSalesTaxT2,
         rma.misc_charges = @RmaMiscCharges,
         rma.freight = @RmaFreight
	    , rma.zla_for_freight = @RmaZlaForFreight
	    , rma.zla_for_freight_t = @RmaZlaForFreightT
	    , rma.zla_for_m_charges_t = @RmaZlaForMChargesT
	    , rma.zla_for_misc_charges = @RmaZlaForMiscCharges
	    , rma.zla_for_sales_tax = @RmaZlaForSalesTax
	    , rma.zla_for_sales_tax_2 = @RmaZlaForSalesTax2
	    , rma.zla_for_sales_tax_t2 = @RmaZlaForSalesTaxT2
	    , rma.zla_for_sales_tax_t = @RmaZlaForSalesTaxT
	 WHERE rma.RowPointer = @RmaRowPointer

      exec @Severity = dbo.SumRmaSp
        @PRmaNum = @RmaRmaNum
      , @RmaTotCredit = @NewTotCredit output
      , @Infobar = @Infobar output

      IF NOT EXISTS (SELECT 1 FROM rmaitem WHERE rmaitem.rma_num = @RmaRmaNum AND rmaitem.stat <> 'C')
      BEGIN
         UPDATE rma
         SET rma.stat = 'C'
         WHERE rma.RowPointer = @RmaRowPointer
      END

      EXEC dbo.UnDefineVariableSp 'RMACreditMemo', @Infobar output

      SET @TPrintInvNum = @TInvNum
      SET @PrintFlag = 0
      IF @CustomerEdiCust = 1
      BEGIN
         EXEC @Severity = dbo.EdiOutObDriverSp
              @PTranType = 'INVC'          /* Invoice */
            , @PCustNum  = @InvHdrCustNum
            , @PCustSeq  = @InvHdrCustSeq
            , @PInvNum   = @InvHdrInvNum
            , @PCoNum    = NULL
            , @PBolNum   = NULL
            , @PFlag     = @PrintFlag OUTPUT   /* Trading partner's print flag */
            , @Infobar   = @Infobar   OUTPUT

         IF @Severity <> 0
            GOTO EXIT_SP
      END
      SET @TInvCount = @TInvCount + 1
      set @CurrLinesDoc = @CurrLinesDoc + @LinesPerDoc
      IF @ArparmUsePrePrintedForms = 0
         break
   END /* while (@LoopLinesDoc > @CurrLinesDoc or @ArparmUsePrePrintedForms = 0) */

   /* ADJUST COMMISSION EARNED/DUE AMOUNT
    * on commdue row that was generated when original invoice was generated
    */
   IF @CoparmsDueOnPmt = 1 AND ISNULL(@RmaApplyToInvNum, '') <> '' AND
      CASE WHEN dbo.IsInteger(@RmaApplyToInvNum) = 1 THEN CONVERT(BIGINT, @RmaApplyToInvNum) ELSE 1 END > 0
   BEGIN
      SELECT
        @OInvHdrRowpointer  = NULL
      , @OInvHdrInvNum      = NULL
      , @OInvHdrInvSeq      = 0
      , @OInvHdrPrice       = 0
      , @OInvHdrPrepaidAmt  = 0
      , @OInvHdrFreight     = 0
      , @OInvHdrMiscCharges = 0
      , @OTaxAmt            = 0
      , @OInvSum            = 0

      SELECT
        @OInvHdrRowpointer  = inv_hdr.rowpointer
      , @OInvHdrInvNum      = inv_hdr.inv_num
      , @OInvHdrInvSeq      = inv_hdr.inv_seq
      , @OInvHdrPrice       = inv_hdr.price
      , @OInvHdrPrepaidAmt  = inv_hdr.prepaid_amt
      , @OInvHdrFreight     = inv_hdr.freight
      , @OInvHdrMiscCharges = inv_hdr.misc_charges
      FROM  inv_hdr WITH (UPDLOCK)
      WHERE inv_hdr.inv_num = @RmaApplyToInvNum
      AND   inv_hdr.inv_seq = 0

      IF @@ROWCOUNT <> 1
         SET @OInvHdrRowpointer = NULL

      IF @OInvHdrRowpointer IS NOT NULL
      BEGIN
         SELECT @OTaxAmt = SUM(ISNULL(inv_stax.sales_tax, 0))
         FROM  inv_stax
         WHERE inv_stax.inv_num = @OInvHdrInvNum
         AND   inv_stax.inv_seq = @OInvHdrInvSeq

         SET @OInvSum = ISNULL(@OInvHdrPrice, 0) + ISNULL(@OInvHdrPrepaidAmt, 0) -
                        ISNULL(@OInvHdrFreight, 0) - ISNULL(@OInvHdrMiscCharges, 0) - ISNULL(@OTaxAmt, 0)

         IF @OInvSum = 0
            SET @OInvSum = 1

         SET @TPerCent = CASE WHEN ABS(@TSubTotal) / @OInvSum > 1.0 THEN 1.0
                              ELSE ABS(@TSubTotal) / @OInvSum
                         END

         DECLARE commdue_crs CURSOR LOCAL STATIC FOR
         SELECT
           commdue.rowpointer
         , commdue.due_date
         , ISNULL(commdue.comm_due, 0)
         , ISNULL(commdue.comm_calc, 0)
         FROM  commdue WITH (UPDLOCK)
         WHERE commdue.inv_num = @RmaApplyToInvNum

         OPEN commdue_crs
         WHILE 1 = 1
         BEGIN
            FETCH commdue_crs INTO
              @CommdueRowpointer
            , @CommdueDueDate
            , @CommdueCommDue
            , @CommdueCommCalc

            IF @@FETCH_STATUS <> 0
               BREAK

            SET @CommdueDueDate = @TCrmDate
            SET @CommdueCommDue = CASE WHEN @CommdueCommCalc >= 0
                                          THEN dbo.MinAmt(@CommdueCommCalc, @CommdueCommDue + ROUND((@CommdueCommCalc * @TPerCent), @DomCurrPlaces))
                                       ELSE dbo.MaxAmt(@CommdueCommCalc, @CommdueCommDue + ROUND((@CommdueCommCalc * @TPerCent), @DomCurrPlaces))
                                  END

            UPDATE commdue
            SET
              due_date = @CommdueDueDate
            , comm_due = @CommdueCommDue
            WHERE rowpointer = @CommdueRowpointer
         END
         CLOSE commdue_crs
         DEALLOCATE commdue_crs

      END /* IF @OInvHdrRowpointer IS NOT NULL */

   END /* IF @CoparmsDueOnPmt = 1 AND @RmaApplyToInvNum IS NOT NULL */

END /* CrmPostSp1Crs WHILE @Severity = 0 */
CLOSE CrmPostSp1Crs
DEALLOCATE CrmPostSp1Crs

IF @BRmaNum = @ERmaNum
BEGIN
   SET @Invoice = 1
   SET @BRmaLine = ISNULL(@BRmaLine, 0)
   SET @ERmaLine = ISNULL(@ERmaLine, 32767)   -- max value of smallint
   SET @BLastReturnDate = ISNULL(@BLastReturnDate, dbo.LowDate())
   SET @ELastReturnDate = ISNULL(@ELastReturnDate, dbo.HighDate())

   IF EXISTS (SELECT 1
              FROM rmaitem item (NOLOCK)
              WHERE item.rma_num = @BRmaNum
              AND((item.return_item = 1 AND item.qty_received > item.qty_credited)
                 OR (item.return_item = 0 AND item.qty_to_return > item.qty_credited))
              AND item.stat IN ('O', 'F')
              AND item.rma_line BETWEEN @BRmaLine AND @ERmaLine
              AND ((item.last_return_date BETWEEN @BLastReturnDate AND @ELastReturnDate) OR item.last_return_date IS NULL)
              AND item.enable_rma_dispositions = 1
              AND item.qty_to_return <> (SELECT ISNULL(SUM(qty_disp), 0) FROM rmaitem_disp disp (NOLOCK) 
                                         WHERE disp.rma_num = item.rma_num
                                         AND   disp.rma_line = item.rma_line
                                         AND   disp.posted = 1)
          )

   BEGIN
      SET @Invoice = 0
   END
END
select * from arinvd where inv_num = @TInvNum 
EXIT_SP:
IF @ReleaseTmpTaxTables = 1
   EXEC dbo.ReleaseTmpTaxTablesSp @SessionId

if @Infobar IS NULL
   EXEC @TTemp = dbo.MsgAppSp @Infobar OUTPUT, 'E=FormPrt'
      , @TInvCount

RETURN @Severity


GO

