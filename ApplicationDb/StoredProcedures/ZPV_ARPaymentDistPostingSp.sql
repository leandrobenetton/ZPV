/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentDistPostingSp]    Script Date: 10/29/2014 12:23:53 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ARPaymentDistPostingSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_ARPaymentDistPostingSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentDistPostingSp]    Script Date: 10/29/2014 12:23:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* $Header: /ApplicationDB/Stored Procedures/ARPaymentDistPostingSp.sp 82    4/11/14 4:04a Ehe $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/ARPaymentDistPostingSp.sp $
 *
 * SL9.00 82 178183 Ehe Fri Apr 11 04:04:53 2014
 * Unable to post A/R payments
 * 178183
 * Add isnull function to  @ArtranCheckSeq.
 *
 * SL9.00 81 178183 Ehe Fri Apr 11 02:56:36 2014
 * Unable to post A/R payments
 * 178183
 * Add logic to offset.
 *
 * SL9.00 80 176882 Ehe Tue Mar 25 04:07:38 2014
 * Offset posting fails
 * 176882
 * Add the logic to set ArTranCheckSeq.
 *
 * SL9.00 79 116549 pgross Fri Mar 07 12:50:50 2014
 * Missing Transaction Detail in AR Journal for references beginning with ARPR if reapplication was a credit reapplication
 * assign Credit Memo information to the journal when reapplying a Credit Memo
 *
 * SL8.04 78 RS5888 Lzhan Tue Mar 26 02:30:42 2013
 * RS5888: corrected module name for FSPM_MS.
 *
 * SL8.04 77 RS5888 Lzhan Thu Mar 14 22:41:32 2013
 * RS5888: added IsAddOnAvailabe logic to control FSP.
 *
 * SL8.04 76 156629 calagappan Tue Jan 15 11:11:44 2013
 * RMA Order Number lost when reapplying Open Credit via A/R Payments form
 * When re-applying open credit memo retain its original CO number
 *
 * SL8.04 75 153401 pgross Wed Sep 19 15:44:39 2012
 * Invalid exchange gain calculation created if negative payment is fully matched against an invoice with a lower balance than the negative payment.
 * use the average exchange rate from GainLossArSp
 *
 * SL8.04 74 94565 Mzhang4 Mon Jul 23 04:02:19 2012
 * RemoteMethodCallSp Clean-up
 * 94565-All objects that utilize RemoteMethodCallSp should pass in NULL for the IDO.
 *
 * SL8.04 73 150453 pgross Thu Jun 21 10:45:55 2012
 * Duplicate transactions causing an incorrect sales total within Box 1 of the EU Vat Report.
 * inv_stax.tax_basis is now based upon allowance and discount
 *
 * SL8.04 72 150089 calagappan Thu Jun 14 17:26:08 2012
 * A/R Payment settlement (early pay) discount journal postings
 * credit tax discounts/allowances amount towards original A/R account
 *
 * SL8.03 71 148119 Ltaylor2 Wed May 02 15:41:39 2012
 * 5325 - Pack and Ship design coding
 * Added shipment_id parameter, insert into artran
 *
 * SL8.03 70 146577 pgross Tue Apr 17 14:59:05 2012
 * Error: [AR Dist] is in use by another user. User Name is (blank).
 * added validation to ensure that the user exists in the site
 *
 * SL8.03 69 137513 calagappan Wed Jul 20 14:05:52 2011
 * Negative payment not reducing commissions earned field on Commissions Due form
 * Allow negative payments to reduce commissions due amount
 *
 * SL8.03 68 138983 pgross Fri Jun 10 16:02:51 2011
 * Additional inv_stax record created when payment does not have any discount/allowance amount.
 * do not create an inv_stax record when discount/allowance is zero
 *
 * SL8.02 67 rs4415 Dahn Tue Mar 09 14:48:38 2010
 * RS4415. Removed tax_mode = 'I' conditions where it checks for displaying the area-based tax systems.
 *
 * SL8.02 66 rs4588 Dahn Thu Mar 04 10:13:41 2010
 * RS4588 Copyright header changes
 *
 * SL8.02 65 rs4588 Dahn Wed Mar 03 17:16:42 2010
 * RS4588 Copyright header changes
 *
 * SL8.02 64 124650 calagappan Wed Nov 11 11:10:36 2009
 * When reversing AR Wire Payment, using foreign currency, the Gain/Loss is not posted correctly.
 * Post gain/loss, if needed, when a wire payment with a negative amount is posted.
 *
 * SL8.01 63 115523 calagappan Fri Feb 13 18:23:56 2009
 * Exchange Gain/Loss does not reverse in Journal when input negative to reverse AR Payment.
 * Post gain/loss, if needed, when a check payment with a negative amount is posted.
 *
 * SL8.01 62 114297 calagappan Thu Jan 08 15:04:34 2009
 * When attempting to reprint Manual AR Credit Memo that have been matched against an Invoice, the VAT (tax) does not display correctly.
 * Revert fix for issue 97501 and 109282.
 *
 * SL8.01 61 110142 calagappan Wed Dec 31 13:25:33 2008
 * Missing Transaction Detail in AR Journal for references beginning with ARPR if reapplication was a credit reapplication.
 * Reverted fix for issue 109125.
 *
 * SL8.01 60 rs3953 Vlitmano Tue Aug 26 16:39:11 2008
 * RS3953 - Changed a Copyright header?
 *
 * SL8.01 59 rs3953 Vlitmano Mon Aug 18 15:04:38 2008
 * Changed a Copyright header information(RS3959)
 *
 * SL8.01 58 107950 pgross Tue Jul 22 19:50:21 2008
 * Sales Commission by Salesperson Report - The commdue earned is updated when early pay discount is taken. It calculates the commdue on the total invoice amount. This should work the same way when allowances are given against an invoice.
 * include allowance in the commission calculation
 *
 * SL8.01 57 109125 akottapp Fri May 30 02:42:35 2008
 * Missing Transaction Detail in AR Journal for references beginning with ARPR if reapplication was a credit reapplication
 * Issue 109125 :
 * Changed the default value of @TSeq variable to 0 instead of 1
 *
 * SL8.01 56 RS4088 dgopi Tue May 20 04:50:27 2008
 * Making the modifications as per RS4088
 *
 * SL8.01 55 RS4088 dgopi Tue May 20 04:43:10 2008
 * Making the modifications as per RS4088
 *
 * SL8.00 54 106268 ljose Thu Dec 13 23:27:49 2007
 * AR Payment & AR Wire Posting - encountered error 'Arithmetic overflow error for data type tinyint, value = 25
 * 106268 Modified the fetch condition for Cursor1 and Cursor2 inv_stax.seq <= @InvStaxSeq  to inv_stax.seq = @InvStaxSeq
 *
 * SL8.00 53 105219 hcl-kumarup Fri Sep 07 07:09:22 2007
 * AR payments part applying open credit memo updates the open credit with the wron
 * Checked-in for issue 105219
 * Modified SELECT query and set value of @ArtranAmount to get Open Credit amount
 *
 * SL8.00 52 rs2968 nkaleel Fri Feb 23 00:19:52 2007
 * changing copyright information
 *
 * SL8.00 51 RS3117 Kkrishna Thu Feb 22 01:07:57 2007
 * RS3117 Sub account removal
 *
 * SL8.00 50 97501 hcl-kumarup Thu Nov 09 03:57:49 2006
 * Reprint of Credit note created AR Invoice Credit debit memo and allocated to more than one invoice does not show VAT (tax) correctly.
 * Checked-in for issue 97501
 * Adjusted the VAT(tax) correctly when reprint of Credit note created AR Invoice Credit debit memo and allocated to more than one invoice.
 * Inserted the query to fetch the correct VAT(tax) and modified the "insert into artran" statement.
 *
 * SL8.00 49 95480 hcl-tiwasun Tue Aug 22 05:13:08 2006
 * During A/R Payment Posting, the Gain/Loss account is coming from Currency Code of Bank Code, not Customer
 * Issue# 95480
 *
 * SL8.00 48 95092 pcoate Thu Jul 20 08:18:59 2006
 * Earned amount on orignal invoice is not being updated when credit is applied
 * Issue 95092 - Prevent unneeded update of inv_hdr commission amount.
 *
 * SL8.00 47 RS2968 prahaladarao.hs Thu Jul 13 02:35:08 2006
 * RS 2968, Name change CopyRight Update.
 *
 * SL8.00 46 RS2968 prahaladarao.hs Tue Jul 11 03:51:03 2006
 * RS 2968
 * Name change CopyRight Update.
 *
 * SL8.00 45 95001 hcl-kumarup Tue Jul 04 05:23:02 2006
 * AR Payments incorrect calculation of currency gain/loss when using 'Allowance' to adjust for bank charges etc.
 * Checked-in for issue #95001
 * Allowances paid amount is taken into consideration for exchange rate
 *
 * SL8.00 44 91554 sivaprasad.b Thu Jun 01 05:15:23 2006
 * invoice number over 10 produces error even when length is set to 12
 * 91554
 * - Changed convert(integer, ...) for invoice numbers to convert(bigint, ... )
 *
 * SL8.00 43 93508 pgross Tue May 02 16:38:12 2006
 * posting of 2000 line payment causes severe blocking on CO table
 * 1)  fully qualify index when searching the tmp_mass_journal table
 * 2)  buffer customer updates
 * 3)  corrected commissions update of inv_hdr
 * 4)  call GainLossArSp only when multi-currency is involved
 * 5)  update artran.active only when it changes
 *
 * SL8.00 42 91264 varun.r Thu Mar 09 14:32:20 2006
 * invalid Posted Balance amount when posting a invoice for a subordinate customer
 * Issue: 91264
 * Code added to update the Posted Balance of the subordinate-customer while updating its corresponding corporate-customer.
 *
 * SL8.00 40 91818 NThurn Mon Jan 09 09:48:13 2006
 * Inserted standard External Touch Point call.  (RS3177)
 *
 * SL7.05 39 90282 Hcl-manobhe Wed Dec 28 05:57:25 2005
 * Code Cleanup
 * Issue 90282
 * Call to JourpostISp has been changed to call JourpostSp directly.
 *
 * SL7.05 38 91252 Grosphi Wed Dec 14 11:05:17 2005
 * Incorrect calculation at "Posted Balance" and "On order balance" value for Corporate Customer
 * when processing an Invoice, update the customer's posted_bal instead of order_bal
 *
 * SL7.05 37 90269 Hcl-tayamoh Mon Nov 28 15:37:32 2005
 * 200 line payment causing blocking of other processes
 * 90269
 *
 * SL7.05 35 87020 Hcl-khurdhe Fri May 20 08:25:31 2005
 * Incorrect NULL comparisons
 * ISSUE # 87020
 * Modified the   Stored Procedure "ARPaymentDistPostingSp", comparisons "= NULL" has been changed to "IS NULL".
 *
 * SL7.05 34 87038 Hcl-chantar Fri May 06 00:03:00 2005
 * AR reallocation of open payment causes tax record to be written to tax table (inv-stax)
 * Issue 87038:
 * Changed the IF condition
 * if @CrossSitePost <> 1
 * to
 * if @CrossSitePost <> 1 AND @ReApplication = 0
 *
 * SL7.04 34 87038 Hcl-chantar Fri May 06 00:01:16 2005
 * AR reallocation of open payment causes tax record to be written to tax table (inv-stax)
 * Issue 87038:
 * Changed the IF condition
 * if @CrossSitePost <> 1
 * to
 * if @CrossSitePost <> 1 AND @ReApplication = 0
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_ARPaymentDistPostingSp] (
  @CorpSite                SiteType
, @ReApplyType             ArtranTypeType
, @ReApplyBankCode         BankCodeType
, @ReApplyDisc             AmountType
, @WireExchangeRate        ExchRateType
, @TIssueDate              DateType
, @TInvSeq                 ArInvSeqType
, @CorpSiteCurrCode        CurrCodeType
, @CorpSiteName            NameType
, @ArpmtRowPointer         RowPointerType
, @ArpmtCustNum            CustNumType
, @ArpmtBankCode           BankCodeType
, @ArpmtType               ArpmtTypeType
, @ArpmtCreditMemoNum      InvNumType
, @ArpmtCheckNum           ArCheckNumType
, @ArpmtRecptDate          DateType
, @ArpmtDueDate            DateType
, @ArpmtRef                ReferenceType
, @ArpmtNoteExistsFlag     FlagNyType
, @ArpmtDescription        DescriptionType
, @ArpmtTransferCash       ListYesNoType
, @ArpmtdInvNum            InvNumType
, @ArpmtdSite              SiteType
, @ArpmtdApplyCustNum      CustNumType
, @ArpmtdExchRate          ExchRateType
, @ArpmtdDomDiscAmt        AmountType
, @ArpmtdForDiscAmt        AmountType
, @ArpmtdDomAllowAmt       AmountType
, @ArpmtdForAllowAmt       AmountType
, @ArpmtdDomAmtApplied     AmountType
, @ArpmtdForAmtApplied     AmountType
, @ArpmtdCoNum             CoNumType
, @ArpmtdDoNum             DoNumType
, @ArpmtdDiscAcct          AcctType
, @ArpmtdDiscAcctUnit1     UnitCode1Type
, @ArpmtdDiscAcctUnit2     UnitCode2Type
, @ArpmtdDiscAcctUnit3     UnitCode3Type
, @ArpmtdDiscAcctUnit4     UnitCode4Type
, @ArpmtdAllowAcct         AcctType
, @ArpmtdAllowAcctUnit1    UnitCode1Type
, @ArpmtdAllowAcctUnit2    UnitCode2Type
, @ArpmtdAllowAcctUnit3    UnitCode3Type
, @ArpmtdAllowAcctUnit4    UnitCode4Type
, @ArpmtdDepositAcct       AcctType
, @ArpmtdDepositAcctUnit1  UnitCode1Type
, @ArpmtdDepositAcctUnit2  UnitCode2Type
, @ArpmtdDepositAcctUnit3  UnitCode3Type
, @ArpmtdDepositAcctUnit4  UnitCode4Type
, @CorpCustaddrCurrCode    CurrCodeType
, @CorpCustaddrCorpCred    ListYesNoType
, @CorpCustaddrCorpCust    CustNumType
, @UpdatePrepaidAmt        FlagNyType
, @SubKey					GenericKeyType
, @ControlPrefix           JourControlPrefixType
, @ControlSite             SiteType
, @ControlYear             FiscalYearType
, @ControlPeriod           FinPeriodType
, @ControlNumber           LastTranType
, @ArpmtdForTaxAmt1        AmountType
, @ArpmtdForTaxAmt2        AmountType
, @ArpmtdDomTaxAmt1        AmountType
, @ArpmtdDomTaxAmt2        AmountType
, @ArpmtdFsSroDeposit      ListYesNoType  = 0    --SSS FSP
, @DepositDebitAcct        AcctType       = NULL --SSS FSP
, @DepositDebitUnit1       UnitCode1Type  = NULL --SSS FSP
, @DepositDebitUnit2       UnitCode2Type  = NULL --SSS FSP
, @DepositDebitUnit3       UnitCode3Type  = NULL --SSS FSP
, @DepositDebitUnit4       UnitCode4Type  = NULL --SSS FSP
, @ArpmtdShipmentId        ShipmentIdType = NULL
, @TCoNum                  CoNumType     = NULL
, @TRma                    ListYesNoType = 0
, @ArpmtdZlaForCurrCode		CurrCodeType 
, @ArpmtdZlaForExchRate		ExchRateType  
, @ArpmtdZlaForAllowAmt		AmountType  
, @ArpmtdZlaForAmtApplied	AmountType  
, @ArpmtdZlaForDiscAmt		AmountType  
, @ArpmtdZlaForNonArAmt		AmountType  
, @ArpmtZlaArPayId			ZlaArPayIdType
, @Infobar                 Infobar  OUTPUT

) AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_ZPV_ARPaymentDistPostingSp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_ARPaymentDistPostingSp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      DECLARE @EXTGEN_Severity int
      EXEC @EXTGEN_Severity = @EXTGEN_SpName
         @CorpSite
         , @ReApplyType
         , @ReApplyBankCode
         , @ReApplyDisc
         , @WireExchangeRate
         , @TIssueDate
         , @TInvSeq
         , @CorpSiteCurrCode
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
         , @ArpmtdInvNum
         , @ArpmtdSite
         , @ArpmtdApplyCustNum
         , @ArpmtdExchRate
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
         , @CorpCustaddrCurrCode
         , @CorpCustaddrCorpCred
         , @CorpCustaddrCorpCust
         , @UpdatePrepaidAmt
         , @SubKey
         , @ControlPrefix
         , @ControlSite
         , @ControlYear
         , @ControlPeriod
         , @ControlNumber
         , @ArpmtdForTaxAmt1
         , @ArpmtdForTaxAmt2
         , @ArpmtdDomTaxAmt1
         , @ArpmtdDomTaxAmt2
         , @ArpmtdFsSroDeposit
         , @DepositDebitAcct
         , @DepositDebitUnit1
         , @DepositDebitUnit2
         , @DepositDebitUnit3
         , @DepositDebitUnit4
         , @ArpmtdShipmentId
         , @TCoNum
         , @TRma
         , @ArpmtdZlaForCurrCode
		 , @ArpmtdZlaForExchRate
		 , @ArpmtdZlaForAllowAmt
		 , @ArpmtdZlaForAmtApplied
		 , @ArpmtdZlaForDiscAmt	
		 , @ArpmtdZlaForNonArAmt
		 , @ArpmtZlaArPayId		
		 , @Infobar OUTPUT
         
 
      -- ETP routine can RETURN 1 to signal that the remainder of this standard routine should now proceed:
      IF @EXTGEN_Severity <> 1
         RETURN @EXTGEN_Severity
   END
   -- End of Generic External Touch Point code.
 
DECLARE
  @Severity          INT

SET @Severity = 0

DECLARE
  @EndtypeRowPointer       RowPointerType
