/****** Object:  StoredProcedure [dbo].[ZPV_InvPostPSp]    Script Date: 16/01/2015 03:14:50 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_InvPostPSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_InvPostPSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_InvPostPSp]    Script Date: 16/01/2015 03:14:50 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* $Header: /ApplicationDB/Stored Procedures/InvPostPSp.sp 68    2/20/13 4:10a exia $  */
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

CREATE PROCEDURE [dbo].[ZPV_InvPostPSp] (
  @InvCred               NCHAR(1)      = 'I'
, @InvDate               DateType      = NULL
, @StartCustomer         CustNumType   = NULL
, @EndCustomer           CustNumType   = NULL
, @StartOrderNum         CoNumType     = NULL
, @EndOrderNum           CoNumType     = NULL
, @StartLine             CoLineType    = NULL
, @EndLine               CoLineType    = NULL
, @StartRelease          CoReleaseType = NULL
, @EndRelease            CoReleaseType = NULL
, @pMooreForms           nvarchar(1)   = 'N'
, @TInvNum               InvNumType    = '0'    OUTPUT
, @StartInvNum           InvNumType    = Null   OUTPUT
, @EndInvNum             InvNumType    = Null   OUTPUT
, @Infobar               InfobarType   = Null   OUTPUT
, @ProcessId             RowPointerType = NULL
, @InvoiceCount int = 0 output
, @EDINoPaperInvoiceCount  int = 0 OUTPUT
, @CalledFrom              InfobarType    = NULL -- can be InvoiceBuilder or NULL           
, @InvoicBuilderProcessID  RowpointerType = NULL
, @ApplyToInvNum		InvNumType = NULL
) AS


DECLARE
  @PrintFlag     FlagNyType
, @ProjAccum     AmountType
, @Severity      INT
, @TPrepaidAmt   AmountType
, @TDistSeq      GenericNoType
, @TSalesTax     GenericDecimalType
, @TSalesTax2    GenericDecimalType
, @TInvStaxSeq   GenericNoType
, @TError        FlagNyType
, @TCurSlsman    SlsmanType
, @TLoopCounter  GenericNoType
, @TCommCalc     GenericDecimalType
, @TCommBase     GenericDecimalType
, @TOpen         ReferenceType
, @TAr           ReferenceType
, @TArCredit     ReferenceType
, @TInvLabel     ReferenceType
, @TCrMemo       ReferenceType
, @TTaxSeq       GenericNoType
, @TotPbillAmt   AmountType
, @ProgBillCnt   Integer
, @TRevPercent   CommPercentType
, @TCommPercent  CommPercentType
, @TCoLine       CoLineType
, @TCommBaseTot  GenericDecimalType
, @TEndAr        AcctType
, @TEndArUnit1   UnitCode1Type
, @TEndArUnit2   UnitCode2Type
, @TEndArUnit3   UnitCode3Type
, @TEndArUnit4   UnitCode4Type
, @TEndAcct      AcctType
, @TEndAcctUnit1 UnitCode1Type
, @TEndAcctUnit2 UnitCode2Type
, @TEndAcctUnit3 UnitCode3Type
, @TEndAcctUnit4 UnitCode4Type
, @TRate         ExchRateType
, @TResultAmt    AmountType
, @TLastTran     InvNumType
, @TOrderBal     AmountType
, @NewRowPointer RowPointerType
, @TaxInclDiscount      ListYesNoType
, @Tax1OnAmount         AmountType
, @Tax2OnAmount         AmountType
, @Tax1OnDiscAmount     AmountType
, @Tax2OnDiscAmount     AmountType
, @Tax1OnUndiscAmount   AmountType
, @Tax2OnUndiscAmount   AmountType
, @TotalTaxOnDiscAmount AmountType
, @DiscAmountInclTax    AmountType
, @DiscAmountInclTax2   AmountType
, @CoIncludeTaxInPrice  ListYesNoType
, @OLvlDiscLineNet      CostPrcType
, @TLineTot             AmountType
, @TLineNet             AmountType
, @xAmount1             AmountType
, @CoDisc               GenericDecimalType
, @TSubTotFull          AmountType


DECLARE
  @ArinvdRowPointer       RowPointerType
, @ArinvdCustNum          CustNumType
, @ArinvdInvNum           InvNumType
, @ArinvdDistSeq          ArDistSeqType
, @ArinvdAmount           AmountType
, @ArinvdAcct             AcctType
, @ArinvdAcctUnit1        UnitCode1Type
, @ArinvdAcctUnit2        UnitCode2Type
, @ArinvdAcctUnit3        UnitCode3Type
, @ArinvdAcctUnit4        UnitCode4Type
, @ArinvdTaxSystem        TaxSystemType
, @ArinvdTaxCode          TaxCodeType
, @ArinvdTaxCodeE         TaxCodeType
, @ArinvdTaxBasis         AmountType

, @ArParmsRowPointer      RowPointerType
, @ArparmsArAcct          AcctType
, @ArparmsArAcctUnit1     UnitCode1Type
, @ArparmsArAcctUnit2     UnitCode2Type
, @ArparmsArAcctUnit3     UnitCode3Type
, @ArparmsArAcctUnit4     UnitCode4Type
, @ArparmsProjAcct        AcctType
, @ArparmsProjAcctUnit1   UnitCode1Type
, @ArparmsProjAcctUnit2   UnitCode2Type
, @ArparmsProjAcctUnit3   UnitCode3Type
, @ArparmsProjAcctUnit4   UnitCode4Type
, @ArparmsProgAcct        AcctType
, @ArparmsProgAcctUnit1   UnitCode1Type
, @ArparmsProgAcctUnit2   UnitCode2Type
, @ArparmsProgAcctUnit3   UnitCode3Type
, @ArparmsProgAcctUnit4   UnitCode4Type
, @ArparmsFreightAcct        AcctType
, @ArparmsFreightAcctUnit1   UnitCode1Type
, @ArparmsFreightAcctUnit2   UnitCode2Type
, @ArparmsFreightAcctUnit3   UnitCode3Type
, @ArparmsFreightAcctUnit4   UnitCode4Type
, @ArparmsMiscAcct        AcctType
, @ArparmsMiscAcctUnit1   UnitCode1Type
, @ArparmsMiscAcctUnit2   UnitCode2Type
, @ArparmsMiscAcctUnit3   UnitCode3Type
, @ArparmsMiscAcctUnit4   UnitCode4Type
, @ArparmsSalesDiscAcct        AcctType
, @ArparmsSalesDiscAcctUnit1   UnitCode1Type
, @ArparmsSalesDiscAcctUnit2   UnitCode2Type
, @ArparmsSalesDiscAcctUnit3   UnitCode3Type
, @ArparmsSalesDiscAcctUnit4   UnitCode4Type
, @ArparmsSalesAcct        AcctType
, @ArparmsSalesAcctUnit1   UnitCode1Type
, @ArparmsSalesAcctUnit2   UnitCode2Type
, @ArparmsSalesAcctUnit3   UnitCode3Type
, @ArparmsSalesAcctUnit4   UnitCode4Type
, @ArparmUsePrePrintedForms  ListYesNoType
, @ArparmLinesPerInv      LinesPerDocType
, @ArparmLinesPerDM       LinesPerDocType
, @ArparmLinesPerCM       LinesPerDocType
, @ArparmsNonInvAcct  AcctType       --For noninv items
, @ArparmsNonInvAcctUnit1   UnitCode1Type
, @ArparmsNonInvAcctUnit2   UnitCode2Type
, @ArparmsNonInvAcctUnit3   UnitCode3Type
, @ArparmsNonInvAcctUnit4   UnitCode4Type

, @ArtranRowPointer       RowPointerType
, @ArtranCustNum          CustNumType
, @ArtranInvNum           InvNumType

, @ArinvRowPointer        RowPointerType
, @ArinvCustNum           CustNumType
, @ArinvInvNum            InvNumType
, @ArinvApplyToInvNum     InvNumType
, @ArinvType              ArinvTypeType
, @ArinvPostFromCo        ListYesNoType
, @ArinvCoNum             CoNumType
, @ArinvInvDate           DateType
, @ArinvTaxCode1          TaxCodeType
, @ArinvTaxCode2          TaxCodeType
, @ArinvTermsCode         TermsCodeType
, @ArinvAcct              AcctType
, @ArinvAcctUnit1         UnitCode1Type
, @ArinvAcctUnit2         UnitCode2Type
, @ArinvAcctUnit3         UnitCode3Type
, @ArinvAcctUnit4         UnitCode4Type
, @ArinvRef               ReferenceType
, @ArinvDescription       DescriptionType
, @ArinvExchRate          ExchRateType
, @ArinvUseExchRate       ListYesNoType
, @ArinvPayType           CustPayTypeType
, @ArinvDraftPrintFlag    ListYesNoType
, @ArinvFixedRate         ListYesNoType
, @ArinvDueDate           DateType
, @ArinvDiscDate          DateType
, @ArinvInvSeq            ArInvSeqType
, @ArinvAmount            AmountType
, @ArinvMiscCharges       AmountType
, @ArinvFreight           AmountType
, @ArinvSalesTax          AmountType
, @ArinvSalesTax2         AmountType

, @BankAddrRowPointer     RowPointerType
, @BankAddrBankNumber     BankNumberType
, @BankAddrAddr##1        AddressType
, @BankAddrAddr##2        AddressType
, @BankAddrBranchCode     BranchCodeType

, @CoRowPointer           RowPointerType
, @CoCustNum              CustNumType
, @CoCustSeq              CustSeqType
, @CoCoNum                CoNumType
, @CoEndUserType          EndUserTypeType
, @CoTermsCode            TermsCodeType
, @CoShipCode             ShipCodeType
, @CoCustPo               CustPoType
, @CoWeight               WeightType
, @CoQtyPackages          PackagesType
, @CoFixedRate            ListYesNoType
, @CoExchRate             ExchRateType
, @CoUseExchRate          ListYesNoType
, @CoTaxCode1             TaxCodeType
, @CoTaxCode2             TaxCodeType
, @CoFrtTaxCode1          TaxCodeType
, @CoFrtTaxCode2          TaxCodeType
, @CoMscTaxCode1          TaxCodeType
, @CoMscTaxCode2          TaxCodeType
, @CoSlsman               SlsmanType
, @CoPrepaidAmt           AmountType
, @CoPrepaidT             AmountType
, @CoMiscCharges          AmountType
, @CoFreight              AmountType
, @CoSalesTax             AmountType
, @CoSalesTax2            AmountType
, @CoSalesTaxT            AmountType
, @CoSalesTaxT2           AmountType
, @CoInvoiced             ListYesNoType
, @CoLcrNum               LcrNumType
, @CoPrice				  AmountType

, @CoitemRowPointer       RowPointerType
, @CoitemCoNum            CoNumType
, @CoitemCoLine           CoLineType
, @CoitemItem             ItemType
, @CoitemDisc             LineDiscType
, @CoitemProcessInd       ProcessIndType
, @CoitemConsNum          ConsignmentsType
, @CoitemTaxCode1         TaxCodeType
, @CoitemTaxCode2         TaxCodeType
, @CoitemPrice            AmountType
, @CoitemQtyOrdered       QtyUnitNoNegType
, @CoitemQtyShipped       QtyUnitNoNegType
, @CoitemQtyReturned      QtyUnitNoNegType
, @CoitemQtyInvoiced      QtyUnitNoNegType
, @CoitemStat             CoitemStatusType
, @CoitemPrgBillTot       AmountType
, @CoitemPrgBillApp       AmountType
, @CoitemCoRelease        CoReleaseType
, @CoitemShipDate         DateType
, @CoitemRefType          RefTypeIJKPRTType
, @CoitemRefNum           JobPoProjReqTrnNumType
, @CoitemRefLineSuf       SuffixPoLineProjTaskReqTrnLineType

, @CommdueInvNum          InvNumType
, @CommdueCoNum           CoNumType
, @CommdueSlsman          SlsmanType
, @CommdueCustNum         CustNumType
, @CommdueCommDue         AmountType
, @CommdueDueDate         DateType
, @CommdueCommCalc        AmountType
, @CommdueCommBase        AmountType
, @CommdueCommBaseSlsp    AmountType
, @CommdueSeq             CommdueSeqType
, @CommduePaidFlag        ListYesNoType
, @CommdueSlsmangr        SlsmanType
, @CommdueStat            CommdueStatusType
, @CommdueRef             ReferenceType
, @CommdueEmpNum          EmpNumType

, @CoParmsRowPointer      RowPointerType
, @CoParmsDueOnPmt        FlagNyType

, @CoSlsCommSlsman        SlsmanType
, @CoSlsCommRevPercent    CommPercentType
, @CoSlsCommCommPercent   CommPercentType
, @CoSlsCommCoLine        CoLineType

, @CountryRowPointer      RowPointerType
, @CountryEcCode          EcCodeType

, @CustdrftRowPointer     RowPointerType
, @CustdrftDraftNum       DraftNumType
, @CustdrftCustNum        CustNumType
, @CustdrftInvDate        DateType
, @CustdrftPaymentDueDate DateType
, @CustdrftAmount         AmountType
, @CustdrftExchRate       ExchRateType
, @CustdrftStat           CustdrftStatusType
, @CustdrftInvNum         InvNumType
, @CustdrftCoNum          CoNumType
, @CustdrftBankCode       BankCodeType
, @CustdrftCustBank       BankCodeType
, @CustdrftBankNumber     BankNumberType
, @CustdrftBankAddr##1    AddressType
, @CustdrftBankAddr##2    AddressType
, @CustdrftBranchCode     BranchCodeType
, @CustdrftPrintFlag      ListYesNoType
, @CustdrftEscalationCntr CustDraftEscalationType
, @CustdrftDunnDate       DateType

, @CustLcrRowPointer      RowPointerType
, @CustLcrShipValue       AmountType

, @CustomerRowPointer     RowPointerType
, @CustomerPayType        CustPayTypeType
, @CustomerDraftPrintFlag ListYesNoType
, @CustomerCustBank       BankCodeType
, @CustomerCustNum        CustNumType
, @CustomerBankCode       BankCodeType
, @CustomerEdiCust        ListYesNoType
, @CustaddrRowPointer     RowPointerType
, @CustaddrState          StateType
, @CustaddrCurrCode       CurrCodeType
, @CustaddrCountry        CountryType
, @CurrencyPlaces         DecimalPlacesType
, @CurrencyCurrCode       CurrCodeType

, @EndtypeRowPointer      RowPointerType
, @EndtypeArAcct          AcctType
, @EndtypeArAcctUnit1     UnitCode1Type
, @EndtypeArAcctUnit2     UnitCode2Type
, @EndtypeArAcctUnit3     UnitCode3Type
, @EndtypeArAcctUnit4     UnitCode4Type
, @EndtypeSalesDsAcct        AcctType
, @EndtypeSalesDsAcctUnit1   UnitCode1Type
, @EndtypeSalesDsAcctUnit2   UnitCode2Type
, @EndtypeSalesDsAcctUnit3   UnitCode3Type
, @EndtypeSalesDsAcctUnit4   UnitCode4Type
, @EndtypeSalesAcct          AcctType
, @EndtypeSalesAcctUnit1     UnitCode1Type
, @EndtypeSalesAcctUnit2     UnitCode2Type
, @EndtypeSalesAcctUnit3     UnitCode3Type
, @EndtypeSalesAcctUnit4     UnitCode4Type
, @EndtypeNonInvAcct         AcctType     --For Noninv item
, @EndtypeNonInvAcctUnit1    UnitCode1Type
, @EndtypeNonInvAcctUnit2    UnitCode2Type
, @EndtypeNonInvAcctUnit3    UnitCode3Type
, @EndtypeNonInvAcctUnit4    UnitCode4Type
, @EndtypeSurchargeAcct      AcctType
, @EndtypeSurchargeAcctUnit1 UnitCode1Type
, @EndtypeSurchargeAcctUnit2 UnitCode2Type
, @EndtypeSurchargeAcctUnit3 UnitCode3Type
, @EndtypeSurchargeAcctUnit4 UnitCode4Type

, @DistacctRowPointer        RowPointerType
, @DistacctSalesAcct         AcctType
, @DistacctSaleDsAcct        AcctType
, @DistacctSalesAcctUnit1    UnitCode1Type
, @DistacctSalesAcctUnit2    UnitCode2Type
, @DistacctSalesAcctUnit3    UnitCode3Type
, @DistacctSalesAcctUnit4    UnitCode4Type
, @DistacctSaleDsAcctUnit1   UnitCode1Type
, @DistacctSaleDsAcctUnit2   UnitCode2Type
, @DistacctSaleDsAcctUnit3   UnitCode3Type
, @DistacctSaleDsAcctUnit4   UnitCode4Type

, @ItemRowPointer            RowPointerType
, @ItemSerialTracked         ListYesNoType
, @ItemItem                  ItemType
, @ItemUWsPrice              CostPrcType
, @ItemProductCode           ProductCodeType
, @ItemSubjectToExciseTax    ListYesNoType
, @ItemExciseTaxPercent      ExciseTaxPercentType

, @ProdcodeRowPointer        RowPointerType
, @ProdcodeUnit              UnitCode2Type

, @TEndDisc      AcctType
, @TEndDiscUnit1 UnitCode1Type
, @TEndDiscUnit2 UnitCode2Type
, @TEndDiscUnit3 UnitCode3Type
, @TEndDiscUnit4 UnitCode4Type

, @TEndSales        AcctType
, @TEndSalesUnit1   UnitCode1Type
, @TEndSalesUnit2   UnitCode2Type
, @TEndSalesUnit3   UnitCode3Type
, @TEndSalesUnit4   UnitCode4Type

, @NonInventoryItem FlagNyType --For Noninv item
, @CoitemNonInvAcct  AcctType
, @CoitemNonInvAcctUnit1   UnitCode1Type
, @CoitemNonInvAcctUnit2   UnitCode2Type
, @CoitemNonInvAcctUnit3   UnitCode3Type
, @CoitemNonInvAcctUnit4   UnitCode4Type

, @ZpvParmsCtrlFiscal	  ListYesNoType

, @InvHdrRowPointer       RowPointerType
, @InvHdrInvNum           InvNumType
, @InvHdrInvSeq           InvSeqType
, @InvHdrCustNum          CustNumType
, @InvHdrCustSeq          CustSeqType
, @InvHdrCoNum            CoNumType
, @InvHdrInvDate          DateType
, @InvHdrTermsCode        TermsCodeType
, @InvHdrShipCode         ShipCodeType
, @InvHdrCustPo           CustPoType
, @InvHdrWeight           WeightType
, @InvHdrQtyPackages      PackagesType
, @InvHdrBillType         BillingTypeType
, @InvHdrState            StateType
, @InvHdrExchRate         ExchRateType
, @InvHdrUseExchRate      ListYesNoType
, @InvHdrTaxCode1         TaxCodeType
, @InvHdrTaxCode2         TaxCodeType
, @InvHdrFrtTaxCode1      TaxCodeType
, @InvHdrFrtTaxCode2      TaxCodeType
, @InvHdrMscTaxCode1      TaxCodeType
, @InvHdrMscTaxCode2      TaxCodeType
, @InvHdrTaxDate          DateType
, @InvHdrShipDate         DateType
, @InvHdrMiscCharges      AmountType
, @InvHdrPrepaidAmt       AmountType
, @InvHdrFreight          AmountType
, @InvHdrCost             AmountType
, @InvHdrPrice            AmountType
, @InvHdrSlsman           SlsmanType
, @InvHdrCommCalc         AmountType
, @InvHdrCommDue          AmountType
, @InvHdrCommPaid         AmountType
, @InvHdrTotCommDue       AmountType
, @InvHdrCommBase         AmountType
, @InvHdrEcCode           EcCodeType

, @InvItemRowPointer      RowPointerType
, @InvItemInvNum          InvNumType
, @InvItemInvSeq          InvSeqType
, @InvItemCoNum           CoNumType
, @InvItemCoLine          CoLineType
, @InvItemCoRelease       CoReleaseType
, @InvItemItem            ItemType
, @InvItemDisc            LineDiscType
, @InvItemProcessInd      ProcessIndType
, @InvItemConsNum         ConsignmentsType
, @InvItemTaxCode1        TaxCodeType
, @InvItemTaxCode2        TaxCodeType
, @InvItemTaxDate         DateType
, @InvItemCost            CostPrcType
, @InvItemQtyInvoiced     QtyUnitType
, @InvItemPrice           CostPrcType
, @InvItemExciseTaxPercent ExciseTaxPercentType

, @InvProRowPointer       RowPointerType
, @InvProSeq              InvProSeqType
, @InvProInvNum           InvNumType
, @InvProCoNum            CoNumType
, @InvProCoLine           CoLineType
, @InvProAmount           AmountType
, @InvProDescription      DescriptionType

, @ItemLastInv            DateType  