, @EndtypeArAcct           AcctType
, @EndtypeArAcctUnit1      UnitCode1Type
, @EndtypeArAcctUnit2      UnitCode2Type
, @EndtypeArAcctUnit3      UnitCode3Type
, @EndtypeArAcctUnit4      UnitCode4Type

, @ParmsSite               SiteType

, @SitenetRowPointer       RowPointerType
, @SitenetArAssetAcct      AcctType
, @SitenetArAssetAcctUnit1 UnitCode1Type
, @SitenetArAssetAcctUnit2 UnitCode2Type
, @SitenetArAssetAcctUnit3 UnitCode3Type
, @SitenetArAssetAcctUnit4 UnitCode4Type

, @ArparmsArAcct           AcctType
, @ArparmsArAcctUnit1      UnitCode1Type
, @ArparmsArAcctUnit2      UnitCode2Type
, @ArparmsArAcctUnit3      UnitCode3Type
, @ArparmsArAcctUnit4      UnitCode4Type

, @TaxAdjAcct           AcctType
, @TaxAdjAcctUnit1      UnitCode1Type
, @TaxAdjAcctUnit2      UnitCode2Type
, @TaxAdjAcctUnit3      UnitCode3Type
, @TaxAdjAcctUnit4      UnitCode4Type

, @CorpArparmsArAcct       AcctType
, @CorpArparmsArAcctUnit1  UnitCode1Type
, @CorpArparmsArAcctUnit2  UnitCode2Type
, @CorpArparmsArAcctUnit3  UnitCode3Type
, @CorpArparmsArAcctUnit4  UnitCode4Type

, @CurrparmsCurrCode       CurrCodeType
, @CurrparmsGainAcct       AcctType
, @CurrparmsGainAcctUnit1  UnitCode1Type
, @CurrparmsGainAcctUnit2  UnitCode2Type
, @CurrparmsGainAcctUnit3  UnitCode3Type
, @CurrparmsGainAcctUnit4  UnitCode4Type
, @CurrparmsLossAcct       AcctType
, @CurrparmsLossAcctUnit1  UnitCode1Type
, @CurrparmsLossAcctUnit2  UnitCode2Type
, @CurrparmsLossAcctUnit3  UnitCode3Type
, @CurrparmsLossAcctUnit4  UnitCode4Type

, @CoparmsDueOnPmt         ListYesNoType

, @CoRowPointer            RowPointerType

, @XCurrencyCurrCode       CurrCodeType
, @XCurrencyPlaces         DecimalPlacesType

, @CurrencyRowPointer      RowPointerType
, @CurrencyRateIsDivisor   ListYesNoType

, @CustomerRowPointer      RowPointerType
, @CustomerCustNum         CustNumType
, @CustomerEndUserType     EndUserTypeType
, @CustomerBankCode        BankCodeType

, @CustaddrRowPointer      RowPointerType
, @CustaddrCurrCode        CurrCodeType
, @CustaddrCorpCred        ListYesNoType
, @CustaddrCorpCust        CustNumType
, @CustaddrCustNum         CustNumType

, @CorpCustomerRowPointer  RowPointerType

, @BankHdrRowPointer       RowPointerType
, @BankHdrAcct             AcctType
, @BankHdrAcctUnit1        UnitCode1Type
, @BankHdrAcctUnit2        UnitCode2Type
, @BankHdrAcctUnit3        UnitCode3Type
, @BankHdrAcctUnit4        UnitCode4Type
, @BankHdrCurrCode         CurrCodeType
, @BankHdrBankCode         BankCodeType

, @InvHdrRowPointer        RowPointerType
, @InvHdrInvNum            InvNumType
, @InvHdrInvSeq            InvSeqType
, @InvHdrPrice             AmountType
, @InvHdrPrepaidAmt        AmountType
, @InvHdrFreight           AmountType
, @InvHdrMiscCharges       AmountType
, @InvHdrExchRate          ExchRateType

, @InvStaxRowPointer       RowPointerType
, @InvStaxSalesTax         AmountType

, @ChartRowPointer         RowPointerType
, @ChartAcct               AcctType

, @ArtranRowPointer        RowPointerType
, @ArtranCustNum           CustNumType
, @ArtranInvNum            InvNumType
, @ArtranInvSeq            ArInvSeqType
, @ArtranAcct              AcctType
, @ArtranAcctUnit1         UnitCode1Type
, @ArtranAcctUnit2         UnitCode2Type
, @ArtranAcctUnit3         UnitCode3Type
, @ArtranAcctUnit4         UnitCode4Type
, @ArtranBankCode          BankCodeType
, @ArtranType              ArtranTypeType
, @ArtranAmount            AmountType
, @ArtranExchRate          ExchRateType
, @ArtranCheckSeq          ArCheckNumType
, @ArtranInvDate           DateType
, @ArtranDueDate           DateType
, @ArtranDescription       DescriptionType
, @ArtranCorpCust          CustNumType
, @ArtranPayType           CustPayTypeType
, @ArtranRef               ReferenceType
, @ArtranActive            ListYesNoType
, @ArtranCoNum             CoNumType
, @ArtranDoNum             DoNumType
, @ArtranDiscAmt           AmountType
, @ArtranIssueDate         DateType
, @ArtranShipmentId        ShipmentIdType
, @ArtranRma               ListYesNoType

, @ArpmtOffset ListYesNoType

-- ZLA
, @ArtranZlaForCurrCode	CurrCodeType
, @ArtranZlaForExchRate	ExchRateType
, @ArtranZlaForNonArAmt	AmountType
, @ArtranZlaForAmount	AmountType
-- ZLA

, @XArtranRowPointer       RowPointerType
, @XArtranCheckSeq         ArCheckNumType
, @XArtranInvSeq           InvSeqType

, @CustdrftRowPointer      RowPointerType

, @CurracctRowPointer      RowPointerType
, @CurracctGainAcct        AcctType
, @CurracctGainAcctUnit1   UnitCode1Type
, @CurracctGainAcctUnit2   UnitCode2Type
, @CurracctGainAcctUnit3   UnitCode3Type
, @CurracctGainAcctUnit4   UnitCode4Type
, @CurracctLossAcct        AcctType
, @CurracctLossAcctUnit1   UnitCode1Type
, @CurracctLossAcctUnit2   UnitCode2Type
, @CurracctLossAcctUnit3   UnitCode3Type
, @CurracctLossAcctUnit4   UnitCode4Type

, @JournalRowPointer       RowPointerType

, @LocalSiteName           NameType
, @CrossSitePost           ListYesNoType
, @ReApplication           ListYesNoType
, @TId                     JournalIdType
, @TCustNum                CustNumType
, @TEndArAcct              AcctType
, @TEndArAcctUnit1         UnitCode1Type
, @TEndArAcctUnit2         UnitCode2Type
, @TEndArAcctUnit3         UnitCode3Type
, @TEndArAcctUnit4         UnitCode4Type
, @TDomPlaces              DecimalPlacesType
, @TTaxAmt                 AmountType
, @TInvSum                 AmountType
, @TRate                   ExchRateType
, @TPerCent                AmountType
, @TCommDue                AmountType
, @TypeDesc                Infobar
, @SiteAmountPosted        AmountType
, @ForSiteAmountPosted     AmountType
, @TAcct                   AcctType
, @TUnit1                  UnitCode1Type
, @TUnit2                  UnitCode2Type
, @TUnit3                  UnitCode3Type
, @TUnit4                  UnitCode4Type
, @TGlAcct                 AcctType
, @TGlUnit1                UnitCode1Type
, @TGlUnit2                UnitCode2Type
, @TGlUnit3                UnitCode3Type
, @TGlUnit4                UnitCode4Type
, @WireExchRate            ExchRateType
, @DomesticAmtApplied      AmountType
, @DomesticDiscAmt         AmountType
, @DomesticAllowAmt        AmountType
, @ForeignAmtApplied       AmountType
, @ForeignDiscAmt          AmountType
, @ForeignAllowAmt         AmountType
, @OAmt1                   AmountType
, @OAmt2                   AmountType
, @TAmt                    AmountType
, @TGain                   AmountType
, @TTransDom               ListYesNoType
, @TForBal                 AmountType
, @TDomBal                 AmountType
, @TAvgExchRate            ExchRateType
, @ApplyAmount             AmountType
, @Adjust                  AmountType
, @TTxt2                   InfobarType
, @Infobar2                InfobarType
, @TUserId                 TokenType
, @DomPostAmount           AmountType
, @ForPostAmount           AmountType
, @Ref                     ReferenceType
, @EndTrans                JournalSeqType
, @TSeq                    ArInvSeqType
, @TExist                  FlagNyType
, @RefType                 ReferenceType
, @TGainLoss               AmountType

, @TISInvNum            InvNumType
, @TISStaxSeq           StaxSeqType
, @TISTaxCode           TaxCodeType
, @TISStaxAcct          AcctType
, @TISStaxAcctUnit1     UnitCode1Type
, @TISStaxAcctUnit2     UnitCode2Type
, @TISStaxAcctUnit3     UnitCode3Type
, @TISStaxAcctUnit4     UnitCode4Type
, @TISSalesTax          AmountType
, @TISTaxBasis          AmountType
, @TISTaxRate           TaxRateType
, @TISTaxJur            TaxJurType
, @TISTaxCodeE          TaxCodeType
, @TISCustSeq           CustSeqType

, @TForTaxAdj           AmountType

, @TArpmtdForAmtTax1    AmountType
, @TArpmtdForAmtTax2    AmountType
, @TArpmtdDomAmtTax1    AmountType
, @TArpmtdDomAmtTax2    AmountType
, @ArpmtdInvNumTrim InvNumType

, @InvStaxSeq           StaxSeqType
, @TaxSystemRowPointer  RowPointerType
, @TaxSystemNarTaxCode  TaxCodeType
, @TaxSystemRecordZero ListYesNoType
, @TaxCodeArAcct        AcctType
, @TaxCodeArAcctUnit1   UnitCode1Type
, @TaxCodeArAcctUnit2   UnitCode2Type
, @TaxCodeArAcctUnit3   UnitCode3Type
, @TaxCodeArAcctUnit4   UnitCode4Type
, @TaxCodeTaxRate       TaxRateType
, @TaxCodeTaxJur        TaxJurType
, @BufferJournal        RowPointerType
, @JournalDeferredVar   Int
, @NetPostedBal AmtTotType
, @NetDiscYtd AmtTotType

SET @Severity = 0
SET @Infobar = NULL
SET @TId = 'AR Dist'
SET @TypeDesc = '@:ArpmtType:' + @ArpmtType
SET @SiteAmountPosted = 0
SET @ForSiteAmountPosted = 0
SET @ArpmtdInvNumTrim = ltrim(rtrim(@ArpmtdInvNum))

exec dbo.GetVariableSp
  @VariableName  	= 'JournalDeferred'
, @DefaultValue  	= null
, @DeleteVariable = 0
, @VariableValue 	= @BufferJournal OUTPUT
, @Infobar        = @Infobar OUTPUT

IF @BufferJournal is not null
   SET @JournalDeferredVar=1
ELSE
   SET @JournalDeferredVar=0

SELECT
   @TUserId = UserId
FROM UserNames WITH (READUNCOMMITTED)
WHERE Username = dbo.UserNameSp()

SELECT
   @ParmsSite = site
FROM parms WITH (READUNCOMMITTED)

if @TUserId is null
begin
   set @TTxt2 = dbo.UserNameSp()
   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=SiteNoExist1'
   , '@user_local'
   , '@UserNames.UserName'
   , @TTxt2
   , @ParmsSite

   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=SiteCmdFailed'
   , '@!Connect'
   , @ParmsSite

   goto EOF
end

SELECT
  @ArparmsArAcct      = ar_acct
, @ArparmsArAcctUnit1 = ar_acct_unit1
, @ArparmsArAcctUnit2 = ar_acct_unit2
, @ArparmsArAcctUnit3 = ar_acct_unit3
, @ArparmsArAcctUnit4 = ar_acct_unit4
FROM arparms WITH (READUNCOMMITTED)

SELECT
  @CorpArparmsArAcct      = ar_acct
, @CorpArparmsArAcctUnit1 = ar_acct_unit1
, @CorpArparmsArAcctUnit2 = ar_acct_unit2
, @CorpArparmsArAcctUnit3 = ar_acct_unit3
, @CorpArparmsArAcctUnit4 = ar_acct_unit4
FROM arparms_all WITH (READUNCOMMITTED)
WHERE site_ref = @CorpSite

SELECT
  @CurrparmsCurrCode      = curr_code
, @CurrparmsGainAcct      = gain_acct
, @CurrparmsGainAcctUnit1 = gain_acct_unit1
, @CurrparmsGainAcctUnit2 = gain_acct_unit2
, @CurrparmsGainAcctUnit3 = gain_acct_unit3
, @CurrparmsGainAcctUnit4 = gain_acct_unit4
, @CurrparmsLossAcct      = loss_acct
, @CurrparmsLossAcctUnit1 = loss_acct_unit1
, @CurrparmsLossAcctUnit2 = loss_acct_unit2
, @CurrparmsLossAcctUnit3 = loss_acct_unit3
, @CurrparmsLossAcctUnit4 = loss_acct_unit4
FROM currparms WITH (READUNCOMMITTED)

SELECT
  @CoparmsDueOnPmt = due_on_pmt
FROM coparms WITH (READUNCOMMITTED)

SELECT
   @LocalSiteName = site_name
FROM site WITH (READUNCOMMITTED)
WHERE site = @ParmsSite

SELECT
  @XCurrencyCurrCode = curr_code
, @XCurrencyPlaces = places
FROM currency WITH (READUNCOMMITTED)
WHERE curr_code = @CurrparmsCurrCode

SELECT  @ArpmtOffset = arpmt.offset
FROM arpmt
WHERE RowPointer = @ArpmtRowPointer

SET @TDomPlaces = @XCurrencyPlaces
SET @CrossSitePost = CASE WHEN @ParmsSite = @CorpSite then 0 ELSE 1 END
SET @ReApplication = CASE WHEN @ReApplyType IS NULL THEN 0 ELSE 1 END

SELECT
  @TEndArAcct      = @ArparmsArAcct
, @TEndArAcctUnit1 = @ArparmsArAcctUnit1
, @TEndArAcctUnit2 = @ArparmsArAcctUnit2
, @TEndArAcctUnit3 = @ArparmsArAcctUnit3
, @TEndArAcctUnit4 = @ArparmsArAcctUnit4

if @CrossSitePost = 1
BEGIN -- CrossSite

   -- LOCK JOURNAL
   EXEC @Severity = dbo.JourLockSp
        @Id          = @TId
      , @LockUserid  = @TUserId
      , @LockJournal = 1         -- Lock the Journal
      , @Infobar     = @Infobar  OUTPUT

   IF @Severity <> 0
      GOTO EOF

   SET @SitenetRowPointer = NULL

   SELECT
     @SitenetRowPointer = sitenet.RowPointer
   , @SitenetArAssetAcct     = sitenet.ar_asset_acct
   , @SitenetArAssetAcctUnit1 = sitenet.ar_asset_acct_unit1
   , @SitenetArAssetAcctUnit2 = sitenet.ar_asset_acct_unit2
   , @SitenetArAssetAcctUnit3 = sitenet.ar_asset_acct_unit3
   , @SitenetArAssetAcctUnit4 = sitenet.ar_asset_acct_unit4
   FROM sitenet WITH (READUNCOMMITTED)
   where sitenet.from_site = @CorpSite and
         sitenet.to_site = @ParmsSite

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
      , @CorpSite
      , '@sitenet.to_site'
      , @ParmsSite

      SET @Infobar = @Infobar + '  ' + @Infobar2

      GOTO EOF
   END
END -- CrossSite
else
   IF OBJECT_ID('tempdb..#customer') IS NULL
      create table #customer (
        cust_num nvarchar(20) primary key
      , disc_ytd decimal(25,10) default 0
      , posted_bal decimal(25,10) default 0
      , order_bal decimal(25,10) default 0
      )

SET @CorpCustomerRowPointer  = NULL

SELECT
  @CorpCustomerRowPointer = RowPointer
FROM customer_all WITH (READUNCOMMITTED)
WHERE site_ref = @CorpSite and
      cust_num = @ArpmtCustNum and
      cust_seq = 0

if @CorpCustomerRowPointer IS NULL
BEGIN
   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
      , '@customer'
      , '@customer.cust_num'
      , @ArpmtCustNum

   GOTO EOF
END

-- Find local customer
SET @CustomerRowPointer  = NULL
SET @CustomerCustNum     = NULL
SET @CustomerEndUserType = NULL
SET @TCustNum = (CASE WHEN @ArpmtdApplyCustNum = '' or @ArpmtdApplyCustNum IS NULL THEN
                     @ArpmtCustNum ELSE @ArpmtdApplyCustNum END)

SELECT
  @CustomerRowPointer  = customer.RowPointer
, @CustomerCustNum     = customer.cust_num
, @CustomerEndUserType = customer.end_user_type
, @CustomerBankCode    = customer.bank_code
FROM customer WITH (READUNCOMMITTED)
WHERE customer.cust_num = @TCustNum
   and customer.cust_seq = 0

if @CustomerRowPointer IS NULL
BEGIN
   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
      , '@customer'
      , '@customer.cust_num'
      , @TCustNum

   GOTO EOF
END

-- Find local custaddr
SET @CustaddrRowPointer = NULL
SET @CustaddrCurrCode   = NULL

SELECT
  @CustaddrRowPointer = custaddr.RowPointer
, @CustaddrCurrCode   = custaddr.curr_code
, @CustaddrCorpCred   = custaddr.corp_cred
, @CustaddrCorpCust   = custaddr.corp_cust
, @CustaddrCustNum    = custaddr.cust_num
FROM custaddr WITH (READUNCOMMITTED)
WHERE custaddr.cust_num = @CustomerCustNum
   and custaddr.cust_seq = 0

if @CustaddrRowPointer IS NULL
BEGIN
   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
      , '@custaddr'
      , '@custaddr.cust_num'
      , @CustomerCustNum

   GOTO EOF
END

SET @CurrencyRowPointer = NULL
SELECT
  @CurrencyRateIsDivisor = currency.rate_is_divisor
, @CurrencyRowPointer = currency.RowPointer
FROM currency WITH (READUNCOMMITTED)
WHERE curr_code = @CustaddrCurrCode

IF @CurrencyRowPointer IS NULL
BEGIN
   EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
      , '@currency'
      , '@currency.curr_code'
      , @CustaddrCurrCode

   GOTO EOF
END

if @CustomerEndUserType IS NOT NULL and @CustomerEndUserType <> ''
BEGIN
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
END

-- Verify cross-site currency constraints are not violated.
if @ArpmtdSite <> '' and @ArpmtdSite IS NOT NULL and
   @ArpmtdSite <> @CorpSite
BEGIN

   if @CorpSiteCurrCode <> @CurrparmsCurrCode
   BEGIN
      SET @Infobar = NULL
      SET @Infobar2 = NULL
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=IsCompare1'
      , '@currparms.curr_code'
      , @CorpSiteCurrCode
      , '@currparms'
      , '@parms.site'
      , @CorpSite

      EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'E=IsCompare1'
      , '@currparms.curr_code'
      , @CurrparmsCurrCode
      , '@currparms'
      , '@parms.site'
      , @ParmsSite

      SET @Infobar = @Infobar + '  ' + @Infobar2

      GOTO EOF
   END

   if @CorpCustaddrCurrCode <> @CustaddrCurrCode
   BEGIN
      SET @Infobar = NULL
      SET @Infobar2 = NULL
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=IsCompare1'
      , '@custaddr.curr_code'
      , @CorpCustaddrCurrCode
      , '@customer'
      , '@customer.cust_num'
      , @ArpmtCustNum

      EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'E=IsCompare1'
      , '@custaddr.curr_code'
      , @CustaddrCurrCode
      , '@customer'
      , '@customer.cust_num'
      , @CustomerCustNum

      SET @Infobar = @Infobar + '  ' + @Infobar2

      GOTO EOF
   END
END

SELECT
  @DomesticDiscAmt    = @ArpmtdDomDiscAmt
, @DomesticAllowAmt   = @ArpmtdDomAllowAmt
, @DomesticAmtApplied = @ArpmtdDomAmtApplied
, @ForeignAmtApplied  = @ArpmtdForAmtApplied
, @ForeignDiscAmt     = @ArpmtdForDiscAmt
, @ForeignAllowAmt    = @ArpmtdForAllowAmt
, @WireExchRate       = @ArpmtdExchRate

SET @InvHdrRowPointer  = NULL
SET @InvHdrPrice       = 0
SET @InvHdrPrepaidAmt  = 0
SET @InvHdrFreight     = 0
SET @InvHdrMiscCharges = 0
SET @InvHdrExchRate    = 0

SELECT
  @InvHdrRowPointer  = inv_hdr.RowPointer
, @InvHdrInvNum      = inv_hdr.inv_num
, @InvHdrInvSeq      = inv_hdr.inv_seq
, @InvHdrPrice       = inv_hdr.price
, @InvHdrPrepaidAmt  = inv_hdr.prepaid_amt
, @InvHdrFreight     = inv_hdr.freight
, @InvHdrMiscCharges = inv_hdr.misc_charges
, @InvHdrExchRate    = inv_hdr.exch_rate
FROM inv_hdr with (UPDLOCK)
 where
   inv_hdr.inv_num = @ArpmtdInvNum and
   inv_hdr.inv_seq = 0

-- COMPUTE COMMISSION BASED ON PAYMENT
if (@ArpmtdForAmtApplied <> 0 or @ArpmtdForDiscAmt > 0 or @ArpmtdForAllowAmt > 0) and
   @CoparmsDueOnPmt = 1 and
   @InvHdrRowPointer IS NOT NULL
BEGIN -- Compute Commission

   SELECT @TTaxAmt = sum(inv_stax.sales_tax)
   FROM inv_stax
   WHERE inv_num = @InvHdrInvNum and
         inv_seq = @InvHdrInvSeq

   SET @TTaxAmt = isnull(@TTaxAmt, 0)

   -- CONVERT TO DOMESTIC CURRENCY

   SET @TInvSum = @InvHdrPrice + @InvHdrPrepaidAmt - @InvHdrFreight -
                  @InvHdrMiscCharges - @TTaxAmt
   SET @TRate = @InvHdrExchRate

   EXEC @Severity = dbo.CurrCnvtSp
        @CurrCode =      @CustaddrCurrCode
      , @FromDomestic =  0
      , @UseBuyRate =    0
      , @RoundResult =   1
      , @Date =          NULL
      , @TRate =         @TRate   OUTPUT
      , @Infobar =       @Infobar OUTPUT
      , @Amount1 =       @TInvSum
      , @Result1 =       @TInvSum OUTPUT
      , @Site = @ParmsSite
      , @DomCurrCode = @CurrparmsCurrCode

   if @Severity <> 0
      GOTO EOF

   if @TInvSum = 0
      SET @TInvSum = 1

   SET @TPerCent =
       dbo.MinAmt(1.0, ((@DomesticAmtApplied + @DomesticDiscAmt + @DomesticAllowAmt) / @TInvSum))

   UPDATE commdue
     SET comm_due = CASE WHEN comm_calc >= 0
                            THEN dbo.MinAmt( comm_calc, dbo.MaxAmt(comm_due +
                                             ROUND((comm_calc * @TPerCent), @TDomPlaces),
                                             0.0) )
                         ELSE dbo.MaxAmt( comm_calc, (comm_due +
                                          ROUND((comm_calc * @TPerCent), @TDomPlaces)) )
                    END
     , due_date = @ArpmtRecptDate
   WHERE commdue.inv_num = @ArpmtdInvNum

END -- Compute Commission

if @ArpmtdInvNumTrim = '-2'
BEGIN -- Non A/R Cash
   if @ReApplication = 1
   BEGIN
      SET @Infobar = NULL
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare=1'
      , '@arpmtd.inv_num'
      , @ArpmtdInvNum
      , '@arpmtd'
      , '@arpmtd.type'
      , @TypeDesc

      GOTO EOF
   END

   SET @ApplyAmount = @ArpmtdDomDiscAmt + @ArpmtdDomAllowAmt

   if @ArpmtdDomDiscAmt <> 0
   BEGIN --CREDIT Account 1

      SET @ChartRowPointer = NULL

      SELECT
       @ChartRowPointer = chart.RowPointer
      FROM chart WITH (READUNCOMMITTED)
      where chart.acct = @ArpmtdDiscAcct

      if @ChartRowPointer IS NULL or @ArpmtdDiscAcct IS NULL
      BEGIN
         SET @Infobar = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistFor1'
         , '@chart'
         , '@arpmtd'
         , '@arpmtd.disc_acct'
         ,  @ArpmtdDiscAcct

         GOTO EOF
      END

      EXEC @Severity = dbo.ChkAcctSp
        @ArpmtdDiscAcct
      , @ArpmtRecptDate
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      EXEC @Severity = dbo.ChkUnitSp
        @ArpmtdDiscAcct
      , @ArpmtdDiscAcctUnit1
      , @ArpmtdDiscAcctUnit2
      , @ArpmtdDiscAcctUnit3
      , @ArpmtdDiscAcctUnit4
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      IF @ArpmtType = 'D'
         SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
      ELSE
         SET @Ref = @ArpmtRef
      SET @RefType = SUBSTRING(@ArpmtRef, 3, 1)

      SET @DomPostAmount = @DomesticDiscAmt * -1
      SET @ForPostAmount = @ForeignDiscAmt * -1

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
      , @acct               = @ArpmtdDiscAcct
      , @acct_unit1         = @ArpmtdDiscAcctUnit1
      , @acct_unit2         = @ArpmtdDiscAcctUnit2
      , @acct_unit3         = @ArpmtdDiscAcctUnit3
      , @acct_unit4         = @ArpmtdDiscAcctUnit4
      , @amount             = @DomPostAmount
      , @for_amount         = @ForPostAmount
      , @bank_code          = @ArpmtBankCode
      , @exch_rate          = @WireExchangeRate
      , @curr_code          = @CustaddrCurrCode
      , @check_num          = @ArpmtCheckNum
      , @check_date         = @ArpmtRecptDate
      , @ref                = @Ref
      , @vend_num           = @CustomerCustNum
      , @ref_type           = @RefType
      , @voucher            = @ArpmtdInvNum
      , @vouch_seq          = @ArpmtCheckNum
      , @from_site          = @CorpSite
      , @ControlPrefix      = @ControlPrefix
      , @ControlSite        = @ControlSite
      , @ControlYear        = @ControlYear
      , @ControlPeriod      = @ControlPeriod
      , @ControlNumber      = @ControlNumber
      , @last_seq           = @EndTrans     OUTPUT
      , @Infobar            = @Infobar      OUTPUT

      if @Severity <> 0
         GOTO EOF

      IF @ArpmtNoteExistsFlag > 0
      BEGIN -- copy notes

         SET @JournalRowPointer = NULL

         IF @JournalDeferredVar = 1
             SELECT
               @JournalRowPointer = journal.RowPointer
             FROM tmp_mass_journal as journal
             WHERE journal.id = @TId and
                   journal.seq = @EndTrans
            and journal.ProcessId = @BufferJournal
         ELSE
             SELECT
               @JournalRowPointer = journal.RowPointer
             FROM journal
             WHERE journal.id = @TId and
                   journal.seq = @EndTrans

         if @JournalRowPointer IS NOT NULL
         BEGIN
            IF @CrossSitePost = 1
            BEGIN
               EXEC @Severity  = dbo.RemoteMethodCallSp
                 @Site         = @CorpSite
               , @IdoName      = NULL
               , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
               , @Infobar      = @Infobar OUTPUT
               , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
               , @Parm2Value   = @ParmsSite         -- Copy to site
               , @Parm3Value   = 'journal'          -- Copy to table
               , @Parm4Value   = @JournalRowPointer -- Copy to row pointer
               , @Parm5Value   = @Infobar

               IF @Severity <> 0
                  GOTO EOF
            END -- cross-site
            ELSE
            BEGIN
               EXEC @Severity = dbo.CopyNotesSp
                'arpmt'
               , @ArpmtRowPointer
               , 'journal'
               , @JournalRowPointer

               if @Severity <> 0
                  GOTO EOF
            END
         END

         IF @JournalDeferredVar = 1
           UPDATE tmp_mass_journal
           SET NoteExistsFlag = 1
           FROM tmp_mass_journal as journal
           WHERE journal.id = @TId and
                 journal.seq = @EndTrans
            and journal.ProcessId = @BufferJournal
      END -- copy notes

      SET @SiteAmountPosted = @SiteAmountPosted - @DomesticDiscAmt
      SET @ForSiteAmountPosted = @ForSiteAmountPosted - @ForeignDiscAmt

   END -- CREDIT Account 1

   if @ArpmtdDomAllowAmt <> 0
   BEGIN -- CREDIT Account 2

      SET @ChartRowPointer = NULL

      SELECT
       @ChartRowPointer = chart.RowPointer
      FROM chart WITH (READUNCOMMITTED)
      where chart.acct = @ArpmtdAllowAcct

      if @ChartRowPointer IS NULL or @ArpmtdAllowAcct IS NULL
      BEGIN
         SET @Infobar = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistFor1'
         , '@chart'
         , '@arpmtd'
         , '@arpmtd.allow_acct'
         , @ArpmtdAllowAcct

         GOTO EOF
      END

      EXEC @Severity = dbo.ChkAcctSp
        @ArpmtdAllowAcct
      , @ArpmtRecptDate
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      EXEC @Severity = dbo.ChkUnitSp
        @ArpmtdAllowAcct
      , @ArpmtdAllowAcctUnit1
      , @ArpmtdAllowAcctUnit2
      , @ArpmtdAllowAcctUnit3
      , @ArpmtdAllowAcctUnit4
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      IF @ArpmtType = 'D'
         SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
      ELSE
         SET @Ref = @ArpmtRef
      SET @RefType = SUBSTRING(@ArpmtRef, 3, 1)

      SET @DomPostAmount = @DomesticAllowAmt * -1
      SET @ForPostAmount = @ForeignAllowAmt * -1
	  
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
      , @acct               = @ArpmtdAllowAcct
      , @acct_unit1         = @ArpmtdAllowAcctUnit1
      , @acct_unit2         = @ArpmtdAllowAcctUnit2
      , @acct_unit3         = @ArpmtdAllowAcctUnit3
      , @acct_unit4         = @ArpmtdAllowAcctUnit4
      , @amount             = @DomPostAmount
      , @for_amount         = @ForPostAmount
      , @bank_code          = @ArpmtBankCode
      , @exch_rate          = @WireExchangeRate
      , @curr_code          = @CustaddrCurrCode
      , @check_num          = @ArpmtCheckNum
      , @check_date         = @ArpmtRecptDate
      , @ref                = @Ref
      , @vend_num           = @CustomerCustNum
      , @ref_type           = @RefType
      , @voucher            = @ArpmtdInvNum
      , @vouch_seq          = @ArpmtCheckNum
      , @from_site          = @CorpSite
      , @ControlPrefix      = @ControlPrefix
      , @ControlSite        = @ControlSite
      , @ControlYear        = @ControlYear
      , @ControlPeriod      = @ControlPeriod
      , @ControlNumber      = @ControlNumber
      , @last_seq           = @EndTrans     OUTPUT
      , @Infobar            = @Infobar      OUTPUT

      if @Severity <> 0
         GOTO EOF

      IF @ArpmtNoteExistsFlag > 0
      BEGIN -- copy notes

         SET @JournalRowPointer = NULL

         IF @JournalDeferredVar=1
             SELECT
               @JournalRowPointer = journal.RowPointer
             FROM tmp_mass_journal as journal
             WHERE journal.id = @TId and
                   journal.seq = @EndTrans
            and journal.ProcessId = @BufferJournal
         ELSE
             SELECT
               @JournalRowPointer = journal.RowPointer
             FROM journal
             WHERE journal.id = @TId and
                   journal.seq = @EndTrans

         if @JournalRowPointer IS NOT NULL
         BEGIN
            IF @CrossSitePost = 1
            BEGIN
               EXEC @Severity  = dbo.RemoteMethodCallSp
                 @Site         = @CorpSite
               , @IdoName      = NULL
               , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
               , @Infobar      = @Infobar OUTPUT
               , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
               , @Parm2Value   = @ParmsSite         -- Copy to site
               , @Parm3Value   = 'journal'          -- Copy to table
               , @Parm4Value   = @JournalRowPointer -- Copy to row pointer
               , @Parm5Value   = @Infobar

               IF @Severity <> 0
                  GOTO EOF
            END -- cross-site
            ELSE
            BEGIN
               EXEC @Severity = dbo.CopyNotesSp
                'arpmt'
               , @ArpmtRowPointer
               , 'journal'
               , @JournalRowPointer

               if @Severity <> 0
                  GOTO EOF
            END
         END

         IF @JournalDeferredVar=1
            UPDATE tmp_mass_journal
            SET NoteExistsFlag = 1
            FROM tmp_mass_journal as journal
            WHERE journal.id = @TId and
                  journal.seq = @EndTrans
            and journal.ProcessId = @BufferJournal
      END -- copy notes

      SET @SiteAmountPosted = @SiteAmountPosted - @DomesticAllowAmt
      SET @ForSiteAmountPosted = @ForSiteAmountPosted - @ForeignAllowAmt

   END -- CREDIT Account 2

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

         SET @Severity = @@ERROR
         IF @Severity <> 0
            GOTO EOF
      END
   END -- Draft

END -- Non A/R Cash

ELSE
IF dbo.IsInteger(@ArpmtdInvNumTrim) = 1 and CONVERT(BIGINT, @ArpmtdInvNumTrim) < 0 AND
   @ArpmtdDomAmtApplied <> 0