, @InvStaxRowPointer      RowPointerType
, @InvStaxInvNum          InvNumType
, @InvStaxInvSeq          InvSeqType
, @InvStaxSeq             StaxSeqType
, @InvStaxTaxCode         TaxCodeType
, @InvStaxSalesTax        AmountType
, @InvStaxStaxAcct        AcctType
, @InvStaxStaxAcctUnit1   UnitCode1Type
, @InvStaxStaxAcctUnit2   UnitCode2Type
, @InvStaxStaxAcctUnit3   UnitCode3Type
, @InvStaxStaxAcctUnit4   UnitCode4Type
, @InvStaxInvDate         DateType
, @InvStaxCustNum         CustNumType
, @InvStaxCustSeq         CustSeqType
, @InvStaxTaxBasis        AmountType
, @InvStaxTaxSystem       TaxSystemType
, @InvStaxTaxRate         TaxRateType
, @InvStaxTaxJur          TaxJurType
, @InvStaxTaxCodeE        TaxCodeType

, @ParmsRowPointer        RowPointerType
, @ParmsSite              SiteType
, @ParmsECReporting       ListYesNoType
, @ParmsCountry           CountryType

, @ProgbillRowPointer     RowPointerType
, @ProgbillInvcFlag       ProgBillInvoiceFlagType
, @ProgbillBillDate       DateType
, @ProgbillBillAmt        AmountType
, @ProgbillSeq            ProgBillSeqType
, @ProgbillDescription    DescriptionType
, @ProgbillInvNum         InvNumType

, @SlsmanRowPointer       RowPointerType
, @SlsmanSlsman           SlsmanType
, @SlsmanSlsmangr         SlsmanType
, @SlsmanRefNum           EmpVendNumType
, @SlsmanSalesYtd         AmountType
, @SlsmanSalesPtd         AmountType

, @TaxparmsRowPointer     RowPointerType
, @TaxparmsLastTaxReport1 DateType
, @TaxparmsLastSsdReport  DateType

, @TermsDueDays           DueDaysType
, @TermsProxCode          ProxCodeType
, @TermsProxDay           ProxDayType
, @TermsTermCode          TermsCodeType
, @TermsProxMonthToForward       ProxMonthToForwardType
, @TermsDiscDays                 DiscDaysType
, @TermsCutoffDay                CutoffDayType
, @TermsHolidayOffsetMethod      HolidayOffsetMethodType    
, @TermsProxDiscMonthToForward   ProxDiscMonthToForwardType
, @TermsProxDiscDay              ProxDiscDayType

, @WTaxCalcRecordZero     Flag
, @WTaxCalcTaxAmt         AmountType
, @WTaxCalcTaxCode        TaxCodeType
, @WTaxCalcArAcct         AcctType
, @WTaxCalcArAcctUnit1    UnitCode1Type
, @WTaxCalcArAcctUnit2    UnitCode2Type
, @WTaxCalcArAcctUnit3    UnitCode3Type
, @WTaxCalcArAcctUnit4    UnitCode4Type
, @WTaxCalcTaxBasis       AmountType
, @WTaxCalcTaxSystem      TaxSystemType
, @WTaxCalcTaxRate        TaxRateType
, @WTaxCalcTaxJur         TaxJurType
, @WTaxCalcTaxCodeE       TaxCodeType

, @XCoRowPointer          RowPointerType
, @XCoCoNum               CoNumType
, @XCountryRowPointer     RowPointerType
, @XCountryEcCode         EcCodeType

, @SessionId              RowPointerType
, @ReleaseTmpTaxTables    FlagNyType
, @LinesPerDoc            INT
, @CurrLinesDoc           INT
, @LoopLinesDoc           INT
, @CoitemLineCounter      INT
, @BeginTranCount         INT
, @prev_identity          INT
, @CustTpPaperInv         ListYesNoType
, @BuilderInvOrigSite      SiteType
, @BuilderInvNum           BuilderInvNumType

DECLARE @arinvd TABLE(
           cust_num    CustNumType
         , inv_num     InvNumType
         , dist_seq    ArDistSeqType
         , amount      AmountType
         , acct        AcctType
         , acct_unit1  UnitCode1Type
         , acct_unit2  UnitCode2Type
         , acct_unit3  UnitCode3Type
         , acct_unit4  UnitCode4Type
         , tax_code    TaxCodeType
         , tax_code_e  TaxCodeType
         , tax_system  TaxSystemType
         , tax_basis   AmountType
         , zla_for_amount			AmountType
		 , zla_for_tax_basis	AmountType
		 , zla_tax_group_id		ZlaTaxGroupIdType
		 , zla_base_dist_seq	ArDistSeqType
		 , zla_description		DescriptionType
		 , zla_tax_rate				TaxRateType
		 , ref_type           RefTypeOType
		 , ref_num            CoNumType
		 , ref_line_suf       CoLineType
		 , ref_release        CoReleaseType
      )

DECLARE  @inv_stax TABLE(
           inv_num         InvNumType
         , inv_seq         InvSeqType
         , seq             StaxSeqType
         , tax_code        TaxCodeType
         , sales_tax       AmountType
         , stax_acct       AcctType
         , stax_acct_unit1 UnitCode1Type
         , stax_acct_unit2 UnitCode2Type
         , stax_acct_unit3 UnitCode3Type
         , stax_acct_unit4 UnitCode4Type
         , inv_date        DateType
         , cust_num        CustNumType
         , cust_seq        CustSeqType
         , tax_basis       AmountType
         , tax_system      TaxSystemType
         , tax_rate        TaxRateType
         , tax_jur         TaxJurType
         , tax_code_e      TaxCodeType
		 , zla_ref_type				RefTypeIJKMNOTType
		 , zla_ref_num				EmpJobCoPoRmaProjPsTrnNumType
		 , zla_ref_line_suf		CoLineSuffixPoLineProjTaskRmaTrnLineType
		 , zla_ref_release		CoReleaseOperNumPoReleaseType
		 , zla_tax_group_id			ZlaTaxGroupIdType
		 , zla_for_tax_basis	AmountType
		 , zla_for_sales_tax	AmountType         
      )

-- ZLA BEGIN Declare Localization Vars
DECLARE
-- For co Tabla
  @CoZlaForFreightT	    AmountType
, @CoZlaForSalesTax	    AmountType
, @CoZlaForSalesTaxT	AmountType
, @CoZlaForSalesTax2	AmountType
, @CoZlaForSalesTaxT2	AmountType
, @CoZlaForPrepaidT	    AmountType
, @CoZlaForMChargesT	AmountType
, @CoZlaArTypeId	    ZlaArTypeIdType
, @CoZlaDocId			ZlaDocumentIdType
, @CoZlaForCurrCode	    CurrCodeType
, @CoZlaForExchRate		ExchRateType
, @CoZlaForPrice		  AmountType
, @CoZlaForMiscCharges	AmountType
, @CoZlaForFreight	    AmountType
, @CoZlaForDiscAmount	AmountType
, @CoZlaForFixedRate	ListYesNoType
, @CoZlaForPrepaidAmt	AmountType
-- For CoBln Table
, @CoBlnZlaForPrice	CostPrcType
, @CoBlnZlaForPriceConv	CostPrcType
-- For inv_stax
, @InvStaxZlaRefType	RefTypeIJKMNOTType
, @InvStaxZlaRefNum	    EmpJobCoPoRmaProjPsTrnNumType
, @InvStaxZlaRefLineSuf	CoLineSuffixPoLineProjTaskRmaTrnLineType
, @InvStaxZlaRefRelease	CoReleaseOperNumPoReleaseType
, @InvStaxZlaTaxGroupId	ZlaTaxGroupIdType
, @InvStaxZlaForTaxBasis	AmountType
, @InvStaxZlaForSalesTax	AmountType
-- InvHdr
, @InvHdrZlaForCurrCode	CurrCodeType
, @InvHdrZlaForExchRate	ExchRateType
, @InvHdrZlaForPrice	AmountType
, @InvHdrZlaForMiscCharges	AmountType
, @InvHdrZlaForFreight	AmountType
, @InvHdrZlaForDiscAmount	AmountType
, @InvHdrZlaForPrepaidAmt	AmountType
, @InvHdrZlaInvNum	ZlaInvNumType
-- Inv_item
, @InvItemZlaCoDiscAmt	AmountType
, @InvItemZlaForPrice	CostPrcType
, @InvItemZlaForOldPrice	CostPrcType
, @InvItemZlaForNewPrice	CostPrcType
, @InvItemZlaForRestockFeeAmt	AmountType
--
-- Arinv
, @ArinvZlaArTypeId	ZlaArTypeIdType
, @ArinvZlaDocId	ZlaDocumentIdType
, @ArinvZlaForAmount	AmountType
, @ArinvZlaForMiscCharges	AmountType
, @ArinvZlaForFreight	AmountType
, @ArinvZlaForExchRate	ExchRateType
, @ArinvZlaForCurrCode	CurrCodeType
, @ArinvZlaForSalesTax	AmountType
, @ArinvZlaForSalesTax2	AmountType
, @ArinvZlaForFixedRate	ListYesNoType
, @ArinvZlaInvNum	ZlaInvNumType
, @ArinvZlaAuthCode	ZlaAuthCode
, @ArinvZlaAuthEndDate	Date4Type
--Arinvd
, @ArinvdZlaForAmount	AmountType
, @ArinvdZlaForTaxBasis	AmountType
, @ArinvdZlaTaxGroupId	ZlaTaxGroupIdType
, @ArinvdZlaBaseDistSeq	ArDistSeqType
, @ArinvdZlaDescription	DescriptionType
, @ArinvdZlaTaxRate		TaxRateType

DECLARE
@ZlaMultiCurrFlag	FlagNyType
,@ZlaTmpSalesTax	AmountType
,@ZlaTmpSalesTax2	AmountType

declare
@ZlaArTypeIdInv		ZlaArTypeIdType
,@ZlaArTypeIdNc		ZlaArTypeIdType
,@ZlaArTypeIdNd		ZlaArTypeIdType

DECLARE
  @tax_type_id varchar(15)
, @tax_group_id varchar(15)
, @base_amount decimal(15,2)
, @base_amount_country decimal(15,2)
, @tax_amount decimal(15,2)
, @tax_amount_country decimal(15,2)
, @tax_percent decimal(6,3)
, @TTaxSeq2						GenericNoType


DECLARE @TmpZlaInvStaxGroup TABLE (
  inv_num	InvNumType
, inv_seq	InvSeqType
, seq	StaxSeqType
, tax_group_id	ZlaTaxGroupIdType
)

declare
	@ZpvCoitemCoNum		CoNumType
,	@ZpvCoitemCoLine	CoLineType
,	@ZpvCoitemCoRelease	int
,	@ZpvCoitemQtyInvoiced	QtyUnitType
,	@ZpvQtyNulled		QtyUnitType

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
 ,[exch_rate] decimal(12,7) NULL
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

-- ZLA END Declare Localization Vars

set @BeginTranCount = @@trancount
if @BeginTranCount = 0
   BEGIN TRANSACTION

-- Init Passed Values
SET @StartInvNum = '0'

SET @EndInvNum = '0'
set @Infobar = NULL

SET @LinesPerDoc   = 0

-- Init Values

SET @PrintFlag     = 0
SET @ProjAccum     = 0
SET @Severity      = 0
SET @TPrepaidAmt   = 0
SET @TDistSeq      = 0
SET @TSalesTax     = 0
SET @TSalesTax2    = 0
SET @TInvStaxSeq   = 0
SET @TError        = 0
SET @TCurSlsman    = NULL
SET @TLoopCounter  = 0
SET @TCommCalc     = 0
SET @TCommBase     = 0
SET @TOpen         = NULL
SET @TAr           = NULL
SET @TArCredit     = NULL
SET @TInvLabel     = NULL
SET @TCrMemo       = NULL
SET @TTaxSeq       = 0
SET @TRevPercent   = 0
SET @TCommPercent  = 0
SET @TCoLine       = 0
SET @TCommBaseTot  = 0
SET @TEndAcct      = NULL
SET @TEndAcctUnit1 = NULL
SET @TEndAcctUnit2 = NULL
SET @TEndAcctUnit3 = NULL
SET @TEndAcctUnit4 = NULL
SET @TRate         = 0
SET @TResultAmt    = 0
SET @TLastTran     = '0'
SET @TOrderBal     = 0

SET @SessionId = dbo.SessionIDSp()

/* Load up labels/literals */
SET @TAr       = dbo.GetLabel('@!ARI') -- "ARI"
SET @TArCredit = dbo.GetLabel('@!ARCOPEN') -- "ARC OPEN"
SET @TInvLabel = dbo.GetLabel('@inv_stax.inv_num')
SET @TOpen = dbo.GetLabel('@CapitalOPEN')

EXEC dbo.GetCodeSp
   @PClass = 'arinv.type',
   @PCode = 'C',
   @PDesc = @TCrMemo       OUTPUT

SET @ParmsRowPointer  = NULL
SET @ParmsSite        = NULL
SET @ParmsECReporting = 0
SET @ParmsCountry     = NULL
SET @ZpvParmsCtrlFiscal	= 0

SELECT
  @ParmsRowPointer  = RowPointer
, @ParmsSite        = site
, @ParmsECReporting = ec_reporting
, @ParmsCountry     = country
FROM parms with (readuncommitted)

IF @ParmsRowPointer IS NULL
BEGIN
   SET @Infobar = NULL
   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT
                       , 'E=NoExist0'
                       , '@parms'

   GOTO END_PROG
END

SELECT
	@ZpvParmsCtrlFiscal = par.ctrl_fiscal
FROM zpv_parms par
WHERE par.parms_key = 0

SET @CoParmsRowPointer = NULL
SET @CoParmsDueOnPmt   = 0

SELECT
  @CoParmsRowPointer = RowPointer
, @CoParmsDueOnPmt = due_on_pmt
FROM coparms with (readuncommitted)

IF @CoParmsRowPointer IS NULL
BEGIN
   SET @Infobar = NULL
   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT
                       , 'E=NoExist0'
                       , '@coparms'

   GOTO END_PROG
END


SET @ArParmsRowPointer    = NULL
SET @ArparmsArAcct        = NULL
SET @ArparmsArAcctUnit1   = NULL
SET @ArparmsArAcctUnit2   = NULL
SET @ArparmsArAcctUnit3   = NULL
SET @ArparmsArAcctUnit4   = NULL
SET @ArparmsProjAcct      = NULL
SET @ArparmsProjAcctUnit1 = NULL
SET @ArparmsProjAcctUnit2 = NULL
SET @ArparmsProjAcctUnit3 = NULL
SET @ArparmsProjAcctUnit4 = NULL
SET @ArparmsProgAcct      = NULL
SET @ArparmsProgAcctUnit1 = NULL
SET @ArparmsProgAcctUnit2 = NULL
SET @ArparmsProgAcctUnit3 = NULL
SET @ArparmsProgAcctUnit4 = NULL
SET @ArparmsFreightAcct      = NULL
SET @ArparmsFreightAcctUnit1 = NULL
SET @ArparmsFreightAcctUnit2 = NULL
SET @ArparmsFreightAcctUnit3 = NULL
SET @ArparmsFreightAcctUnit4 = NULL
SET @ArparmsMiscAcct        = NULL
SET @ArparmsMiscAcctUnit1   = NULL
SET @ArparmsMiscAcctUnit2   = NULL
SET @ArparmsMiscAcctUnit3   = NULL
SET @ArparmsMiscAcctUnit4   = NULL
SET @ArparmsSalesDiscAcct        = NULL
SET @ArparmsSalesDiscAcctUnit1   = NULL
SET @ArparmsSalesDiscAcctUnit2   = NULL
SET @ArparmsSalesDiscAcctUnit3   = NULL
SET @ArparmsSalesDiscAcctUnit4   = NULL
SET @ArparmsSalesAcct        = NULL
SET @ArparmsSalesAcctUnit1   = NULL
SET @ArparmsSalesAcctUnit2   = NULL
SET @ArparmsSalesAcctUnit3   = NULL
SET @ArparmsSalesAcctUnit4   = NULL

SELECT
  @ArParmsRowPointer    = arParms.RowPointer
, @ArparmsArAcct        = arparms.ar_acct
, @ArparmsArAcctUnit1   = arparms.ar_acct_unit1
, @ArparmsArAcctUnit2   = arparms.ar_acct_unit2
, @ArparmsArAcctUnit3   = arparms.ar_acct_unit3
, @ArparmsArAcctUnit4   = arparms.ar_acct_unit4
, @ArparmsProjAcct      = arparms.proj_acct
, @ArparmsProjAcctUnit1 = arparms.proj_acct_unit1
, @ArparmsProjAcctUnit2 = arparms.proj_acct_unit2
, @ArparmsProjAcctUnit3 = arparms.proj_acct_unit3
, @ArparmsProjAcctUnit4 = arparms.proj_acct_unit4
, @ArparmsProgAcct      = arparms.prog_acct
, @ArparmsProgAcctUnit1 = arparms.prog_acct_unit1
, @ArparmsProgAcctUnit2 = arparms.prog_acct_unit2
, @ArparmsProgAcctUnit3 = arparms.prog_acct_unit3
, @ArparmsProgAcctUnit4 = arparms.prog_acct_unit4
, @ArparmsFreightAcct      = arparms.freight_acct
, @ArparmsFreightAcctUnit1 = arparms.freight_acct_unit1
, @ArparmsFreightAcctUnit2 = arparms.freight_acct_unit2
, @ArparmsFreightAcctUnit3 = arparms.freight_acct_unit3
, @ArparmsFreightAcctUnit4 = arparms.freight_acct_unit4
, @ArparmsMiscAcct        = arparms.misc_acct
, @ArparmsMiscAcctUnit1   = arparms.misc_acct_unit1
, @ArparmsMiscAcctUnit2   = arparms.misc_acct_unit2
, @ArparmsMiscAcctUnit3   = arparms.misc_acct_unit3
, @ArparmsMiscAcctUnit4   = arparms.misc_acct_unit4
, @ArparmsSalesDiscAcct        = arparms.sales_disc_acct
, @ArparmsSalesDiscAcctUnit1   = arparms.sales_disc_acct_unit1
, @ArparmsSalesDiscAcctUnit2   = arparms.sales_disc_acct_unit2
, @ArparmsSalesDiscAcctUnit3   = arparms.sales_disc_acct_unit3
, @ArparmsSalesDiscAcctUnit4   = arparms.sales_disc_acct_unit4
, @ArparmsSalesAcct        = arparms.sales_acct
, @ArparmsSalesAcctUnit1   = arparms.sales_acct_unit1
, @ArparmsSalesAcctUnit2   = arparms.sales_acct_unit2
, @ArparmsSalesAcctUnit3   = arparms.sales_acct_unit3
, @ArparmsSalesAcctUnit4   = arparms.sales_acct_unit4
FROM arparms with (readuncommitted)

IF @ArParmsRowPointer IS NULL
BEGIN
   SET @Infobar = NULL
   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT
                       , 'E=NoExist0'
                       , '@arparms'

   GOTO END_PROG
END

   EXEC dbo.GetArparmLinesPerDocSp
                @ArparmUsePrePrintedForms OUTPUT,
                @ArparmLinesPerInv OUTPUT,
                @ArparmLinesPerDM OUTPUT,
                @ArparmLinesPerCM OUTPUT

IF @InvCred = 'I' AND @ArparmUsePrePrintedForms >0
   SET @LinesPerDoc = @ArparmLinesPerInv
ELSE IF @InvCred = 'C' AND @ArparmUsePrePrintedForms >0
   SET @LinesPerDoc = @ArparmLinesPerCM

SET @TaxparmsRowPointer     = NULL
SET @TaxparmsLastTaxReport1 = NULL
SET @TaxparmsLastSsdReport  = NULL

SELECT
  @TaxparmsRowPointer     = taxparms.RowPointer
, @TaxparmsLastTaxReport1 = taxparms.last_tax_report_1
, @TaxparmsLastSsdReport  = taxparms.last_ssd_report
FROM taxparms with (readuncommitted)

IF @TaxparmsRowPointer IS NULL
BEGIN
   SET @Infobar = NULL
   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT
                       , 'E=NoExist0'
                       , '@taxparms'

   GOTO END_PROG
END

SET @InvDate		= ISNULL(@InvDate, dbo.GetSiteDate(getdate()))
SET @StartCustomer  = ISNULL(@StartCustomer , dbo.LowCharacter())
SET @EndCustomer    = ISNULL(@EndCustomer , dbo.HighCharacter())
SET @StartOrderNum  = ISNULL(@StartOrderNum , dbo.LowCharacter())
SET @EndOrderNum    = ISNULL(@EndOrderNum , dbo.HighCharacter())
SET @StartLine		= ISNULL(@StartLine , dbo.LowAnyInt('CoLineType'))
SET @EndLine		= ISNULL(@EndLine , dbo.HighAnyInt('CoLineType'))
SET @StartRelease   = ISNULL(@StartRelease , dbo.LowAnyInt('CoReleaseType'))
SET @EndRelease		= ISNULL(@StartRelease , dbo.HighAnyInt('CoReleaseType'))
SET @TInvNum		= ISNULL(@TInvNum, '0')

SET @XCountryRowPointer = NULL
SET @XCountryEcCode     = NULL

SELECT
     @XCountryRowPointer = country.RowPointer
   , @XCountryEcCode     = country.ec_code