BEGIN -- Finance Charge

   -- CREDIT Accounts Receivable - Asset
   SET @ArtranRowPointer = NULL
   SET @ArtranAcct       = NULL
   SET @ArtranAcctUnit1  = NULL
   SET @ArtranAcctUnit2  = NULL
   SET @ArtranAcctUnit3  = NULL
   SET @ArtranAcctUnit4  = NULL
   SET @ArtranCustNum    = NULL
   SET @ArtranInvNum     = '0'
   SET @ArtranInvSeq     = 0

   SELECT TOP 1 -- first
     @ArtranRowPointer = artran.RowPointer
   , @ArtranAcct       = artran.acct
   , @ArtranAcctUnit1  = artran.acct_unit1
   , @ArtranAcctUnit2  = artran.acct_unit2
   , @ArtranAcctUnit3  = artran.acct_unit3
   , @ArtranAcctUnit4  = artran.acct_unit4
   , @ArtranCustNum    = artran.cust_num
   , @ArtranInvNum     = artran.inv_num
   , @ArtranInvSeq     = artran.inv_seq
   FROM artran
   where artran.cust_num = @CustomerCustNum
      and artran.inv_num = '-1'
      and artran.type = 'F'

   SET @ChartRowPointer = NULL
   SET @ChartAcct       = NULL
   SET @TAcct = CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcct else
                     @CorpArparmsArAcct END
   SET @TUnit1 = CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcctUnit1 else
                     @CorpArparmsArAcctUnit1 END
   SET @TUnit2 = CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcctUnit2 else
                     @CorpArparmsArAcctUnit2 END
   SET @TUnit3 = CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcctUnit3 else
                     @CorpArparmsArAcctUnit3 END
   SET @TUnit4 = CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcctUnit4 else
                     @CorpArparmsArAcctUnit4 END

   SELECT
     @ChartRowPointer = chart.RowPointer
   , @ChartAcct       = chart.acct
   FROM chart WITH (READUNCOMMITTED)
   where chart.acct = @TAcct

   EXEC @Severity = dbo.ChkAcctSp
     @TAcct
   , @ArpmtRecptDate
   , @Infobar OUTPUT

   IF @Severity <> 0
      GOTO EOF

   EXEC @Severity = dbo.ChkUnitSp
     @TAcct
   , @TUnit1
   , @TUnit2
   , @TUnit3
   , @TUnit4
   , @Infobar OUTPUT

   IF @Severity <> 0
      GOTO EOF

   IF @ArpmtType = 'D'
      SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
   ELSE
      SET @Ref = @ArpmtRef
   SET @RefType = SUBSTRING(@ArpmtRef, 3, 1)

   SET @DomPostAmount = @DomesticAmtApplied * -1
   SET @ForPostAmount = @ForeignAmtApplied * -1
   
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
   , @amount             = @DomPostAmount
   , @for_amount         = @ForPostAmount
   , @bank_code          = @ArpmtBankCode
   , @exch_rate          = @WireExchangeRate
   , @curr_code          = @CustaddrCurrCode
   , @check_num          = @ArpmtCheckNum
   , @check_date         = @ArpmtRecptDate
   , @ref                = @Ref
   , @vend_num           = @CustomerCustNum
   , @ref_type           = @RefType
   , @voucher            = @ArpmtdInvNum
   , @vouch_seq          = @ArpmtCheckNum
   , @from_site          = @CorpSite
   , @ControlPrefix      = @ControlPrefix
   , @ControlSite        = @ControlSite
   , @ControlYear        = @ControlYear
   , @ControlPeriod      = @ControlPeriod
   , @ControlNumber      = @ControlNumber
   , @last_seq           = @EndTrans     OUTPUT
   , @Infobar            = @Infobar      OUTPUT

   if @Severity <> 0
      GOTO EOF

   IF @ArpmtNoteExistsFlag > 0
   BEGIN -- copy notes

      SET @JournalRowPointer = NULL

      IF @JournalDeferredVar=1
          SELECT
            @JournalRowPointer = journal.RowPointer
          FROM tmp_mass_journal as journal
          WHERE journal.id = @TId and
                journal.seq = @EndTrans
         and journal.ProcessId = @BufferJournal
      ELSE
          SELECT
            @JournalRowPointer = journal.RowPointer
          FROM journal
          WHERE journal.id = @TId and
                journal.seq = @EndTrans

      if @JournalRowPointer IS NOT NULL
      BEGIN
         IF @CrossSitePost = 1
         BEGIN
            EXEC @Severity  = dbo.RemoteMethodCallSp
              @Site         = @CorpSite
            , @IdoName      = NULL
            , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
            , @Infobar      = @Infobar OUTPUT
            , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
            , @Parm2Value   = @ParmsSite         -- Copy to site
            , @Parm3Value   = 'journal'          -- Copy to table
            , @Parm4Value   = @JournalRowPointer -- Copy to row pointer
            , @Parm5Value   = @Infobar

            IF @Severity <> 0
               GOTO EOF
         END -- cross-site
         ELSE
         BEGIN
            EXEC @Severity = dbo.CopyNotesSp
             'arpmt'
            , @ArpmtRowPointer
            , 'journal'
            , @JournalRowPointer

            if @Severity <> 0
               GOTO EOF
         END
      END

      IF @JournalDeferredVar = 1
        UPDATE tmp_mass_journal
        SET NoteExistsFlag = 1
        FROM tmp_mass_journal as journal
        WHERE journal.id = @TId and
             journal.seq = @EndTrans
         and journal.ProcessId = @BufferJournal
   END -- copy notes

   if @ArpmtType <> 'D'
   BEGIN -- Not a draft
      if @CrossSitePost = 1
         UPDATE customer
            SET posted_bal = posted_bal - @ForeignAmtApplied
         WHERE RowPointer = @CustomerRowPointer
      else
      begin
         update #customer
         set posted_bal = posted_bal - @ForeignAmtApplied
         where cust_num = @TCustNum

         if @@rowcount = 0
            insert into #customer (cust_num, posted_bal)
            values(@TCustNum, - @ForeignAmtApplied)
      end

      SET @Severity = @@ERROR
      IF @Severity <> 0
         GOTO EOF

      SET @ApplyAmount = @ArpmtdDomAmtApplied
      SET @SiteAmountPosted = @SiteAmountPosted - @DomesticAmtApplied
      SET @ForSiteAmountPosted = @ForSiteAmountPosted - @ForeignAmtApplied

      if @CustaddrCorpCred = 1
      BEGIN
         SET @Adjust = (- @ForeignAmtApplied)
         if @CrossSitePost = 1
         begin
            EXEC @Severity = dbo.UpdObalSp
              @CustaddrCorpCust
            , @Adjust  --SUBTRACT

            if @Severity <> 0
               GOTO EOF
         end
         else
         begin
            update #customer
            set order_bal = order_bal + @Adjust
            where cust_num = @CustaddrCorpCust

            if @@rowcount = 0
               insert into #customer (cust_num, order_bal)
               values(@CustaddrCorpCust, @Adjust)
         end
      END -- CorpCred

      if @ReApplication = 1
      BEGIN
         if @CrossSitePost = 1
            UPDATE customer
               SET posted_bal = posted_bal + @ForeignAmtApplied
            WHERE RowPointer = @CustomerRowPointer
         else
         begin
            update #customer
            set posted_bal = posted_bal + @ForeignAmtApplied
            where cust_num = @TCustNum

            if @@rowcount = 0
               insert into #customer (cust_num, posted_bal)
               values(@TCustNum, @ForeignAmtApplied)
         end

         if @CorpCustaddrCorpCred = 1
         BEGIN
            if @CrossSitePost = 1
            begin
               EXEC @Severity  = dbo.RemoteMethodCallSp
                 @Site         = @CorpSite
               , @IdoName      = NULL
               , @MethodName   = 'UpdObalSp'
               , @Infobar      = @Infobar OUTPUT
               , @Parm1Value   = @CorpCustaddrCorpCust
               , @Parm2Value   = @ForeignAmtApplied

               IF @Severity <> 0
                  GOTO EOF
            end
            else
            begin
               update #customer
               set order_bal = order_bal + @ForeignAmtApplied
               where cust_num = @CorpCustaddrCorpCust

               if @@rowcount = 0
                  insert into #customer (cust_num, order_bal)
                  values(@CorpCustaddrCorpCust, @ForeignAmtApplied)
            end
         END
      END

   END -- Not a draft
   ELSE
   BEGIN
      SET @ApplyAmount = @ArpmtdDomAmtApplied
      SET @SiteAmountPosted = @SiteAmountPosted - @DomesticAmtApplied
      SET @ForSiteAmountPosted = @ForSiteAmountPosted - @ForeignAmtApplied
   END

   IF @ArpmtOffset = 0
   BEGIN
      IF @ArpmtType <> 'A'
      BEGIN -- Not an Adjustment

        IF EXISTS (SELECT 1
        FROM artran
        WHERE artran.cust_num = @CustomerCustNum
           and artran.inv_num = '-1'
           and artran.inv_seq = @ArpmtCheckNum
           and artran.check_seq = 0)
        BEGIN
           SET @Infobar = NULL
           EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=Exist3'
           , '@artran'
           , '@artran.cust_num'
           , @CustomerCustNum
           , '@artran.inv_num'
           , '-1'
           , '@artran.inv_seq'
           , @ArpmtCheckNum
           
           GOTO EOF
         END
      END -- Not an Adjustment
      SET  @ArtranCheckSeq = 0
   END
   ELSE
   BEGIN
      SELECT @ArtranCheckSeq = (MAX(ISNULL(check_seq,0)) + 1)
      FROM artran
      WHERE artran.inv_num = @ArtranInvNum
        AND artran.inv_seq = 0
   END

   SELECT
     @ArtranRowPointer = NEWID ()
   , @ArtranCustNum = @CustomerCustNum
   , @ArtranInvNum = '-1'
   , @ArtranInvSeq = @ArpmtCheckNum
   , @ArtranType = 'P'
   , @ArtranInvDate = @ArpmtRecptDate
   , @ArtranAcct    = @TAcct
   , @ArtranAcctUnit1 = @TUnit1
   , @ArtranAcctUnit2 = @TUnit2
   , @ArtranAcctUnit3 = @TUnit3
   , @ArtranAcctUnit4 = @TUnit4
   , @ArtranBankCode = @ArpmtBankCode
   , @ArtranDescription = @ArpmtDescription
   , @ArtranExchRate = @WireExchangeRate
   , @ArtranAmount = @ForeignAmtApplied
   , @ArtranCorpCust = @CustaddrCorpCust
   , @ArtranPayType = @ArpmtType
   , @ArtranDueDate = @ArpmtRecptDate
   , @ArtranRef = @ArpmtRef
	-- ZLA
   , @ArtranZlaForCurrCode	= @ArpmtdZlaForCurrCode
   , @ArtranZlaForExchRate	= @ArpmtdZlaForExchRate
   , @ArtranZlaForNonArAmt	 = @ArpmtdZlaForNonArAmt
   , @ArtranZlaForAmount   = @ArpmtdZlaForAmtApplied
	-- ZLA

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
   , zla_for_curr_code
	, zla_for_exch_rate
	, zla_for_non_ar_amt
	, zla_for_amount
	, zla_ar_pay_id
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
   , @ArpmtdInvNum
   , @ArtranZlaForCurrCode	
	, @ArtranZlaForExchRate	
	, @ArtranZlaForNonArAmt	 
	, @ArtranZlaForAmount  
	, @ArpmtZlaArPayId)

   SET @Severity = @@ERROR
   IF @Severity <> 0
      GOTO EOF

   IF @ArpmtNoteExistsFlag > 0
   BEGIN -- copy notes
      IF @CrossSitePost = 1
      BEGIN
         EXEC @Severity  = dbo.RemoteMethodCallSp
           @Site         = @CorpSite
         , @IdoName      = NULL
         , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
         , @Infobar      = @Infobar OUTPUT
         , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
         , @Parm2Value   = @ParmsSite         -- Copy to site
         , @Parm3Value   = 'artran'           -- Copy to table
         , @Parm4Value   = @ArtranRowPointer  -- Copy to row pointer
         , @Parm5Value   = @Infobar

         IF @Severity <> 0
            GOTO EOF

         EXEC @Severity  = dbo.RemoteMethodCallSp
           @Site         = @CorpSite
         , @IdoName      = NULL
         , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
         , @Infobar      = @Infobar OUTPUT
         , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
         , @Parm2Value   = @ParmsSite         -- Copy to site
         , @Parm3Value   = 'artran_all'       -- Copy to table
         , @Parm4Value   = @ArtranRowPointer  -- Copy to row pointer
         , @Parm5Value   = @Infobar

         IF @Severity <> 0
            GOTO EOF
      END -- cross-site
      ELSE
      BEGIN
         EXEC @Severity = dbo.CopyNotesSp
          'arpmt'
         , @ArpmtRowPointer
         , 'artran'
         , @ArtranRowPointer

         if @Severity <> 0
            GOTO EOF

         EXEC @Severity = dbo.CopyNotesSp
          'arpmt'
         , @ArpmtRowPointer
         , 'artran_all'
         , @ArtranRowPointer

         if @Severity <> 0
            GOTO EOF
      END
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
            artran.inv_num =  @ArpmtdInvNum and
            artran.inv_seq =  @ArpmtCheckNum and
            artran.check_seq <> 0
      ORDER BY cust_num, inv_num, inv_seq, check_seq DESC

      UPDATE artran
         SET check_seq = CASE WHEN @XArtranRowPointer IS NOT NULL then @XArtranCheckSeq + 1
                           else 1 END
      WHERE artran.RowPointer = @ArtranRowPointer

      SET @Severity = @@ERROR
      IF @Severity <> 0
         GOTO EOF
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

         SET @Severity = @@ERROR
         IF @Severity <> 0
            GOTO EOF
      END
   END -- Draft

END -- Finance Charge

ELSE
BEGIN  -- Open Credit / Invoice

   SET @TGain = 0

   SET @ArtranRowPointer = NULL
   SET @ArtranAcct       = NULL
   SET @ArtranAcctUnit1  = NULL
   SET @ArtranAcctUnit2  = NULL
   SET @ArtranAcctUnit3  = NULL
   SET @ArtranAcctUnit4  = NULL
   SET @ArtranCustNum    = NULL
   SET @ArtranInvNum     = '0'
   SET @ArtranInvSeq     = 0

   SELECT TOP 1 -- first
     @ArtranRowPointer = artran.RowPointer
   , @ArtranAcct       = artran.acct
   , @ArtranAcctUnit1  = artran.acct_unit1
   , @ArtranAcctUnit2  = artran.acct_unit2
   , @ArtranAcctUnit3  = artran.acct_unit3
   , @ArtranAcctUnit4  = artran.acct_unit4
   , @ArtranCustNum    = artran.cust_num
   , @ArtranInvNum     = artran.inv_num
   , @ArtranInvSeq     = artran.inv_seq
   , @ArtranActive = artran.active
   FROM artran
   where artran.cust_num = @CustomerCustNum
      and artran.inv_num = @ArpmtdInvNum
      and artran.inv_seq = 0
      and artran.fixed_rate = 0

   if @ArtranRowPointer IS NOT NULL
   BEGIN
      SET @TAcct  = @ArtranAcct
      SET @TUnit1 = @ArtranAcctUnit1
      SET @TUnit2 = @ArtranAcctUnit2
      SET @TUnit3 = @ArtranAcctUnit3
      SET @TUnit4 = @ArtranAcctUnit4

      SET @TAmt = CASE WHEN @ReApplyType = 'C' then 0 else (@ArpmtdForAmtApplied + @ArpmtdForAllowAmt +
                      @ArpmtdForDiscAmt) END
      SET @TTransDom = CASE WHEN @CustaddrCurrCode = @CurrparmsCurrCode
                       then 0 else 1 END

      if @TTransDom = 1
      begin
         EXEC @Severity = dbo.GainLossArSp
           @pCustNum = @ArtranCustNum
         , @pInvNum = @ArtranInvNum
         , @pCustCurrCode = @CustaddrCurrCode
         , @pUseHistRate = 1
         , @pTTransDom = @TTransDom
         , @pInvSeq = 0
         , @rTDomBal = @TDomBal OUTPUT
         , @rTForBal = @TForBal OUTPUT
         , @rTGainLoss = @TGainLoss OUTPUT
         , @rInfobar = @Infobar OUTPUT
         , @ReturnTable = 0
         , @TAvgExchRate = @TAvgExchRate output

         if @Severity <> 0
            GOTO EOF

         if @TDomBal = 0 or @TForBal = 0
            SET @TAvgExchRate = @WireExchRate

         EXEC @Severity = dbo.CurrCnvtSp
             @CurrCode =      @CustaddrCurrCode
           , @FromDomestic =  0
           , @UseBuyRate =    0
           , @RoundResult =   1
           , @Date =          NULL
           , @TRate =         @TAvgExchRate OUTPUT
           , @Infobar =       @Infobar OUTPUT
           , @Amount1 =       @TAmt
           , @Result1 =       @OAmt1  OUTPUT
         , @Site = @ParmsSite
         , @DomCurrCode = @CurrparmsCurrCode

         if @Severity <> 0
            GOTO EOF

         SET @TRate = @WireExchangeRate

         EXEC @Severity = dbo.CurrCnvtSp
             @CurrCode =      @CustaddrCurrCode
           , @FromDomestic =  0
           , @UseBuyRate =    0
           , @RoundResult =   1
           , @Date =          NULL
           , @TRate =         @TRate   OUTPUT
           , @Infobar =       @Infobar OUTPUT
           , @Amount1 =       @TAmt
           , @Result1 =       @OAmt2  OUTPUT
         , @Site = @ParmsSite
         , @DomCurrCode = @CurrparmsCurrCode

         if @Severity <> 0
            GOTO EOF

         -- use the gain/loss from the GainLossArSp call when the balance is zero
         -- when it is an Adjustment or a Check/Wire with a negative payment (effectively reversing the original payment)
         IF (@TDomBal = 0 OR @TForBal = 0) AND ( @ArpmtType = 'A' OR (CHARINDEX(@ArpmtType, 'CW') > 0 AND @TAmt < 0) )
            SET @TGain = @TGainLoss * CASE WHEN @TAmt > 0 THEN 1 ELSE -1 END
         ELSE
            SET @TGain = @OAmt2 - @OAmt1
      end

      if @ArtranActive = 0
      BEGIN
         UPDATE artran
            SET active = 1
         WHERE RowPointer = @ArtranRowPointer

         SET @Severity = @@ERROR
         IF @Severity <> 0
            GOTO EOF
      END
   END

   if @TGain <> 0
   BEGIN -- @TGain <> 0

      -- POST gain

      SET @BankHdrRowPointer = NULL

      SELECT
        @BankHdrRowPointer = bank_hdr.RowPointer
      , @BankHdrCurrCode = bank_hdr.curr_code
      FROM bank_hdr WITH (READUNCOMMITTED)
      where bank_hdr.bank_code = @CustomerBankCode

      if @BankHdrRowPointer IS NULL
      BEGIN
         SET @Infobar = NULL
         SET @Infobar2 = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=IsCompare'
         , '@parms.site'
         , @LocalSiteName

         EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'E=NoExist1'
         , '@bank_hdr'
         , '@bank_hdr.bank_code'
         , @CustomerBankCode

         SET @Infobar = @Infobar + '  ' + @Infobar2

         GOTO EOF
      END

      SET @CurracctRowPointer = NULL

      SELECT
       @CurracctRowPointer = curracct.RowPointer
      , @CurracctGainAcct = curracct.gain_acct
      , @CurracctGainAcctUnit1 = curracct.gain_acct_unit1
      , @CurracctGainAcctUnit2 = curracct.gain_acct_unit2
      , @CurracctGainAcctUnit3 = curracct.gain_acct_unit3
      , @CurracctGainAcctUnit4 = curracct.gain_acct_unit4
      , @CurracctLossAcct      = curracct.loss_acct
      , @CurracctLossAcctUnit1 = curracct.loss_acct_unit1
      , @CurracctLossAcctUnit2 = curracct.loss_acct_unit2
      , @CurracctLossAcctUnit3 = curracct.loss_acct_unit3
      , @CurracctLossAcctUnit4 = curracct.loss_acct_unit4
      FROM curracct WITH (READUNCOMMITTED)
       where
         curracct.curr_code = CASE WHEN (@CustaddrCurrCode IS NOT NULL) THEN @CustaddrCurrCode ELSE @BankHdrCurrCode END

      if @CurracctRowPointer IS NOT NULL
      BEGIN --- Found the Curracct

         if @TGain > 0
         BEGIN -- @TGain > 0
            SET @ChartRowPointer = NULL
            SET @ChartAcct       = NULL

            SELECT
              @ChartRowPointer = chart.RowPointer
            , @ChartAcct       = chart.acct
            FROM chart WITH (READUNCOMMITTED)
            where chart.acct = @CurracctGainAcct
            if @ChartRowPointer IS NULL or @ChartAcct IS NULL
            BEGIN
               SET @ChartRowPointer = NULL
               SET @ChartAcct       = NULL

               SELECT
                 @ChartRowPointer = chart.RowPointer
               , @ChartAcct       = chart.acct
               FROM chart WITH (READUNCOMMITTED)
               where chart.acct = @CurrparmsGainAcct
               if @ChartRowPointer IS NOT NULL and @ChartAcct IS NOT NULL
               BEGIN
                  SET @TGlAcct  = @CurrparmsGainAcct
                  SET @TGlUnit1 = @CurrparmsGainAcctUnit1
                  SET @TGlUnit2 = @CurrparmsGainAcctUnit2
                  SET @TGlUnit3 = @CurrparmsGainAcctUnit3
                  SET @TGlUnit4 = @CurrparmsGainAcctUnit4
               END
            END
            ELSE
            BEGIN
               SET @TGlAcct = @CurracctGainAcct
               SET @TGlUnit1 = @CurracctGainAcctUnit1
               SET @TGlUnit2 = @CurracctGainAcctUnit2
               SET @TGlUnit3 = @CurracctGainAcctUnit3
               SET @TGlUnit4 = @CurracctGainAcctUnit4
            END

         END -- @TGain > 0
         ELSE
         BEGIN -- @TGain < 0
            SET @ChartRowPointer = NULL
            SET @ChartAcct       = NULL

            SELECT
              @ChartRowPointer = chart.RowPointer
            , @ChartAcct       = chart.acct
            FROM chart WITH (READUNCOMMITTED)
            where chart.acct = @CurracctLossAcct
            if @ChartRowPointer IS NULL or @ChartAcct IS NULL
            BEGIN

               SET @ChartRowPointer = NULL
               SET @ChartAcct       = NULL

               SELECT
                 @ChartRowPointer = chart.RowPointer
               , @ChartAcct       = chart.acct
               FROM chart WITH (READUNCOMMITTED)
               where chart.acct = @CurrparmsLossAcct
               if @ChartRowPointer IS NOT NULL and @ChartAcct IS NOT NULL
               BEGIN
                  SET @TGlAcct  = @CurrparmsLossAcct
                  SET @TGlUnit1 = @CurrparmsLossAcctUnit1
                  SET @TGlUnit2 = @CurrparmsLossAcctUnit2
                  SET @TGlUnit3 = @CurrparmsLossAcctUnit3
                  SET @TGlUnit4 = @CurrparmsLossAcctUnit4
               END
            END
            ELSE
            BEGIN
               SET @TGlAcct  = @CurracctLossAcct
               SET @TGlUnit1 = @CurracctLossAcctUnit1
               SET @TGlUnit2 = @CurracctLossAcctUnit2
               SET @TGlUnit3 = @CurracctLossAcctUnit3
               SET @TGlUnit4 = @CurracctLossAcctUnit4
            END
         END -- @TGain < 0

      END -- Found the Curracct
      ELSE
      BEGIN -- Didn't find Curracct
         if @TGain > 0
         BEGIN
            SET @ChartRowPointer = NULL
            SET @ChartAcct       = NULL

            SELECT
              @ChartRowPointer = chart.RowPointer
            , @ChartAcct       = chart.acct
            FROM chart WITH (READUNCOMMITTED)
            where chart.acct = @CurrparmsGainAcct
            if @ChartRowPointer IS NOT NULL and @ChartAcct IS NOT NULL
            BEGIN
               SET @TGlAcct  = @CurrparmsGainAcct
               SET @TGlUnit1 = @CurrparmsGainAcctUnit1
               SET @TGlUnit2 = @CurrparmsGainAcctUnit2
               SET @TGlUnit3 = @CurrparmsGainAcctUnit3
               SET @TGlUnit4 = @CurrparmsGainAcctUnit4
            END
         END
         ELSE
         BEGIN
            SET @ChartRowPointer = NULL
            SET @ChartAcct       = NULL

            SELECT
              @ChartRowPointer = chart.RowPointer
            , @ChartAcct       = chart.acct
            FROM chart WITH (READUNCOMMITTED)
            where chart.acct = @CurrparmsLossAcct
            if @ChartRowPointer IS NOT NULL and @ChartAcct IS NOT NULL
            BEGIN
               SET @TGlAcct  = @CurrparmsLossAcct
               SET @TGlUnit1 = @CurrparmsLossAcctUnit1
               SET @TGlUnit2 = @CurrparmsLossAcctUnit2
               SET @TGlUnit3 = @CurrparmsLossAcctUnit3
               SET @TGlUnit4 = @CurrparmsLossAcctUnit4
            END
         END

      END -- Didn't find Curracct

      if @ChartRowPointer IS NULL or @ChartAcct IS NULL
      BEGIN -- Couldn't find a valid account
         if @TGain > 0
         BEGIN
            SET @Infobar = NULL
            SET @Infobar2 = NULL
            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=IsCompare'
            , '@parms.site'
            , @LocalSiteName

            EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'E=NoExistFor1'
            , '@chart'
            , '@parms'
            , '@currparms.gain_acct'
            , @CurrparmsGainAcct

            SET @Infobar = @Infobar + '  ' + @Infobar2

            GOTO EOF
         END
         ELSE
         BEGIN
            SET @Infobar = NULL
            SET @Infobar2 = NULL
            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=IsCompare'
            , '@parms.site'
            , @LocalSiteName

            EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'E=NoExistFor1'
            , '@chart'
            , '@parms'
            , '@currparms.loss_acct'
            , @CurrparmsLossAcct

            SET @Infobar = @Infobar + '  ' + @Infobar2

            GOTO EOF
         END
      END -- Couldn't find a valid account

      EXEC @Severity = dbo.ChkUnitSp
        @TGlAcct
      , @TGlUnit1
      , @TGlUnit2
      , @TGlUnit3
      , @TGlUnit4
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      SET @DomPostAmount = @TGain * -1
      SET @ForPostAmount = @TGain * -1
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
      , @acct               = @TGlAcct
      , @acct_unit1         = @TGlUnit1
      , @acct_unit2         = @TGlUnit2
      , @acct_unit3         = @TGlUnit3
      , @acct_unit4         = @TGlUnit4
      , @amount             = @DomPostAmount
      , @for_amount         = @ForPostAmount
      , @bank_code          = @ArpmtBankCode
      , @curr_code          = @CurrparmsCurrCode
      , @check_num          = @ArpmtCheckNum
      , @ref                = 'ARX'
      , @vend_num           = @CustomerCustNum
      , @ref_type           = 'X'
      , @ControlPrefix      = @ControlPrefix
      , @ControlSite        = @ControlSite
      , @ControlYear        = @ControlYear
      , @ControlPeriod      = @ControlPeriod
      , @ControlNumber      = @ControlNumber
      , @Infobar            = @Infobar      OUTPUT

      if @Severity <> 0
         GOTO EOF

      EXEC @Severity = dbo.ChkUnitSp
        @TAcct
      , @TUnit1
      , @TUnit2
      , @TUnit3
      , @TUnit4
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      -- POST to account that was debited at the
      -- time of posting the Invoice

      SET @DomPostAmount = @TGain
      SET @ForPostAmount = @TGain
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
      , @amount             = @DomPostAmount
      , @for_amount         = @ForPostAmount
      , @bank_code          = @ArpmtBankCode
      , @curr_code          = @CurrparmsCurrCode
      , @check_num          = @ArpmtCheckNum
      , @ref                = 'ARX'
      , @vend_num           = @CustomerCustNum
      , @ref_type           = 'X'
      , @ControlPrefix      = @ControlPrefix
      , @ControlSite        = @ControlSite
      , @ControlYear        = @ControlYear
      , @ControlPeriod      = @ControlPeriod
      , @ControlNumber      = @ControlNumber
      , @Infobar            = @Infobar      OUTPUT

      if @Severity <> 0
         GOTO EOF

   END -- TGain <> 0

   SET @ArtranRowPointer = NULL
   SET @ArtranAcct       = NULL
   SET @ArtranAcctUnit1  = NULL
   SET @ArtranAcctUnit2  = NULL
   SET @ArtranAcctUnit3  = NULL
   SET @ArtranAcctUnit4  = NULL
   SET @ArtranCustNum    = NULL
   SET @ArtranInvNum     = '0'
   SET @ArtranInvSeq     = 0

   SELECT TOP 1 -- first
     @ArtranRowPointer = artran.RowPointer
   , @ArtranAcct       = artran.acct
   , @ArtranAcctUnit1  = artran.acct_unit1
   , @ArtranAcctUnit2  = artran.acct_unit2
   , @ArtranAcctUnit3  = artran.acct_unit3
   , @ArtranAcctUnit4  = artran.acct_unit4
   , @ArtranCustNum    = artran.cust_num
   , @ArtranInvNum     = artran.inv_num
   , @ArtranInvSeq     = artran.inv_seq
   FROM artran
   where artran.cust_num = @CustaddrCustNum
      and artran.inv_num = @ArpmtdInvNum
      and artran.inv_seq = 0

   if @ArpmtType <> 'D'
   BEGIN -- Not a Draft
      set @NetDiscYtd = @DomesticDiscAmt + @DomesticAllowAmt
      set @NetPostedBal = @ForeignDiscAmt + @ForeignAllowAmt + @ForeignAmtApplied
      if @CrossSitePost = 1
         UPDATE customer
            SET posted_bal = posted_bal - @NetPostedBal
              , disc_ytd = disc_ytd + @NetDiscYtd
         WHERE RowPointer = @CustomerRowPointer
      else
      begin
         update #customer
         set disc_ytd = disc_ytd + @NetDiscYtd
         , posted_bal = posted_bal - @NetPostedBal
         where cust_num = @TCustNum

         if @@rowcount = 0
            insert into #customer (cust_num, disc_ytd, posted_bal)
            values(@TCustNum, @NetDiscYtd, - @NetPostedBal)
      end

      SET @ApplyAmount = @ArpmtdDomAmtApplied

      if @CustaddrCorpCred = 1
      BEGIN
         SET @Adjust = @ForeignAmtApplied
         if @CrossSitePost = 1
         begin
            EXEC @Severity = dbo.UpdPbalSp
              @CorpCustNum = @CustaddrCorpCust
            , @Adjust = @Adjust
            , @Operator = 'SUBTRACT'
            , @Message = @Infobar OUTPUT

            if @Severity <> 0
               GOTO EOF
         end
         else
         begin
            update #customer
            set posted_bal = posted_bal - @Adjust
            where cust_num = @CustaddrCorpCust

            if @@rowcount = 0
               insert into #customer (cust_num, posted_bal)
               values(@CustaddrCorpCust, - @Adjust)
         end
      END -- CorpCred

      if @ReApplication = 1
      BEGIN -- ReApply
         if @CrossSitePost = 1
            UPDATE customer
               SET posted_bal = posted_bal + @ForeignAmtApplied
            WHERE RowPointer = @CustomerRowPointer
         else
         begin
            update #customer
            set posted_bal = posted_bal + @ForeignAmtApplied
            where cust_num = @TCustNum

            if @@rowcount = 0
               insert into #customer (cust_num, posted_bal)
               values(@TCustNum, @ForeignAmtApplied)
         end

         if @CorpCustaddrCorpCred = 1
         BEGIN
            if @CrossSitePost = 1
            begin
               EXEC @Severity  = dbo.RemoteMethodCallSp
                 @Site         = @CorpSite
               , @IdoName      = NULL
               , @MethodName   = 'UpdPbalSp'
               , @Infobar      = @Infobar OUTPUT
               , @Parm1Value   = @CorpCustaddrCorpCust
               , @Parm2Value   = @ForeignAmtApplied
               , @Parm3Value   = 'SUBTRACT'
               , @Parm4Value   = @Infobar

               IF @Severity <> 0
                  GOTO EOF
            end
            else
            begin
               update #customer
               set posted_bal = posted_bal - @ForeignAmtApplied
               where cust_num = @CorpCustaddrCorpCust

               if @@rowcount = 0
                  insert into #customer (cust_num, posted_bal)
                  values(@CorpCustaddrCorpCust, - @ForeignAmtApplied)
            end
         END
      END -- ReApply
   END -- Not a Draft
   ELSE
   BEGIN -- Draft
      set @NetDiscYtd = @DomesticDiscAmt + @DomesticAllowAmt
      if @CrossSitePost = 1
         UPDATE customer
            SET disc_ytd = disc_ytd + @NetDiscYtd
         WHERE RowPointer = @CustomerRowPointer
      else
      begin
         update #customer
         set disc_ytd = disc_ytd + @NetDiscYtd
         where cust_num = @TCustNum

         if @@rowcount = 0
            insert into #customer (cust_num, disc_ytd)
            values(@TCustNum, @NetDiscYtd)
      end

      SET @ApplyAmount = @ArpmtdDomAmtApplied
   END -- Draft

   if @DomesticDiscAmt <> 0
   BEGIN -- Discount

      -- DEBIT Early Pay Discount - Revenue

      SET @ChartRowPointer = NULL
      SET @ChartAcct       = NULL

      SELECT
        @ChartRowPointer = chart.RowPointer
      , @ChartAcct       = chart.acct
      FROM chart WITH (READUNCOMMITTED)
      where chart.acct = @ArpmtdDiscAcct

      if @ChartRowPointer IS NULL or @ArpmtdDiscAcct IS NULL
      BEGIN
         SET @Infobar = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistFor1'
         , '@chart'
         , '@arpmtd'
         , '@arpmtd.disc_acct'
         , @ArpmtdDiscAcct

         GOTO EOF
      END

      EXEC @Severity = dbo.ChkAcctSp
        @ArpmtdDiscAcct
      , @ArpmtRecptDate
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      EXEC @Severity = dbo.ChkUnitSp
        @ArpmtdDiscAcct
      , @ArpmtdDiscAcctUnit1
      , @ArpmtdDiscAcctUnit2
      , @ArpmtdDiscAcctUnit3
      , @ArpmtdDiscAcctUnit4
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      IF @ArpmtType = 'D'
         SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
      ELSE
         SET @Ref = @ArpmtRef
      SET @RefType = SUBSTRING(@ArpmtRef, 3, 1)

      SET @DomPostAmount = @DomesticDiscAmt
      SET @ForPostAmount = @ForeignDiscAmt
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
      , @acct               = @ArpmtdDiscAcct
      , @acct_unit1         = @ArpmtdDiscAcctUnit1
      , @acct_unit2         = @ArpmtdDiscAcctUnit2
      , @acct_unit3         = @ArpmtdDiscAcctUnit3
      , @acct_unit4         = @ArpmtdDiscAcctUnit4
      , @amount             = @DomPostAmount
      , @for_amount         = @ForPostAmount
      , @bank_code          = @ArpmtBankCode
      , @exch_rate          = @WireExchangeRate
      , @curr_code          = @CustaddrCurrCode
      , @check_num          = @ArpmtCheckNum
      , @check_date         = @ArpmtRecptDate
      , @ref                = @Ref
      , @vend_num           = @CustomerCustNum
      , @ref_type           = @RefType
      , @voucher            = @ArpmtdInvNum
      , @vouch_seq          = @ArpmtCheckNum
      , @from_site          = @CorpSite
      , @ControlPrefix      = @ControlPrefix
      , @ControlSite        = @ControlSite
      , @ControlYear        = @ControlYear
      , @ControlPeriod      = @ControlPeriod
      , @ControlNumber      = @ControlNumber
      , @last_seq           = @EndTrans     OUTPUT
      , @Infobar            = @Infobar      OUTPUT

      if @Severity <> 0
         GOTO EOF

      IF @ArpmtNoteExistsFlag > 0
      BEGIN -- copy notes

         SET @JournalRowPointer = NULL

         IF @JournalDeferredVar = 1
             SELECT
               @JournalRowPointer = journal.RowPointer
             FROM tmp_mass_journal as journal
             WHERE journal.id = @TId and
                   journal.seq = @EndTrans
            and journal.ProcessId = @BufferJournal
         ELSE
             SELECT
               @JournalRowPointer = journal.RowPointer
             FROM journal
             WHERE journal.id = @TId and
                   journal.seq = @EndTrans

         if @JournalRowPointer IS NOT NULL
         BEGIN
            IF @CrossSitePost = 1
            BEGIN
               EXEC @Severity  = dbo.RemoteMethodCallSp
                 @Site         = @CorpSite
               , @IdoName      = NULL
               , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
               , @Infobar      = @Infobar OUTPUT
               , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
               , @Parm2Value   = @ParmsSite         -- Copy to site
               , @Parm3Value   = 'journal'          -- Copy to table
               , @Parm4Value   = @JournalRowPointer -- Copy to row pointer
               , @Parm5Value   = @Infobar

               IF @Severity <> 0
                  GOTO EOF
            END -- cross-site
            ELSE
            BEGIN
               EXEC @Severity = dbo.CopyNotesSp
                'arpmt'
               , @ArpmtRowPointer
               , 'journal'
               , @JournalRowPointer

               if @Severity <> 0
                  GOTO EOF
            END
         END

       IF @JournalDeferredVar=1
         UPDATE tmp_mass_journal
         SET NoteExistsFlag = 1
         FROM tmp_mass_journal as journal
         WHERE journal.id = @TId and
              journal.seq = @EndTrans
         and journal.ProcessId = @BufferJournal
      END -- copy notes

   END -- Discount

   if @DomesticAllowAmt <> 0
   BEGIN -- Allowance

      -- DEBIT Allowance - (Contra-)Asset

      SET @ChartRowPointer = NULL
      SET @ChartAcct       = NULL

      SELECT
        @ChartRowPointer = chart.RowPointer
      , @ChartAcct       = chart.acct
      FROM chart WITH (READUNCOMMITTED)
      where chart.acct = @ArpmtdAllowAcct

      if @ChartRowPointer IS NULL or @ArpmtdAllowAcct IS NULL
      BEGIN
         SET @Infobar = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExistFor1'
         , '@chart'
         , '@arpmtd'
         , '@arpmtd.allow_acct'
         , @ArpmtdAllowAcct

         GOTO EOF
      END

      EXEC @Severity = dbo.ChkAcctSp
        @ArpmtdAllowAcct
      , @ArpmtRecptDate
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      EXEC @Severity = dbo.ChkUnitSp
        @ArpmtdAllowAcct
      , @ArpmtdAllowAcctUnit1
      , @ArpmtdAllowAcctUnit2
      , @ArpmtdAllowAcctUnit3
      , @ArpmtdAllowAcctUnit4
      , @Infobar OUTPUT

      IF @Severity <> 0
         GOTO EOF

      IF @ArpmtType = 'D'
         SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
      ELSE
         SET @Ref = @ArpmtRef
      SET @RefType = SUBSTRING(@ArpmtRef, 3, 1)

      SET @DomPostAmount = @DomesticAllowAmt
      SET @ForPostAmount = @ForeignAllowAmt
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
      , @acct               = @ArpmtdAllowAcct
      , @acct_unit1         = @ArpmtdAllowAcctUnit1
      , @acct_unit2         = @ArpmtdAllowAcctUnit2
      , @acct_unit3         = @ArpmtdAllowAcctUnit3
      , @acct_unit4         = @ArpmtdAllowAcctUnit4
      , @amount             = @DomPostAmount
      , @for_amount         = @ForPostAmount
      , @bank_code          = @ArpmtBankCode
      , @exch_rate          = @WireExchangeRate
      , @curr_code          = @CustaddrCurrCode
      , @check_num          = @ArpmtCheckNum
      , @check_date         = @ArpmtRecptDate
      , @ref                = @Ref
      , @vend_num           = @CustomerCustNum
      , @ref_type           = @RefType
      , @voucher            = @ArpmtdInvNum
      , @vouch_seq          = @ArpmtCheckNum
      , @from_site          = @CorpSite
      , @ControlPrefix      = @ControlPrefix
      , @ControlSite        = @ControlSite
      , @ControlYear        = @ControlYear
      , @ControlPeriod      = @ControlPeriod
      , @ControlNumber      = @ControlNumber
      , @last_seq           = @EndTrans     OUTPUT
      , @Infobar            = @Infobar      OUTPUT

      if @Severity <> 0
         GOTO EOF

      IF @ArpmtNoteExistsFlag > 0
      BEGIN -- copy notes

         SET @JournalRowPointer = NULL

         IF @JournalDeferredVar=1
             SELECT
               @JournalRowPointer = journal.RowPointer
             FROM tmp_mass_journal as journal
             WHERE journal.id = @TId and
                   journal.seq = @EndTrans
            and journal.ProcessId = @BufferJournal
         ELSE
             SELECT
               @JournalRowPointer = journal.RowPointer
             FROM journal
             WHERE journal.id = @TId and
                   journal.seq = @EndTrans

         if @JournalRowPointer IS NOT NULL
         BEGIN
            IF @CrossSitePost = 1
            BEGIN
               EXEC @Severity  = dbo.RemoteMethodCallSp
                 @Site         = @CorpSite
               , @IdoName      = NULL
               , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
               , @Infobar      = @Infobar OUTPUT
               , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
               , @Parm2Value   = @ParmsSite         -- Copy to site
               , @Parm3Value   = 'journal'          -- Copy to table
               , @Parm4Value   = @JournalRowPointer -- Copy to row pointer
               , @Parm5Value   = @Infobar

               IF @Severity <> 0
                  GOTO EOF
            END -- cross-site
            ELSE
            BEGIN
               EXEC @Severity = dbo.CopyNotesSp
                'arpmt'
               , @ArpmtRowPointer
               , 'journal'
               , @JournalRowPointer

               if @Severity <> 0
                  GOTO EOF
            END
         END

       IF @JournalDeferredVar=1
         UPDATE tmp_mass_journal
         SET NoteExistsFlag = 1
         FROM tmp_mass_journal as journal
         WHERE journal.id = @TId and
              journal.seq = @EndTrans
         and journal.ProcessId = @BufferJournal
      END -- copy notes
   END -- Allowance

   -- CREDIT Deposit - Liability OR Accounts Receivable - Asset

   if @ReApplication =  0
   BEGIN -- not a ReApply
      SET @ArtranRowPointer = NULL
      SET @ArtranAcct       = NULL
      SET @ArtranAcctUnit1  = NULL
      SET @ArtranAcctUnit2  = NULL
      SET @ArtranAcctUnit3  = NULL
      SET @ArtranAcctUnit4  = NULL
      SET @ArtranCustNum    = NULL
      SET @ArtranInvNum     = '0'
      SET @ArtranInvSeq     = 0

      SELECT TOP 1
        @ArtranRowPointer = artran.RowPointer
      , @ArtranAcct       = artran.acct
      , @ArtranAcctUnit1  = artran.acct_unit1
      , @ArtranAcctUnit2  = artran.acct_unit2
      , @ArtranAcctUnit3  = artran.acct_unit3
      , @ArtranAcctUnit4  = artran.acct_unit4
      , @ArtranCustNum    = artran.cust_num
      , @ArtranInvNum     = artran.inv_num
      , @ArtranInvSeq     = artran.inv_seq
      FROM artran
         where artran.cust_num = @CustomerCustNum
            and artran.inv_num = @ArpmtdInvNum
            and artran.type = 'I'
   END -- not a ReApply

   SET @ChartRowPointer = NULL
   SET @ChartAcct       = NULL

   SELECT
     @ChartRowPointer = chart.RowPointer
   , @ChartAcct       = chart.acct
   FROM chart WITH (READUNCOMMITTED)
   where chart.acct = (CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcct
                            WHEN @ArpmtdInvNumTrim = '0' then @ArpmtdDepositAcct
                            else @ArparmsArAcct END)

   if @ChartRowPointer IS NULL or @ChartAcct IS NULL
   BEGIN
      SET @ChartRowPointer = NULL
      SET @ChartAcct       = NULL

      SELECT
        @ChartRowPointer = chart.RowPointer
      , @ChartAcct       = chart.acct
      FROM chart WITH (READUNCOMMITTED)
         where chart.acct = @ArparmsArAcct
   END

   EXEC @Severity = dbo.ChkAcctSp
     @ChartAcct
   , @ArpmtRecptDate
   , @Infobar OUTPUT

   IF @Severity <> 0
      GOTO EOF

   SET @TTxt2 = (CASE WHEN @ArpmtdInvNumTrim = '0' then 'Deposit ' + @ArpmtCustNum
                      else '' END)
   SET @TUnit1 = CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcctUnit1
                      WHEN @ArpmtdInvNumTrim = '0' then @ArpmtdDepositAcctUnit1
                      else @ArparmsArAcctUnit1 END
   SET @TUnit2 = CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcctUnit2
                      WHEN @ArpmtdInvNumTrim = '0' then @ArpmtdDepositAcctUnit2
                      else @ArparmsArAcctUnit2 END
   SET @TUnit3 = CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcctUnit3
                      WHEN @ArpmtdInvNumTrim = '0' then @ArpmtdDepositAcctUnit3
                      else @ArparmsArAcctUnit3 END
   SET @TUnit4 = CASE WHEN @ArtranRowPointer IS NOT NULL then @ArtranAcctUnit4
                      WHEN @ArpmtdInvNumTrim = '0' then @ArpmtdDepositAcctUnit4
                      else @ArparmsArAcctUnit4 END

   EXEC @Severity = dbo.ChkUnitSp
     @ChartAcct
   , @TUnit1
   , @TUnit2
   , @TUnit3
   , @TUnit4
   , @Infobar OUTPUT

   IF @Severity <> 0
      GOTO EOF

   /* credit tax discount/allowance amounts towards original A/R account */
   SET @TaxAdjAcct      = @ChartAcct
   SET @TaxAdjAcctUnit1 = @TUnit1
   SET @TaxAdjAcctUnit2 = @TUnit2
   SET @TaxAdjAcctUnit3 = @TUnit3
   SET @TaxAdjAcctUnit4 = @TUnit4

   IF @ArpmtType = 'D'
      SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
   ELSE
      SET @Ref = @ArpmtRef
   SET @RefType = SUBSTRING(@ArpmtRef, 3, 1)

   SET @DomPostAmount = (@DomesticDiscAmt + @DomesticAllowAmt + @DomesticAmtApplied) * -1
   SET @ForPostAmount = (@ForeignDiscAmt + @ForeignAllowAmt + @ForeignAmtApplied) * -1

   SET @XArtranRowPointer = NULL
   SELECT TOP 1 -- last
     @XArtranRowPointer = artran.RowPointer
   , @XArtranInvSeq     = artran.inv_seq
   FROM artran
   WHERE artran.cust_num = @CustomerCustNum and
         artran.inv_num  = @ArpmtCreditMemoNum and
         artran.type <> 'P'
   ORDER BY cust_num, inv_num DESC

   /* Walk around Payments */
   SET @TExist = 0
   WHILE @Severity = 0
   BEGIN
      if @XArtranRowPointer IS NOT NULL and @TIssueDate IS NULL
         SET @TSeq = @XArtranInvSeq + 1
      ELSE
      BEGIN
        if @XArtranRowPointer IS NOT NULL and @TIssueDate IS NOT NULL
        BEGIN
           if @XArtranInvSeq = @TSeq and @TExist = 1
              SET @TSeq = @XArtranInvSeq + 1
           ELSE
              SET @TSeq = @TInvSeq
        END
        ELSE
           SET @TSeq = 1
      END

      SET @XArtranRowPointer = NULL
      SELECT
        @XArtranRowPointer = artran.RowPointer
      , @XArtranInvSeq     = artran.inv_seq
      FROM artran
      WHERE artran.cust_num = @CustomerCustNum and
            artran.inv_num  = @ArpmtCreditMemoNum and
            artran.inv_seq  = @TSeq

      if @XArtranRowPointer IS NULL
         BREAK
      ELSE
         SET @TExist = 1
   END -- while @Severity = 0

   if @ArpmtdInvNum = '0' or isnull(@ReApplyType, '') != 'C'
   begin
      set @ArtranInvNum = @ArpmtdInvNum
      set @ArtranInvSeq = @ArpmtCheckNum
   end
   else
   begin
      set @ArtranInvNum = @ArpmtCreditMemoNum
      set @ArtranInvSeq = @TSeq
   end
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
   , @acct               = @ChartAcct
   , @acct_unit1         = @TUnit1
   , @acct_unit2         = @TUnit2
   , @acct_unit3         = @TUnit3
   , @acct_unit4         = @TUnit4
   , @amount             = @DomPostAmount
   , @for_amount         = @ForPostAmount
   , @bank_code          = @ArpmtBankCode
   , @exch_rate          = @WireExchangeRate
   , @curr_code          = @CustaddrCurrCode
   , @check_num          = @ArpmtCheckNum
   , @check_date         = @ArpmtRecptDate
   , @ref                = @Ref
   , @vend_num           = @CustomerCustNum
   , @ref_type           = @RefType
   , @voucher            = @ArtranInvNum
   , @vouch_seq          = @ArtranInvSeq
   , @from_site          = @CorpSite
   , @ControlPrefix      = @ControlPrefix
   , @ControlSite        = @ControlSite
   , @ControlYear        = @ControlYear
   , @ControlPeriod      = @ControlPeriod
   , @ControlNumber      = @ControlNumber
   , @last_seq           = @EndTrans     OUTPUT
   , @Infobar            = @Infobar      OUTPUT

   if @Severity <> 0
      GOTO EOF

   IF @ArpmtNoteExistsFlag > 0
   BEGIN -- copy notes

      SET @JournalRowPointer = NULL

      IF @JournalDeferredVar=1
          SELECT
            @JournalRowPointer = journal.RowPointer
          FROM tmp_mass_journal as journal
          WHERE journal.id = @TId and
                journal.seq = @EndTrans
         and journal.ProcessId = @BufferJournal
      ELSE
          SELECT
             @JournalRowPointer = journal.RowPointer
          FROM journal
          WHERE journal.id = @TId and
                journal.seq = @EndTrans

      if @JournalRowPointer IS NOT NULL
      BEGIN
         IF @CrossSitePost = 1
         BEGIN
            EXEC @Severity  = dbo.RemoteMethodCallSp
              @Site         = @CorpSite
            , @IdoName      = NULL
            , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
            , @Infobar      = @Infobar OUTPUT
            , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
            , @Parm2Value   = @ParmsSite         -- Copy to site
            , @Parm3Value   = 'journal'          -- Copy to table
            , @Parm4Value   = @JournalRowPointer -- Copy to row pointer
            , @Parm5Value   = @Infobar

            IF @Severity <> 0
               GOTO EOF
         END -- cross-site
         ELSE
         BEGIN
            EXEC @Severity = dbo.CopyNotesSp
             'arpmt'
            , @ArpmtRowPointer
            , 'journal'
            , @JournalRowPointer

            if @Severity <> 0
               GOTO EOF
         END
      END

      IF @JournalDeferredVar=1
        UPDATE tmp_mass_journal
        SET NoteExistsFlag = 1
        FROM tmp_mass_journal as journal
        WHERE journal.id = @TId and
              journal.seq = @EndTrans
         and journal.ProcessId = @BufferJournal
   END -- copy notes

   SET @SiteAmountPosted = @SiteAmountPosted - @DomesticAmtApplied
   SET @ForSiteAmountPosted = @ForSiteAmountPosted - @ForeignAmtApplied

   if @ArpmtdInvNumTrim = '0' AND
      @ReApplication = 0 AND
      @UpdatePrepaidAmt = 1 AND
      @ArpmtdCoNum IS NOT NULL AND
      @ArpmtdCoNum <> ' '
   BEGIN -- Update symix.co.prepaid-amt
      IF OBJECT_ID('dbo.SSSFSDepositSumSp') IS NOT NULL
      AND @ArpmtdFsSroDeposit = 1
      BEGIN
         DECLARE @EXTSSSFSP_Spname2 Sysname
         SET @EXTSSSFSP_Spname2 = 'dbo.SSSFSDepositSumSp'
         EXEC @Severity = @EXTSSSFSP_Spname2
                          @ArpmtdCoNum
                        , @CustomerCustNum
                        , @Infobar OUTPUT
         IF @Severity <> 0
            GOTO EOF
      END
      ELSE
      BEGIN
         SET @CoRowPointer = NULL
         SELECT
          @CoRowPointer = co.RowPointer
         FROM co
         where co.co_num = @ArpmtdCoNum

         if @CoRowPointer IS NOT NULL
         BEGIN
            UPDATE co
               SET prepaid_amt = prepaid_amt + @ForeignAmtApplied
            WHERE co.RowPointer = @CoRowPointer

            SET @Severity = @@ERROR
            IF @Severity <> 0
               GOTO EOF
         END
      END
   END -- Update symix.co.prepaid-amt

   if @ReApplyType IS NULL and @ArpmtType <> 'A' AND @ArpmtOffset = 0
   BEGIN
      if EXISTS (SELECT 1
      FROM artran
      where artran.cust_num = @CustomerCustNum
         and artran.inv_num = @ArpmtdInvNum
         and artran.inv_seq = @ArpmtCheckNum
         and artran.check_seq = 0)
      BEGIN
         SET @Infobar = NULL
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=Exist3'
         , '@artran'
         , '@artran.cust_num'
         , @CustomerCustNum
         , '@artran.inv_num'
         , @ArpmtdInvNum
         , '@artran.inv_seq'
         , @ArpmtCheckNum

         GOTO EOF
      END
   END

   IF (dbo.IsAddonAvailable('SyteLineFSP') = 1 OR dbo.IsAddonAvailable('SyteLineFSPM') = 1 
      OR dbo.IsAddonAvailable('SyteLineFSP_MS') = 1 OR dbo.IsAddonAvailable('SyteLineFSPM_MS') = 1)
      AND @ArpmtdFsSroDeposit = 1
   BEGIN
      DECLARE @EXTSSSFS_Spname Sysname
      SET @EXTSSSFS_Spname = 'dbo.EXTSSSFSARPaymentDistPostingSp'
      EXEC @Severity = @EXTSSSFS_Spname
                       @ReApplyType
                     , @TIssueDate
                     , @ArpmtCheckNum
                     , @CustomerCustNum
                     , @ArpmtdCoNum
                     , @ForeignAmtApplied
                     , @DepositDebitAcct
                     , @DepositDebitUnit1
                     , @DepositDebitUnit2
                     , @DepositDebitUnit3
                     , @DepositDebitUnit4
                     , @ChartAcct
                     , @TUnit1
                     , @TUnit2
                     , @TUnit3
                     , @TUnit4
                     , @ArpmtRecptDate
                     , @CrossSitePost
                     , @ArpmtBankCode
                     , @Infobar OUTPUT
      IF @Severity <> 0
         GOTO EOF
   END
   ELSE
   BEGIN

   if @ReApplyType = 'C'
   BEGIN
      if @TIssueDate IS NOT NULL
      BEGIN
         SET @ArtranIssueDate = @TIssueDate

         SET @XArtranRowPointer = NULL
         SET @XArtranCheckSeq   = NULL

         SELECT TOP 1 -- last
           @XArtranRowPointer = artran.RowPointer
         FROM artran with (UPDLOCK)
         WHERE artran.cust_num = @CustomerCustNum and
               artran.inv_num  = @ArpmtCreditMemoNum and
               artran.type <> 'P' and
               artran.issue_date IS NULL
         ORDER BY cust_num, inv_num DESC

         if @XArtranRowPointer IS NOT NULL
         BEGIN
            UPDATE artran
               SET issue_date = @TIssueDate
            WHERE artran.RowPointer = @XArtranRowPointer

            SET @Severity = @@ERROR
            IF @Severity <> 0
               GOTO EOF
         END
      END
   END -- @ReApplyType = "C"
   ELSE
      SET @TSeq = @ArpmtCheckNum

   SET @TForTaxAdj   = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN - (@ArpmtdForTaxAmt1 + @ArpmtdForTaxAmt2)
                            ELSE + (@ArpmtdForTaxAmt1 + @ArpmtdForTaxAmt2) END
   SELECT
     @ArtranRowPointer = NEWID ()
   , @ArtranPayType = @ArpmtType
   , @ArtranDueDate = @ArpmtDueDate
   , @ArtranInvNum  = ( CASE WHEN @ArpmtCreditMemoNum IS NOT NULL
                             THEN @ArpmtCreditMemoNum
                             ELSE @ArpmtdInvNum
                        END )
   , @ArtranCoNum   = CASE WHEN @TCoNum IS NOT NULL THEN @TCoNum ELSE @ArpmtdCoNum END
   , @ArtranRma     = @TRma
   , @ArtranDoNum   = CASE WHEN (Not(dbo.IsInteger(@ArpmtdInvNumTrim)= 1)or(dbo.IsInteger(@ArpmtdInvNumTrim)=1 and CONVERT(BIGINT, @ArpmtdInvNumTrim) > 0))then
                           @ArpmtdDoNum else
                           NULL
                      END
   , @ArtranCustNum = @CustomerCustNum
   , @ArtranType    = CASE WHEN @ReApplication = 1 then @ReApplyType else 'P' END
   , @ArtranInvDate = @ArpmtRecptDate
   , @ArtranDueDate = @ArpmtRecptDate
   , @ArtranAcct    = @ChartAcct
   , @ArtranAcctUnit1 = @TUnit1
   , @ArtranAcctUnit2 = @TUnit2
   , @ArtranAcctUnit3 = @TUnit3
   , @ArtranAcctUnit4 = @TUnit4
   , @ArtranDescription = @ArpmtDescription
   , @ArtranRef     = @ArpmtRef
   , @ArtranAmount  = @ForeignAmtApplied + @ForeignDiscAmt + @ForeignAllowAmt + @TForTaxAdj
   , @ArtranExchRate = @WireExchangeRate
   , @ArtranCorpCust = @CustaddrCorpCust
   , @ArtranCheckSeq = 0
   , @ArtranInvSeq = @ArpmtCheckNum
   , @ArtranBankCode = CASE WHEN @CrossSitePost = 0 then @ArpmtBankCode else NULL END
   , @ArtranInvSeq   = @TSeq
   -- If open Pmt/CR remains after re-application, add back
   -- disc/allowance of original open Pmt/CR for user's info
   , @ArtranDiscAmt = CASE WHEN @ReApplication = 1 and @ArpmtdInvNumTrim = '0' then
                      (@ForeignDiscAmt + @ForeignAllowAmt + @TForTaxAdj + @ReApplyDisc) else
                      (@ForeignDiscAmt + @ForeignAllowAmt + @TForTaxAdj)
                      END
   , @ArtranShipmentId = @ArpmtdShipmentId
   -- ZLA
   , @ArtranZlaForCurrCode	= @ArpmtdZlaForCurrCode
   , @ArtranZlaForExchRate	= @ArpmtdZlaForExchRate
   , @ArtranZlaForNonArAmt	 = @ArpmtdZlaForNonArAmt
   , @ArtranZlaForAmount   = @ArpmtdZlaForAmtApplied
	-- ZLA
	
   IF @ArpmtOffset = 0
   BEGIN
     if @ArpmtType = 'A' -- Adjustment
      SELECT TOP 1 -- last
        @ArtranCheckSeq   = artran.check_seq + 1
      FROM artran
      WHERE artran.cust_num = @ArpmtCustNum and
            artran.inv_num =  @ArpmtdInvNum and
            artran.inv_seq =  @ArpmtCheckNum
      ORDER BY cust_num, inv_num, inv_seq, check_seq DESC

     if @ReapplyType = 'P'
     begin
      SELECT TOP 1 -- last
         @ArtranCheckSeq   = artran.check_seq + 1
       FROM artran
       WHERE artran.cust_num = @ArpmtCustNum and
            artran.inv_num =  @ArpmtdInvNum and
            artran.inv_seq =  @ArpmtCheckNum
       ORDER BY cust_num, inv_num, inv_seq, check_seq DESC
      SET @ArtranCheckSeq = ISNULL(@ArtranCheckSeq,0)
     end
    END
    ELSE
    BEGIN
       SELECT @ArtranCheckSeq = (MAX(ISNULL(check_seq,0)) + 1)
       FROM artran
       WHERE artran.inv_num = @ArtranInvNum
        AND artran.inv_seq = @ArpmtCheckNum
       SET @ArtranCheckSeq = ISNULL(@ArtranCheckSeq,0)
    END


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
   , co_num
   , do_num
   , disc_amt
   , apply_to_inv_num
   , shipment_id
   , rma
   , zla_for_curr_code
	, zla_for_exch_rate
	, zla_for_non_ar_amt
	, zla_for_amount
   , zla_ar_pay_id
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
   , @ArtranCoNum
   , @ArtranDoNum
   , @ArtranDiscAmt
   , @ArpmtdInvNum
   , @ArtranShipmentId
   , @ArtranRma
   , @ArtranZlaForCurrCode
   , @ArtranZlaForExchRate
   , @ArtranZlaForNonArAmt
   , @ArtranZlaForAmount
   , @ArpmtZlaArPayId
   )

   SET @Severity = @@ERROR
   IF @Severity <> 0
      GOTO EOF

   IF @ArpmtNoteExistsFlag > 0
   BEGIN -- copy notes
      IF @CrossSitePost = 1
      BEGIN
         EXEC @Severity  = dbo.RemoteMethodCallSp
           @Site         = @CorpSite
         , @IdoName      = NULL
         , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
         , @Infobar      = @Infobar OUTPUT
         , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
         , @Parm2Value   = @ParmsSite         -- Copy to site
         , @Parm3Value   = 'artran'           -- Copy to table
         , @Parm4Value   = @ArtranRowPointer  -- Copy to row pointer
         , @Parm5Value   = @Infobar

         IF @Severity <> 0
            GOTO EOF

         EXEC @Severity  = dbo.RemoteMethodCallSp
           @Site         = @CorpSite
         , @IdoName      = NULL
         , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
         , @Infobar      = @Infobar OUTPUT
         , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
         , @Parm2Value   = @ParmsSite         -- Copy to site
         , @Parm3Value   = 'artran_all'       -- Copy to table
         , @Parm4Value   = @ArtranRowPointer  -- Copy to row pointer
         , @Parm5Value   = @Infobar

         IF @Severity <> 0
            GOTO EOF
      END -- cross-site
      ELSE
      BEGIN
         EXEC @Severity = dbo.CopyNotesSp
          'arpmt'
         , @ArpmtRowPointer
         , 'artran'
         , @ArtranRowPointer

         if @Severity <> 0
            GOTO EOF

         EXEC @Severity = dbo.CopyNotesSp
          'arpmt'
         , @ArpmtRowPointer
         , 'artran_all'
         , @ArtranRowPointer

         if @Severity <> 0
            GOTO EOF
      END
   END -- copy notes
   END

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

         SET @Severity = @@ERROR
         IF @Severity <> 0
            GOTO EOF
      END
   END -- Draft