FROM country with (readuncommitted)
WHERE country.country = @ParmsCountry

SET @BuilderInvOrigSite = NULL
SET @BuilderInvNum      = NULL
IF @CalledFrom = 'InvoiceBuilder'
BEGIN
   SELECT TOP 1
          @BuilderInvOrigSite = builder_inv_orig_site
        , @BuilderInvNum      = builder_inv_num
     FROM tmp_invoice_builder   
    WHERE process_ID = @InvoicBuilderProcessID      
END

-- BEGIN_PROG:
-- EXEC SLDevEnv_App.dbo.SQLTraceSp 'InvPostPSp: Top', 'thoblo'
IF @CalledFrom = 'InvoiceBuilder'
   DECLARE coCrs CURSOR LOCAL STATIC FOR
   SELECT co.RowPointer,
          co.co_num
     FROM co
    INNER JOIN tmp_invoice_builder
       ON co.RowPointer = co_RowPointer AND process_ID = @InvoicBuilderProcessID 
   WHERE --co.type = 'R'
      co.co_num BETWEEN ISNULL(@StartOrderNum, co.co_num) And ISNULL (@EndOrderNum, co.co_num)
      AND co.cust_num BETWEEN ISNULL(@StartCustomer, co.cust_num) And ISNULL(@EndCustomer, co.cust_num)
      AND (CHARINDEX(co.stat, 'POS') > 0)
ELSE  
   DECLARE coCrs CURSOR LOCAL STATIC FOR
   SELECT co.RowPointer,
          co.co_num
   FROM co
   WHERE --co.type = 'R'
      co.co_num BETWEEN ISNULL(@StartOrderNum, co.co_num) And ISNULL (@EndOrderNum, co.co_num)
      AND co.cust_num BETWEEN ISNULL(@StartCustomer, co.cust_num) And ISNULL(@EndCustomer, co.cust_num)
      AND (CHARINDEX(co.stat, 'POS') > 0)

OPEN coCrs