END  -- Open Credit / Invoice

if @CrossSitePost  = 1 and @SiteAmountPosted <> 0.0
BEGIN
	
   -- "TO" Site:
   --  DEBIT Inter-Site Asset OR Cash - Asset
   if @ReApplication = 1 and @ArpmtTransferCash = 1
   BEGIN
      SET @BankHdrRowPointer = NULL

      SELECT
        @BankHdrRowPointer = bank_hdr.RowPointer
      , @BankHdrBankCode   = bank_hdr.bank_code
      , @BankHdrAcct       = bank_hdr.acct
      , @BankHdrAcctUnit1  = bank_hdr.acct_unit1
      , @BankHdrAcctUnit2  = bank_hdr.acct_unit2
      , @BankHdrAcctUnit3  = bank_hdr.acct_unit3
      , @BankHdrAcctUnit4  = bank_hdr.acct_unit4
      FROM bank_hdr WITH (READUNCOMMITTED)
      where bank_hdr.bank_code = @CustomerBankCode

      if @BankHdrRowPointer IS NULL or @BankHdrAcct IS NULL
      BEGIN
         SET @Infobar = NULL
         SET @Infobar2 = NULL

         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=IsCompare'
         , '@parms.site'
         , @LocalSiteName

         EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'E=NoExist1'
         , '@bank_hdr'
         , '@bank_hdr.bank_code'
         , @CustomerBankCode

         SET @Infobar = @Infobar + '  ' + @Infobar2

         GOTO EOF
      END

      SET @ChartRowPointer = NULL

      SELECT
        @ChartRowPointer = chart.RowPointer
      FROM chart WITH (READUNCOMMITTED)
      where chart.acct = @BankHdrAcct

      if @ChartRowPointer IS NULL or @BankHdrAcct IS NULL
      BEGIN
         SET @Infobar = NULL
         SET @Infobar2 = NULL

         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=IsCompare'
         , '@parms.site'
         , @LocalSiteName

         EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'E=NoExistFor2'
         , '@chart'
         , '@bank_hdr'
         , '@bank_hdr.acct'
         , @BankHdrAcct
         , '@bank_hdr.bank_code'
         , @BankHdrBankCode

         SET @Infobar = @Infobar + '  ' + @Infobar2

         GOTO EOF
      END

      SET @TAcct  = @BankHdrAcct
      SET @TUnit1 = @BankHdrAcctUnit1
      SET @TUnit2 = @BankHdrAcctUnit2
      SET @TUnit3 = @BankHdrAcctUnit3
      SET @TUnit4 = @BankHdrAcctUnit4

   END -- Re-app and Transfer Cash
   ELSE
   BEGIN

      SET @ChartRowPointer = NULL

      SELECT
        @ChartRowPointer = chart.RowPointer
      FROM chart WITH (READUNCOMMITTED)
      where chart.acct = @SitenetArAssetAcct

      if @ChartRowPointer IS NULL or @SitenetArAssetAcct IS NULL
      BEGIN
         SET @Infobar = NULL
         SET @Infobar2 = NULL

         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=IsCompare'
         , '@parms.site'
         , @LocalSiteName

         EXEC @Severity = dbo.MsgAppSp @Infobar2 OUTPUT, 'E=NoExistFor1'
         , '@chart'
         , '@sitenet'
         , '@sitenet.ar_asset_acct'
         , @SitenetArAssetAcct

         SET @Infobar = @Infobar + '  ' + @Infobar2

         GOTO EOF
      END

      SET @TAcct  = @SitenetArAssetAcct
      SET @TUnit1 = @SitenetArAssetAcctUnit1
      SET @TUnit2 = @SitenetArAssetAcctUnit2
      SET @TUnit3 = @SitenetArAssetAcctUnit3
      SET @TUnit4 = @SitenetArAssetAcctUnit4
   END

   EXEC @Severity = dbo.ChkAcctSp
     @TAcct
   , @ArpmtRecptDate
   , @Infobar OUTPUT

   IF @Severity <> 0
      GOTO EOF

   EXEC @Severity = dbo.ChkUnitSp
     @TAcct
   , @TUnit1
   , @TUnit2
   , @TUnit3
   , @TUnit4
   , @Infobar OUTPUT

   IF @Severity <> 0
      GOTO EOF

   IF @ArpmtType = 'D'
      SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
   ELSE
      SET @Ref = @ArpmtRef
   SET @RefType = SUBSTRING(@ArpmtRef, 3, 1)

   SET @DomPostAmount = @SiteAmountPosted * -1

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
   , @amount             = @DomPostAmount
   , @bank_code          = @ArpmtBankCode
   , @curr_code          = @CurrparmsCurrCode
   , @check_num          = @ArpmtCheckNum
   , @check_date         = @ArpmtRecptDate
   , @ref                = @Ref
   , @vend_num           = @ArpmtdApplyCustNum
   , @ref_type           = @RefType
   , @voucher            = @ArpmtdInvNum
   , @vouch_seq          = @ArpmtCheckNum
   , @from_site          = @CorpSite
   , @ControlPrefix      = @ControlPrefix
   , @ControlSite        = @ControlSite
   , @ControlYear        = @ControlYear
   , @ControlPeriod      = @ControlPeriod
   , @ControlNumber      = @ControlNumber
   , @last_seq           = @EndTrans     OUTPUT
   , @Infobar            = @Infobar      OUTPUT

   if @Severity <> 0
      GOTO EOF

   IF @ArpmtNoteExistsFlag > 0
   BEGIN -- copy notes
      SET @JournalRowPointer = NULL

      IF @JournalDeferredVar=1
          SELECT
            @JournalRowPointer = journal.RowPointer
          FROM tmp_mass_journal as journal
          WHERE journal.id = @TId and
                journal.seq = @EndTrans
         and journal.ProcessId = @BufferJournal
      ELSE
          SELECT
            @JournalRowPointer = journal.RowPointer
          FROM journal
          WHERE journal.id = @TId and
                journal.seq = @EndTrans

      if @JournalRowPointer IS NOT NULL
      BEGIN
         EXEC @Severity  = dbo.RemoteMethodCallSp
           @Site         = @CorpSite
         , @IdoName      = NULL
         , @MethodName   = 'ARPayPostRemoteCopyNotesSp'
         , @Infobar      = @Infobar OUTPUT
         , @Parm1Value   = @ArpmtRowPointer   -- From table row pointer
         , @Parm2Value   = @ParmsSite         -- Copy to site
         , @Parm3Value   = 'journal'          -- Copy to table
         , @Parm4Value   = @JournalRowPointer -- Copy to row pointer
         , @Parm5Value   = @Infobar

         IF @Severity <> 0
            GOTO EOF
      END

      IF @JournalDeferredVar=1
         UPDATE tmp_mass_journal
         SET NoteExistsFlag = 1
         FROM tmp_mass_journal as journal
         WHERE journal.id = @TId and
               journal.seq = @EndTrans
         and journal.ProcessId = @BufferJournal
   END -- copy notes