WHILE @Severity = 0
BEGIN
   FETCH coCrs INTO
     @XCoRowPointer
   , @XCoCoNum
   IF @@FETCH_STATUS = -1
      BREAK

   -- This session variable should not be defined at this point.
   EXEC dbo.UnDefineVariableSp 'TmpTaxTablesInUse' , @Infobar
   -- Need to clear tax tables
   -- Tmp Tax Table init
   EXEC @Severity = dbo.UseTmpTaxTablesSp @SessionId, @ReleaseTmpTaxTables OUTPUT, @Infobar OUTPUT

   /* PROCESS ONLY IF INVOICING REQUIRED */
   SET @TotPbillAmt = 0
   SET @ProgBillCnt = 0
   IF @CalledFrom = 'InvoiceBuilder'
      SELECT
         @TotPbillAmt = @TotPBillAmt + isnull(progbill.bill_amt,0),
         @ProgBillCnt = @ProgBillCnt + 1
        FROM progbill 
        --join co on co.co_num = progbill.co_num
        join co_bln 
          on co_bln.co_num = progbill.co_num and co_bln.co_line = progbill.co_line
       INNER JOIN tmp_invoice_builder
          ON co_bln.RowPointer = coitem_RowPointer AND process_ID = @InvoicBuilderProcessID    
       WHERE progbill.co_num = @XCoCoNum AND progbill.seq > 0  AND
            (progbill.invc_flag = 'Y' OR progbill.invc_flag = 'A') AND
             co_bln.ship_site = @ParmsSite AND
             co_bln.co_line BETWEEN ISNULL(@StartLine, co_bln.co_line) And ISNULL (@EndLine, co_bln.co_line) AND
             co_bln.stat = 'O'
   ELSE
      SELECT
         @TotPbillAmt = @TotPBillAmt + isnull(progbill.bill_amt,0),
         @ProgBillCnt = @ProgBillCnt + 1
      FROM progbill join co_bln on co_bln.co_num = progbill.co_num and co_bln.co_line = progbill.co_line
      WHERE progbill.co_num = @XCoCoNum AND progbill.seq > 0 AND
           (progbill.invc_flag = 'Y' OR progbill.invc_flag = 'A') AND
            co_bln.ship_site = @ParmsSite AND
            co_bln.co_line BETWEEN ISNULL(@StartLine, co_bln.co_line) And ISNULL (@EndLine, co_bln.co_line) AND
            co_bln.stat = 'O'
   
   IF @ProgBillCnt = 0 OR
      (@InvCred = 'I' AND @TotPbillAmt <= 0) OR
      (@InvCred = 'C' AND @TotPbillAmt >= 0)
      CONTINUE
	
   /* Determine how many coitem lines are involved. */
   IF @CalledFrom = 'InvoiceBuilder'
      SELECT @CoitemLineCounter = COUNT(DISTINCT co_bln.co_line)
        FROM progbill 
        join co_bln 
          on co_bln.co_num = progbill.co_num and co_bln.co_line = progbill.co_line
       INNER JOIN tmp_invoice_builder
          ON co_bln.RowPointer = coitem_RowPointer AND process_ID = @InvoicBuilderProcessID   
       WHERE progbill.co_num = @XCoCoNum AND progbill.seq > 0 AND progbill.bill_date <= @InvDate AND
            (progbill.invc_flag = 'Y' OR progbill.invc_flag = 'A') AND
             co_bln.ship_site = @ParmsSite AND
             co_bln.co_line BETWEEN ISNULL(@StartLine, co_bln.co_line) And ISNULL (@EndLine, co_bln.co_line) AND
             co_bln.stat = 'O'
   ELSE   
      SELECT @CoitemLineCounter = COUNT(DISTINCT co_bln.co_line)
      FROM progbill join co_bln on co_bln.co_num = progbill.co_num and co_bln.co_line = progbill.co_line
      WHERE progbill.co_num = @XCoCoNum AND progbill.seq > 0 AND
           (progbill.invc_flag = 'Y' OR progbill.invc_flag = 'A') AND
            co_bln.ship_site = @ParmsSite AND
            co_bln.co_line BETWEEN ISNULL(@StartLine, co_bln.co_line) And ISNULL (@EndLine, co_bln.co_line) AND
            co_bln.stat = 'O'

   -- BEGIN_TRX_LOOP:
   SET @CurrLinesDoc  = 0
   SET @LoopLinesDoc  = @CoitemLineCounter

     
   /* FIND REQUIRED RECORDS */

   SET @CoRowPointer  = NULL
   SET @CoCustNum     = NULL
   SET @CoCustSeq     = 0
   SET @CoCoNum       = NULL
   SET @CoEndUserType = NULL
   SET @CoTermsCode   = NULL
   SET @CoShipCode    = NULL
   SET @CoCustPo      = NULL
   SET @CoWeight      = 0
   SET @CoQtyPackages = 0
   SET @CoFixedRate   = 0
   SET @CoExchRate    = 0
   SET @CoUseExchRate = 0
   SET @CoTaxCode1    = NULL
   SET @CoTaxCode2    = NULL
   SET @CoFrtTaxCode1 = NULL
   SET @CoFrtTaxCode2 = NULL
   SET @CoMscTaxCode1 = NULL
   SET @CoMscTaxCode2 = NULL
   SET @CoSlsman      = NULL
   SET @CoPrepaidAmt  = 0
   SET @CoPrepaidT    = 0
   SET @CoMiscCharges = 0
   SET @CoFreight     = 0
   SET @CoSalesTax    = 0
   SET @CoSalesTax2   = 0
   SET @CoSalesTaxT   = 0
   SET @CoSalesTaxT2  = 0
   SET @CoInvoiced    = 0
   SET @CoLcrNum      = NULL

   SELECT
        @CoRowPointer  = co.RowPointer
      , @CoCustNum     = co.cust_num
      , @CoCustSeq     = co.cust_seq
      , @CoCoNum       = co.co_num
      , @CoEndUserType = co.end_user_type
      , @CoTermsCode   = co.terms_code
      , @CoShipCode    = co.ship_code
      , @CoCustPo      = co.cust_po
      , @CoWeight      = co.weight
      , @CoQtyPackages = co.qty_packages
      , @CoFixedRate   = co.fixed_rate
      , @CoExchRate    = co.exch_rate
      , @CoUseExchRate = co.use_exch_rate
      , @CoTaxCode1    = co.tax_code1
      , @CoTaxCode2    = co.tax_code2
      , @CoFrtTaxCode1 = co.frt_tax_code1
      , @CoFrtTaxCode2 = co.frt_tax_code2
      , @CoMscTaxCode1 = co.msc_tax_code1
      , @CoMscTaxCode2 = co.msc_tax_code2
      , @CoSlsman      = co.slsman
      , @CoPrepaidAmt  = co.prepaid_amt
      , @CoPrepaidT    = co.prepaid_t
      , @CoMiscCharges = co.misc_charges
      , @CoFreight     = co.freight
      , @CoSalesTax    = co.sales_tax
      , @CoSalesTax2   = co.sales_tax_2
      , @CoSalesTaxT   = co.sales_tax_t
      , @CoSalesTaxT2  = co.sales_tax_t2
      , @CoInvoiced    = co.invoiced
      , @CoLcrNum      = co.lcr_num
      , @ArinvApplyToInvNum = co.apply_to_inv_num
      , @CoIncludeTaxInPrice = co.include_tax_in_price
      , @CoDisc         = co.disc
   FROM co WITH (UPDLOCK)
   WHERE co.RowPointer = @XCoRowPointer

	SELECT 
		@ZlaArTypeIdInv		= arend.ar_type_id
	FROM zla_ar_endtype arend
	WHERE	arend.end_user_type = @CoEndUserType
		and arend.type = 'I'

	SELECT 
		@ZlaArTypeIdNc		= arend.ar_type_id
	FROM zla_ar_endtype arend
	WHERE	arend.end_user_type = @CoEndUserType
		and arend.type = 'C'

	SELECT 
		@ZlaArTypeIdNd		= arend.ar_type_id
	FROM zla_ar_endtype arend
	WHERE	arend.end_user_type = @CoEndUserType
		and arend.type = 'D'

   SET @CoWeight      = ISNULL(@CoWeight, 0)
   SET @CoQtyPackages = ISNULL(@CoQtyPackages, 0)
   SET @CoFixedRate   = ISNULL(@CoFixedRate, 0)
   SET @CoExchRate    = ISNULL(@CoExchRate, 0)
   SET @CoPrepaidAmt  = ISNULL(@CoPrepaidAmt, 0)
   SET @CoPrepaidT    = ISNULL(@CoPrepaidT, 0)
   SET @CoMiscCharges = ISNULL(@CoMiscCharges, 0)
   SET @CoFreight     = ISNULL(@CoFreight, 0)
   SET @CoSalesTax    = ISNULL(@CoSalesTax, 0)
   SET @CoSalesTax2   = ISNULL(@CoSalesTax2, 0)
   SET @CoSalesTaxT   = ISNULL(@CoSalesTaxT, 0)
   SET @CoSalesTaxT2  = ISNULL(@CoSalesTaxT2, 0)
   SET @CoInvoiced    = ISNULL(@CoInvoiced, 0)

   SET @CustomerRowPointer     = NULL
   SET @CustomerPayType        = NULL
   SET @CustomerDraftPrintFlag = 0
   SET @CustomerCustBank       = NULL
   SET @CustomerCustNum        = NULL
   SET @CustomerBankCode       = NULL
   SET @CustomerEdiCust        = 0

   SELECT
        @CustomerRowPointer     = customer.RowPointer
      , @CustomerPayType        = customer.pay_type
      , @CustomerDraftPrintFlag = customer.draft_print_flag
      , @CustomerCustBank       = customer.cust_bank
      , @CustomerCustNum        = customer.cust_num
      , @CustomerBankCode       = customer.bank_code
      , @CustomerEdiCust        = customer.edi_cust
   FROM customer
   WHERE customer.cust_num = @CoCustNum
      AND customer.cust_seq = @CoCustSeq

   IF @CustomerRowPointer IS NULL
   BEGIN
       SET @Infobar = NULL

       EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistForIsAndIs1'
         , '@customer'
         , '@customer.cust_num'
         , @CoCustNum
         , '@customer.cust_seq'
         , @CoCustSeq
         , '@co'
         , '@co.co_num'
         , @CoCoNum

   GOTO END_PROG
   END
   
	-- ZLA Load Localization Fields from Order
	SELECT 
		  @CoZlaForFreightT		= zla_for_freight_t
		, @CoZlaForSalesTax		= zla_for_sales_tax
		, @CoZlaForSalesTaxT	= zla_for_sales_tax_t
		, @CoZlaForSalesTax2	= zla_for_sales_tax_2
		, @CoZlaForSalesTaxT2	= zla_for_sales_tax_t2
		, @CoZlaForPrepaidT		= zla_for_prepaid_t
		, @CoZlaForMChargesT	= zla_for_m_charges_t
		, @CoZlaArTypeId		= case @InvCred 
									when 'I' then @ZlaArTypeIdInv
									when 'C' then @ZlaArTypeIdNc
									when 'D' then @ZlaArTypeIdNd
								  end
		, @CoZlaDocId			= case @InvCred 
									when 'I' then zla_doc_id
									when 'C' then zla_doc_id
									when 'D' then zla_doc_id
								  end
		, @CoZlaForCurrCode		= zla_for_curr_code
		, @CoZlaForExchRate		= zla_for_exch_rate
		, @CoZlaForPrice		= zla_for_price
		, @CoZlaForMiscCharges	= zla_for_misc_charges
		, @CoZlaForFreight		= zla_for_freight
		, @CoZlaForDiscAmount	= zla_for_disc_amount
		, @CoZlaForFixedRate	= zla_for_fixed_rate
		, @CoZlaForPrepaidAmt	= zla_for_prepaid_amt
	FROM co
	WHERE Co_num = @CoCoNum
	 
   /* IF EDI CUSTOMER, CHECK IF PAPER INVOICE FLAG IS SET */
   SET @CustTpPaperInv = 1
   IF @CustomerEdiCust = 1
   BEGIN      
      SELECT @CustTpPaperInv = paper_inv
      FROM cust_tp
      WHERE cust_num = @CoCustNum AND
            cust_seq = @CoCustSeq 
   END

   SET @CustaddrRowPointer = NULL
   SET @CustaddrState      = NULL
   SET @CustaddrCurrCode   = NULL
   SET @CustaddrCountry    = NULL

   SELECT
        @CustaddrRowPointer = custaddr.RowPointer
      , @CustaddrState      = custaddr.state
      , @CustaddrCurrCode   = custaddr.curr_code
      , @CustaddrCountry    = custaddr.country
   FROM custaddr with (readuncommitted)
   WHERE custaddr.cust_num = @CoCustNum
      AND custaddr.cust_seq = @CoCustSeq

   IF @CustaddrRowPointer IS NULL
   BEGIN
      SET @Infobar = NULL
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistForIsAndIs1'
         , '@custaddr'
         , '@custaddr.cust_num'
         , @CoCustNum
         , '@custaddr.cust_seq'
         , @CoCustSeq
         , '@co'
         , '@co.co_num'
         , @CoCoNum

      GOTO END_PROG
   END
   
   SET @TEndAr        = @ArparmsArAcct
   SET @TEndArUnit1   = @ArparmsArAcctUnit1
   SET @TEndArUnit2   = @ArparmsArAcctUnit2
   SET @TEndArUnit3   = @ArparmsArAcctUnit3
   SET @TEndArUnit4   = @ArparmsArAcctUnit4
   
   SET @TEndAcct      = @ArparmsArAcct
   SET @TEndAcctUnit1 = @ArparmsArAcctUnit1
   SET @TEndAcctUnit2 = @ArparmsArAcctUnit2
   SET @TEndAcctUnit3 = @ArparmsArAcctUnit3
   SET @TEndAcctUnit4 = @ArparmsArAcctUnit4

   IF @CoEndUserType <> '' AND NOT (@CoEndUserType IS NULL)
   BEGIN
		SET @EndtypeRowPointer  = NULL
		SET @EndtypeArAcct      = NULL
		SET @EndtypeArAcctUnit1 = NULL
		SET @EndtypeArAcctUnit2 = NULL
		SET @EndtypeArAcctUnit3 = NULL
		SET @EndtypeArAcctUnit4 = NULL
		SET @EndtypeSalesDsAcct      = NULL
		SET @EndtypeSalesDsAcctUnit1 = NULL
		SET @EndtypeSalesDsAcctUnit2 = NULL
		SET @EndtypeSalesDsAcctUnit3 = NULL
		SET @EndtypeSalesDsAcctUnit4 = NULL
		SET @EndtypeSalesAcct        = NULL
		SET @EndtypeSalesAcctUnit1   = NULL
		SET @EndtypeSalesAcctUnit2   = NULL
		SET @EndtypeSalesAcctUnit3   = NULL
		SET @EndtypeSalesAcctUnit4   = NULL
		SET @EndtypeNonInvAcct       = NULL   
		SET @EndtypeNonInvAcctUnit1  = NULL   
		SET @EndtypeNonInvAcctUnit2  = NULL        
		SET @EndtypeNonInvAcctUnit3  = NULL        
		SET @EndtypeNonInvAcctUnit4  = NULL         
		SET @EndtypeSurchargeAcct        = NULL
		SET @EndtypeSurchargeAcctUnit1   = NULL
		SET @EndtypeSurchargeAcctUnit2   = NULL
		SET @EndtypeSurchargeAcctUnit3   = NULL
		SET @EndtypeSurchargeAcctUnit4   = NULL

		SELECT
		  @EndtypeRowPointer  = endtype.RowPointer
		, @EndtypeArAcct      = endtype.ar_acct
		, @EndtypeArAcctUnit1 = endtype.ar_acct_unit1
		, @EndtypeArAcctUnit2 = endtype.ar_acct_unit2
		, @EndtypeArAcctUnit3 = endtype.ar_acct_unit3
		, @EndtypeArAcctUnit4 = endtype.ar_acct_unit4
		, @EndtypeSalesDsAcct      = endtype.sales_ds_acct
		, @EndtypeSalesDsAcctUnit1 = endtype.sales_ds_acct_unit1
		, @EndtypeSalesDsAcctUnit2 = endtype.sales_ds_acct_unit2
		, @EndtypeSalesDsAcctUnit3 = endtype.sales_ds_acct_unit3
		, @EndtypeSalesDsAcctUnit4 = endtype.sales_ds_acct_unit4
		, @EndtypeSalesAcct        = endtype.sales_acct
		, @EndtypeSalesAcctUnit1   = endtype.sales_acct_unit1
		, @EndtypeSalesAcctUnit2   = endtype.sales_acct_unit2
		, @EndtypeSalesAcctUnit3   = endtype.sales_acct_unit3
		, @EndtypeSalesAcctUnit4   = endtype.sales_acct_unit4
		, @EndtypeNonInvAcct        = endtype.non_inv_acct
		, @EndtypeNonInvAcctUnit1   = endtype.non_inv_acct_unit1
		, @EndtypeNonInvAcctUnit2   = endtype.non_inv_acct_unit2
		, @EndtypeNonInvAcctUnit3   = endtype.non_inv_acct_unit3
		, @EndtypeNonInvAcctUnit4   = endtype.non_inv_acct_unit4 
		, @EndtypeSurchargeAcct      = endtype.surcharge_acct
		, @EndtypeSurchargeAcctUnit1 = endtype.surcharge_acct_unit1
		, @EndtypeSurchargeAcctUnit2 = endtype.surcharge_acct_unit2
		, @EndtypeSurchargeAcctUnit3 = endtype.surcharge_acct_unit3
		, @EndtypeSurchargeAcctUnit4 = endtype.surcharge_acct_unit4
		FROM endtype with (readuncommitted)
		WHERE endtype.end_user_type = @CoEndUserType

		IF (@EndtypeRowPointer IS NOT NULL) AND (@EndtypeArAcct IS NOT NULL)
		BEGIN
	        SET @TEndAcct      = @EndtypeArAcct
			SET @TEndAcctUnit1 = @EndtypeArAcctUnit1
			SET @TEndAcctUnit2 = @EndtypeArAcctUnit2
			SET @TEndAcctUnit3 = @EndtypeArAcctUnit3
			SET	@TEndAcctUnit4 = @EndtypeArAcctUnit4
		END
	END

	IF ISNULL(@CoZlaForCurrCode,'') = ''
	SET @CoZlaForCurrCode = @CustaddrCurrCode	
   
	SET @CurrencyPlaces     = 0
	SET @CurrencyCurrCode   = NULL

	SELECT
        @CurrencyPlaces     = currency.places
      , @CurrencyCurrCode   = currency.curr_code
	FROM currency with (readuncommitted)
	WHERE currency.curr_code = @CustaddrCurrCode

   SET @CurrencyPlaces = ISNULL(@CurrencyPlaces, 0)

   SET @TRate = NULL
   EXEC @Severity = dbo.CurrCnvtSingleValueSp
                                  @Amount = 1
            , @CurrCode = @CurrencyCurrCode
            , @FromDomestic = 0
            , @UseBuyRate = 0
            , @RoundResult = 0
            , @RateDate = @InvDate
            , @Result = @TResultAmt          OUTPUT
            , @TRate = @TRate                OUTPUT
            , @Infobar = @Infobar            OUTPUT

   IF @Severity <> 0
      GOTO END_PROG
   
 	
   WHILE (@LoopLinesDoc > @CurrLinesDoc or @ArparmUsePrePrintedForms = 0)
   BEGIN

	-- If ZlaFor CurrCode Not set, the use the same for customer
	BEGIN	--  = NOT Multi-Currency Order, use std co 
		SET @CoZlaForCurrCode		= @CustaddrCurrCode
		SET @CoZlaForExchRate		= @CoExchRate
		SET @CoZlaForFreight		= @CoFreight
		SET @CoZlaForMiscCharges	= @CoMiscCharges
		SET @CoZlaForPrepaidAmt		= @CoPrepaidAmt
		SET @CoZlaForFixedRate		= @CoFixedRate
	 
		-- SET Invoice Header Multicurrency Fields
		SET @InvHdrZlaForCurrCode		 = @CoZlaForCurrCode
		SET @InvHdrZlaForExchRate		 = @CoZlaForExchRate
		SET @InvHdrZlaForFreight		 = @CoZlaForFreight
		SET @InvHdrZlaForMiscCharges	 = @CoZlaForMiscCharges
		SET @InvHdrZlaForPrepaidAmt		 = @CoZlaForPrepaidAmt

	END 

	SET @ArinvZlaArTypeId = @CoZlaArTypeId
	SET @ArinvZlaDocId    = @CoZlaDocId
	
	-- ZLA Override Unit Codes with Document unit
	  --BEGIN
	
	  EXECUTE ZLA_ArDocUnitCodeSp
				@ArinvZlaDocId
			    ,@TEndAr
			    ,@TEndArUnit1 OUTPUT
			    ,@TEndArUnit2 OUTPUT
			    ,@TEndArUnit3 OUTPUT
			    ,@TEndArUnit4 OUTPUT
			    ,@Infobar OUTPUT

    --END
    
   
	EXEC @Severity		 = dbo.ZLA_NextInvNumSp
			@Custnum	 = @CoCustNum
			 , @InvDate     = @InvDate
			 , @Type        = @InvCred
			 , @InvNum      = @TLastTran OUTPUT
			 , @Action      = 'NextNum'
			 , @Infobar     =		@Infobar OUTPUT
			 , @ZlaArTypeId =		@ArinvZlaArTypeId
			 , @ZlaInvNum	 =		@ArinvZlaInvNum OUTPUT
			 , @ZlaAuthCode    =	@ArinvZlaAuthCode OUTPUT 
			 , @ZlaAuthEndDate =	@arinvzlaAuthEndDate OUTPUT
			 , @ZlaDocId	    =	@ArinvZlaDocId

			IF @Severity <> 0
				GOTO END_PROG

			IF @TInvNum IS NULL
				SET @TInvNum = '0'

			IF dbo.prefixonly(@TLastTran)<> dbo.prefixonly(@TInvNum)
				SET @TInvNum = @TLastTran

			SET @TInvNum = dbo.MaxInvNum(@TLastTran, @TInvNum)

			EXEC @Severity = dbo.ZLA_NextInvNumSp
				@Custnum      = @CoCustNum
			 , @InvDate      = @InvDate
			 , @Type         = @InvCred
			 , @InvNum       = @TInvNum OUTPUT
			 , @Action       = 'AddedNum'
			 , @Infobar      =		@Infobar OUTPUT
			 , @ZlaArTypeId	 =		@ArinvZlaArTypeId
			 , @ZlaInvNum    =		@ArinvZlaInvNum OUTPUT
			 , @ZlaAuthCode	 = 		@ArinvZlaAuthCode OUTPUT 
			 , @ZlaAuthEndDate =	@arinvzlaAuthEndDate OUTPUT
			 , @ZlaDocId	    =	@ArinvZlaDocId       

   set @InvoiceCount = @InvoiceCount + 1

   IF @CustTpPaperInv = 0
      set @EDINoPaperInvoiceCount = @EDINoPaperInvoiceCount   + 1

   IF @Severity <> 0
      GOTO END_PROG


   SET @InvHdrRowPointer  = NULL

   SELECT
      @InvHdrRowPointer  = inv_hdr.RowPointer
   FROM inv_hdr
   WHERE inv_hdr.inv_num = @TInvNum

   IF @InvHdrRowPointer IS NOT NULL
   BEGIN
      SET @Infobar = NULL
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=Exist1'
         , '@inv_hdr'
         , '@inv_hdr.inv_num'
         , @TInvNum

      GOTO END_PROG
   END

   -- INITIALIZING VARS FOR TABLE INSERT
   SELECT
        @InvHdrInvNum      = ('0')
      , @InvHdrInvSeq      = (0)
      , @InvHdrCustNum     = NULL
      , @InvHdrCustSeq     = (0)
      , @InvHdrCoNum       = NULL
      , @InvHdrInvDate     = NULL
      , @InvHdrTermsCode   = NULL
      , @InvHdrShipCode    = NULL
      , @InvHdrCustPo      = NULL
      , @InvHdrWeight      = (0)
      , @InvHdrQtyPackages = (0)
      , @InvHdrBillType    = ('R')
      , @InvHdrState       = NULL
      , @InvHdrExchRate    = (1.0)
      , @InvHdrUseExchRate = (0)
      , @InvHdrTaxCode1    = NULL
      , @InvHdrTaxCode2    = NULL
      , @InvHdrFrtTaxCode1 = NULL
      , @InvHdrFrtTaxCode2 = NULL
      , @InvHdrMscTaxCode1 = NULL
      , @InvHdrMscTaxCode2 = NULL
      , @InvHdrTaxDate     = NULL
      , @InvHdrShipDate    = NULL
      , @InvHdrMiscCharges = (0)
      , @InvHdrPrepaidAmt  = (0)
      , @InvHdrFreight     = (0)
      , @InvHdrCost        = (0)
      , @InvHdrPrice       = (0)
      , @InvHdrSlsman      = NULL
      , @InvHdrCommCalc    = (0)
      , @InvHdrCommDue     = (0)
      , @InvHdrCommPaid    = (0)
      , @InvHdrTotCommDue  = (0)
      , @InvHdrCommBase    = (0)
      , @InvHdrEcCode      = NULL

   SET @InvHdrInvNum       = @TInvNum
   SET @InvHdrInvSeq       = 0
   SET @InvHdrCustNum      = @CoCustNum
   SET @InvHdrCustSeq      = @CoCustSeq
   SET @InvHdrCoNum        = @CoCoNum
   SET @InvHdrInvDate      = @InvDate
   SET @InvHdrTermsCode    = @CoTermsCode
   SET @InvHdrShipCode     = @CoShipCode
   SET @InvHdrCustPo       = @CoCustPo
   SET @InvHdrWeight       = @CoWeight
   SET @InvHdrQtyPackages  = @CoQtyPackages
   SET @InvHdrBillType     = 'P'
   SET @InvHdrState        = @CustaddrState
   SET @InvHdrExchRate     = CASE WHEN (@CoFixedRate = 1) THEN @CoExchRate ELSE @TRate END
   SET @InvHdrUseExchRate  = @CoUseExchRate
   SET @InvHdrTaxCode1     = @CoTaxCode1
   SET @InvHdrTaxCode2     = @CoTaxCode2
   SET @InvHdrFrtTaxCode1  = @CoFrtTaxCode1
   SET @InvHdrFrtTaxCode2  = @CoFrtTaxCode2
   SET @InvHdrMscTaxCode1  = @CoMscTaxCode1
   SET @InvHdrMscTaxCode2  = @CoMscTaxCode2
   SET @InvHdrFreight	   = @CoFreight
   SET @InvHdrTaxDate      = CASE WHEN ((@InvHdrInvDate < @TaxparmsLastTaxReport1)
                      AND   (@TaxparmsLastTaxReport1 IS NOT NULL))
                                  THEN
               @TaxparmsLastTaxReport1
                   ELSE
               @InvHdrInvDate
              END

   /* THE FOLLOWING ARE COMPUTED LATER */
   SET @InvHdrShipDate    = NULL
   SET @InvHdrMiscCharges = 0
   SET @InvHdrPrepaidAmt  = 0
   --SET @InvHdrFreight     = 0
   SET @InvHdrCost        = 0
   SET @InvHdrPrice       = 0
   SET @InvHdrSlsman      = @CoSlsman
   SET @InvHdrCommCalc    = 0
   SET @InvHdrCommDue     = 0
   SET @InvHdrCommPaid    = 0

   /* we will insert the inv_hdr record AFTER the arinv header
      due to trigger dependencies (arinvIup) */

   /* CREATE A/R HEADER */


   SET @TermsDueDays  = (0)
   SET @TermsProxCode = (99)
   SET @TermsProxDay  = (0)

   SELECT
        @TermsDueDays =  terms.due_days
      , @TermsProxCode = terms.prox_code
      , @TermsProxDay = terms.prox_day
      , @TermsProxMonthToForward     = terms.prox_month_to_forward
      , @TermsProxDiscDay            = terms.prox_disc_day
      , @TermsProxDiscMonthToForward = terms.prox_disc_month_to_forward
      , @TermsDiscDays               = terms.disc_days     
      , @TermsCutoffDay              = terms.cutoff_day
      , @TermsHolidayOffsetMethod    = terms.holiday_offset_method   
   FROM terms with (readuncommitted)
   WHERE terms.terms_code = @CoTermsCode

   SET @TermsDueDays =  ISNULL(@TermsDueDays, 0)
   SET @TermsProxDay = ISNULL(@TermsProxDay, 0)

   IF  @InvCred = 'I'
   BEGIN
      SET @ArtranRowPointer = NULL
      SET @ArtranCustNum    = NULL
      SET @ArtranInvNum     = '0'

      SELECT
           @ArtranRowPointer = artran.RowPointer
         , @ArtranCustNum    = artran.cust_num
         , @ArtranInvNum     = artran.inv_num
      FROM artran
      WHERE artran.cust_num  = @CoCustNum
    AND artran.inv_num   = @TInvNum
    AND artran.inv_seq   = 0
    AND artran.check_seq = 0

      IF @ArtranRowPointer IS NOT NULL
      BEGIN
    SET @Infobar = NULL
    EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=Exist2'
            , '@artran'
            , '@artran.cust_num'
            , @ArtranCustNum
            , '@artran.inv_num'
            , @ArtranInvNum

     GOTO END_PROG
      END

      SET @ArinvRowPointer     = NULL

      SET @ArinvCustNum        = NULL
      SET @ArinvInvNum         = '0'
      SET @ArinvType           = NULL
      SET @ArinvPostFromCo     = 0
      SET @ArinvCoNum          = NULL
      SET @ArinvInvDate        = NULL
      SET @ArinvTaxCode1       = NULL
      SET @ArinvTaxCode2       = NULL
      SET @ArinvTermsCode      = NULL
      SET @ArinvAcct           = NULL
      SET @ArinvAcctUnit1      = NULL
      SET @ArinvAcctUnit2      = NULL
      SET @ArinvAcctUnit3      = NULL
      SET @ArinvAcctUnit4      = NULL
      SET @ArinvRef            = NULL
      SET @ArinvDescription    = NULL
      SET @ArinvExchRate       = 0
      SET @ArinvUseExchRate    = 0
      SET @ArinvPayType        = NULL
      SET @ArinvDraftPrintFlag = 0
      SET @ArinvFixedRate      = 0
      SET @ArinvDueDate        = NULL
      SET @ArinvInvSeq         = 0
      SET @ArinvAmount         = 0
      SET @ArinvMiscCharges    = 0
      SET @ArinvFreight        = 0
      SET @ArinvSalesTax       = 0
      SET @ArinvSalesTax2      = 0

      SELECT
           @ArinvRowPointer     = arinv.RowPointer
         , @ArinvCustNum        = arinv.cust_num
         , @ArinvInvNum         = arinv.inv_num
         , @ArinvType           = arinv.type
         , @ArinvPostFromCo     = arinv.post_from_co
         , @ArinvCoNum          = arinv.co_num
         , @ArinvInvDate        = arinv.inv_date
         , @ArinvTaxCode1       = arinv.tax_code1
         , @ArinvTaxCode2       = arinv.tax_code2
         , @ArinvTermsCode      = arinv.terms_code
         , @ArinvAcct           = arinv.acct
         , @ArinvAcctUnit1      = arinv.acct_unit1
         , @ArinvAcctUnit2      = arinv.acct_unit2
         , @ArinvAcctUnit3      = arinv.acct_unit3
         , @ArinvAcctUnit4      = arinv.acct_unit4
         , @ArinvRef            = arinv.ref
         , @ArinvDescription    = arinv.description
         , @ArinvExchRate       = arinv.exch_rate
         , @ArinvUseExchRate    = arinv.use_exch_rate
         , @ArinvPayType        = arinv.pay_type
         , @ArinvDraftPrintFlag = arinv.draft_print_flag
         , @ArinvFixedRate      = arinv.fixed_rate
         , @ArinvDueDate        = arinv.due_date
         , @ArinvInvSeq         = arinv.inv_seq
         , @ArinvAmount         = arinv.amount
         , @ArinvMiscCharges    = arinv.misc_charges
         , @ArinvFreight        = arinv.freight
         , @ArinvSalesTax       = arinv.sales_tax
         , @ArinvSalesTax2      = arinv.sales_tax_2
      FROM arinv
      WHERE arinv.cust_num = @CoCustNum
         AND arinv.inv_num = @TInvNum
	
      IF @ArinvRowPointer IS NOT NULL
      BEGIN
         SET @Infobar = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=Exist2'
            , '@arinv'
            , '@arinv.cust_num'
            , @ArinvCustNum
            , '@arinv.inv_num'
            , @ArinvInvNum

         GOTO END_PROG
      END

      SET @ArinvExchRate       = ISNULL(@ArinvExchRate, 0)
      SET @ArinvAmount         = ISNULL(@ArinvAmount, 0)
      SET @ArinvMiscCharges    = ISNULL(@ArinvMiscCharges, 0)
      SET @ArinvFreight        = ISNULL(@ArinvFreight, 0)
      SET @ArinvSalesTax       = ISNULL(@ArinvSalesTax, 0)
      SET @ArinvSalesTax2      = ISNULL(@ArinvSalesTax2, 0)

      -- INITIALIZING VARS FOR TABLE INSERT
      SELECT
           @ArinvAmount         = (0)
         , @ArinvMiscCharges    = (0)
         , @ArinvFreight        = (0)
         , @ArinvSalesTax       = (0)
         , @ArinvSalesTax2      = (0)

      SET @ArinvCustNum        = @CoCustNum
      SET @ArinvInvNum         = @TInvNum
      SET @ArinvType           = 'I'
      SET @ArinvPostFromCo     = 1
      SET @ArinvCoNum          = @CoCoNum
      SET @ArinvInvDate        = @InvDate
      SET @ArinvTaxCode1       = @CoTaxCode1
      SET @ArinvTaxCode2       = @CoTaxCode2
      SET @ArinvTermsCode      = @CoTermsCode
      SET @ArinvAcct           = @TEndAcct
      SET @ArinvAcctUnit1      = @TEndAcctUnit1
      SET @ArinvAcctUnit2      = @TEndAcctUnit2
      SET @ArinvAcctUnit3      = @TEndAcctUnit3
      SET @ArinvAcctUnit4      = @TEndAcctUnit4
      SET @ArinvRef            = @TAr + CASE WHEN dbo.IsInteger(@ArinvInvNum) = 1 and convert(BIGINT, @ArinvInvNum) < 0
                                             THEN
                    ' -' + @ArinvInvNum
                    ELSE
                    '  ' + @ArinvInvNum
                    END
      SET @ArinvDescription    = @TInvLabel + ' ' + @ArinvInvNum
      SET @ArinvExchRate       = @InvHdrExchRate
      SET @ArinvUseExchRate    = @CoUseExchRate
      SET @ArinvPayType        = @CustomerPayType
      SET @ArinvDraftPrintFlag = CASE WHEN @CustomerPayType = 'D'
                    AND @CustomerDraftPrintFlag = 1
                    AND @pMooreForms = 'D'
                                      THEN
                  1
                  ELSE
                  0
                  END

      SET @ArinvFixedRate      = @CoFixedRate
      EXEC dbo.DueDateSp @InvoiceDate = @ArinvInvDate
                 , @DueDays     = @TermsDueDays
                 , @ProxCode    = @TermsProxCode
                 , @ProxDay     = @TermsProxDay
                 , @pTermsCode  = @CoTermsCode
                 , @ProxMonthToForward     = @TermsProxMonthToForward
                 , @CutoffDay              = @TermsCutoffDay
                 , @HolidayOffsetMethod    = @TermsHolidayOffsetMethod
                 , @ProxDiscMonthToForward = @TermsProxDiscMonthToForward
                 , @DiscDays               = @TermsDiscDays
                 , @ProxDiscDay            = @TermsProxDiscDay                 
                 , @DueDate                = @ArinvDueDate   OUTPUT
                 , @DiscDate                = @ArinvDiscDate   OUTPUT
                 
	-- ZLA BEGIN ARINV
	SET  @ArinvZlaForAmount			=  0	-- ZLA Pending
	SET  @ArinvZlaForMiscCharges	= @InvHdrZlaForMiscCharges
	SET  @ArinvZlaForFreight		= @InvHdrZlaForFreight
	SET  @ArinvZlaForExchRate		= @InvHdrZlaForExchRate
	SET  @ArinvZlaForCurrCode		= @InvHdrZlaForCurrCode
	SET  @ArinvZlaForSalesTax		= 0
	SET  @ArinvZlaForSalesTax2		= 0
	SET  @ArinvZlaForFixedRate		= @CoZlaForFixedRate       
    -- ZLA END                 

      INSERT INTO arinv
         ( cust_num
         , inv_num
         , type
         , post_from_co
         , co_num
         , inv_date
         , tax_code1
         , tax_code2
         , terms_code
         , acct
         , acct_unit1
         , acct_unit2
         , acct_unit3
         , acct_unit4
         , ref
         , description
         , exch_rate
         , use_exch_rate
         , pay_type
         , draft_print_flag
         , fixed_rate
         , due_date
         , apply_to_inv_num 
         , builder_inv_orig_site
         , builder_inv_num
		         , zla_inv_num
				 , zla_ar_type_id
				 , zla_doc_id
				 , zla_for_amount
				 , zla_for_misc_charges
				 , zla_for_freight
				 , zla_for_exch_rate
				 , zla_for_curr_code
				 , zla_for_sales_tax
				 , zla_for_sales_tax_2
				 , zla_for_fixed_rate
				 , zla_auth_code 
				 , zla_auth_end_date )
      VALUES
         ( @ArinvCustNum
         , @ArinvInvNum
         , @ArinvType
         , 0 --@ArinvPostFromCo
         , @ArinvCoNum
         , @ArinvInvDate
         , @ArinvTaxCode1
         , @ArinvTaxCode2
         , @ArinvTermsCode
         , @ArinvAcct
         , @ArinvAcctUnit1
         , @ArinvAcctUnit2
         , @ArinvAcctUnit3
         , @ArinvAcctUnit4
         , @ArinvRef
         , @ArinvDescription
         , @ArinvExchRate
         , @ArinvUseExchRate
         , @ArinvPayType
         , @ArinvDraftPrintFlag
         , @ArinvFixedRate
         , @ArinvDueDate
         , @ArinvInvNum 
         , @BuilderInvOrigSite
         , @BuilderInvNum
				 , @ArinvZlaInvNum
				 , @ArinvZlaArTypeId
				 , @ArinvZlaDocId
				 , @ArinvAmount
				 , @ArinvMiscCharges
				 , @ArinvFreight
				 , @ArinvExchRate
				 , @ArinvZlaForCurrCode
				 , @ArinvSalesTax
				 , @ArinvSalesTax2
				 , @ArinvFixedRate
				 , @ArinvZlaAuthCode
				 , @ArinvZlaAuthEndDate)
	

   END /* IF @InvCred = 'I' */
   ELSE
   BEGIN
	  /*  @InvCred = 'C' */

      SET @ArinvCustNum        = @CoCustNum
      SET @ArinvInvNum         = @TInvNum --'0'  /*t-inv-num*/
      SET @ArinvType           = 'C'
      SET @ArinvCoNum          = @CoCoNum
      SET @ArinvInvDate        = @InvDate
      SET @ArinvDueDate        = @InvDate
      SET @ArinvTaxCode1       = @CoTaxCode1
      SET @ArinvTaxCode2       = @CoTaxCode2
      SET @ArinvTermsCode      = @CoTermsCode
      SET @ArinvAcct           = @TEndAcct
      SET @ArinvAcctUnit1      = @TEndAcctUnit1
      SET @ArinvAcctUnit2      = @TEndAcctUnit2
      SET @ArinvAcctUnit3      = @TEndAcctUnit3
      SET @ArinvAcctUnit4      = @TEndAcctUnit4
      /* amount, misc-charges, sales-tax, freight SET BELOW */
      SET @ArinvRef            = @TArCredit
      SET @ArinvDescription    = @TOpen  + ' ' + @TInvNum
      SET @ArinvPostFromCo     = 1
      SET @ArinvExchRate       = @InvHdrExchRate
      SET @ArinvUseExchRate    = @CoUseExchRate
      SET @ArinvPayType        = @CustomerPayType

      SET @ArinvDraftPrintFlag = CASE WHEN @CustomerPayType = 'D'
                  AND @CustomerDraftPrintFlag = 1
                  AND @pMooreForms = 'D'
                                      THEN
                  1
                  ELSE
                  0
                  END

      SET @ArinvFixedRate      = @CoFixedRate
      SET @ArinvRowPointer     = newid()
	  SET @ArinvApplyToInvNum	= @ApplyToInvNum

	  --select @ArinvApplyToInvNum = co.zpv_inv_num from co where co.co_num = @CoCoNum
      if not exists(select * from progbill where inv_num = @ArinvApplyToInvNum)
	  begin
		set @Infobar = 'Error en factura a aplicar'
		GOTO END_PROG
	  end

	  INSERT INTO arinv
         ( cust_num
         , inv_num
         , type
         , post_from_co
         , co_num
         , inv_date
         , due_date
         , tax_code1
         , tax_code2
         , terms_code
         , acct
         , acct_unit1
         , acct_unit2
         , acct_unit3
         , acct_unit4
         , ref
         , description
         , exch_rate
         , use_exch_rate
         , pay_type
         , draft_print_flag
         , fixed_rate
         , RowPointer
         , apply_to_inv_num
         , builder_inv_orig_site
         , builder_inv_num
				, zla_inv_num
				 , zla_ar_type_id
				 , zla_doc_id
				 , zla_for_amount
				 , zla_for_misc_charges
				 , zla_for_freight
				 , zla_for_exch_rate
				 , zla_for_curr_code
				 , zla_for_sales_tax
				 , zla_for_sales_tax_2
				 , zla_for_fixed_rate
				 , zla_auth_code 
				 , zla_auth_end_date )         
      VALUES
         ( @ArinvCustNum
         , @ArinvInvNum
         , @ArinvType
         , @ArinvPostFromCo
         , @ArinvCoNum
         , @ArinvInvDate
         , @ArinvDueDate
         , @ArinvTaxCode1
         , @ArinvTaxCode2
         , @ArinvTermsCode
         , @ArinvAcct
         , @ArinvAcctUnit1
         , @ArinvAcctUnit2
         , @ArinvAcctUnit3
         , @ArinvAcctUnit4
         , @ArinvRef
         , @ArinvDescription
         , @ArinvExchRate
         , @ArinvUseExchRate

         , @ArinvPayType
         , @ArinvDraftPrintFlag
         , @ArinvFixedRate
         , @ArinvRowPointer
         , ISNULL(@ArinvApplyToInvNum,'0')   
         , @BuilderInvOrigSite
         , @BuilderInvNum
				 , @ArinvZlaInvNum
				 , @ArinvZlaArTypeId
				 , @ArinvZlaDocId
				 , @ArinvAmount
				 , @ArinvMiscCharges
				 , @ArinvFreight
				 , @ArinvExchRate
				 , @ArinvZlaForCurrCode
				 , @ArinvSalesTax
				 , @ArinvSalesTax2
				 , @ArinvFixedRate
				 , @ArinvZlaAuthCode
				 , @ArinvZlaAuthEndDate)
         
   END


   --  Get ArinvInvSeq as it is set by the trigger

   SET @ArinvInvSeq = 0
   SELECT
      @ArinvInvSeq = arinv.inv_seq
   FROM arinv
   WHERE arinv.RowPointer = @ArinvRowPointer

   SET @NewRowpointer = NEWID()

   /* now insert the inv_hdr record */
   INSERT INTO inv_hdr
      ( inv_num
      , inv_seq
      , cust_num
      , cust_seq
      , co_num
      , inv_date
      , terms_code
      , ship_code
      , cust_po
      , weight
      , qty_packages
      , bill_type
      , state
      , exch_rate
      , use_exch_rate
      , tax_code1
      , tax_code2
      , frt_tax_code1
      , frt_tax_code2
      , msc_tax_code1
      , msc_tax_code2
      , tax_date
      , misc_charges
      , prepaid_amt
      , freight
      , cost
      , price
      , slsman
      , comm_calc
      , comm_due
      , comm_paid
      , tot_comm_due
      , comm_base
      , ec_code
      , RowPointer 
      , builder_inv_orig_site
      , builder_inv_num
				 , zla_inv_num
				 , zla_for_curr_code
				 , zla_for_exch_rate
				 , zla_for_price
				 , zla_for_misc_charges
				 , zla_for_freight
				 , zla_for_disc_amount
				 , zla_for_prepaid_amt)
   VALUES
      ( @InvHdrInvNum
      , @InvHdrInvSeq
      , @InvHdrCustNum
      , @InvHdrCustSeq
      , @InvHdrCoNum
      , @InvHdrInvDate
      , @InvHdrTermsCode
      , @InvHdrShipCode
      , @InvHdrCustPo
      , @InvHdrWeight
      , @InvHdrQtyPackages
      , @InvHdrBillType
      , @InvHdrState
      , @InvHdrExchRate
      , @InvHdrUseExchRate
      , @InvHdrTaxCode1
      , @InvHdrTaxCode2
      , @InvHdrFrtTaxCode1
      , @InvHdrFrtTaxCode2
      , @InvHdrMscTaxCode1
      , @InvHdrMscTaxCode2
      , @InvHdrTaxDate
      , @InvHdrMiscCharges
      , @InvHdrPrepaidAmt
      , @InvHdrFreight
      , @InvHdrCost
      , @InvHdrPrice
      , @InvHdrSlsman
      , @InvHdrCommCalc
      , @InvHdrCommDue
      , @InvHdrCommPaid
      , @InvHdrTotCommDue
      , @InvHdrCommBase
      , @InvHdrEcCode
      , @NewRowpointer 
      , @BuilderInvOrigSite
      , @BuilderInvNum
				 , @InvHdrZlaInvNum
				 , @InvHdrZlaForCurrCode
				 , @InvHdrExchRate
				 , @InvHdrPrice
				 , @InvHdrMiscCharges
				 , @InvHdrFreight
				 , @InvHdrZlaForDiscAmount
				 , @InvHdrPrepaidAmt)

   -- Enter record in TrackRows for printing
   IF @CustTpPaperInv = 1
   BEGIN
      INSERT INTO TrackRows (
        SessionId
      , TrackedOperType
      , RowPointer )
      VALUES (
        @ProcessId
      , 'inv_hdr'
      , @NewRowpointer )
   END
   
   
   -- Begin/End Invoice Number
   IF @StartInvNum = '0' or @InvHdrInvNum < @StartInvNum
      SET @StartInvNum = @InvHdrInvNum
   
   IF @EndInvNum = '0' or @InvHdrInvNum > @EndInvNum
      SET @EndInvNum = @InvHdrInvNum


   /* PROCESSES ALL LINE ITEMS ON THIS ORDER */


   SET @CoitemLineCounter = 0
   SET @TDistSeq        = 0
   SET @TOrderBal       = 0
   SET @TSalesTax       = 0
   SET @TSalesTax2      = 0
   SET @TPrepaidAmt     = @CoPrepaidAmt
   SET @ProjAccum       = 0
   IF @CalledFrom = 'InvoiceBuilder'
      DECLARE coitemCrs CURSOR local static FOR
      SELECT
           co_bln.RowPointer
         , co_bln.co_num
         , co_bln.co_line
         , co_bln.item
         , co_bln.zpv_total_disc			--co_bln.disc
         , null								--coitem.process_ind
         , 0								--coitem.cons_num
         , co_bln.zpv_tax_code1				--coitem.tax_code1
         , co_bln.zpv_tax_code2				--coitem.tax_code2
         , co_bln.cont_price_conv
         , co_bln.blanket_qty_conv
         , co_bln.zpv_qty_shipped			--coitem.qty_shipped
         , co_bln.zpv_qty_returned			--coitem.qty_returned
         , co_bln.zpv_qty_invoiced			--coitem.qty_invoiced
         , co_bln.stat
         , co_bln.zpv_prg_bill_tot			--coitem.prg_bill_tot
         , co_bln.zpv_prg_bill_app			--coitem.prg_bill_app
         , 0			--coitem.co_release
         , null			--coitem.ship_date
         , 'I'			--coitem.ref_type
         , null			--coitem.ref_num
         , 0			--coitem.ref_line_suf
         , isnull((select sum(progbill.bill_amt) from progbill
            where progbill.co_num = co_bln.co_num
            and progbill.co_line = co_bln.co_line
            and progbill.seq > 0
            and (progbill.invc_flag = 'Y' or (progbill.invc_flag = 'A'
               and progbill.bill_date <= @InvDate))), 0) as progbill_total      
         , item.subject_to_excise_tax 
         , item.excise_tax_percent 
      FROM co_bln WITH (UPDLOCK)
      INNER JOIN tmp_invoice_builder 
        ON co_bln.RowPointer = coitem_RowPointer AND process_ID = @InvoicBuilderProcessID  
      LEFT OUTER JOIN item ON item.item = co_bln.item 
      WHERE co_bln.co_num = @CoCoNum
         AND co_bln.co_line BETWEEN ISNULL(@StartLine, co_bln.co_line) AND ISNULL(@EndLine, co_bln.co_line)
         AND co_bln.stat = 'O'   
   ELSE
	  
      DECLARE coitemCrs CURSOR local static FOR
      SELECT
           co_bln.RowPointer
         , co_bln.co_num
         , co_bln.co_line
         , co_bln.item
         , co_bln.zpv_co_disc				--co_bln.disc
         , null								--coitem.process_ind
         , 0								--coitem.cons_num
         , co_bln.zpv_tax_code1				--coitem.tax_code1
         , co_bln.zpv_tax_code2				--coitem.tax_code2
         , co_bln.cont_price_conv - isnull(co_bln.zpv_total_disc,0) --coitem.price
         , case @InvCred 
				when 'I' then co_bln.blanket_qty_conv
				when 'C' then co_bln.zpv_qty_returned
				else 0
		   end
         , co_bln.zpv_qty_shipped			--coitem.qty_shipped
         , 0								--coitem.qty_returned
         , 0								--coitem.qty_invoiced
         , co_bln.stat
         , co_bln.zpv_prg_bill_tot			--coitem.prg_bill_tot
         , co_bln.zpv_prg_bill_app			--coitem.prg_bill_app
         , 0								--coitem.co_release
         , null								--coitem.ship_date
         , 'I'								--coitem.ref_type
         , null								--coitem.ref_num
         , 0								--coitem.ref_line_suf
		 , isnull((select sum(progbill.bill_amt) from progbill
            where progbill.co_num = co_bln.co_num
            and progbill.co_line = co_bln.co_line
            and progbill.seq > 0
            and (progbill.invc_flag = 'Y' or (progbill.invc_flag = 'A'
               and progbill.bill_date <= @InvDate))), 0) as progbill_total      
         , item.subject_to_excise_tax 
         , item.excise_tax_percent 
      FROM co_bln WITH (UPDLOCK)
      LEFT OUTER JOIN item ON item.item = co_bln.item 
      WHERE co_bln.co_num = @CoCoNum
         AND co_bln.co_line BETWEEN ISNULL(@StartLine, co_bln.co_line) AND ISNULL(@EndLine, co_bln.co_line)
         AND co_bln.stat = 'O'
      
   OPEN coitemCrs

   WHILE @Severity = 0
   BEGIN
      FETCH coitemCrs INTO
           @CoitemRowPointer
         , @CoitemCoNum
         , @CoitemCoLine
         , @CoitemItem
         , @CoitemDisc
         , @CoitemProcessInd
         , @CoitemConsNum
         , @CoitemTaxCode1
         , @CoitemTaxCode2
         , @CoitemPrice
         , @CoitemQtyOrdered
         , @CoitemQtyShipped
         , @CoitemQtyReturned
         , @CoitemQtyInvoiced
         , @CoitemStat
         , @CoitemPrgBillTot
         , @CoitemPrgBillApp
         , @CoitemCoRelease
         , @CoitemShipDate
         , @CoitemRefType
         , @CoitemRefNum
         , @CoitemRefLineSuf
		 , @ProgbillBillAmt
         , @ItemSubjectToExciseTax 
         , @ItemExciseTaxPercent 

      IF @@FETCH_STATUS = -1
         BREAK

      if @ProgbillBillAmt = 0 and @CoitemPrice != 0
         continue

      SET @CoitemDisc = ISNULL(@CoitemDisc, 0)
      SET @CoitemPrice = ISNULL(@CoitemPrice, 0)
      SET @CoitemQtyOrdered = ISNULL(@CoitemQtyOrdered, 0)
      SET @CoitemQtyShipped = ISNULL(@CoitemQtyShipped, 0)
      SET @CoitemQtyReturned = ISNULL(@CoitemQtyReturned, 0)
      SET @CoitemQtyInvoiced = ISNULL(@CoitemQtyInvoiced, 0)
      SET @CoitemPrgBillTot = ISNULL(@CoitemPrgBillTot, 0)
      SET @CoitemPrgBillApp = ISNULL(@CoitemPrgBillApp, 0)

      /* POST TO INVOICE HISTORY */

      -- INITIALIZING VARS FOR TABLE INSERT
      SELECT
           @InvItemCost        = (0)
         , @InvItemQtyInvoiced = (0)
         , @InvItemPrice       = (0)

      SET @CoitemLineCounter = @CoitemLineCounter +1
      SET @InvItemInvNum      = @InvHdrInvNum
      SET @InvItemInvSeq      = @InvHdrInvSeq
      SET @InvItemCoNum       = @CoitemCoNum
      SET @InvItemCoLine      = @CoitemCoLine
      SET @InvItemCoRelease   = 0
      SET @InvItemItem        = @CoitemItem
      SET @InvItemDisc        = @CoitemDisc
      SET @InvItemProcessInd  = @CoitemProcessInd
      SET @InvItemConsNum     = @CoitemConsNum
      SET @InvItemTaxCode1    = @CoitemTaxCode1
      SET @InvItemTaxCode2    = @CoitemTaxCode2
      SET @InvItemTaxDate     = CASE WHEN ((@InvHdrInvDate < @TaxparmsLastSsdReport)
                  AND @TaxparmsLastSsdReport IS NOT NULL)
                                     THEN
                  @TaxparmsLastSsdReport
                 ELSE
                  @InvHdrInvDate
                 END
      SET @InvItemCost        = 0
      SET @InvItemQtyInvoiced = case 
									when @ProgbillBillAmt < 0 then -(@CoitemQtyOrdered)
									else @CoitemQtyOrdered
								end --@CoitemQtyShipped + @CoitemQtyReturned - @CoitemQtyInvoiced
      SET @InvItemExciseTaxPercent = CASE WHEN @ItemSubjectToExciseTax <> 1
										  THEN NULL
										  ELSE @ItemExciseTaxPercent
										  END
	  
	  SET @InvItemPrice		  = @CoitemPrice
	  SET @InvItemZlaForPrice = @InvItemPrice
	  
	  INSERT INTO inv_item
            ( inv_num
            , inv_seq
            , co_num
            , co_line
            , co_release
            , item
            , disc
            , process_ind
            , cons_num
            , tax_code1
            , tax_code2
            , tax_date
            , cost
            , price
            , qty_invoiced
            , excise_tax_percent
            , zla_for_price )
			
      VALUES
            ( @InvItemInvNum
            , @InvItemInvSeq
            , @InvItemCoNum
            , @InvItemCoLine
            , @InvItemCoRelease
            , @InvItemItem
            , @InvItemDisc
            , @InvItemProcessInd
            , @InvItemConsNum
            , @InvItemTaxCode1
            , @InvItemTaxCode2
            , @InvItemTaxDate
            , @InvItemCost
            , @InvItemPrice --@ProgbillBillAmt
            , @InvItemQtyInvoiced
            , @InvItemExciseTaxPercent
            , @InvItemPrice)
            
      /* PROCESSES ALL PROGRESSIVE BILLS ON THIS LINE ITEM */
	  
      DECLARE progbill2Crs CURSOR local static FOR
      SELECT
           progbill.RowPointer
         , progbill.invc_flag
         , progbill.bill_date
         , progbill.bill_amt
         , progbill.seq
         , progbill.description
         , progbill.inv_num
      FROM progbill WITH (UPDLOCK)
      WHERE progbill.co_num = @CoitemCoNum
         AND progbill.co_line = @CoitemCoLine
         AND progbill.seq > 0


      OPEN progbill2Crs

      WHILE @Severity = 0
      BEGIN
         FETCH progbill2Crs INTO
              @ProgbillRowPointer
            , @ProgbillInvcFlag
       , @ProgbillBillDate
       , @ProgbillBillAmt
       , @ProgbillSeq
       , @ProgbillDescription
       , @ProgbillInvNum

         IF @@FETCH_STATUS = -1
       BREAK

         SET @ProgbillBillAmt = ISNULL(@ProgbillBillAmt, 0)

         IF NOT ((@ProgbillInvcFlag = 'Y'
       OR (@ProgbillInvcFlag = 'A' AND @ProgbillBillDate <=  @InvDate)))
       CONTINUE

         IF @CoitemStat = 'O' OR @CoitemStat = 'F'
       SET @TOrderBal = @TOrderBal - dbo.LineBalSp(  @CoitemQtyOrdered
                          , @CoitemQtyInvoiced
                          , @CoitemQtyReturned
                          , @CoitemPrice
                          , @CoitemDisc
                          , @CoitemPrgBillTot
                          , @CoitemPrgBillApp
                          , @CurrencyPlaces)

         SET @InvProSeq         = @ProgbillSeq
         SET @InvProInvNum      = @InvHdrInvNum
         SET @InvProCoNum       = @CoitemCoNum
         SET @InvProCoLine      = @CoitemCoLine
         SET @InvProAmount      = @ProgbillBillAmt
         SET @InvProDescription = @ProgbillDescription

         INSERT INTO inv_pro
         ( seq
         , inv_num
         , co_num
         , co_line
         , amount
         , description)
         VALUES
         ( @InvProSeq
         , @InvProInvNum
         , @InvProCoNum
         , @InvProCoLine
         , @InvProAmount
         , @InvProDescription )

         UPDATE progbill
         SET
              invc_flag = 'I'
            , inv_num   = @InvProInvNum
         WHERE
            progbill.RowPointer = @ProgbillRowPointer
		 	
         --  Because the SumCoSp routine uses a total regeneration algorithmn,
         -- all the coitem records are needed. This lock is to prevent deadlock
         -- in cases where multiple users are working with different coitem
         -- records on the same order, like someone else is adding a release.

         EXEC @Severity = dbo.LockCoSp
           @CoNum = @CoCoNum
         , @Lock  = 1

		 
         SET @CoitemPrgBillTot = @CoitemPrgBillTot + @ProgbillBillAmt

         EXEC @Severity = dbo.DefineVariableSp 'CoitemUpdatePrgBillTot', '1', @Infobar
         EXEC @Severity = dbo.DefineVariableSp 'SkipCoitemUpdateCustOrderBal', '1', @Infobar
		 
         
         UPDATE co_bln
         SET	zpv_prg_bill_tot = isnull(zpv_prg_bill_tot,0) + @ProgbillBillAmt,
				zpv_qty_invoiced = isnull(zpv_qty_invoiced,0) + @InvItemQtyInvoiced	
         WHERE co_bln.RowPointer = @CoitemRowPointer
		 
		 IF @InvItemQtyInvoiced > 0 --Factura
		 BEGIN
			 UPDATE coitem
			 SET	qty_invoiced = 0 --qty_ordered
			 WHERE  co_num = @CoitemCoNum
				and	co_line = @CoitemCoLine
		 END		 	
		 ELSE --Nota de Credito
		 BEGIN
			set @ZpvQtyNulled = -(@InvItemQtyInvoiced)
			declare CurCoitemNulled cursor for
			select
				coi.co_num
			,	coi.co_line
			,	coi.co_release
			,	coi.qty_invoiced
			from coitem coi
			where	coi.co_num = @CoitemCoNum
				and	coi.co_line = @CoitemCoLine
			order by coi.due_date desc
			open CurCoitemNulled
			fetch next from CurCoitemNulled
			into
				@ZpvCoitemCoNum
			,	@ZpvCoitemCoLine
			,	@ZpvCoitemCoRelease
			,	@ZpvCoitemQtyInvoiced
			while @@fetch_status = 0
			begin
				if @ZpvQtyNulled > 0
				begin
					if @ZpvCoitemQtyInvoiced >= @ZpvQtyNulled
					begin
						UPDATE	coitem
						SET		qty_invoiced = 0 --qty_invoiced - @ZpvQtyNulled
						WHERE	co_num = @ZpvCoitemCoNum
							and	co_line = @ZpvCoitemCoLine
							and co_release = @ZpvCoitemCoRelease
						SET @ZpvQtyNulled = -1
					end	
					else
					begin
						UPDATE	coitem
						SET		qty_invoiced = 0
						WHERE	co_num = @ZpvCoitemCoNum
							and	co_line = @ZpvCoitemCoLine
							and co_release = @ZpvCoitemCoRelease
						SET @ZpvQtyNulled = @ZpvQtyNulled - @ZpvCoitemQtyInvoiced
					end
				end
				else break

				fetch next from CurCoitemNulled
				into
					@ZpvCoitemCoNum
				,	@ZpvCoitemCoLine
				,	@ZpvCoitemCoRelease
				,	@ZpvCoitemQtyInvoiced
			end
			close CurCoitemNulled
			deallocate CurCoitemNulled
		 END

         EXEC dbo.UndefineVariableSp 'SkipCoitemUpdateCustOrderBal', @Infobar
         EXEC dbo.UndefineVariableSp 'CoitemUpdatePrgBillTot', @Infobar

         SET @InvHdrPrice       = @InvHdrPrice + @ProgbillBillAmt
         UPDATE inv_hdr
         SET price = @InvHdrPrice, zla_for_price = @InvHdrPrice
         WHERE inv_num = @InvHdrInvNum
       AND inv_seq = @InvHdrInvSeq

         /*
		 SET @InvItemPrice = @InvItemPrice + @CoitemPrice
         UPDATE inv_item
         SET price = @InvItemPrice, zla_for_price = @InvItemPrice
         WHERE inv_num = @InvItemInvNum
         AND inv_seq = @InvItemInvSeq
         AND inv_line = 0
         AND co_num = @InvItemCoNum
         AND co_line = @InvItemCoLine
         AND co_release = 0 --@InvItemCoRelease
		 */

		
         IF @CoitemStat = 'O' OR @CoitemStat = 'F'
       SET @TOrderBal = @TOrderBal + dbo.LineBalSp(  @CoitemQtyOrdered
                          , @CoitemQtyInvoiced
                          , @CoitemQtyReturned
                          , @CoitemPrice
                          , @CoitemDisc
                          , @CoitemPrgBillTot
                          , @CoitemPrgBillApp
                          , @CurrencyPlaces)
      END

      CLOSE      progbill2Crs
      DEALLOCATE progbill2Crs /* for each progbill */

      /* POST TO ITEM MASTER */
	 

      SET @ItemRowPointer = NULL
      SET @ItemLastInv    = NULL
      SET @NonInventoryItem = 0

      SELECT
           @ItemRowPointer = item.RowPointer
         , @ItemLastInv    = item.last_inv
      FROM item WITH (UPDLOCK)
      WHERE item = @CoitemItem

      IF @ItemRowPointer IS NULL
      BEGIN
         SET @NonInventoryItem = 1
      END

      IF @NonInventoryItem = 0
      BEGIN
	     SET @ItemLastInv = @InvDate  
         UPDATE item  
         SET last_inv = @ItemLastInv  
         WHERE item = @CoitemItem
      END
      
      SET @InvHdrShipDate = dbo.MinDate(@InvHdrShipDate, @CoitemShipDate)
      SET @InvHdrPrepaidAmt = CASE WHEN @InvHdrBillType = 'P' AND @InvCred = 'I'
                                   THEN
         case when @InvHdrPrice >= 0 then
                                        dbo.MinQty(@InvHdrPrice,@CoPrepaidAmt)
         else
            dbo.MaxQty(@InvHdrPrice, @CoPrepaidAmt)
         end
                                   ELSE
                                        0
                                   END
      UPDATE inv_hdr
      SET ship_date   = @InvHdrShipDate
        , prepaid_amt = @InvHdrPrepaidAmt
      WHERE inv_num = @InvHdrInvNum
         AND inv_seq = @InvHdrInvSeq
		
      SET @CoPrepaidT = @CoPrepaidT + @InvHdrPrepaidAmt
      SET @CoPrepaidAmt  = @CoPrepaidAmt - @InvHdrPrepaidAmt
      UPDATE co
      SET prepaid_t   = @CoPrepaidT
        , prepaid_amt = @CoPrepaidAmt
      WHERE RowPointer = @XCoRowPointer

         SET @OLvlDiscLineNet = @TLineNet * (1.0 - ISNULL(@CoDisc,0.0) / 100.0)
         SET @TLineNet = round(@InvItemQtyInvoiced * @InvItemPrice, @CurrencyPlaces)
         SET @TLineTot = round(@InvItemQtyInvoiced * @CoitemPrice, @CurrencyPlaces)
         SET @TSubTotFull = @TSubTotFull + @TLineNet
         SET @TSubTotFull = 0
         SET @TaxInclDiscount      = 0
         SET @Tax1OnAmount         = 0.0
         SET @Tax2OnAmount         = 0.0
         SET @Tax1OnDiscAmount     = 0.0
         SET @Tax2OnDiscAmount     = 0.0
         SET @Tax1OnUndiscAmount   = 0.0
         SET @Tax2OnUndiscAmount   = 0.0
         SET @TotalTaxOnDiscAmount = 0.0
         SET @DiscAmountInclTax    = 0.0
         SET @DiscAmountInclTax2   = 0.0


         IF @CoIncludeTaxInPrice = 1
         BEGIN
            SET @DiscAmountInclTax = @TLineTot - @TLineNet
            SET @DiscAmountInclTax2 = @TLineTot - @InvHdrPrice
            set @InvHdrPrice = @InvHdrPrice - @InvItemPrice

            -- Separate amount including tax to amount without tax and tax amounts
            EXEC @Severity = dbo.TaxPriceSeparationSp
                 @InvType                 = 'R'
               , @Type                    = 'I'
               , @TaxCode1                = @InvItemTaxCode1
               , @TaxCode2                = @InvItemTaxCode2
               , @HdrTaxCode1             = @InvHdrTaxCode1
               , @HdrTaxCode2             = @InvHdrTaxCode2
               , @Amount                  = @InvItemPrice
               , @UndiscAmount            = @InvItemPrice
               , @CurrCode                = @CustaddrCurrCode
               , @ExchRate                = @InvHdrExchRate
               , @UseExchRate             = @InvHdrUseExchRate
               , @Places                  = @CurrencyPlaces
               , @InvDate                 = @InvHdrInvDate
               , @TermsCode               = @InvHdrTermsCode
               , @AmountWithoutTax        = @InvItemPrice OUTPUT
               , @UndiscAmountWithoutTax  = @InvItemPrice OUTPUT
               , @Tax1OnAmount            = @Tax1OnAmount       OUTPUT
               , @Tax2OnAmount            = @Tax2OnAmount       OUTPUT
               , @Tax1OnUndiscAmount      = @Tax1OnUndiscAmount OUTPUT
               , @Tax2OnUndiscAmount      = @Tax2OnUndiscAmount OUTPUT
               , @Infobar                 = @Infobar            OUTPUT


            IF @Severity <> 0
               GOTO END_PROG

            set @InvHdrPrice = @InvHdrPrice + @InvItemPrice

            /* If CO is set as Price Included Tax and if dicounts are involved
             * then the discount was applied on Price Including Tax.
             * If discounts are not taxed then tax portion of discount needs to be
             * added to Sales amount.  To find that out find if there is a difference
             * between @Tax1OnAmount + @Tax1OnAmount (tax on discounted amount)
             * and @Tax1OnUndiscAmount + @Tax1OnUndiscAmount (tax on undiscounted amount).
             * Find the tax on Discount amount for this line and add this to Sales amount.
             */


            IF (@Tax1OnUndiscAmount + @Tax2OnUndiscAmount) - (@Tax1OnAmount + @Tax2OnAmount) = 0.0
               SET @TaxInclDiscount = 0
            ELSE
               SET @TaxInclDiscount = 1

            -- Find the tax on Discount amount to be added to Sales amount.
            EXEC @Severity = dbo.TaxPriceSeparationSp
                 @InvType                 = 'R'
               , @Type                    = 'I'
               , @TaxCode1                = @InvItemTaxCode1
               , @TaxCode2                = @InvItemTaxCode2
               , @HdrTaxCode1             = @InvHdrTaxCode1
               , @HdrTaxCode2             = @InvHdrTaxCode2
               , @Amount                  = @DiscAmountInclTax2
               , @UndiscAmount            = @DiscAmountInclTax2
               , @CurrCode                = @CustaddrCurrCode
               , @ExchRate                = @InvHdrExchRate
               , @UseExchRate             = @InvHdrUseExchRate
               , @Places                  = @CurrencyPlaces
               , @InvDate                 = @InvHdrInvDate
               , @TermsCode               = @InvHdrTermsCode
               , @AmountWithoutTax        = @xAmount1         OUTPUT
               , @UndiscAmountWithoutTax  = @xAmount1         OUTPUT
               , @Tax1OnAmount            = @Tax1OnDiscAmount OUTPUT
               , @Tax2OnAmount            = @Tax2OnDiscAmount OUTPUT
               , @Tax1OnUndiscAmount      = @xAmount1         OUTPUT
               , @Tax2OnUndiscAmount      = @xAmount1         OUTPUT
               , @Infobar                 = @Infobar          OUTPUT

            IF @Severity <> 0
               GOTO END_PROG

            SET @TotalTaxOnDiscAmount = @Tax1OnDiscAmount + @Tax2OnDiscAmount

         END -- IF @CoIncludeTaxInPrice = 1

      /* ACCUMULATE TAXABLES FOR THIS LINE ITEM */
      SELECT @InvItemRowPointer = inv_item.RowPointer  
      FROM inv_item                                    
      WHERE inv_item.inv_num    =  @InvItemInvNum      
        AND inv_item.inv_seq    =  @InvItemInvSeq      
        AND inv_item.co_num     =  @InvItemCoNum       
        AND inv_item.co_line    =  @InvItemCoLine      
        AND inv_item.co_release =  0 --@InvItemCoRelease
	  
	  
      EXEC @Severity = dbo.TaxBaseSp
                           @PInvType        = 'P'
          , @PType           = 'I'
          , @PTaxCode1       = @InvItemTaxCode1
          , @PTaxCode2       = @InvItemTaxCode2
          , @PAmount         = @ProgbillBillAmt  --@InvItemPrice
          , @PAmountToApply  = 0
          , @PUndiscAmount   = @ProgbillBillAmt  --@InvItemPrice
          , @PUWsPrice       = NULL
          , @PTaxablePrice   = NULL
          , @PQtyInvoiced    = @InvItemQtyInvoiced
          , @PCurrCode       = @CustaddrCurrCode
          , @PInvDate        = @InvHdrInvDate
          , @PExchRate       = @InvHdrExchRate
          , @Infobar         = @Infobar            OUTPUT
          , @pRefType       = 'IP'			   -- SSS Vertex Add 
          , @pHdrPtr        = @NewRowPointer   -- SSS Vertex Add
          , @pLineRefType   = NULL                
          , @pLinePtr       = @InvItemRowPointer

      IF @Severity <> 0
      BEGIN
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed3'
            , '@%co/tax_base'
            , '@coitem'
            , '@coitem.co_num'
            , @CoitemCoNum
            , '@coitem.co_line'
            , @CoitemCoLine
            , '@coitem.co_release'
            , @CoitemCoRelease

         GOTO END_PROG
      END
	  
      /* POST TO PROJECT */

      IF @CoitemRefType = 'K' AND @CoitemRefNum <> '' AND NOT (@CoitemRefNum IS NULL)
      BEGIN
         EXEC @Severity = dbo.ProjSaleSp @PProjNum   = @CoitemRefNum
               , @PTaskNum   = @CoitemRefLineSuf
               , @PCoNum     = @CoitemCoNum
               , @PCoLine   = @CoitemCoLine
               , @PCoRelease = @CoitemCoRelease
               , @PInvDate  = @InvHdrInvDate
               , @PInvAmt   = @InvItemPrice
               , @PCurrCode    = @CustaddrCurrCode
               , @PExchRate    = @InvHdrExchRate
               , @Infobar   = @Infobar            OUTPUT
         IF @Severity <>0
            GOTO END_PROG
         ELSE
            SET @ProjAccum = @ProjAccum + @InvItemPrice

      END  /* POST TO PROJECT */
   IF @ArparmUsePrePrintedForms > 0 and @CoitemLineCounter = @LinesPerDoc
   goto exit_crs

   END /* END COITEM */

exit_crs:
   CLOSE      coitemCrs
   DEALLOCATE coitemCrs

   
   SET @InvHdrPrepaidAmt = CASE WHEN @InvHdrBillType = 'P' AND @InvCred = 'I'
                                THEN
         case when @InvHdrPrice >= 0 then
                 dbo.MinQty(@InvHdrPrice, @TPrepaidAmt)
         else
            dbo.MaxQty(@InvHdrPrice, @TPrepaidAmt)
         end
            ELSE
                 0
            END
   UPDATE inv_hdr
   SET prepaid_amt = @InvHdrPrepaidAmt
   WHERE inv_num = @InvHdrInvNum
      AND inv_seq = @InvHdrInvSeq

   /* COMPUTE TAX & TOTAL */

   --EXEC SLDevEnv_App.dbo.SQLTraceSp 'InvPostPSp: Calling TaxCalcSp', 'thoblo'
   EXEC @Severity = dbo.TaxCalcSp @PInvType      = 'P'
             , @PTaxCode1     = @InvHdrTaxCode1
             , @PTaxCode2     = @InvHdrTaxCode2
             , @PFreight      = @InvHdrFreight
             , @PFrtTaxCode1  = @InvHdrFrtTaxCode1
             , @PFrtTaxCode2  = @InvHdrFrtTaxCode2
             , @PMisc         = @InvHdrMiscCharges
             , @PMiscTaxCode1 = @InvHdrMscTaxCode1
             , @PMiscTaxCode2 = @InvHdrMscTaxCode2
             , @PInvDate      = @InvHdrInvDate
             , @PTermsCode    = @InvHdrTermsCode
             , @PUseExchRate  = @InvHdrUseExchRate
             , @PCurrCode     = @CustaddrCurrCode
             , @PPlaces       = @CurrencyPlaces
             , @PExchRate     = @InvHdrExchRate
             , @PSalesTax1    = @TSalesTax       OUTPUT
             , @PSalesTax2    = @TSalesTax2      OUTPUT
             , @Infobar       = @Infobar         OUTPUT
             , @pRefType       = 'IP'				-- SSS Vertex Add            
             , @pHdrPtr        = @NewRowPointer		-- SSS Vertex Add  

	IF @TSalesTax2 = 0 SET @TSalesTax2 = @CoZlaForSalesTax2

   IF @Severity <> 0
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed1'
         , '@%co/tax_calc'
         , '@co'
         , '@co.co_num'
         , @CoCoNum

      GOTO END_PROG
   END

   /* CREATE inv-stax RECORDS */
   
   SET @TTaxSeq = 0

    INSERT INTO @inv_stax
            ( inv_num
            , inv_seq
            , seq
            , tax_code
            , sales_tax
            , stax_acct
            , stax_acct_unit1
            , stax_acct_unit2
            , stax_acct_unit3
            , stax_acct_unit4
            , inv_date
            , cust_num
            , cust_seq
            , tax_basis
            , tax_system
            , tax_rate
            , tax_jur
            , tax_code_e
				,zla_for_sales_tax
				,zla_for_tax_basis
				,zla_ref_num
				,zla_ref_line_suf
				,zla_ref_release
				,zla_ref_type
				,zla_tax_group_id)
       SELECT
              @InvHdrInvNum
            , @InvHdrInvSeq
            , @TTaxSeq
            , tax_code
            , case tax_system
				when 1 then round(ISNULL(tax_amt, 0), @CurrencyPlaces)
				when 2 then round(isnull(@CoZlaForSalesTax2, 0), @CurrencyPlaces)
			  end					
            , ar_acct
            , ar_acct_unit1
            , ar_acct_unit2
            , ar_acct_unit3
            , ar_acct_unit4
            , @InvHdrTaxDate
            , @InvHdrCustNum
            , @InvHdrCustSeq
            , ISNULL(tax_basis, 0)
            , tax_system
            , ISNULL(tax_rate, 0)
            , tax_jur
            , tax_code_e
				, case tax_system
					when 1 then round(ISNULL(tax_amt, 0), @CurrencyPlaces)
					when 2 then round(isnull(@CoZlaForSalesTax2, 0), @CurrencyPlaces)
				  end					
				, ISNULL(tax_basis, 0)
				, @InvItemCoNum
				, @InvItemCoLine
				, @InvItemCoRelease
				, null
				, null
      FROM tmp_tax_calc
      WHERE ProcessId = @SessionId
        AND (record_zero = 1 OR tax_amt <> 0)

   UPDATE @inv_stax
       SET seq = @TTaxSeq ,
           @TTaxSeq = @TTaxSeq + 1

   INSERT INTO inv_stax
            ( inv_num
            , inv_seq
            , seq
            , tax_code
            , sales_tax
            , stax_acct
            , stax_acct_unit1
            , stax_acct_unit2
            , stax_acct_unit3
            , stax_acct_unit4
            , inv_date
            , cust_num
            , cust_seq
            , tax_basis
            , tax_system
            , tax_rate
            , tax_jur
            , tax_code_e 
				,zla_for_sales_tax
				,zla_for_tax_basis
				,zla_ref_num
				,zla_ref_line_suf
				,zla_ref_release
				,zla_ref_type
				,zla_tax_group_id)
       SELECT
              inv_num
            , inv_seq
            , seq
            , tax_code
            , sales_tax
            , stax_acct
            , stax_acct_unit1
            , stax_acct_unit2
            , stax_acct_unit3
            , stax_acct_unit4
            , inv_date
            , cust_num
            , cust_seq
            , tax_basis
            , tax_system
            , tax_rate
            , tax_jur
            , tax_code_e
				, sales_tax
				, tax_basis
				, @InvItemCoNum
				, @InvItemCoLine
				, @InvItemCoRelease
				, null
				, null
        FROM @inv_stax

     DELETE FROM @inv_stax

     SET @InvStaxInvNum   = @InvHdrInvNum
     SET @InvStaxInvSeq   = @InvHdrInvSeq
     SET @InvStaxInvDate  = @InvHdrTaxDate
     SET @InvStaxCustNum  = @InvHdrCustNum
     SET @InvStaxCustSeq  = @InvHdrCustSeq

     SELECT
        @InvStaxTaxCode       = tax_code
      , @InvStaxSalesTax      = ISNULL(tax_amt,0)
      , @InvStaxStaxAcct      = ar_acct
      , @InvStaxStaxAcctUnit1 = ar_acct_unit1
      , @InvStaxStaxAcctUnit2 = ar_acct_unit2
      , @InvStaxStaxAcctUnit3 = ar_acct_unit3
      , @InvStaxStaxAcctUnit4 = ar_acct_unit4
      , @InvStaxTaxBasis      = ISNULL(tax_basis,0)
      , @InvStaxTaxSystem     = tax_system
      , @InvStaxTaxRate       = ISNULL(tax_rate,0)
      , @InvStaxTaxJur        = tax_jur
      , @InvStaxTaxCodeE      = tax_code_e
     FROM tmp_tax_calc
     WHERE ProcessId = @SessionId
       AND (record_zero = 1 OR tax_amt <> 0)

      DELETE FROM tmp_tax_calc
      WHERE  ProcessId  = @SessionId

   /* COMPUTE COMMISSION (Note: any changes here see also co/invpost.p) */

   DECLARE co_sls_commCrs CURSOR LOCAL STATIC FOR
   SELECT
        co_sls_comm.slsman
      , co_sls_comm.rev_percent
      , co_sls_comm.comm_percent
      , co_sls_comm.co_line
   FROM co_sls_comm
   WHERE co_sls_comm.co_num = @InvHdrCoNum

   OPEN co_sls_commCrs

   WHILE @Severity = 0
   BEGIN
      FETCH co_sls_commCrs INTO
           @CoSlsCommSlsman
         , @CoSlsCommRevPercent
         , @CoSlsCommCommPercent
         , @CoSlsCommCoLine

      IF @@FETCH_STATUS = -1
    BREAK

      SET @CoSlsCommRevPercent = ISNULL(@CoSlsCommRevPercent, 0)

      SET @TCurSlsman   = @CoSlsCommSlsman
      SET @TLoopCounter = 0
      SET @TRevPercent  = @CoSlsCommRevPercent
      SET @TCommPercent = @CoSlsCommCommPercent
      SET @TCoLine      = @CoSlsCommCoLine

      WHILE @TCurSlsman <> ' '
      BEGIN
         SET @TLoopCounter = @TLoopCounter + 1
         IF @TLoopCounter > 20
         BEGIN
            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=Recursive1'
               , '@slsman'
               , '@slsman.slsman'
               , @InvHdrSlsman

            GOTO END_PROG
         END

         SET @SlsmanRowPointer = NULL
         SET @SlsmanSlsman     = NULL
         SET @SlsmanSlsmangr   = NULL
         SET @SlsmanRefNum     = NULL
         SET @SlsmanSalesYtd   = 0
         SET @SlsmanSalesPtd   = 0

         SELECT
              @SlsmanRowPointer = slsman.RowPointer
            , @SlsmanSlsman     = slsman.slsman
            , @SlsmanSlsmangr   = slsman.slsmangr
            , @SlsmanRefNum     = slsman.ref_num
            , @SlsmanSalesYtd   = slsman.sales_ytd
            , @SlsmanSalesPtd   = slsman.sales_ptd
         FROM slsman WITH (UPDLOCK)
         WHERE slsman.slsman = @TCurSlsman

         IF @SlsmanRowPointer IS NULL
         BEGIN
            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
               , '@slsman'
               , '@slsman.slsman'
               , @TCurSlsman

            GOTO END_PROG
         END

         SET @SlsmanSalesYtd   = ISNULL(@SlsmanSalesYtd, 0)
         SET @SlsmanSalesPtd   = ISNULL(@SlsmanSalesPtd, 0)

         EXEC @Severity = dbo.CommCalcSp
                                  @TMode         = 'P'
            , @TInvNum       = @TInvNum
            , @TCoNum        = @InvHdrCoNum
            , @TCurSlsman    = @TCurSlsman
            , @TCurrCode     = @CurrencyCurrCode
            , @TPlaces       = @CurrencyPlaces
            , @TExchRate     = @InvHdrExchRate
            , @TRevPercent   = @TRevPercent
            , @TCommPercent  = @TCommPercent
            , @TCoLine       = @TCoLine
            , @TInvItemRecid = NULL
            , @TCommBaseTot  = @TCommBaseTot OUTPUT
            , @TCommCalc     = @TCommCalc         OUTPUT
            , @TCommBase     = @TCommBase         OUTPUT
            , @Infobar       = @Infobar      OUTPUT

         SET @TCommPercent = NULL

         IF @Severity <> 0
         BEGIN
            SET @Infobar = NULL
            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed1'
               , '@commtran'
               , '@co'
               , '@co.co_num'
               , @CoCoNum

            GOTO END_PROG
         END

         SET @InvHdrTotCommDue = @InvHdrTotCommDue + @TCommCalc

         /* update inv-hdr with inv-hdr.slsman calculations only */
         IF @InvHdrSlsman = @TCurSlsman
         BEGIN
            SET @InvHdrCommCalc = @InvHdrCommCalc + @TCommCalc
            SET @InvHdrCommBase = @TCommBaseTot
            SET @InvHdrCommDue = @InvHdrCommDue +
               CASE WHEN @CoParmsDueOnPmt = 0 OR @InvCred = 'C'
                                             THEN
                    @TCommCalc
                    ELSE
                    0
                    END
         END

         IF @TCommCalc <> 0
         BEGIN
            SET @CommdueInvNum       = @InvHdrInvNum
            SET @CommdueCoNum        = @InvHdrCoNum
            SET @CommdueSlsman       = @TCurSlsman
            SET @CommdueCustNum      = @CoCustNum
            SET @CommdueCommDue      = CASE WHEN @CoParmsDueOnPmt = 0 OR @InvCred = 'C'
                                            THEN
                   @TCommCalc
                   ELSE
                   0
                   END
            SET @CommdueDueDate      = @InvHdrInvDate
            SET @CommdueCommCalc     = @TCommCalc
            SET @CommdueCommBase     = @TCommBaseTot
            SET @CommdueCommBaseSlsp = @TCommBase
            SET @CommdueSeq          = 1
            SET @CommduePaidFlag     = 0
            SET @CommdueSlsmangr     = CASE WHEN @SlsmanSlsman = @SlsmanSlsmangr AND @TLoopCounter > 1
                                            THEN
                   ' '
                   ELSE
                   @SlsmanSlsmangr
                   END

            SET @CommdueStat         = 'P'
            SET @CommdueRef          = CASE WHEN @InvCred = 'I'
                                            THEN
                   @TInvLabel
                   ELSE
                   @TCrMemo
                   END
            SET @CommdueEmpNum       = @SlsmanRefNum

            INSERT INTO commdue
               ( inv_num
               , co_num
               , slsman
               , cust_num
               , comm_due
               , due_date
               , comm_calc
               , comm_base
               , comm_base_slsp
               , seq
               , paid_flag
               , slsmangr
               , stat
               , ref
               , emp_num )
            VALUES
               ( @CommdueInvNum
               , @CommdueCoNum
               , @CommdueSlsman
               , @CommdueCustNum
               , @CommdueCommDue
               , @CommdueDueDate
               , @CommdueCommCalc
               , @CommdueCommBase
               , @CommdueCommBaseSlsp
               , @CommdueSeq
               , @CommduePaidFlag
               , @CommdueSlsmangr
               , @CommdueStat
               , @CommdueRef
               , @CommdueEmpNum )
         END

         /* DON'T INCREASE TWICE IF HE MANAGES HIMSELF AND HE MADE THE SALE */

         IF NOT (@TLoopCounter > 1 AND @CoSlsCommSlsman = @SlsmanSlsmangr)
         BEGIN
            SET @SlsmanSalesYtd = @SlsmanSalesYtd + @TCommBase
            SET @SlsmanSalesPtd = @SlsmanSalesPtd + @TCommBase
            UPDATE slsman
               SET sales_ytd = @SlsmanSalesYtd
                 , sales_ptd = @SlsmanSalesPtd
            WHERE RowPointer = @SlsmanRowPointer
         END

         /* PROCESS MANAGER OF SALESMAN NEXT ITERATION, IF SALESMAN IS
       HIS/HER OWN MANAGER, ONLY PROCESS IF THE MANAGER MADE THE
       SALE THEMSELF (.ie t-loop-counter = 1). */

         SET @TCurSlsman = CASE WHEN @SlsmanSlsman = @SlsmanSlsmangr AND @TLoopCounter > 1
                                THEN
                 ' '
            ELSE
                  @SlsmanSlsmangr
            END
      END /* WHILE @TCurSlsman <> ' ' */
   END

   UPDATE inv_hdr
      SET comm_calc    = @InvHdrCommCalc
        , comm_base    = @InvHdrCommBase
        , comm_due     = @InvHdrCommDue
        , tot_comm_due = @InvHdrTotCommDue
   WHERE inv_num = @InvHdrInvNum
      AND inv_seq = @InvHdrInvSeq

   CLOSE      co_sls_commCrs
   DEALLOCATE co_sls_commCrs /* for each co_sls_comm */

   /* POST TO PROJECT BILLING ACCOUNT */

   IF @ProjAccum <> 0 AND @ArparmsProjAcct <> '' AND NOT (@ArparmsProjAcct IS NULL)
   BEGIN
      SET @TDistSeq       = @TDistSeq + 5
      SET @ArinvdCustNum  = @ArinvCustNum
      SET @ArinvdInvNum   = @ArinvInvNum
      SET @ArinvdDistSeq  = @TDistSeq
      SET @ArinvdAmount   = CASE WHEN @InvCred = 'I'
                                 THEN
                  @ProjAccum
             ELSE
                 -(@ProjAccum)
             END
      SET @ArinvdAcct      = @ArparmsProjAcct
      SET @ArinvdAcctUnit1 = @ArparmsProjAcctUnit1
      SET @ArinvdAcctUnit2 = @ArparmsProjAcctUnit2
      SET @ArinvdAcctUnit3 = @ArparmsProjAcctUnit3
      SET @ArinvdAcctUnit4 = @ArparmsProjAcctUnit4

      INSERT INTO arinvd
         ( cust_num
         , inv_num
         , dist_seq
         , amount
         , acct
         , acct_unit1
         , acct_unit2
         , acct_unit3
         , acct_unit4
			, zla_base_dist_seq
			, zla_description
			, zla_for_amount
			, zla_for_tax_basis
			, zla_tax_group_id
			, zla_tax_rate )
      VALUES
         ( @ArinvdCustNum
         , @ArinvdInvNum
         , @ArinvdDistSeq
         , @ArinvdAmount
         , @ArinvdAcct
         , @ArinvdAcctUnit1
         , @ArinvdAcctUnit2
         , @ArinvdAcctUnit3
         , @ArinvdAcctUnit4
			, @ArinvdDistSeq
			, null
			, @ArinvdAmount
			, null
			, null
			, null )
   END
   
   ELSE
      SET @ProjAccum = 0

   /* POST TO A/R */
	DECLARE
		@ProgRowPointer	RowPointerType,
		@ProgCoNum		CoNumType,
		@ProgCoLine		CoLineType,
		@ProgItem		ItemType,
		@ProgAmt		AmountType,
		@ProgWhse		WhseType
	
	DECLARE CurProgBill CURSOR FOR
	SELECT
		   co_bln.RowPointer
		 , co_bln.co_num
		 , co_bln.co_line
		 , co_bln.item
		 , case @InvCred 
				when 'I' then
				(select 
					round(sum((bln1.blanket_qty_conv * (bln1.cont_price_conv - isnull(bln1.zpv_total_disc,0)))),2)
					from co_bln_mst bln1	
					where
						bln1.co_num		= co_bln.co_num and
						bln1.co_line	= co_bln.co_line)
				when 'C' then
				(select 
					round(sum((bln1.zpv_qty_returned * (bln1.cont_price_conv - isnull(bln1.zpv_total_disc,0)))),2)
					from co_bln_mst bln1	
					where
						bln1.co_num		= co_bln.co_num and
						bln1.co_line	= co_bln.co_line)
				else 0
			end
		 , co_bln.zpv_ship_whse
	  FROM co_bln WITH (UPDLOCK)
	  WHERE co_bln.co_num = @CoCoNum
		 AND co_bln.co_line BETWEEN ISNULL(@StartLine, co_bln.co_line) AND ISNULL(@EndLine, co_bln.co_line)
		 AND co_bln.stat = 'O'	
	OPEN CurProgBill
	FETCH NEXT FROM CurProgBill
	INTO
		@ProgRowPointer,
		@ProgCoNum,
		@ProgCoLine,
		@ProgItem,
		@ProgAmt,
		@ProgWhse
	WHILE @@FETCH_STATUS = 0
	BEGIN
		select @ProgAmt

		SET @DistacctRowPointer = dbo.FndDist(@ProgItem, @ProgWhse)
		IF @DistacctRowPointer IS NOT NULL	
		BEGIN
			SET @DistacctSalesAcct      = NULL
			SET @DistacctSaleDsAcct       = NULL
			SET @DistacctSalesAcctUnit1  = NULL
			SET @DistacctSalesAcctUnit2  = NULL
			SET @DistacctSalesAcctUnit3  = NULL
			SET @DistacctSalesAcctUnit4  = NULL
			SET @DistacctSaleDsAcctUnit1 = NULL
			SET @DistacctSaleDsAcctUnit2 = NULL
			SET @DistacctSaleDsAcctUnit3 = NULL
			SET @DistacctSaleDsAcctUnit4 = NULL

			SELECT
				 @DistacctSalesAcct       = distacct.sales_acct
			   , @DistacctSaleDsAcct      = distacct.sale_ds_acct
			   , @DistacctSalesAcctUnit1  = distacct.sales_acct_unit1
			   , @DistacctSalesAcctUnit2  = distacct.sales_acct_unit2
			   , @DistacctSalesAcctUnit3  = distacct.sales_acct_unit3
			   , @DistacctSalesAcctUnit4  = distacct.sales_acct_unit4
			   , @DistacctSaleDsAcctUnit1 = distacct.sale_ds_acct_unit1
			   , @DistacctSaleDsAcctUnit2 = distacct.sale_ds_acct_unit2
			   , @DistacctSaleDsAcctUnit3 = distacct.sale_ds_acct_unit3
			   , @DistacctSaleDsAcctUnit4 = distacct.sale_ds_acct_unit4
			FROM distacct with (readuncommitted)
			WHERE distacct.RowPointer = @DistacctRowPointer
		END
		SET @ProdcodeRowPointer = NULL
		SET @ProdcodeUnit       = NULL
		
		IF @NonInventoryItem <> 1
		BEGIN
			SELECT @ItemProductCode = item.product_code FROM item WHERE item.item = @ProgItem
			
			SELECT
				@ProdcodeRowPointer = prodcode.RowPointer
				, @ProdcodeUnit       = prodcode.unit
			FROM prodcode with (readuncommitted)
			WHERE prodcode.product_code = @ItemProductCode
		END   
		IF @NonInventoryItem = 1
		BEGIN		
			SET @TEndSales = @CoitemNonInvAcct
			SET @TEndSalesUnit1 = @CoitemNonInvAcctUnit1
			SET @TEndSalesUnit2 = @CoitemNonInvAcctUnit2
			SET @TEndSalesUnit3 = @CoitemNonInvAcctUnit3
			SET @TEndSalesUnit4 = @CoitemNonInvAcctUnit4
		    
			IF @TEndSales is NULL
			BEGIN
				SET @TEndSales = @EndTypeNonInvAcct
				SET @TEndSalesUnit1 = @EndTypeNonInvAcctUnit1
				SET @TEndSalesUnit2 = @EndTypeNonInvAcctUnit2
				SET @TEndSalesUnit3 = @EndTypeNonInvAcctUnit3
				SET @TEndSalesUnit4 = @EndTypeNonInvAcctUnit4
			END
			IF @TEndSales is NULL
			BEGIN
				SET @TEndSales = @ArparmsNonInvAcct
				SET @TEndSalesUnit1 = @ArparmsNonInvAcctUnit1
				SET @TEndSalesUnit2 = @ArparmsNonInvAcctUnit2
				SET @TEndSalesUnit3 = @ArparmsNonInvAcctUnit3
				SET @TEndSalesUnit4 = @ArparmsNonInvAcctUnit4
			END
		END
		ELSE
		
		BEGIN
			IF @EndtypeSalesAcct IS NOT NULL 
			BEGIN
				SET @TEndSales		= @EndtypeSalesAcct
				SET @TEndSalesUnit1 = isnull(@EndtypeSalesAcctUnit1,@DistacctSalesAcctUnit1)
				SET @TEndSalesUnit2 = isnull(@EndtypeSalesAcctUnit2,@DistacctSalesAcctUnit2)
				SET @TEndSalesUnit3 = isnull(@EndtypeSalesAcctUnit3,@DistacctSalesAcctUnit3)
				SET @TEndSalesUnit4 = isnull(@EndtypeSalesAcctUnit4,@DistacctSalesAcctUnit4)
			END
			ELSE
			BEGIN
				SET @TEndSales		= @DistacctSalesAcct
				SET @TEndSalesUnit1 = @DistacctSalesAcctUnit1
				SET @TEndSalesUnit2 = @DistacctSalesAcctUnit2
				SET @TEndSalesUnit3 = @DistacctSalesAcctUnit3
				SET @TEndSalesUnit4 = @DistacctSalesAcctUnit4
			END
		END
		
		SET @TDistSeq        = @TDistSeq + 5
		
		SET @ArinvdCustNum   = @ArinvCustNum
		SET @ArinvdInvNum    = @ArinvInvNum
		SET @ArinvdDistSeq   = @TDistSeq
		SET @ArinvdAmount    = @ProgAmt
		SET @ArinvdAcct      = @TEndSales
		SET @ArinvdAcctUnit1 = @TEndSalesUnit1
		SET @ArinvdAcctUnit2 = @TEndSalesUnit2
		SET @ArinvdAcctUnit3 = @TEndSalesUnit3
		SET @ArinvdAcctUnit4 = @TEndSalesUnit4
		
		INSERT INTO arinvd
			( cust_num
			, inv_num
			, dist_seq
			, amount
			, acct
			, acct_unit1
			, acct_unit2
			, acct_unit3
			, acct_unit4 
			, zla_base_dist_seq
			, zla_description
			, zla_for_amount
			, zla_for_tax_basis
			, zla_tax_group_id
			, zla_tax_rate )
		VALUES
			( @ArinvdCustNum
			, @ArinvdInvNum
			, @ArinvdDistSeq
			, @ArinvdAmount
			, @ArinvdAcct
			, @ArinvdAcctUnit1
			, @ArinvdAcctUnit2
			, @ArinvdAcctUnit3
			, @ArinvdAcctUnit4
			, @ArinvdDistSeq
			, null
			, @ArinvdAmount
			, null
			, null
			, null )
				
		FETCH NEXT FROM CurProgBill
		INTO
			@ProgRowPointer,
			@ProgCoNum,
			@ProgCoLine,
			@ProgItem,
			@ProgAmt,
			@ProgWhse
	END
	CLOSE CurProgBill
	DEALLOCATE CurProgBill
	
   IF NOT (@ArparmsFreightAcct IS NULL) AND @InvHdrFreight > 0
   BEGIN
      SET @TDistSeq        = @TDistSeq + 5
      SET @ArinvdCustNum   = @ArinvCustNum
      SET @ArinvdInvNum    = @ArinvInvNum
      SET @ArinvdDistSeq   = @TDistSeq
      SET @ArinvdAmount    = @InvHdrFreight
      SET @ArinvdAcct      = @ArparmsFreightAcct
      SET @ArinvdAcctUnit1 = @ArparmsFreightAcctUnit1
      SET @ArinvdAcctUnit2 = @ArparmsFreightAcctUnit2
      SET @ArinvdAcctUnit3 = @ArparmsFreightAcctUnit3
      SET @ArinvdAcctUnit4 = @ArparmsFreightAcctUnit4
      
      INSERT INTO arinvd
         ( cust_num
         , inv_num
         , dist_seq
         , amount
         , acct
         , acct_unit1
         , acct_unit2
         , acct_unit3
         , acct_unit4 
			, zla_base_dist_seq
			, zla_description
			, zla_for_amount
			, zla_for_tax_basis
			, zla_tax_group_id
			, zla_tax_rate )
      VALUES
         ( @ArinvdCustNum
         , @ArinvdInvNum
         , @ArinvdDistSeq
         , @ArinvdAmount
         , @ArinvdAcct
         , @ArinvdAcctUnit1
         , @ArinvdAcctUnit2
         , @ArinvdAcctUnit3
         , @ArinvdAcctUnit4
			, @ArinvdDistSeq
			, null
			, @ArinvdAmount
			, null
			, null
			, null )
   END

   /* POST TAX DISTRIBUTION */

   INSERT INTO @arinvd
      ( cust_num
      , inv_num
      , dist_seq
      , acct
      , acct_unit1
      , acct_unit2
      , acct_unit3
      , acct_unit4
      , amount
      , tax_system
      , tax_code
      , tax_code_e
      , tax_basis
			, zla_base_dist_seq
			, zla_description
			, zla_for_amount
			, zla_for_tax_basis
			, zla_tax_group_id
			, zla_tax_rate )
   SELECT
        @ArinvCustNum
      , @ArinvInvNum
      , @TDistSeq
      , inv_stax.stax_acct
      , inv_stax.stax_acct_unit1
      , inv_stax.stax_acct_unit2
      , inv_stax.stax_acct_unit3
      , inv_stax.stax_acct_unit4
      , CASE WHEN  @InvCred = 'I' THEN ISNULL(inv_stax.sales_tax,0) ELSE ISNULL(-(inv_stax.sales_tax),0) END
      , inv_stax.tax_system
      , inv_stax.tax_code
      , inv_stax.tax_code_e
      , CASE WHEN  @InvCred = 'I' THEN ISNULL(inv_stax.tax_basis,0) ELSE ISNULL(-(inv_stax.tax_basis),0) END
			, @TDistSeq
			, null
			, CASE WHEN  @InvCred = 'I' THEN ISNULL(inv_stax.sales_tax,0) ELSE ISNULL(-(inv_stax.sales_tax),0) END
			, CASE WHEN  @InvCred = 'I' THEN ISNULL(inv_stax.tax_basis,0) ELSE ISNULL(-(inv_stax.tax_basis),0) END
			, null
			, null
   FROM inv_stax
   WHERE inv_stax.inv_num = @InvHdrInvNum
     AND inv_stax.inv_seq = @InvHdrInvSeq

   UPDATE @arinvd
     SET dist_seq = @TDistSeq,
      @TDistSeq = @TDistSeq + 1

   INSERT INTO arinvd
     ( cust_num
      , inv_num
      , dist_seq
      , acct
      , acct_unit1
      , acct_unit2
      , acct_unit3
      , acct_unit4
      , amount
      , tax_system
      , tax_code
      , tax_code_e
      , tax_basis
			, zla_base_dist_seq
			, zla_description
			, zla_for_amount
			, zla_for_tax_basis
			, zla_tax_group_id
			, zla_tax_rate )
   SELECT
        cust_num
      , inv_num
      , dist_seq
      , acct
      , acct_unit1
      , acct_unit2
      , acct_unit3
      , acct_unit4
      , amount
      , tax_system
      , tax_code
      , tax_code_e
      , tax_basis
			, dist_seq
			, null
			, amount
			, tax_basis
			, null
			, null
   FROM @arinvd

   DELETE FROM @arinvd

   SET @ArinvdCustNum   = @ArinvCustNum
   SET @ArinvdInvNum    = @ArinvInvNum
   SET @ArinvdDistSeq   = @TDistSeq

   SELECT
        @ArinvdAcct      = inv_stax.stax_acct
      , @ArinvdAcctUnit1 = inv_stax.stax_acct_unit1
      , @ArinvdAcctUnit2 = inv_stax.stax_acct_unit2
      , @ArinvdAcctUnit3 = inv_stax.stax_acct_unit3
      , @ArinvdAcctUnit4 = inv_stax.stax_acct_unit4
      , @ArinvdAmount    = CASE WHEN  @InvCred = 'I' THEN ISNULL(inv_stax.sales_tax,0) ELSE ISNULL(-(inv_stax.sales_tax),0) END
      , @ArinvdTaxSystem = inv_stax.tax_system
      , @ArinvdTaxCode   = inv_stax.tax_code
      , @ArinvdTaxCodeE  = inv_stax.tax_code_e
      , @ArinvdTaxBasis  = CASE WHEN  @InvCred = 'I' THEN ISNULL(inv_stax.tax_basis,0) ELSE ISNULL(-(inv_stax.tax_basis),0) END
   FROM inv_stax
   WHERE inv_stax.inv_num = @InvHdrInvNum
     AND inv_stax.inv_seq = @InvHdrInvSeq

   /* POST TOTALS TO A/R -NOTE: SIGNS ALWAYS + IN ARINV */

   IF  @InvCred = 'C'
   BEGIN
      SET @ArinvAmount    = -(@InvHdrPrice)
      SET @ArinvSalesTax  = -(@TSalesTax)
      SET @ArinvSalesTax2 = @TSalesTax2
   END
   ELSE
   BEGIN
      SET @ArinvAmount    =   @InvHdrPrice
      SET @ArinvSalesTax  =   @TSalesTax
      SET @ArinvSalesTax2 =   @TSalesTax2
   END
   
   UPDATE arinv
   SET amount				= @ArinvAmount
     , sales_tax			= @ArinvSalesTax
     , sales_tax_2			= @ArinvSalesTax2
     , zla_for_amount		= @ArinvAmount
     , zla_for_sales_tax	= @ArinvSalesTax
     , zla_for_sales_tax_2	= @ArinvSalesTax2
     , freight				= @InvHdrFreight
     , zla_for_freight		= @InvHdrFreight
   WHERE cust_num = @ArinvCustNum
      AND inv_num  = @ArinvInvNum
      AND inv_seq  = @ArinvInvSeq
      

   IF @InvCred = 'I' AND @CustomerPayType = 'D' AND @CustomerDraftPrintFlag = 1 AND
      @pMooreForms = 'D'
   BEGIN
      SET @BankAddrRowPointer = NULL
      SET @BankAddrBankNumber = NULL
      SET @BankAddrAddr##1    = NULL
      SET @BankAddrAddr##2    = NULL
      SET @BankAddrBranchCode = NULL

      SELECT
           @BankAddrRowPointer = bank_addr.RowPointer
         , @BankAddrBankNumber = bank_addr.bank_number
         , @BankAddrAddr##1    = bank_addr.addr##1
         , @BankAddrAddr##2    = bank_addr.addr##2
         , @BankAddrBranchCode = bank_addr.branch_code
      FROM bank_addr with (readuncommitted)
      WHERE bank_addr.bank_code = @CustomerCustBank

      IF (@BankAddrRowPointer IS NULL)
      BEGIN
         SET @Infobar = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistForIs1'
            , '@bank_addr'
            , '@bank_addr.bank_code'
            , @CustomerCustBank
            , '@customer'
            , '@customer.cust_num'
            , @CustomerCustNum

         GOTO END_PROG
      END

      -- SET @CustdrftDraftNum          = @ArinvInvNum (Identity Col)
      SET @CustdrftCustNum           = @ArinvCustNum
      SET @CustdrftInvDate           = @ArinvInvDate
      SET @CustdrftPaymentDueDate    = @ArinvDueDate
      SET @CustdrftAmount            = @ArinvAmount + @ArinvSalesTax + @ArinvSalesTax2
      SET @CustdrftExchRate          = @ArinvExchRate
      SET @CustdrftStat              = 'T'
      SET @CustdrftInvNum            = @ArinvInvNum
      SET @CustdrftCoNum             = @ArinvCoNum
      SET @CustdrftBankCode          = @CustomerBankCode
      SET @CustdrftCustBank          = @CustomerCustBank
      SET @CustdrftBankNumber        = @BankAddrBankNumber
      SET @CustdrftBankAddr##1       = @BankAddrAddr##1
      SET @CustdrftBankAddr##2       = @BankAddrAddr##2
      SET @CustdrftBranchCode        = @BankAddrBranchCode
      SET @CustdrftPrintFlag         = 1
      SET @CustdrftEscalationCntr    = 0
      SET @CustdrftDunnDate          = NULL

      INSERT INTO custdrft
         ( cust_num
         , inv_date
         , payment_due_date
         , amount
         , exch_rate
         , stat
         , inv_num
         , co_num
         , bank_code
         , cust_bank
         , bank_number
         , bank_addr##1
         , bank_addr##2
         , branch_code
         , print_flag
         , escalation_cntr
         , dunn_date )
      VALUES
         ( @CustdrftCustNum
         , @CustdrftInvDate
         , @CustdrftPaymentDueDate
         , @CustdrftAmount
         , @CustdrftExchRate
         , @CustdrftStat
         , @CustdrftInvNum
         , @CustdrftCoNum
         , @CustdrftBankCode
         , @CustdrftCustBank
         , @CustdrftBankNumber
         , @CustdrftBankAddr##1
         , @CustdrftBankAddr##2
         , @CustdrftBranchCode
         , @CustdrftPrintFlag
         , @CustdrftEscalationCntr
         , @CustdrftDunnDate )
   END

   /*
    * decrement inv-hdr invoice price by appropriate pre-paid amount
    * after assigning value to arinv & arinvd to ensure Cust does
    * NOT receive Overstated Invoice.
    */

   SET @TOrderBal    = @TOrderBal + dbo.ArBalSp ( @InvCred
                       , @ArinvMiscCharges
                  , @ArinvFreight
                  , @ArinvSalesTax
                  , @ArinvAmount
                  , @ArinvSalesTax2)

   SET @TOrderBal    = @TOrderBal - dbo.CoBalSp ( @CoMiscCharges
                  , @CoFreight
                  , @CoSalesTax
                  , @CoSalesTax2)

   SET @InvHdrPrice  = @InvHdrPrice - @InvHdrPrepaidAmt
   SET @InvHdrPrice  = @InvHdrPrice + @TSalesTax + @TSalesTax2
   UPDATE inv_hdr
   SET price = @InvHdrPrice, zla_for_price = @InvHdrPrice
   WHERE inv_num = @InvHdrInvNum
      AND inv_seq = @InvHdrInvSeq

   SET @CoSalesTax   = @CoSalesTax   - dbo.minqty(@CoSalesTax,@TSalesTax)
   SET @CoSalesTax2  = @CoSalesTax2  - dbo.minqty(@CoSalesTax2,@TSalesTax2)
   SET @CoSalesTaxT  = @CoSalesTaxT  + @TSalesTax
   SET @CoSalesTaxT2 = @CoSalesTaxT2 + @TSalesTax2
   SET @CoInvoiced   = 1

   IF @ReleaseTmpTaxTables = 1
   BEGIN
      EXEC dbo.ReleaseTmpTaxTablesSp @SessionId
      SET @ReleaseTmpTaxTables = 0
   END
   
   IF @ZpvParmsCtrlFiscal = 1
   BEGIN
		EXEC	[dbo].[ZPV_GenerateCtrlFiscalSp]
			@InvNum		= @ArinvInvNum,
			@CustNum	= @ArinvCustNum,
			@Infobar	= @Infobar OUTPUT
   END		
   
   UPDATE co
   SET --sales_tax    = @CoSalesTax
     --, sales_tax_2  = @CoSalesTax2
     --, sales_tax_t  = @CoSalesTaxT
     --, sales_tax_t2 = @CoSalesTaxT2
      invoiced     = @CoInvoiced
     --, zla_for_sales_tax    = @CoSalesTax
     --, zla_for_sales_tax_2  = @CoSalesTax2
     --, zla_for_sales_tax_t  = @CoSalesTaxT
     --, zla_for_sales_tax_t2 = @CoSalesTaxT2
     , zpv_inv_num	= @ArinvInvNum
   WHERE RowPointer = @XCoRowPointer
   
   	
   SET @TOrderBal = @TOrderBal + dbo.CoBalSp ( @CoMiscCharges
                  , @CoFreight
                  , @CoSalesTax
                  , @CoSalesTax2)

   IF @CoLcrNum <> '' AND NOT (@CoLcrNum IS NULL)
   BEGIN
      SET @CustLcrRowPointer = NULL
      SET @CustLcrShipValue  = 0

      SELECT
           @CustLcrRowPointer = cust_lcr.RowPointer
         , @CustLcrShipValue  = cust_lcr.ship_value
      FROM cust_lcr WITH (UPDLOCK)
      WHERE cust_lcr.cust_num = @CoCustNum
         AND cust_lcr.lcr_num  = @CoLcrNum

      SET @CustLcrShipValue = ISNULL(@CustLcrShipValue , 0)

      IF @CustLcrRowPointer IS NOT NULL
      BEGIN
         SET @CustLcrShipValue = @CustLcrShipValue + (@TSalesTax + @TSalesTax2)
         UPDATE cust_lcr
         SET ship_value = @CustLcrShipValue
         WHERE RowPointer = @CustLcrRowPointer
      END
   END


   /* SET EC-CODE OF 'BILL-TO' CUSTOMER */

   IF @ParmsECReporting = 1
   BEGIN
      SET @CustomerRowPointer     = NULL
      SET @CustomerPayType        = NULL
      SET @CustomerDraftPrintFlag = 0
      SET @CustomerCustBank       = NULL
      SET @CustomerCustNum        = NULL
      SET @CustomerBankCode       = NULL
      SET @CustomerEdiCust        = 0

      SELECT
           @CustomerRowPointer     = customer.RowPointer
         , @CustomerPayType        = customer.pay_type
         , @CustomerDraftPrintFlag = customer.draft_print_flag
         , @CustomerCustBank       = customer.cust_bank
         , @CustomerCustNum        = customer.cust_num
         , @CustomerBankCode       = customer.bank_code
         , @CustomerEdiCust        = customer.edi_cust
      FROM customer
      WHERE customer.cust_num = @CoCustNum
         AND customer.cust_seq = 0

      SET @CustaddrRowPointer = NULL
      SET @CustaddrState      = NULL
      SET @CustaddrCurrCode   = NULL
      SET @CustaddrCountry    = NULL

      SELECT
           @CustaddrRowPointer = custaddr.RowPointer
         , @CustaddrState      = custaddr.state
         , @CustaddrCurrCode   = custaddr.curr_code
         , @CustaddrCountry    = custaddr.country
      FROM custaddr with (readuncommitted)
      WHERE custaddr.cust_num = @CustomerCustNum
         AND custaddr.cust_seq = 0

      IF @ParmsCountry <> @CustaddrCountry
      BEGIN
         /* Export! */

         SET @CountryRowPointer = NULL
         SET @CountryEcCode     = NULL

         SELECT
              @CountryRowPointer = country.RowPointer
            , @CountryEcCode     = country.ec_code
         FROM country
         WHERE country.country = @CustaddrCountry

         SET @InvHdrEcCode = CASE WHEN (@CountryRowPointer IS NOT NULL AND @XCountryRowPointer IS NULL)
                                    OR (@CountryRowPointer IS NOT NULL AND @XCountryRowPointer IS NOT NULL AND ISNULL(@CountryEcCode,'') <> ISNULL(@XCountryEcCode,'')) THEN
                                     @CountryEcCode
                                  ELSE
                                     NULL
                             END

         UPDATE inv_hdr
         SET ec_code = @InvHdrEcCode
         WHERE inv_num = @InvHdrInvNum
           AND inv_seq = @InvHdrInvSeq
      END
   END

   /* Begin EDI */

   SET @PrintFlag = 1
   IF (@CustomerRowPointer IS NOT NULL AND ISNULL(@CustomerEdiCust, 0) = 1)
   BEGIN
      EXEC @Severity = dbo.EdiOutObDriverSp
        @PTranType = 'INVC'
      , @PCustNum  = @CoCustNum
      , @PCustSeq  = @CoCustSeq
      , @PInvNum   = @InvHdrInvNum
      , @PCoNum    = NULL
      , @PBolNum   = NULL
      , @PFlag     = @PrintFlag     OUTPUT
      , @Infobar   = @Infobar       OUTPUT

      IF @Severity <> 0
         GOTO END_PROG
   END

   /* End EDI */
   	
	/* Calculo de Percepciones */
	DECLARE @RefDistSeq AS INT
	SELECT TOP(1) @RefDistSeq = isnull(dist_seq,20) FROM arinvd 
	WHERE 
		cust_num = @ArinvCustNum
		AND inv_num = @ArinvInvNum 
		AND inv_seq = @ArinvInvSeq	
		AND tax_system = 1
	ORDER BY dist_seq DESC		
	
	IF @RefDistSeq IS NOT NULL
	BEGIN
	   INSERT INTO zla_arinvd_tax(
			cust_num,
			inv_num,
			inv_seq,
			dist_seq,
			tax_group_id)
		SELECT
			@ArinvCustNum,
			@ArinvInvNum,
			@ArinvInvSeq,
			@RefDistSeq,
			tax.tax_group_id
		FROM zla_co_tax tax
		WHERE
			tax.co_num = @CoCoNum

		INSERT INTO
		#temp_ar_tax_in
		(
		[tax_type_id]
		,[tax_group_id]
		,[acct]
		,[amount]
		,[vat_amount]
		,[vat_acct]
		,[state]
		)
		SELECT
		TGrp.tax_type_id
		,TGrp.group_id
		,AriBase.acct
		,AriTax.zla_for_tax_basis
		,AriTax.zla_for_amount
		,AriTax.Acct
		,NULL
		FROM
		zla_arinvd_tax Tax
		INNER JOIN zla_tax_group TGrp ON TGrp.GROUP_ID = tax.tax_group_id

		INNER JOIN arinvd AriTax ON AriTax.cust_num = tax.cust_num
							AND AriTax.inv_num = tax.Inv_num
							AND AriTax.inv_seq = tax.inv_seq
							AND AriTax.dist_seq = tax.dist_seq

		INNER JOIN arinvd AriBase 
		ON AriBase.cust_num = AriTax.cust_num
			AND AriBase.inv_num = AriTax.Inv_num
			AND AriBase.inv_seq = AriTax.inv_seq
			AND AriBase.dist_seq = AriTax.zla_base_dist_seq 
		WHERE
		tax.cust_num = @ArinvCustNum
		AND tax.Inv_num = @ArinvInvNum
		AND tax.inv_seq = @ArinvInvSeq
		
		-- Call MUCI Tax Calculation
		EXECUTE [ZLA_MuciSp] 'AR', @ArinvInvDate, @ArinvCustNum, @CustaddrCurrCode, @ArinvZlaArTypeId,@ArinvExchRate, NULL

		DELETE  FROM
				arinvd
		WHERE
		cust_num = @ArinvCustNum
		AND inv_num = @ArinvInvNum
		AND inv_seq = @ArinvInvSeq
		AND tax_system = 2

		SET @ArinvSalesTax = 0
		SET @ArinvSalesTax2  = 0
		SET @ArinvZlaForSalesTax = 0
		SET @ArinvZlaForSalesTax2 = 0

		SELECT @ArinvdDistSeq = MAX(dist_seq)
		From arinvd
		WHERE
			cust_num = @ArinvCustNum
			AND inv_num = @ArinvInvNum
			AND inv_seq = @ArinvInvSeq

		IF EXISTS(SELECT 1 FROM #temp_ar_tax_out)
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
				FETCH ZlaTaxOutCur INTO @tax_type_id 
				,@tax_group_id 
				,@base_amount 
				,@base_amount_country
				,@tax_amount 
				,@tax_amount_country 
				,@tax_percent
				IF @@FETCH_STATUS <> 0
					BREAK
				SELECT
					@ArinvdAcct = ACCOUNT_ID
				, @ArinvdTaxSystem = tax_system
				, @ArinvdTaxCode  = tax_code
				FROM
					zla_tax_group
				WHERE
				group_id = @tax_group_id
				IF ( EXISTS(SELECT 1 from tax_system 
					Where tax_system = @ArinvdTaxSystem
					And record_zero = 1 ) And  @tax_amount = 0 )
					OR @tax_amount <> 0
				BEGIN 
					-- Set Defauult Sequence for Tax System 2 Distributio
					SET @ArinvdDistSeq = @ArinvdDistSeq + 5
					-- Accumulate Tax System 2 Taxes in @TSalesTax2
					SET @ArinvSalesTax2 = @ArinvSalesTax2 + @tax_amount
					INSERT INTO
						arinvd
						(
						[cust_num]
						,[inv_num]
						,[inv_seq]
						,[dist_seq]
						,[acct]
						,[amount]
						,[tax_code]
						,[tax_basis]
						,[tax_system]
						,[zla_for_tax_basis] 
						,[zla_for_amount] 
								, zla_tax_group_id
								, zla_tax_rate
							)
					VALUES
						(
						@ArinvCustNum
						,@ArinvInvNum
						,@ArinvInvSeq
						,@ArinvdDistSeq
						,@ArinvdAcct
						,@tax_amount_country
						,@ArinvdTaxCode
						,@base_amount_country
						,@ArinvdTaxSystem
						,@base_amount
						,@tax_amount
								,@tax_group_id
								, @tax_percent
						)
				END
			END
			CLOSE ZlaTaxOutCur
			DEALLOCATE ZlaTaxOutCur
		END

		Select @ArinvSalesTax = SUM(arinvd.amount),
				@arinvZlaForSalesTax = SUM(arinvd.zla_for_amount)
		FROM arinvd 
		WHERE 
		cust_num = @ArinvCustNum
		and arinvd.inv_num = @ArinvInvNum
		And inv_seq = @ArinvInvSeq
		And tax_system = 1
    
		Select @ArinvSalesTax2 = SUM(arinvd.amount),
				@arinvZlaForSalesTax2 = SUM(arinvd.zla_for_amount)
		FROM arinvd 
		WHERE 
		cust_num = @ArinvCustNum
		and arinvd.inv_num = @ArinvInvNum
		And inv_seq = @ArinvInvSeq
		And tax_system = 2

	    UPDATE arinv 
		SET sales_tax = ISNULL(@ArinvSalesTax,0)
		,sales_tax_2 = ISNULL(@ArinvSalesTax2,0)
		,zla_for_sales_tax = ISNULL(@ArinvZlaForSalesTax,0)
		,zla_for_sales_tax_2 = ISNULL(@ArinvZlaForSalesTax2,0)
		WHERE
		cust_num = @ArinvCustNum
		and inv_num = @ArinvInvNum
		And inv_seq = @ArinvInvSeq
	END		
	ELSE
	BEGIN
		 SET @Infobar = 'Error al distribuir los impuestos'
         GOTO END_PROG
	END
	
	UPDATE arinv SET post_from_co = 1 
	WHERE  cust_num = @ArinvCustNum
	  AND inv_num  = @ArinvInvNum
      AND inv_seq  = @ArinvInvSeq	
	
	select
		@CoPrice		= ari.amount
	,	@CoFreight		= ari.freight
	,	@CoSalesTax		= ari.sales_tax
	,	@CoSalesTax2	= ari.sales_tax_2
	,	@CoZlaForPrice	= ari.zla_for_amount
	,	@CoZlaForFreight = ari.zla_for_freight
	,	@CoZlaForSalesTax	= ari.zla_for_sales_tax
	,	@CoZlaForSalesTax2	= ari.zla_for_sales_tax_2
	from arinv ari
	where  cust_num = @ArinvCustNum
	  and inv_num  = @ArinvInvNum
      and inv_seq  = @ArinvInvSeq	
	
	update co
		set	price				= isnull(@CoPrice,0)
		,	freight				= isnull(@CoFreight,0)
		,	sales_tax			= isnull(@CoSalesTax,0)
		,	sales_tax_2			= isnull(@CoSalesTax2,0)
		,	zla_for_price		= isnull(@CoZlaForPrice,0)
		,	zla_for_freight		= isnull(@CoZlaForFreight,0)
		,	zla_for_sales_tax	= isnull(@CoZlaForSalesTax,0)	
		,	zla_for_sales_tax_2	= isnull(@CoZlaForSalesTax2,0)
	where co.co_num = @CoCoNum
			
	EXEC	@Severity = [dbo].[ZPV_GenerateCtrlFiscalSp]
		@InvNum = @ArinvInvNum,
		@CustNum = @ArinvCustNum,
		@Infobar = @Infobar OUTPUT

	/* Calculo de percepciones */

-- END_TRX_LOOP:
SET @CurrLinesDoc = @CurrLinesDoc + @LinesPerDoc
IF @ArparmUsePrePrintedForms = 0
   goto END_SP
END
END_SP:
END

END_PROG:

CLOSE      coCrs
DEALLOCATE coCrs

if @BeginTranCount = 0
   if @Severity > 0
      ROLLBACK TRANSACTION
   else
      COMMIT TRANSACTION

IF @ReleaseTmpTaxTables = 1
   EXEC dbo.ReleaseTmpTaxTablesSp @SessionId

--EXEC SLDevEnv_App.dbo.SQLTraceSp 'InvPostPSp: Return', 'thoblo'
RETURN @Severity


GO