END  -- if Cross-Site Post

/* Create new inv_stax record for item based tax systems
   DO NOT create locally if posting across sites         */

if @CrossSitePost <> 1 AND @ReApplication = 0
and not (dbo.IsInteger(@ArpmtdInvNumTrim) = 1 and CONVERT(BIGINT, @ArpmtdInvNumTrim) <= 0)
and (@ArpmtdDomDiscAmt != 0 or @ArpmtdDomAllowAmt != 0)
BEGIN
   /* For Tax System 1 */

   SET @TaxSystemRowPointer = NULL
   SET @TaxSystemNarTaxCode = NULL

   SELECT
      @TaxSystemRowPointer = tax_system.RowPointer
     ,@TaxSystemNarTaxCode = tax_system.nar_tax_code
   , @TaxSystemRecordZero = tax_system.record_zero
   FROM tax_system WITH (READUNCOMMITTED)
   WHERE tax_system.tax_system = 1 and
         tax_system.tax_disc_allow = 1

   IF @TaxSystemRowPointer IS NOT NULL
   and (@TaxSystemRecordZero = 1 or @ArpmtdDomTaxAmt1 != 0)
   BEGIN
      /* Initialise taxcode variables */
      SET @TaxCodeArAcct = NULL
      SET @TaxCodeArAcctUnit1 = NULL
      SET @TaxCodeArAcctUnit2 = NULL
      SET @TaxCodeArAcctUnit3 = NULL
      SET @TaxCodeArAcctUnit4 = NULL

      SELECT
          @TaxCodeArAcct      = taxcode.ar_acct
         ,@TaxCodeArAcctUnit1 = taxcode.ar_acct_unit1
         ,@TaxCodeArAcctUnit2 = taxcode.ar_acct_unit2
         ,@TaxCodeArAcctUnit3 = taxcode.ar_acct_unit3
         ,@TaxCodeArAcctUnit4 = taxcode.ar_acct_unit4
         ,@TaxCodeTaxRate     = taxcode.tax_rate
         ,@TaxCodeTaxJur      = taxcode.tax_jur
      FROM taxcode WITH (READUNCOMMITTED)
      WHERE taxcode.tax_system = 1 and
            taxcode.tax_code_type = 'R' and
            taxcode.tax_code = @TaxSystemNarTaxCode

      SET @TISInvNum = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN '0'
                            ELSE @ArpmtdInvNum
                       END

      SET @InvStaxRowPointer = NULL

      SELECT TOP 1 /* last sequence no.*/
         @InvStaxRowPointer = inv_stax.RowPointer
        ,@InvStaxSeq        = inv_stax.seq
      FROM inv_stax
      WHERE inv_stax.inv_num = @TISInvNum and
            inv_stax.inv_seq = 0
      ORDER BY inv_stax.seq DESC

      IF @InvStaxRowPointer IS NOT NULL
          SET @TISStaxSeq = @InvStaxSeq
      ELSE
      BEGIN
          SET @InvStaxSeq = 1
          SET @TISStaxSeq = 0
      END

      DECLARE CrsLoop1 CURSOR LOCAL STATIC FOR
      SELECT
           inv_stax.tax_code
         , inv_stax.stax_acct
         , inv_stax.stax_acct_unit1
         , inv_stax.stax_acct_unit2
         , inv_stax.stax_acct_unit3
         , inv_stax.stax_acct_unit4
         , inv_stax.cust_seq
         , inv_stax.tax_rate
         , inv_stax.tax_jur
         , inv_stax.tax_code_e
         , inv_stax.tax_basis
         , inv_stax.sales_tax
      FROM inv_stax
      WHERE inv_stax.inv_num = @ArpmtdInvNum AND
            inv_stax.inv_seq = 0 AND
            inv_stax.seq = @InvStaxSeq AND
            inv_stax.tax_system = 1
      OPEN CrsLoop1
      WHILE @Severity = 0
      BEGIN
         FETCH CrsLoop1 INTO
              @TISTaxCode
            , @TISStaxAcct
            , @TISStaxAcctUnit1
            , @TISStaxAcctUnit2
            , @TISStaxAcctUnit3
            , @TISStaxAcctUnit4
            , @TISCustSeq
            , @TISTaxRate
            , @TISTaxJur
            , @TISTaxCodeE
            , @TISTaxBasis
            , @InvStaxSalesTax

         IF @@Fetch_status = -1
            BREAK

         SET @TISStaxSeq       = @TISStaxSeq + 1
         SET @TISStaxAcct      = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcct
                                      ELSE @TISStaxAcct END
         SET @TISStaxAcctUnit1 = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcctUnit1
                                      ELSE @TISStaxAcctUnit1 END
         SET @TISStaxAcctUnit2 = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcctUnit2
                                      ELSE @TISStaxAcctUnit2 END
         SET @TISStaxAcctUnit3 = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcctUnit3
                                      ELSE @TISStaxAcctUnit3 END
         SET @TISStaxAcctUnit4 = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcctUnit4
                                      ELSE @TISStaxAcctUnit4 END

         SET @TISSalesTax  = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @ArpmtdDomTaxAmt1
                                  ELSE - (@ArpmtdDomTaxAmt1) END
         SET @TForTaxAdj   = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @ArpmtdForTaxAmt1
                                  ELSE - (@ArpmtdForTaxAmt1) END
         SET @TISTaxBasis = -(@ArpmtdDomDiscAmt + @ArpmtdDomAllowAmt)

         INSERT INTO inv_stax (
              inv_stax.inv_num
            , inv_stax.inv_seq
            , inv_stax.seq
            , inv_stax.inv_date
            , inv_stax.tax_code
            , inv_stax.stax_acct
            , inv_stax.stax_acct_unit1
            , inv_stax.stax_acct_unit2
            , inv_stax.stax_acct_unit3
            , inv_stax.stax_acct_unit4
            , inv_stax.sales_tax
            , inv_stax.cust_num
            , inv_stax.cust_seq
            , inv_stax.tax_basis
            , inv_stax.tax_system
            , inv_stax.tax_rate
            , inv_stax.tax_jur
            , inv_stax.tax_code_e
         ) VALUES (
              @TISInvNum
            , 0
            , @TISStaxSeq
            , @ArpmtRecptDate
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxSystemNarTaxCode
                   ELSE @TISTaxCode END
            , @TISStaxAcct
            , @TISStaxAcctUnit1
            , @TISStaxAcctUnit2
            , @TISStaxAcctUnit3
            , @TISStaxAcctUnit4
            , @TISSalesTax
            , @ArpmtCustNum
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN 0
                   ELSE @TISCustSeq END
            , @TISTaxBasis
            , 1
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeTaxRate
                   ELSE @TISTaxRate END
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeTaxJur
                   ELSE @TISTaxJur END
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN ''
                   ELSE @TISTaxCodeE END )

         IF @ArpmtType = 'D'
           SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
         ELSE
           SET @Ref = @ArpmtRef

         /* Create Journal Entries - debit Accounts Receivable */
	     SELECT
	      @ControlNumber = KeyID + 1
	     FROM NextKeys
	     WHERE
	      TableColumnName = 'journal.control_number' and
		  SubKey			= @SubKey
		
	     IF @ControlNumber IS NULL SET @ControlNumber = 1
		
         EXEC @Severity = dbo.ZPV_JourpostSp
              @id                 = 'AR Dist'         
            , @trans_date = @ArpmtRecptDate
            , @acct = @TaxAdjAcct
            , @acct_unit1 = @TaxAdjAcctUnit1
            , @acct_unit2 = @TaxAdjAcctUnit2
            , @acct_unit3 = @TaxAdjAcctUnit3
            , @acct_unit4 = @TaxAdjAcctUnit4
            , @amount = @TISSalesTax
            , @ref = @Ref
            , @voucher = @ArpmtdInvNum
            , @check_num = @ArpmtCheckNum
            , @check_date = @ArpmtRecptDate
            , @from_site = @ParmsSite
            , @ref_type = 'P'
            , @vouch_seq = @ArpmtCheckNum
            , @bank_code = @ArpmtBankCode
            , @curr_code = @CustaddrCurrCode
            , @for_amount = @TForTaxAdj
            , @exch_rate = @ArpmtdExchRate
            , @ControlPrefix = @ControlPrefix
            , @ControlSite = @ControlSite
            , @ControlYear = @ControlYear
            , @ControlPeriod = @ControlPeriod
            , @ControlNumber = @ControlNumber
            , @Infobar = @Infobar OUTPUT

         IF @Severity <> 0
            GOTO EOF

         SET @TISSalesTax = -@TISSalesTax
         SET @TForTaxAdj = -@TForTaxAdj

         /* Create Journal Entries - credit Sales Tax Account */
                  
	     SELECT
	      @ControlNumber = KeyID + 1
	     FROM NextKeys
	     WHERE
	      TableColumnName = 'journal.control_number' and
		  SubKey			= @SubKey
		
	     IF @ControlNumber IS NULL SET @ControlNumber = 1
		
         EXEC @Severity = dbo.ZPV_JourpostSp
              @id                 = 'AR Dist'         
            , @trans_date = @ArpmtRecptDate
            , @acct = @TISStaxAcct
            , @acct_unit1 = @TISStaxAcctUnit1
            , @acct_unit2 = @TISStaxAcctUnit2
            , @acct_unit3 = @TISStaxAcctUnit3
            , @acct_unit4 = @TISStaxAcctUnit4
            , @amount = @TISSalesTax
            , @ref = @Ref
            , @voucher = @ArpmtdInvNum
            , @check_num = @ArpmtCheckNum
            , @check_date = @ArpmtRecptDate
            , @from_site = @ParmsSite
            , @ref_type = 'P'
            , @vouch_seq = @ArpmtCheckNum
            , @bank_code = @ArpmtBankCode
            , @curr_code = @CustaddrCurrCode
            , @for_amount = @TForTaxAdj
            , @exch_rate = @ArpmtdExchRate
            , @ControlPrefix = @ControlPrefix
            , @ControlSite = @ControlSite
            , @ControlYear = @ControlYear
            , @ControlPeriod = @ControlPeriod
            , @ControlNumber = @ControlNumber
            , @Infobar = @Infobar OUTPUT

         IF @Severity <> 0
            GOTO EOF

      END /* End of CrsLoop1 */
      CLOSE      CrsLoop1
      DEALLOCATE CrsLoop1

   END /* IF @TaxSystemRowPointer IS NOT NULL */

   /* For Tax System 2 */

   SET @TaxSystemRowPointer = NULL
   SET @TaxSystemNarTaxCode = NULL

   SELECT
      @TaxSystemRowPointer = tax_system.RowPointer
     ,@TaxSystemNarTaxCode = tax_system.nar_tax_code
   , @TaxSystemRecordZero = tax_system.record_zero
   FROM tax_system WITH (READUNCOMMITTED)
   WHERE tax_system.tax_system = 2 and
         tax_system.tax_disc_allow = 1

   IF @TaxSystemRowPointer IS NOT NULL
   and (@TaxSystemRecordZero = 1 or @ArpmtdDomTaxAmt2 != 0)
   BEGIN

      /* Initialise taxcode variables */
      SET @TaxCodeArAcct = NULL
      SET @TaxCodeArAcctUnit1 = NULL
      SET @TaxCodeArAcctUnit2 = NULL
      SET @TaxCodeArAcctUnit3 = NULL
      SET @TaxCodeArAcctUnit4 = NULL

      SELECT
          @TaxCodeArAcct      = taxcode.ar_acct
         ,@TaxCodeArAcctUnit1 = taxcode.ar_acct_unit1
         ,@TaxCodeArAcctUnit2 = taxcode.ar_acct_unit2
         ,@TaxCodeArAcctUnit3 = taxcode.ar_acct_unit3
         ,@TaxCodeArAcctUnit4 = taxcode.ar_acct_unit4
         ,@TaxCodeTaxRate     = taxcode.tax_rate
         ,@TaxCodeTaxJur      = taxcode.tax_jur
      FROM taxcode WITH (READUNCOMMITTED)
      WHERE taxcode.tax_system = 2 and
            taxcode.tax_code_type = 'R' and
            taxcode.tax_code = @TaxSystemNarTaxCode

      SET @TISInvNum = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN '0'
                            ELSE @ArpmtdInvNum
                       END

      SET @InvStaxRowPointer = NULL

      SELECT TOP 1 /* last sequence no.*/
         @InvStaxRowPointer = inv_stax.RowPointer
        ,@InvStaxSeq        = inv_stax.seq
      FROM inv_stax
      WHERE inv_stax.inv_num = @TISInvNum and
            inv_stax.inv_seq = 0
      ORDER BY inv_stax.seq DESC

      IF @InvStaxRowPointer IS NOT NULL
          SET @TISStaxSeq = @InvStaxSeq
      ELSE
      BEGIN
          SET @InvStaxSeq = 1
          SET @TISStaxSeq = 0
      END

      DECLARE CrsLoop2 CURSOR LOCAL STATIC FOR
      SELECT
           inv_stax.tax_code
         , inv_stax.stax_acct
         , inv_stax.stax_acct_unit1
         , inv_stax.stax_acct_unit2
         , inv_stax.stax_acct_unit3
         , inv_stax.stax_acct_unit4
         , inv_stax.cust_seq
         , inv_stax.tax_rate
         , inv_stax.tax_jur
         , inv_stax.tax_code_e
         , inv_stax.tax_basis
         , inv_stax.sales_tax
      FROM inv_stax
      WHERE inv_stax.inv_num = @ArpmtdInvNum AND
            inv_stax.inv_seq = 0 AND
            inv_stax.seq = @InvStaxSeq AND
            inv_stax.tax_system = 2
      OPEN CrsLoop2
      WHILE @Severity = 0
      BEGIN
         FETCH CrsLoop2 INTO
              @TISTaxCode
            , @TISStaxAcct
            , @TISStaxAcctUnit1
            , @TISStaxAcctUnit2
            , @TISStaxAcctUnit3
            , @TISStaxAcctUnit4
            , @TISCustSeq
            , @TISTaxRate
            , @TISTaxJur
            , @TISTaxCodeE
            , @TISTaxBasis
            , @InvStaxSalesTax

         IF @@Fetch_status = -1
            BREAK

         SET @TISStaxSeq       = @TISStaxSeq + 1
         SET @TISStaxAcct      = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcct
                                      ELSE @TISStaxAcct END
         SET @TISStaxAcctUnit1 = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcctUnit1
                                      ELSE @TISStaxAcctUnit1 END
         SET @TISStaxAcctUnit2 = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcctUnit2
                                      ELSE @TISStaxAcctUnit2 END
         SET @TISStaxAcctUnit3 = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcctUnit3
                                      ELSE @TISStaxAcctUnit3 END
         SET @TISStaxAcctUnit4 = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeArAcctUnit4
                                      ELSE @TISStaxAcctUnit4 END

         SET @TISSalesTax  = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @ArpmtdDomTaxAmt2
                                  ELSE - (@ArpmtdDomTaxAmt2) END
         SET @TForTaxAdj   = CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @ArpmtdForTaxAmt2
                                  ELSE - (@ArpmtdForTaxAmt2) END
         SET @TISTaxBasis = -(@ArpmtdDomDiscAmt + @ArpmtdDomAllowAmt)

         INSERT INTO inv_stax (
              inv_stax.inv_num
            , inv_stax.inv_seq
            , inv_stax.seq
            , inv_stax.inv_date
            , inv_stax.tax_code
            , inv_stax.stax_acct
            , inv_stax.stax_acct_unit1
            , inv_stax.stax_acct_unit2
            , inv_stax.stax_acct_unit3
            , inv_stax.stax_acct_unit4
            , inv_stax.sales_tax
            , inv_stax.cust_num
            , inv_stax.cust_seq
            , inv_stax.tax_basis
            , inv_stax.tax_system
            , inv_stax.tax_rate
            , inv_stax.tax_jur
            , inv_stax.tax_code_e
         ) VALUES (
              @TISInvNum
            , 0
            , @TISStaxSeq
            , @ArpmtRecptDate
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxSystemNarTaxCode
                   ELSE @TISTaxCode END
            , @TISStaxAcct
            , @TISStaxAcctUnit1
            , @TISStaxAcctUnit2
            , @TISStaxAcctUnit3
            , @TISStaxAcctUnit4
            , @TISSalesTax
            , @ArpmtCustNum
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN 0
                   ELSE @TISCustSeq END
            , @TISTaxBasis
            , 2
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeTaxRate
                   ELSE @TISTaxRate END
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN @TaxCodeTaxJur
                   ELSE @TISTaxJur END
            , CASE WHEN @ArpmtdInvNumTrim = '-2' THEN ''
                   ELSE @TISTaxCodeE END )

         IF @ArpmtType = 'D'
            SET @Ref = CAST(@ArpmtRef as NVARCHAR(20)) + '/' + @ArpmtCustNum
         ELSE
            SET @Ref = @ArpmtRef

         /* Create Journal Entries - debit Accounts Receivable */
	     SELECT
	      @ControlNumber = KeyID + 1
	     FROM NextKeys
	     WHERE
	      TableColumnName = 'journal.control_number' and
		  SubKey			= @SubKey
		
	     IF @ControlNumber IS NULL SET @ControlNumber = 1
		
         EXEC @Severity = dbo.ZPV_JourpostSp
              @id                 = 'AR Dist'         
            , @trans_date = @ArpmtRecptDate
            , @acct = @TaxAdjAcct
            , @acct_unit1 = @TaxAdjAcctUnit1
            , @acct_unit2 = @TaxAdjAcctUnit2
            , @acct_unit3 = @TaxAdjAcctUnit3
            , @acct_unit4 = @TaxAdjAcctUnit4
            , @amount = @TISSalesTax
            , @ref = @Ref
            , @voucher = @ArpmtdInvNum
            , @check_num = @ArpmtCheckNum
            , @check_date = @ArpmtRecptDate
            , @from_site = @ParmsSite
            , @ref_type = 'P'
            , @vouch_seq = @ArpmtCheckNum
            , @bank_code = @ArpmtBankCode
            , @curr_code = @CustaddrCurrCode
            , @for_amount = @TForTaxAdj
            , @exch_rate = @ArpmtdExchRate
            , @ControlPrefix = @ControlPrefix
            , @ControlSite = @ControlSite
            , @ControlYear = @ControlYear
            , @ControlPeriod = @ControlPeriod
            , @ControlNumber = @ControlNumber
            , @Infobar = @Infobar OUTPUT

         IF @Severity <> 0
            GOTO EOF

         SET @TISSalesTax = -@TISSalesTax
         SET @TForTaxAdj = -@TForTaxAdj

         /* Create Journal Entries - credit Sales Tax Account */
	     SELECT
	      @ControlNumber = KeyID + 1
	     FROM NextKeys
	     WHERE
	      TableColumnName = 'journal.control_number' and
		  SubKey			= @SubKey
		
	     IF @ControlNumber IS NULL SET @ControlNumber = 1
		
         EXEC @Severity = dbo.ZPV_JourpostSp
              @id                 = 'AR Dist'         
            , @trans_date = @ArpmtRecptDate
            , @acct = @TISStaxAcct
            , @acct_unit1 = @TISStaxAcctUnit1
            , @acct_unit2 = @TISStaxAcctUnit2
            , @acct_unit3 = @TISStaxAcctUnit3
            , @acct_unit4 = @TISStaxAcctUnit4
            , @amount = @TISSalesTax
            , @ref = @Ref
            , @voucher = @ArpmtdInvNum
            , @check_num = @ArpmtCheckNum
            , @check_date = @ArpmtRecptDate
            , @from_site = @ParmsSite
            , @ref_type = 'P'
            , @vouch_seq = @ArpmtCheckNum
            , @bank_code = @ArpmtBankCode
            , @curr_code = @CustaddrCurrCode
            , @for_amount = @TForTaxAdj
            , @exch_rate = @ArpmtdExchRate
            , @ControlPrefix = @ControlPrefix
            , @ControlSite = @ControlSite
            , @ControlYear = @ControlYear
            , @ControlPeriod = @ControlPeriod
            , @ControlNumber = @ControlNumber
            , @Infobar = @Infobar OUTPUT

         IF @Severity <> 0
            GOTO EOF
      END /* End of CrsLoop2 */
      CLOSE      CrsLoop2
      DEALLOCATE CrsLoop2

   END /* IF @TaxSystemRowPointer IS NOT NULL */
END -- IF @CrossSitePost <> 1

-- Unlock Site's Journal
if @CrossSitePost = 1
BEGIN
   -- LOCK JOURNAL
   EXEC @Severity = dbo.JourLockSp
        @Id          = @TId
      , @LockUserid  = @TUserId
      , @LockJournal = 0         -- Unlock the Journal
      , @Infobar     = @Infobar  OUTPUT

   IF @Severity <> 0
      GOTO EOF
END

EOF:
IF @Severity <> 0
   EXEC dbo.RemoteInfobarSaveSp @Infobar

RETURN @Severity

GO

